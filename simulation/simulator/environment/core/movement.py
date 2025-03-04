from __future__ import annotations

from abc import abstractmethod
from math import sqrt

import numpy as np
from simulator.environment.core.position import Position


class Movement:
    def __init__(
        self,
        map_size: tuple[float, float],
    ):
        self._width, self._height = map_size

        self.position: Position = None

    def _get_random_position(self):
        return Position(
            self._rng.uniform(0, self._width), self._rng.uniform(0, self._height)
        )

    def reset(self, rng: np.random.Generator):
        self._rng = rng

    @abstractmethod
    def move(self, velocity: float):
        """Move the position that is maintained by this Movement object"""
        pass


class StationaryMovement(Movement):
    def __init__(self, map_size, position=(0.0, 0.0)):
        super().__init__(map_size)
        self.position = Position(*position)

    def move(self, velocity):
        pass


class RandomWaypointMovement(Movement):
    def __init__(self, map_size):
        super().__init__(map_size)
        self._next_waypoint: Position = None

    def move(self, velocity):
        """Move the position a step towards the next waypoint"""
        if not self._next_waypoint:
            self._next_waypoint = self._get_random_position()

        if self.position.distance(self._next_waypoint) <= velocity:
            self.position = self._next_waypoint
            self._next_waypoint = None
        else:
            # Move by `velocity` towards next waypoint – avoids using numpy for
            # performance
            waypoint_x, waypoint_y = self._next_waypoint.as_tuple()
            pos_x, pos_y = self.position.as_tuple()

            v = (waypoint_x - pos_x, waypoint_y - pos_y)
            norm_v = sqrt(v[0] ** 2 + v[1] ** 2)

            self.position.x = pos_x + velocity * v[0] / norm_v
            self.position.y = pos_y + velocity * v[1] / norm_v

    def reset(self, rng):
        super().reset(rng)
        self._next_waypoint = None
        self.position = self._get_random_position()
