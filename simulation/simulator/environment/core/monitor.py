from __future__ import annotations

from typing import TYPE_CHECKING, Any, Callable

if TYPE_CHECKING:
    from simulator.environment.core.environment import BaseEnvironment


class Monitor:
    def __init__(self, environment: BaseEnvironment):
        self.environment = environment
        self.metrics: dict[str, Callable[[BaseEnvironment], Any]] = dict()
        self.history = []
        self.is_resettable = True

    def add_metric(
        self, metric_name: str, metric_function: Callable[[BaseEnvironment], Any]
    ):
        self.metrics[metric_name] = metric_function

    def reset(self):
        if self.is_resettable:
            self.history = []

    def sample(self):
        self.history.append(
            {
                metric_name: metric_function(self.environment)
                for metric_name, metric_function in self.metrics.items()
            }
        )

    @property
    def current_metrics(self) -> dict:
        if len(self.history) == 0:
            return {}

        return self.history[-1]

    def get_metric_history(self, metric_name: str) -> list:
        assert metric_name in self.metrics
        return [record[metric_name] for record in self.history]
