import numpy as np
from simulator.environment.core.environment import BaseEnvironment
from simulator.environment.core.metrics import (
    connected_ues,
    mean_datarate,
    mean_utility,
)
from simulator.environments import make_environment
from simulator.metrics import mean_connected_ue_power, utility_fairness
from simulator.utils import get_model_name, get_model_path
from stable_baselines3 import PPO
from stable_baselines3.common.callbacks import BaseCallback, EvalCallback
from stable_baselines3.common.monitor import Monitor
from stable_baselines3.ppo import MlpPolicy


class TensorboardEvalLogCallback(BaseCallback):
    """Adds custom evaluation metric plots to Tensorboard"""

    def __init__(self, eval_env: BaseEnvironment, verbose=0):
        super().__init__(verbose)
        self.eval_env = eval_env

    def _on_step(self) -> bool:
        environment: BaseEnvironment = self.eval_env.unwrapped
        monitor = environment.monitor

        for metric in [
            "mean_utility",
            "mean_datarate",
            "connected_ues",
            "mean_connected_ue_power",
            "utility_fairness",
        ]:
            self.logger.record(
                f"eval/{metric}",
                np.nanmean(monitor.get_metric_history(metric)),
            )

        monitor.is_resettable = True
        monitor.reset()
        monitor.is_resettable = False

        return True


def train(
    model_name: str,
    hyperparameters=dict(),
    callbacks=[],
    progress_bar=False,
    tensorboard_dir="logs",
):
    environment = make_environment()

    model = PPO(
        MlpPolicy, environment, tensorboard_log=tensorboard_dir, **hyperparameters
    )
    model.set_random_seed(0)
    model.learn(
        total_timesteps=600000,
        tb_log_name=model_name,
        callback=callbacks,
        progress_bar=progress_bar,
    )

    return model


hyperparameters = {
    1: {
        "n_steps": 16,
        "batch_size": 16,
        "gamma": 0.95,
        "learning_rate": 7.98e-05,
        "clip_range": 0.2,
        "n_epochs": 5,
        "gae_lambda": 0.8,
        "max_grad_norm": 0.7,
        "vf_coef": 0.644,
    },
}


def run():
    model_name = get_model_name()
    evaluation_environment = make_environment()

    # Manual monitor resets to keep metrics across episodes:
    evaluation_environment.monitor.is_resettable = False
    # Add relevant metrics to monitor environment for logging:
    evaluation_environment.monitor.add_metric("mean_utility", mean_utility)
    evaluation_environment.monitor.add_metric("mean_datarate", mean_datarate)
    evaluation_environment.monitor.add_metric("connected_ues", connected_ues)
    evaluation_environment.monitor.add_metric(
        "mean_connected_ue_power", mean_connected_ue_power
    )
    evaluation_environment.monitor.add_metric("utility_fairness", utility_fairness)

    evaluation_callback = EvalCallback(
        Monitor(evaluation_environment),
        eval_freq=10000,
        n_eval_episodes=20,
        deterministic=True,
        render=False,
        verbose=0,
        best_model_save_path=f"models/{model_name}",
        callback_after_eval=TensorboardEvalLogCallback(evaluation_environment),
    )

    model = train(
        model_name,
        callbacks=[evaluation_callback],
        progress_bar=True,
        hyperparameters=hyperparameters[1],
    )
    model.save(get_model_path())
