from __future__ import annotations

from typing import TYPE_CHECKING

import numpy as np
from simulator.environment.core.channels import Channel, OkumuraHata
from simulator.environment.core.movement import Position
from simulator.environment.core.schedulers import ResourceFair, Scheduler

if TYPE_CHECKING:
    from simulator.environment.core.connection import Connection
    from simulator.environment.core.user_equipment import UserEquipment


class BaseStation:
    def _create_channel(self) -> Channel:
        """Override this method to alter the BS's channel model"""
        return OkumuraHata(self)

    def __init__(
        self,
        position: tuple[float, float],
        bandwidth=90e6,  # Hz
        freq=3600,  # MHz (n78)
        tx=30,  # dBm
        height=15,  # m
        scheduler=ResourceFair(),
    ):
        self.position = Position(*position)
        self.bandwidth = bandwidth  # in Hz
        self.frequency = freq  # in MHz
        self.tx_power = tx  # in dBm
        self.height = height  # in m
        self._scheduler: Scheduler = scheduler

        self.channel = self._create_channel()

        # Assigned by the environment:
        self.id: int = None

        self.connections: dict[UserEquipment, Connection] = {}

    def __str__(self):
        return f"BS: {self.id}"

    def schedule(self):
        """
        Schedules the station's resources (e.g. phy. res. blocks) to connected UEs,
        updating the data rates in the corresponding Connection objects
        """
        self._scheduler.update_data_rates(self, self.connections.values())

    def get_average_ue_utility(self):
        if len(self.connections) == 0:
            return np.nan

        return np.mean([ue.get_utility() for ue in self.connections])
