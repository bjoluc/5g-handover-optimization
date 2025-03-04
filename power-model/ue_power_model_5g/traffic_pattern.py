from functools import cached_property

from ue_power_model_5g.drx import DrxConfig
from ue_power_model_5g.sleep_ratio.simulation import estimate_sleep_ratio


class TrafficPattern:
    def __init__(
        self,
        iat_uplink: int,
        iat_downlink: int,
        drx_config: DrxConfig,
        bwp_mhz: int = 100,
    ):
        self.iat_uplink = iat_uplink
        self.iat_downlink = iat_downlink
        self.drx_config = drx_config
        self.bwp_mhz = bwp_mhz

    @cached_property
    def _sleep_estimates(self):
        return estimate_sleep_ratio(
            10e4,
            self.drx_config.cycle_time * 2,
            self.drx_config.on_duration * 2,
            self.drx_config.inactivity_timer * 2,
            self.iat_uplink * 2,
            self.iat_downlink * 2,
        )

    @property
    def sleep_ratio(self):
        return self._sleep_estimates[0]

    @property
    def sleep_periods_per_cycle(self):
        return self._sleep_estimates[1]

    def estimate_power(self, tx_power_dbm: float):
        return (
            0.75 * self.bwp_mhz
            + self.sleep_ratio * (-0.75 * self.bwp_mhz - 24.0)
            + 25.0
            + (
                1.47335693522488 * 10 ** (tx_power_dbm / 10)
                - 0.375 * self.bwp_mhz
                + 148.526643064775
            )
            / self.iat_uplink
            + (0.75 * self.bwp_mhz + 25.0) / self.iat_downlink
            + 225 * self.sleep_periods_per_cycle / self.drx_config.cycle_time
        )
