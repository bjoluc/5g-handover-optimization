from pathlib import Path

import optuna
from optuna.pruners import MedianPruner
from optuna.samplers import TPESampler
from simulator.environments import make_environment
from simulator.scripts.train import train
from stable_baselines3.common.callbacks import (
    EvalCallback,
    StopTrainingOnNoModelImprovement,
)
from stable_baselines3.common.monitor import Monitor
from torch import nn as nn

STUDY_NAME = "study-05"
STUDY_PATH = Path("optuna") / STUDY_NAME
STUDY_PATH.mkdir(exist_ok=True, parents=True)
DATABASE_URL = "postgresql://postgres:postgres@localhost/optuna"


def sample_ppo_params(trial: optuna.Trial):
    # Based on
    # https://github.com/DLR-RM/rl-baselines3-zoo/blob/506bb7aa40e9d90e997580a369f2e9bf64abe594/rl_zoo3/hyperparams_opt.py#L11

    batch_size = trial.suggest_categorical("batch_size", [8, 16, 32, 64, 128, 256, 512])
    n_steps = trial.suggest_categorical(
        "n_steps", [8, 16, 32, 64, 128, 256, 512, 1024, 2048]
    )

    if batch_size > n_steps:
        batch_size = n_steps

    return {
        "n_steps": n_steps,
        "batch_size": batch_size,
        "gamma": trial.suggest_categorical(
            "gamma", [0.9, 0.95, 0.98, 0.99, 0.995, 0.999, 0.9999]
        ),
        "learning_rate": trial.suggest_float("learning_rate", 1e-5, 1, log=True),
        "ent_coef": trial.suggest_float("ent_coef", 0.00000001, 0.1, log=True),
        "clip_range": trial.suggest_categorical("clip_range", [0.1, 0.2, 0.3, 0.4]),
        "n_epochs": trial.suggest_categorical("n_epochs", [1, 5, 10, 20]),
        "gae_lambda": trial.suggest_categorical(
            "gae_lambda", [0.8, 0.9, 0.92, 0.95, 0.98, 0.99, 1.0]
        ),
        "max_grad_norm": trial.suggest_categorical(
            "max_grad_norm", [0.3, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2, 5]
        ),
        "vf_coef": trial.suggest_float("vf_coef", 0, 1),
    }


class OptunaEvalCallback(EvalCallback):
    def __init__(self, trial: optuna.Trial, **kwargs):

        super().__init__(**kwargs)
        self.trial = trial
        self.evaluation_index = 0
        self.is_pruned = False

    def _on_step(self) -> bool:
        continue_training = True
        if self.eval_freq > 0 and self.n_calls % self.eval_freq == 0:
            continue_training = super()._on_step()
            self.evaluation_index += 1
            self.trial.report(self.last_mean_reward, self.evaluation_index)

            if self.trial.should_prune():
                self.is_pruned = True
                return False

        return continue_training


def objective(trial: optuna.Trial) -> float:
    hyperparameters = sample_ppo_params(trial)

    path = STUDY_PATH / f"trial_{trial.number}"
    path.mkdir(exist_ok=True)

    evaluation_environment = make_environment()
    evaluation_callback = OptunaEvalCallback(
        trial,
        eval_env=Monitor(evaluation_environment),
        best_model_save_path=path.as_posix(),
        log_path=path.as_posix(),
        n_eval_episodes=10,
        eval_freq=10000,
        deterministic=False,
        verbose=0,
        callback_after_eval=StopTrainingOnNoModelImprovement(
            max_no_improvement_evals=15, min_evals=30, verbose=1
        ),
    )

    with (path / "parameters.txt").open("w") as file:
        file.write(str(hyperparameters))

    try:
        train(
            f"trial-{trial.number}",
            hyperparameters,
            [evaluation_callback],
            tensorboard_dir=(STUDY_PATH / "logs").as_posix(),
        )
    except (AssertionError, ValueError) as e:
        print(e)
        raise optuna.exceptions.TrialPruned()

    if evaluation_callback.is_pruned:
        raise optuna.exceptions.TrialPruned()

    return evaluation_callback.best_mean_reward


def run():
    study = optuna.create_study(
        study_name=STUDY_NAME,
        sampler=TPESampler(n_startup_trials=10, multivariate=True),
        pruner=MedianPruner(n_startup_trials=10, n_warmup_steps=10),
        load_if_exists=True,
        direction="maximize",
        storage=DATABASE_URL,
    )

    try:
        study.optimize(objective, n_trials=256)
    except KeyboardInterrupt:
        pass

    print("Number of finished trials: ", len(study.trials))

    trial = study.best_trial
    print(f"Best trial: {trial.number}")
    print("Value: ", trial.value)

    print("Params: ")
    for key, value in trial.params.items():
        print(f"    {key}: {value}")

    study.trials_dataframe().to_csv(STUDY_PATH / "report.csv")
