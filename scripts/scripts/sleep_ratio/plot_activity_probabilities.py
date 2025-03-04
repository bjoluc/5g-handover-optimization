import matplotlib.pyplot as plt
import numpy as np
from ue_power_model_5g.sleep_ratio.simulation import estimate_activity_probabilities

from scripts.sleep_ratio.constants import CYCLE_DURATION, INACTIVITY_TIMER, ON_DURATION
from scripts.utils import copy_data_as_typst

if __name__ == "__main__":
    slot_activity_probabilities = estimate_activity_probabilities(
        10e5,  # cycles
        CYCLE_DURATION,
        ON_DURATION,
        INACTIVITY_TIMER,
        80 * 2,  # IAT UL
        80 * 2,  # IAT DL
    )

    x_values = np.linspace(0, CYCLE_DURATION / 2, CYCLE_DURATION)

    print(
        "Avg. active duration per cycle", np.sum(slot_activity_probabilities) / 2, "ms"
    )

    plt.figure()
    plt.xlabel("Time in DRX cycle (ms)")
    plt.ylabel("P(UE Active)")
    plt.ylim(0, 1)
    plt.plot(x_values, slot_activity_probabilities)
    plt.grid(True)

    copy_data_as_typst(x_values[::2], slot_activity_probabilities[::2])

    plt.show()
