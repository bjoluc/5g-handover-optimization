import gymnasium
import numpy as np
from gymnasium import spaces
from simulator.environment.core.base_station import BaseStation
from simulator.environment.core.monitor import Monitor
from simulator.environment.core.movement import RandomWaypointMovement
from simulator.environment.core.user_equipment import UserEquipment
from simulator.environment.core.visualizer import Visualizer


class BaseEnvironment(gymnasium.Env):
    metadata = {"render_modes": ["rgb_array", "human"]}
    reward_range = (-1, 1)

    def __init__(
        self,
        stations: list[BaseStation],
        users: list[UserEquipment],
        size=(2e3, 2e3),
        episode_duration=100,
        seed=0,
        render_mode=None,
    ):
        super().__init__()
        self.size = size
        self.episode_duration = episode_duration
        self.seed = seed
        self.render_mode = render_mode  # Expected by gymnasium.Env
        self.time: float = None

        self.stations = stations
        self.ues = users

        for ue_index, ue in enumerate(self.ues):
            ue.id = ue_index + 1
            if ue._movement is None:
                ue._movement = self._make_movement(ue)

        for bs_index, bs in enumerate(self.stations):
            bs.id = bs_index

        self.monitor = Monitor(self)
        self.visualizer = Visualizer(self, render_mode) if render_mode else None

    def _make_movement(self, ue: UserEquipment):
        """Creates a `Movement` to be assigned to a UE"""
        return RandomWaypointMovement(self.size)

    def reset(self, seed=None):
        # Create a new seeded RNG if this is the first time the environment is reset
        if seed is None and self.time is None:
            seed = self.seed + 4  # for compatibility with the original environment
        super().reset(seed=seed)

        for ue in self.ues:
            ue.reset(self.np_random)

        self.time = 0.0
        self.monitor.reset()
        return self._get_observation(), self.monitor.current_metrics

    def _apply_action(self, action: int, ue: UserEquipment) -> None:
        """Connect or disconnect `ue` to/from basestation `action`."""
        if action == 0:
            return

        bs = self.stations[action - 1]
        if ue.is_connected_to(bs):
            ue.disconnect_from(bs)

        elif ue.can_connect_to(bs):
            ue.connect_to(bs)

    def step(self, actions: dict[int, int]):
        assert not self.is_episode_over, "step() called on terminated episode"

        for ue, action in zip(self.ues, actions):
            self._apply_action(action, ue)

        # Move UEs
        for ue in self.ues:
            ue.move()

        # Reschedule BS resources with the changed connections
        for bs in self.stations:
            bs.schedule()

        self.monitor.sample()

        self.time += 1

        if self.is_episode_over and self.visualizer:
            self.visualizer.quit()
            self.visualizer = None

        return (
            self._get_observation(),
            self._get_reward(),
            False,  # `terminated`: Always False because there's only truncation
            self.is_episode_over,  # `truncated``
            self.monitor.current_metrics,  # `info`
        )

    @property
    def is_episode_over(self):
        """true after max. time steps"""
        return self.time >= self.episode_duration

    def render(self) -> None:
        if self.visualizer:
            self.visualizer.render()

    @property
    def action_space(self):
        # Each element denotes one UE's decision
        return spaces.MultiDiscrete([len(self.stations) + 1] * len(self.ues))

    @property
    def observation_space(self):
        # Observation is a vector of concatenated UE observations
        return spaces.Box(low=-1.0, high=1.0, shape=(self.observation_size,))

    @property
    def observation_size(self):
        return len(self.ues) * self.ue_observation_size

    def _get_observation(self) -> np.ndarray:
        return np.concatenate([self._get_ue_observation(ue) for ue in self.ues])

    @property
    def ue_observation_size(self):
        return 2 * len(self.stations) + 1

    def _get_ue_observation(self, ue: UserEquipment):
        # (1) Observation of current connections as a one-hot vector
        connections = np.zeros(len(self.stations), dtype=np.float32)
        connections[[ue.is_connected_to(bs) for bs in self.stations]] = 1

        # (2) Normalized SNR to each BS
        snrs = np.asarray([ue.get_snr(bs) for bs in self.stations], dtype=np.float32)
        normalized_snrs = snrs / np.max(snrs)

        # (3) UE utility
        utility = np.asarray([ue.get_utility()], dtype=np.float32)

        return np.concatenate((connections, normalized_snrs, utility))

    def _get_reward(self):
        return np.mean([ue.get_utility() for ue in self.ues])
