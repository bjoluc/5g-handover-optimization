import logging
import os
import pickle
import sys
from pathlib import Path
from random import shuffle
from time import sleep, time
from typing import Dict, List, Literal

import numpy as np
import plotille
from current_recorder import CurrentRecorder
from plot import Plot
from qmi import UnlockedQmiDevice
from scenarios import TrafficScenario
from scipy.stats import sem
from tqdm import tqdm

DEVICE_PATH = "/dev/cdc-wdm1"
MONITOR_SIGNAL_INFO = "--monitor-signal-info" in sys.argv
MODES: List[Literal["umts", "lte", "5gnr"]] = ["5gnr"]  # ["lte", "5gnr"]

# All of these PINs are tried in the given order to support swapping SIM cards without
# modifying PINs in the script. Caution: Don't use more than four PINs here to avoid
# running out of verification retries!
SIM_PINS = [
    # T-Mobile 5G SA
    "8370",
    # T-Mobile 5G NSA
    "2693",
]

logger = logging.getLogger(__name__)


def make_unlocked_qmi_device():
    return UnlockedQmiDevice(DEVICE_PATH, SIM_PINS, MODES)


def measure_time_series():
    current_recorder = CurrentRecorder()

    with make_unlocked_qmi_device() as device:
        with TrafficScenario(
            device,
            stabilization_time=1,
            duration=5,
            randomize_iats=True,
            iat_dl=1 / 8,
            iat_ul=1 / 8,
            packet_size_dl=1024,
            packet_size_ul=16,
        ) as scenario:
            condition = scenario.condition
            print(condition)
            current_recorder.start(4)

    current_recorder.plot(
        *current_recorder.get_measurements(decimate=False), condition=condition
    )


def measure_pps_series(packet_rates):
    packet_size_dl = 1024
    packet_size_ul = 256

    max_sem = 0.00125  # was 0.002 before

    logger.info(f"Measuring power for {len(packet_rates)} packet rates")
    current_recorder = CurrentRecorder()
    measured_means_by_pps: Dict[int, List[float]] = {pps: [] for pps in packet_rates}
    signal_info = None
    start_time = time()

    def plot_ascii_graph():
        """Returns an intermediate power-over-pps ASCII graph as a string"""
        pruned_means = {
            pps: np.mean(means) * 1000
            for pps, means in measured_means_by_pps.items()
            if len(means) > 0
        }

        terminal_columns, terminal_lines = os.get_terminal_size()

        def int_formatter(val, chars, delta, left=False):
            return "{:{}{}d}".format(int(val), "<" if left else "", chars)

        fig = plotille.Figure()
        fig.width = terminal_columns - 25
        fig.height = terminal_lines - 6
        fig.set_x_limits(min_=int(packet_rates[0]), max_=int(packet_rates[-1]))
        fig.set_y_limits(min_=0, max_=400)
        fig.x_label = "PPS"
        fig.y_label = "I [mA]"
        fig.register_label_formatter(float, int_formatter)
        fig.register_label_formatter(int, int_formatter)
        fig.origin = False
        fig.plot(pruned_means.keys(), pruned_means.values(), lc="green")
        return fig.show()

    def get_chunk_size(pps: int):
        # Number of 4-sec measurements in a row
        return 4 if pps > 20 else 16

    def are_measurements_sufficient(means, chunk_size):
        # return len(means) >= 8 * chunk_size and sem(means) <= max_sem
        return len(means) >= 9 * chunk_size

    pending_measurements = {**measured_means_by_pps}

    with tqdm(total=len(packet_rates), desc="Completed IATs") as progressbar:
        while len(pending_measurements) > 0:
            items = list(pending_measurements.items())
            shuffle(items)
            for pps, means in items:
                chunk_size = get_chunk_size(pps)

                progressbar.set_postfix(
                    pps=pps,
                    sem=sem(means) if len(means) > 1 else None,
                    power=np.mean(means) if len(means) > 0 else None,
                )

                progressbar.write(plot_ascii_graph())

                iat = 1 / pps

                current_iteration_means = []
                was_measurement_successful = False
                while not was_measurement_successful:
                    try:
                        with make_unlocked_qmi_device() as device:
                            with TrafficScenario(
                                device,
                                duration=4.3 * chunk_size,
                                randomize_iats=True,
                                iat_dl=iat,
                                iat_ul=iat,
                                packet_size_dl=packet_size_dl,
                                packet_size_ul=packet_size_ul,
                            ) as scenario:
                                for _ in tqdm(
                                    range(chunk_size), desc="Measurement", leave=False
                                ):
                                    current_recorder.start(4)
                                    current_iteration_means.append(
                                        np.mean(current_recorder.get_measurements()[1])
                                    )

                                signal_info = scenario.condition["signal"]

                        was_measurement_successful = True

                    except Exception:
                        logger.warning(
                            "An unexpected error occurred. Continuing with next measurement iteration.",
                            exc_info=True,
                        )
                        sleep(1)

                means.extend(current_iteration_means)

                if are_measurements_sufficient(means, chunk_size):
                    pending_measurements.pop(pps)
                    progressbar.update(1)

    # Dump all measured means in a file
    with Path(f"./plots/dumps/{round(time())}.pickle").open("wb") as file:
        pickle.dump(measured_means_by_pps, file)

    powers = np.array([np.mean(means) for means in measured_means_by_pps.values()])

    plot = Plot()
    plot.add_subplot(
        packet_rates,
        powers * 1000,
        x_label="Packets per Second",
        y_label="Avg. Power [mA]",
        y_min=0,
        y_max=max(powers) * 1000,
        condition={
            "signal": signal_info,
            "packet_size_dl": packet_size_dl,
            "packet_size_ul": packet_size_ul,
            "max_sem": max_sem,
            "start_time": start_time,
            "stop_time": time(),
        },
    )
    plot.show()


