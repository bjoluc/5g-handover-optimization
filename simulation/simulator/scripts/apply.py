from simulator.environments import make_environment
from simulator.utils import get_model_path
from stable_baselines3 import PPO


def run():
    environment = make_environment(render=True, episode_duration=1000, seed=3)
    model = PPO.load(get_model_path())

    obs, info = environment.reset()
    done = False

    while not done:
        action, _ = model.predict(obs, deterministic=True)
        print(action)

        obs, reward, terminated, truncated, info = environment.step(action)
        done = terminated or truncated
        environment.render()
