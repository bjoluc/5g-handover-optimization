from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from simulator.environment.core.base_station import BaseStation
    from simulator.environment.core.user_equipment import UserEquipment


class Connection:
    def __init__(
        self, bs: BaseStation, ue: UserEquipment, snr: float, maximal_datarate: float
    ):
        self.bs = bs
        self.ue = ue
        self.snr = snr
        self.maximal_datarate = maximal_datarate

        self.current_datarate = 0.0

    def __str__(self):
        return f"Connection(bs: {self.bs.id}, ue: {self.ue.id})"
