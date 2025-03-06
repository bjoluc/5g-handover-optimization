from functools import cache
from math import log10

from simulator.environment.core.user_equipment import UserEquipment
from simulator.simulation_models.applications import generic_data_heavy


class AppAwareUserEquipment(UserEquipment):
    def __init__(self, application=generic_data_heavy, **kwargs):
        self._application = application
        super().__init__(**kwargs)

    def get_tx_power_dbm(self, snr: float):
        # Need to make assumptions here – TX power regulation is complex and out of
        # scope. Basing this on the average observed in the Jörke et al. 2025 paper:
        #
        # 0 dBm Tx power at 40 dB SNR; 23 dBm Tx power at 0 dB SNR

        snr_db = 10 * log10(snr)
        if snr_db >= 40:
            return 0.0

        if snr_db <= 0:
            return 23.0

        return (1 - snr_db / 40) * 23

    def get_average_power(self) -> float:
        if not self.is_connected():
            # Deep sleep power is 1 PU (assumes that the UE camps on a cell and paging
            # power is neglectable)
            return 1

        # This assumes the UE is receiving/transmitting data according to its traffic
        # pattern, and the serving cell is the BS with the strongest signal
        return self._application.traffic_pattern.estimate_power(
            self.get_tx_power_dbm(
                max(self.connections.values(), key=lambda c: c.snr).snr
            )
        )

    @property
    def desired_data_rate(self):
        """Highest data rate (in bits/s) that the UE desires."""
        return self._application.desired_data_rate + self.minimal_data_rate

    @cache
    def get_utility(self):
        if not self.is_connected():
            return -1

        data_rate = self.get_data_rate() - self.minimal_data_rate
        return self._application.get_qoe_by_data_rate(data_rate)
