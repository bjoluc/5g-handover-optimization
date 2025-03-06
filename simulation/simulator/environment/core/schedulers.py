from __future__ import annotations

from abc import abstractmethod
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from simulator.environment.core.base_station import BaseStation
    from simulator.environment.core.connection import Connection


class Scheduler:
    @abstractmethod
    def update_data_rates(self, bs: BaseStation, connections: set[Connection]) -> None:
        pass


class ResourceFair(Scheduler):
    def update_data_rates(self, bs, connections):
        for connection in connections:
            connection.current_data_rate = connection.maximal_data_rate / len(
                connections
            )


class RateFair(Scheduler):
    def update_data_rates(self, bs, connections):
        rate = 1 / sum([1 / connection.maximal_data_rate for connection in connections])
        for connection in connections:
            connection.current_data_rate = rate
