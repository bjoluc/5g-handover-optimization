from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.pair cimport pair

cdef extern from "Simulation.cpp":
    cdef vector[double] estimate_activity_probabilities(
        unsigned long cycles,
        unsigned int cycleDuration,
        unsigned int onDuration,
        unsigned int inactivityTimer,
        unsigned int iatUl,
        unsigned int iatDl
    )

    cdef pair[double, double] estimate_sleep_ratio(
        unsigned long cycles,
        unsigned int cycleDuration,
        unsigned int onDuration,
        unsigned int inactivityTimer,
        unsigned int iatUl,
        unsigned int iatDl
    )

    cdef vector[bool] simulate_activity(
        unsigned long cycles,
        unsigned int cycleDuration,
        unsigned int onDuration,
        unsigned int inactivityTimer,
        unsigned int iatUl,
        unsigned int iatDl
    )