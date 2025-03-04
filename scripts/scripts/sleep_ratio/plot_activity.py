import numpy as np
from ue_power_model_5g.sleep_ratio.simulation import simulate_activity

from scripts.measurements.plot import Plot

if __name__ == "__main__":
    time = 4  # s
    pps = 16
    cycles = time // 0.32 + 1
    activity = simulate_activity(
        cycles, 320 * 2, 20 * 2, 100 * 2, 1000 / pps * 2, 1000 / pps * 2
    )[: time * 2000]
    time = np.arange(0, time, 0.0005)

    plot = Plot(subplot_count=2)
    plot.add_subplot(
        time,
        activity,
        x_label="t [s]",
        y_label="Activity",
        y_min=0,
        y_max=3,
    )

    plot.show()
