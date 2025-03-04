import time

import numpy as np
from ue_power_model_5g.sleep_ratio.simulation import estimate_sleep_ratio

from scripts.sleep_ratio.constants import CYCLE_DURATION, INACTIVITY_TIMER, ON_DURATION

if __name__ == "__main__":
    IAT = 80 * 2

    ratios = []
    times = []

    for _ in range(10000):
        start_time = time.time()
        ratios.append(
            estimate_sleep_ratio(
                10e3,  # cycles
                CYCLE_DURATION,
                ON_DURATION,
                INACTIVITY_TIMER,
                IAT,  # UL
                IAT,  # DL
            )[0]
        )
        times.append(time.time() - start_time)

    print(f"Std. deviation: {np.std(ratios):.6f}")
    print(f"Avg. computation time: {np.mean(times)*10e3:.2f}")
