import numpy as np
from gymnasium import spaces
from numpy.typing import NDArray
from simulator.environment.core.base_station import BaseStation
from simulator.environment.core.environment import BaseEnvironment
from simulator.environment.core.user_equipment import UserEquipment
from simulator.simulation_models.ues import AppAwareUserEquipment
from simulator.utils import compute_jains_fairness_index


def make_environment(render=False, episode_duration=100, seed=0):
    environment = SmallEnvironment(
        episode_duration=episode_duration,
        seed=seed,
        render_mode="human" if render else None,
    )

    if render:
        environment.metadata["render_fps"] = 24
    return environment


class HandoverEnvironment(BaseEnvironment):
    handover_penalty = 1.0  # One-off UE utility loss for handover actions
    fairness_weight = 0.5  # Amount of fairness rating in the reward

    def __init__(
        self, stations: list[BaseStation], users: list[UserEquipment], **kwargs
    ):
        super().__init__(stations, users, **kwargs)

    def step(self, actions):
        self.penalties_in_current_step = 0
        return super().step(actions)

    @property
    def action_space(self):
        return spaces.MultiDiscrete([len(self.stations)] * len(self.ues))

    # Override _apply_action to establish only one connection per UE
    def _apply_action(self, action: int, ue: UserEquipment):
        """Connects `ue` to basestation `action` if it is not already connected."""

        bs = self.stations[action]
        if ue.is_connected_to(bs):
            return

        if ue.can_connect_to(bs):
            ue.disconnect()
            ue.connect_to(bs)

        # Penalize for handovers and infeasible actions
        self.penalties_in_current_step += 1

    def _get_reward(self):
        # Penalize for unconnected UEs in reach of a BS
        if any(
            [
                not ue.is_connected()
                and any([ue.can_connect_to(bs) for bs in self.stations])
                for ue in self.ues
            ]
        ):
            return -1

        utilities = np.asarray([ue.get_utility() for ue in self.ues])

        # Jain's fairness index (normalized to [-1,1]) of [0,2]-normalized UE utilities
        fairness = compute_jains_fairness_index(utilities + 1) * 2 - 1

        reward = (1 - self.fairness_weight) * np.mean(
            utilities
        ) + self.fairness_weight * fairness

        penalized_reward = (
            reward
            - self.handover_penalty * self.penalties_in_current_step / len(self.ues)
        )
        return max(-1, penalized_reward)

    def reset(self, seed=None):
        self.previous_snrs: dict[UserEquipment, NDArray] = {}
        return super().reset(seed)

    @property
    def ue_observation_size(self):
        return 3 * len(self.stations) + 2

    def _get_ue_observation(self, ue):
        connections = np.zeros(len(self.stations), dtype=np.float32)
        connections[[ue.is_connected_to(bs) for bs in self.stations]] = 1

        snrs_raw = [ue.get_snr(bs) for bs in self.stations]
        snrs = np.asarray(snrs_raw, dtype=np.float32)
        normalized_snrs = snrs / np.max(snrs)

        if ue not in self.previous_snrs:
            snr_velocities = np.zeros(len(self.stations), dtype=np.float32)
            normalized_snr_velocities = snr_velocities
        else:
            snr_velocities = snrs - self.previous_snrs[ue]
            normalized_snr_velocities = snr_velocities / np.max(np.abs(snr_velocities))
        self.previous_snrs[ue] = snrs

        utility = np.asarray([ue.get_utility()], dtype=np.float32)

        connection = next(iter(ue.connections.values())) if ue.is_connected() else None
        is_better_snr_available = np.asarray(
            [(1 if connection is None else max(snrs_raw) > connection.snr)],
            dtype=np.float32,
        )

        return np.concatenate(
            (
                connections,
                normalized_snrs,
                normalized_snr_velocities,
                utility,
                is_better_snr_available,
            )
        )


class SmallEnvironment(HandoverEnvironment):
    def __init__(self, **kwargs):
        super().__init__(
            stations=[
                BaseStation((0.7e3, 0.8e3)),
                BaseStation((1.9e3, 0.8e3)),
            ],
            users=[AppAwareUserEquipment() for _ in range(8)],
            size=(2.6e3, 1.6e3),
            **kwargs,
        )


class MediumEnvironment(HandoverEnvironment):
    def __init__(self, **kwargs):
        super().__init__(
            stations=[
                BaseStation((0.8e3, 0.6e3)),
                BaseStation((1.8e3, 0.6e3)),
                BaseStation((1.3e3, 1.6e3)),
            ],
            users=[AppAwareUserEquipment() for _ in range(10)],
            size=(2.6e3, 2.2e3),
            **kwargs,
        )


class LargeEnvironment(HandoverEnvironment):
    def __init__(self, **kwargs):
        super().__init__(
            stations=[
                BaseStation((0.5e3, 0.5e3)),
                BaseStation((2e3, 0.5e3)),
                BaseStation((1.25e3, 1.25e3)),
                BaseStation((0.5e3, 2e3)),
                BaseStation((2e3, 2e3)),
            ],
            users=[AppAwareUserEquipment() for _ in range(20)],
            size=(2.5e3, 2.5e3),
            **kwargs,
        )
