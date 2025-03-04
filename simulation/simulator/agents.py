from abc import ABC, abstractmethod
from typing import TypedDict

from numpy.typing import NDArray
from simulator.environment.core.environment import BaseEnvironment
from simulator.utils import get_model_path
from stable_baselines3 import PPO


class BsObservation(TypedDict):
    id: int
    connected: bool
    snr: float


class Agent(ABC):
    def __init__(self, environment: BaseEnvironment):
        self.ue_count = len(environment.ues)
        self.bs_count = len(environment.stations)

    @abstractmethod
    def get_action(self, observation: NDArray): ...


class RlAgent(Agent):
    def __init__(self, environment: BaseEnvironment):
        super().__init__(environment)
        self.model = PPO.load(get_model_path())

    def get_action(self, observation):
        action, _ = self.model.predict(observation, deterministic=True)
        return action


class ConventionalAgent(Agent, ABC):
    def translate_observation(self, observation: NDArray) -> list[list[BsObservation]]:
        ue_observation_size = self.bs_count * 3 + 2

        return [
            [
                {
                    "id": bs,
                    "connected": bool(ue_observation[bs]),
                    "snr": ue_observation[self.bs_count + bs],
                }
                for bs in range(self.bs_count)
            ]
            for ue_observation in observation.reshape(
                (self.ue_count, ue_observation_size)
            )
        ]

    def get_action(self, observation):
        return self._compute_action(self.translate_observation(observation))

    @abstractmethod
    def _compute_action(self, observation: list[list[BsObservation]]): ...


class SnrAgent(ConventionalAgent):
    def _compute_action(self, observation):
        return [
            max(ue_stations, key=lambda bs: bs["snr"])["id"]
            for ue_stations in observation
        ]
