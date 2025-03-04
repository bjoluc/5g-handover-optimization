import matplotlib.pyplot as plt
import numpy as np
from ue_power_model_5g import DrxConfig, TrafficPattern

from scripts.utils import copy_data_as_typst

if __name__ == "__main__":
    x_values = list(range(0, 201))
    # drx = DrxConfig(160, 8, 100)
    drx = DrxConfig(320, 20, 100)

    def pps_to_iat(pps: int):
        if pps == 0:
            return 10e7
        return 1000 / pps

    powers = np.asarray(
        [
            TrafficPattern(
                pps_to_iat(pps),
                pps_to_iat(pps),
                drx,
                bwp_mhz=90,
            ).estimate_power(0)
            for pps in x_values
        ]
    )

    plt.figure()
    plt.xlabel("PPS")
    plt.ylabel("Avg. Power")
    plt.ylim(0, 300)
    plt.plot(x_values, powers)
    plt.grid(True)

    copy_data_as_typst(x_values, powers, False)

    plt.show()
