# distutils: language = c++

import cython  # type: ignore
import numpy as np

# isort: off
from cython.cimports.Simulation import (  # type: ignore
    estimate_activity_probabilities as estimate_activity_probabilities_native,
    estimate_sleep_ratio as estimate_sleep_ratio_native,
    simulate_activity as simulate_activity_native,
)

# isort: on


def estimate_activity_probabilities(
    cycles: cython.ulong,
    cycle_duration: cython.uint,
    on_duration: cython.uint,
    inactivity_timer: cython.uint,
    iat_ul: cython.uint,
    iat_dl: cython.uint,
):
    return (
        np.asarray(
            estimate_activity_probabilities_native(
                cycles, cycle_duration, on_duration, inactivity_timer, iat_ul, iat_dl
            )
        )
        / cycles
    )


def estimate_sleep_ratio(
    cycles: cython.ulong,
    cycle_duration: cython.uint,
    on_duration: cython.uint,
    inactivity_timer: cython.uint,
    iat_ul: cython.uint,
    iat_dl: cython.uint,
):
    return estimate_sleep_ratio_native(
        cycles, cycle_duration, on_duration, inactivity_timer, iat_ul, iat_dl
    )


def simulate_activity(
    cycles: cython.ulong,
    cycle_duration: cython.uint,
    on_duration: cython.uint,
    inactivity_timer: cython.uint,
    iat_ul: cython.uint,
    iat_dl: cython.uint,
):
    return simulate_activity_native(
        cycles, cycle_duration, on_duration, inactivity_timer, iat_ul, iat_dl
    )
