from __future__ import annotations

from abc import abstractmethod
from math import log2, log10
from typing import TYPE_CHECKING

import numpy as np
from simulator.environment.core.movement import StationaryMovement
from simulator.environment.core.position import Position
from simulator.environment.core.user_equipment import UserEquipment

if TYPE_CHECKING:
    from simulator.environment.core.base_station import BaseStation


EPSILON = 1e-16


class Channel:
    def __init__(self, bs: BaseStation):
        self.base_station = bs

    @abstractmethod
    def compute_power_loss(self, ue: UserEquipment) -> float:
        """Calculate power loss for transmission between BS and UE."""
        pass

    def compute_snr(self, ue: UserEquipment):
        """Calculate SNR for transmission between BS and UE."""
        loss = self.compute_power_loss(ue)
        power = 10 ** ((self.base_station.tx_power - loss) / 10)
        return power / (ue.noise * self.base_station.bandwidth)

    def compute_maximal_data_rate(self, snr: float):
        """Calculate max. data rate (Bps) for transmission between BS and UE."""
        return self.base_station.bandwidth * log2(1 + snr)

    def isoline(self, map_size: tuple, dthresh: float, num: int = 64):
        """Isoline where UEs receive at least `dthresh` (Bps) max. data."""
        width, height = map_size
        bs_position = self.base_station.position

        dummy = UserEquipment(movement=StationaryMovement(map_size))
        dummy._channel = self

        isoline = []

        for theta in np.linspace(EPSILON, 2 * np.pi, num=num):
            # calculate collision point with map boundary
            x1, y1 = self.boundary_collison(theta, bs_position, width, height)

            # points on line between BS and collision with map
            slope = (y1 - bs_position.y) / (x1 - bs_position.x)
            xs = np.linspace(bs_position.x, x1, num=100)
            ys = slope * (xs - bs_position.x) + bs_position.y

            # compute data rate for each point
            def drate(point):
                dummy.move()  # To reset the UE's SNR cache
                dummy.position.x, dummy.position.y = point
                return self.compute_maximal_data_rate(self.compute_snr(dummy))

            points = zip(xs.tolist(), ys.tolist())
            data_rates = np.asarray(list(map(drate, points)))

            # find largest / smallest x coordinate where drate is exceeded
            (idx,) = np.where(data_rates > dthresh)
            idx = np.max(idx)

            isoline.append((xs[idx], ys[idx]))

        xs, ys = zip(*isoline)
        return xs, ys

    @classmethod
    def boundary_collison(
        cls, theta: float, position: Position, width: float, height: float
    ) -> tuple[float, float]:
        """Find point on map boundaries with angle theta to BS."""
        # collision with right boundary of map rectangle
        rgt_x1, rgt_y1 = width, np.tan(theta) * (width - position.x) + position.y
        # collision with upper boundary of map rectangle
        upr_x1, upr_y1 = (-1) * np.tan(theta - 1 / 2 * np.pi) * (
            height - position.y
        ) + position.x, height
        # collision with left boundary of map rectangle
        lft_x1, lft_y1 = 0.0, np.tan(theta) * (0.0 - position.x) + position.y
        # collision with lower boundary of map rectangle
        lwr_x1, lwr_y1 = (
            np.tan(theta - 1 / 2 * np.pi) * (position.y - 0.0) + position.x,
            0.0,
        )

        if theta == 0.0:
            return width, position.y

        elif theta > 0.0 and theta < 1 / 2 * np.pi:
            x1 = np.min((rgt_x1, upr_x1, width))
            y1 = np.min((rgt_y1, upr_y1, height))
            return x1, y1

        elif theta == 1 / 2 * np.pi:
            return position.x, height

        elif theta > 1 / 2 * np.pi and theta < np.pi:
            x1 = np.max((lft_x1, upr_x1, 0.0))
            y1 = np.min((lft_y1, upr_y1, height))
            return x1, y1

        elif theta == np.pi:
            return 0.0, position.y

        elif theta > np.pi and theta < 3 / 2 * np.pi:
            return np.max((lft_x1, lwr_x1, 0.0)), np.max((lft_y1, lwr_y1, 0.0))

        elif theta == 3 / 2 * np.pi:
            return position.x, 0.0

        else:
            x1 = np.min((rgt_x1, lwr_x1, width))
            y1 = np.max((rgt_y1, lwr_y1, 0.0))
            return x1, y1


class OkumuraHata(Channel):
    def compute_power_loss(self, ue: UserEquipment):
        distance = self.base_station.position.distance(ue.position)
        log10_frequency = log10(self.base_station.frequency)
        log10_height = log10(self.base_station.height)

        ch = 0.8 + (1.1 * log10_frequency - 0.7) * ue.height - 1.56 * log10_frequency

        return (
            (69.55 + 26.16 * log10_frequency - 13.82 * log10_height)
            - ch
            + (44.9 - 6.55 * log10_height)
            * log10(
                distance * 1e-3 + EPSILON  # add epsilon to avoid log(0) if distance = 0
            )
        )
