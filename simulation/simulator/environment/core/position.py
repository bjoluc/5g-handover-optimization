from __future__ import annotations


class Position:
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

    def distance(self, to: Position) -> float:
        return (((self.x - to.x) ** 2) + ((self.y - to.y) ** 2)) ** 0.5

    def as_tuple(self) -> tuple[float, float]:
        return (self.x, self.y)
