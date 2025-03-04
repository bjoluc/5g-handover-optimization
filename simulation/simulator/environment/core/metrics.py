from __future__ import annotations

from typing import TYPE_CHECKING

import numpy as np

if TYPE_CHECKING:
    from simulator.environment.core.environment import BaseEnvironment


def connections(sim: BaseEnvironment):
    """Calculates the total number of connections."""
    return sum([len(bs.connections) for bs in sim.stations])


def connected_ues(sim: BaseEnvironment):
    """Calculates the number of UEs that are connected."""
    return sum([int(ue.is_connected()) for ue in sim.ues])


def mean_datarate(sim: BaseEnvironment):
    """Calculates the average data rate (in Mbps) of UEs."""
    return np.mean([ue.get_datarate() for ue in sim.ues]) * 1e-6


def mean_utility(sim: BaseEnvironment):
    """Calculates the average utility of UEs."""
    return np.mean([ue.get_utility() for ue in sim.ues])
