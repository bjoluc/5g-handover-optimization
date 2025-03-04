import matplotlib.pyplot as plt
from constants import CYCLE_DURATION, INACTIVITY_TIMER, ON_DURATION
from ue_power_model_5g.sleep_ratio.simulation import estimate_sleep_ratio

from scripts.utils import copy_data_as_typst

if __name__ == "__main__":
    pps_values = list(range(1, 101))
    sleep_ratios = [
        estimate_sleep_ratio(
            10e4,  # cycles
            CYCLE_DURATION,
            ON_DURATION,
            INACTIVITY_TIMER,
            1000 / pps * 2,  # UL
            1000 / pps * 2,  # DL
        )[0]
        for pps in pps_values
    ]

    plt.figure()
    plt.xlabel("pps")
    plt.ylabel("r_sleep")
    plt.ylim(0, 1)
    plt.plot(pps_values, sleep_ratios)
    plt.grid(True)

    copy_data_as_typst(pps_values, sleep_ratios)

    plt.show()
