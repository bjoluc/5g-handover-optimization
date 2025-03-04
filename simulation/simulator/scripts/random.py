from simulator.environments import make_environment
from stable_baselines3.common.env_checker import check_env


def run():
    environment = make_environment(render=True, episode_duration=500)
    check_env(environment, warn=True)

    obs, info = environment.reset()

    done = False
    while not done:
        action = environment.action_space.sample()
        obs, reward, terminated, truncated, info = environment.step(action)
        # print(action)
        # print(obs)
        # print(reward)
        done = terminated or truncated
        environment.render()


if __name__ == "__main__":
    run()
