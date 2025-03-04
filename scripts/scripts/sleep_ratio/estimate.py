import time

from ue_power_model_5g.sleep_ratio.simulation import estimate_sleep_ratio

from scripts.sleep_ratio.constants import CYCLE_DURATION, INACTIVITY_TIMER, ON_DURATION

if __name__ == "__main__":
    CYCLES = 10e5
    IAT = 40 * 2

    start_time = time.time()

    sleep_ratio, sleep_periods_per_cycle = estimate_sleep_ratio(
        CYCLES,
        CYCLE_DURATION,
        ON_DURATION,
        INACTIVITY_TIMER,
        IAT,
        IAT,
    )

    print(time.time() - start_time, "seconds")

    print("Sleep ratio:", sleep_ratio)
    print("Sleep periods/cycle:", sleep_periods_per_cycle)
