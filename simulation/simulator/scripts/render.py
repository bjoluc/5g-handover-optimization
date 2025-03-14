from simulator.environments import SmallEnvironment
from simulator.utils import get_model_path, get_model_name
from stable_baselines3 import PPO
from gymnasium.wrappers import RecordVideo


def run():
    environment = RecordVideo(
        SmallEnvironment(
            episode_duration=500,
            seed=3,
            render_mode="rgb_array",
        ),
        video_folder="videos",
        name_prefix=get_model_name(),
    )
    environment.metadata["render_fps"] = 10

    model = PPO.load(get_model_path())

    obs, info = environment.reset()
    done = False
    while not done:
        action, _ = model.predict(obs, deterministic=True)
        obs, reward, terminated, truncated, info = environment.step(action)
        done = terminated or truncated

    environment.close()
