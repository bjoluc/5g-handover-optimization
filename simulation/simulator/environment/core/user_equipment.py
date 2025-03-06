from __future__ import annotations

from functools import cache
from math import log10
from typing import TYPE_CHECKING

import numpy as np
from simulator.environment.core.connection import Connection
from simulator.environment.core.default_constants import (
    MINIMAL_UE_DATA_RATE,
    THERMAL_NOISE,
)
from simulator.environment.core.movement import Movement
from simulator.environment.core.util import clip

if TYPE_CHECKING:
    from simulator.environment.core.base_station import BaseStation


class UserEquipment:
    def __init__(
        self,
        velocity=15,  # m per step
        minimal_data_rate=MINIMAL_UE_DATA_RATE,  # bits/s
        noise=THERMAL_NOISE,  # mW/Hz
        height=1.5,  # m
        movement: Movement = None,
    ):
        self._velocity = velocity
        self.minimal_data_rate = minimal_data_rate
        self.noise = noise
        self.height = height

        self.connections: dict[BaseStation, Connection] = {}

        # Assigned by the environment:
        self.id: int = None

        # Set by the environment if not passed to the constructor:
        self._movement = movement

    def __str__(self):
        return f"UE: {self.id}"

    def _reset_caches(self):
        self.get_snr.cache_clear()
        self.get_maximal_data_rate.cache_clear()
        self.get_utility.cache_clear()

    def reset(self, rng: np.random.Generator):
        """Invoked by the environment: Resets the state maintained by this UE so it is
        fresh for a new episode"""
        self.disconnect()
        self._movement.reset(rng)
        self._reset_caches()

    @property
    def position(self):
        return self._movement.position

    def move(self):
        """Moves the UE according to its `Movement`"""
        self._movement.move(self._velocity)
        self._reset_caches()

        for bs, connection in list(self.connections.items()):
            if self.can_connect_to(bs):
                connection.snr = self.get_snr(bs)
                connection.maximal_data_rate = self.get_maximal_data_rate(bs)
            else:
                self.disconnect_from(connection.bs)

    @cache
    def get_snr(self, bs: BaseStation):
        return bs.channel.compute_snr(self)

    @cache
    def get_maximal_data_rate(self, bs: BaseStation):
        return bs.channel.compute_maximal_data_rate(self.get_snr(bs))

    def can_connect_to(self, bs: BaseStation):
        return self.get_maximal_data_rate(bs) >= self.minimal_data_rate

    def connect_to(self, bs: BaseStation):
        connection = Connection(
            bs,
            self,
            snr=self.get_snr(bs),
            maximal_data_rate=self.get_maximal_data_rate(bs),
        )

        self.connections[bs] = connection
        bs.connections[self] = connection

    def is_connected(self):
        return len(self.connections) > 0

    def is_connected_to(self, bs: BaseStation):
        return bs in self.connections

    def disconnect_from(self, bs: BaseStation):
        self.connections.pop(bs)
        bs.connections.pop(self)

    def disconnect(self):
        """Disconnects the UE from all BSs"""
        for bs in self.connections:
            bs.connections.pop(self)
        self.connections.clear()

    def get_data_rate(self):
        """Returns the joint data rate of all the UE's connections"""
        return sum(
            [connection.current_data_rate for connection in self.connections.values()]
        )

    @cache
    def get_utility(self):
        """
        Returns the UE's current utility as a float in range [-1, 1]. The utility value
        is cached and recomputed on first access after each UE movement, i.e. this
        method must only be called after the BSs have scheduled their resources. The
        environment's `step()` method does this right after moving the UEs.
        """
        data_rate = (self.get_data_rate() - self.minimal_data_rate) * 1e-6  # Mbps
        if data_rate <= 0.0:
            return -1

        return clip(0.5 * log10(data_rate), -1, 1)
