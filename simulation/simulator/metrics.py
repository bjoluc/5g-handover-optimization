import numpy as np
from simulator.environment.core.environment import BaseEnvironment
from simulator.utils import compute_jains_fairness_index


def power_by_connected_ue(env: BaseEnvironment):
    return {ue: ue.get_average_power() for ue in env.ues if ue.is_connected()}


def ue_powers(env: BaseEnvironment):
    return {ue: ue.get_average_power() for ue in env.ues}


def mean_connected_ue_power(env: BaseEnvironment):
    powers = power_by_connected_ue(env).values()
    if len(powers) == 0:
        return np.nan

    return np.mean(list(powers))


def utility_fairness(env: BaseEnvironment):
    # Jain's fairness index applied to utilities (normalized to [0,2])
    utilities = np.asarray([ue.get_utility() for ue in env.ues])
    return compute_jains_fairness_index(utilities + 1)