def measure_rsrp_series():
    logger.info(f"Measuring power for varying RSRPs until the cell ID changes")

    current_recorder = CurrentRecorder()
    condition = None
    rsrps = []
    powers = []

    has_cell_id_changed = False

    try:
        while not has_cell_id_changed:
            was_measurement_successful = False
            while not was_measurement_successful:
                try:
                    with make_unlocked_qmi_device() as device:
                        with TrafficScenario(
                            device,
                            duration=5,
                            randomize_iats=False,
                            iat_dl=0.01,
                            iat_ul=0.01,
                            packet_size_dl=1024,
                            packet_size_ul=16,
                        ) as scenario:
                            if condition is None:
                                condition = scenario.condition
                            else:
                                if (
                                    scenario.condition["signal"]["cell"]["cid"]
                                    != condition["signal"]["cell"]["cid"]
                                ):
                                    logger.info(
                                        f'The physical cell ID changed from {condition["signal"]["cell"]["cid"]} to {scenario.condition["signal"]["cell"]["cid"]}. Finishing.'
                                    )
                                    has_cell_id_changed = True

                            logger.info(
                                f'Measuring with RSRP {scenario.condition["signal"]["cell"]["rsrp"]}'
                            )
                            current_recorder.start(2)

                    was_measurement_successful = True
                    rsrps.append(scenario.condition["signal"]["cell"]["rsrp"])
                    powers.append(np.mean(current_recorder.get_measurements()[1]))

                except Exception:
                    logger.warning(
                        "An unexpected error occurred. Repeating the measurement.",
                        exc_info=True,
                    )
                    sleep(1)

            for _ in tqdm(range(10), leave=False, desc="Time to move"):
                sleep(3 / 10)
    except KeyboardInterrupt:
        pass
    finally:
        plot = Plot()
        plot.add_subplot(
            np.asarray(rsrps),
            np.asarray(powers) * 1000,
            x_label="RSRP",
            y_label="Avg. Power [mA]",
            y_min=0,
            y_max=max(powers) * 1000,
            condition=condition,
        )
        plot.show()


def measure_packet_size_series(packet_sizes, iat_dl=None, iat_ul=0.005):
    logger.info(f"Measuring power for {len(packet_sizes)} packet sizes")

    current_recorder = CurrentRecorder()
    condition = None
    powers = []

    with tqdm(packet_sizes) as t:
        for packet_size in t:
            was_measurement_successful = False
            while not was_measurement_successful:
                try:
                    with make_unlocked_qmi_device() as device:
                        with TrafficScenario(
                            device,
                            duration=4.5,
                            randomize_iats=False,
                            iat_dl=iat_dl,
                            iat_ul=iat_ul,
                            packet_size_dl=int(packet_size),
                            packet_size_ul=int(packet_size),
                        ) as scenario:
                            condition = scenario.condition
                            current_recorder.start(4)
                    was_measurement_successful = True
                    powers.append(np.mean(current_recorder.get_measurements()[1]))
                    t.set_postfix(power=powers[-1])
                except Exception:
                    logger.warning(
                        "An unexpected error occurred. Repeating the measurement.",
                        exc_info=True,
                    )
                    sleep(1)

    plot = Plot()
    plot.add_subplot(
        np.asarray(packet_sizes),
        np.asarray(powers) * 1000,
        x_label="Packet Size [bytes]",
        y_label="Avg. Power [mA]",
        y_min=0,
        y_max=max(powers) * 1000,
        condition={**condition, "iat_dl": iat_dl, "iat_ul": iat_ul},
    )
    plot.show()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    if MONITOR_SIGNAL_INFO:
        with make_unlocked_qmi_device() as device:
            while True:
                try:
                    info = device.get_signal_info()
                    logger.info(info["cell"]["rsrp"] if "--rsrp" in sys.argv else info)
                    sleep(1)
                except KeyboardInterrupt:
                    exit(0)

    # measure_time_series()
    measure_pps_series(np.arange(1, 201, 1))
    # measure_rsrp_series()
    # measure_packet_size_series(np.arange(16, 1024, 8))
