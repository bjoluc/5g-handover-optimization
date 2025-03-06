import numpy as np
from simulator.agents import RlAgent, SnrAgent
from simulator.environment.core.metrics import (
    connected_ues,
    mean_data_rate,
    mean_utility,
)
from simulator.environments import make_environment
from simulator.metrics import mean_connected_ue_power, utility_fairness
from simulator.utils import get_model_name

RENDER = False


def run():
    environment = make_environment(
        render=RENDER,
        episode_duration=100000,
        seed=0,
    )
    environment.monitor.add_metric("mean_utility", mean_utility)
    environment.monitor.add_metric("mean_data_rate", mean_data_rate)
    environment.monitor.add_metric("connected_ues", connected_ues)
    environment.monitor.add_metric("mean_connected_ue_power", mean_connected_ue_power)
    environment.monitor.add_metric("utility_fairness", utility_fairness)

    agent = SnrAgent(environment) if get_model_name() == "snr" else RlAgent(environment)

    obs, info = environment.reset()
    done = False

    while not done:
        action = agent.get_action(obs)
        obs, reward, terminated, truncated, info = environment.step(action)
        done = terminated or truncated
        if RENDER:
            environment.render()

    history = environment.monitor.get_metric_history("mean_connected_ue_power")

    for label, id in {
        "Avg. UE Utility": "mean_utility",
        "Avg. UE Data Rate (Mbps)": "mean_data_rate",
        "Avg. Number of Connected UEs": "connected_ues",
        "Avg. UE Utility Fairness": "utility_fairness",
        "Avg. Connected UE Power (PU)": "mean_connected_ue_power",
    }.items():
        history = environment.monitor.get_metric_history(id)
        mean = np.nanmean(history)
        std = np.nanstd(history)
        print(f"{label}: {mean:.4f} ({std:.4f})")


def store_kde_pdf_json(values):
    import json

    import matplotlib.pyplot as plt
    import seaborn

    _, ax = plt.subplots()
    seaborn.kdeplot(values, ax=ax)
    line = ax.get_lines()[0]
    kde_pdf = list(zip(line.get_xdata(), line.get_ydata()))

    with open("kde_pdf.json", "w") as f:
        json.dump(kde_pdf, f)
