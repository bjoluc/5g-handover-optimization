import logging
import warnings
from time import sleep

import numpy as np
from handyscope import Oscilloscope
from plot import Plot, SlotDualSubPlot
from scipy import signal

logger = logging.getLogger(__name__)

SHUNT_RESISTANCE = 0.55  # Ohms

OVERSAMPLING_FACTOR = 8


# Console output of recorder.measure_noise():
NOISE_OFFSET = 0.006  # V; Due to imperfections of the oscilloscope
NOISE_STD_DEVIATION = 0.0007  # V


class CurrentRecorder:
    def __init__(self, target_frequency=4e3):
        self._target_frequency = target_frequency
        self._nyquist_frequency = 2 * self._target_frequency
        self._ideal_sample_frequency = self._target_frequency * OVERSAMPLING_FACTOR

        self._oscilloscope = Oscilloscope("HS3")
        self._oscilloscope.resolution = 16  # bit

        with warnings.catch_warnings():
            warnings.filterwarnings("ignore")
            self._oscilloscope.sample_freq = self._ideal_sample_frequency

        self._sample_frequency = self._oscilloscope.sample_freq
        logger.debug(f"Ideal sample frequency: {self._ideal_sample_frequency/1e3} kHz")
        logger.debug(f"Real sample frequency: {self._sample_frequency/1e3} kHz")

        for channel in self._oscilloscope.channels[:2]:
            channel.is_enabled = True
            channel.range = 8

    def start(self, duration: int):
        with warnings.catch_warnings():
            warnings.filterwarnings("ignore")
            self._oscilloscope.record_length = int(self._sample_frequency * duration)

        logger.debug(
            f"Recording {self._oscilloscope.record_length/self._sample_frequency} s"
        )
        self._oscilloscope.start()

    def _retrieve_voltage_differences(self):
        """
        Blocks until recording is completed and returns the sampled voltage differences
        between channel 1 and 2
        """
        while not self._oscilloscope.is_data_ready:
            sleep(0.1)

        logger.debug("Recording finished")

        measurements = self._oscilloscope.retrieve()

        # Subtract channel 2 from channel 1
        difference = np.array(measurements[0]) - measurements[1]

        return difference

    def _filter(self, samples):
        filter_order = 2
        return signal.sosfiltfilt(
            signal.butter(
                filter_order,
                self._nyquist_frequency,
                "lowpass",
                fs=self._sample_frequency,
                output="sos",
            ),
            samples,
        )

    def _resample_to_ideal_sample_frequency(self, time, samples):
        duration = time.size / self._sample_frequency
        new_sample_count = int(duration * self._ideal_sample_frequency)
        resampled_samples = signal.resample(samples, new_sample_count)
        resampled_time = np.linspace(0, duration, new_sample_count)

        return resampled_time, resampled_samples

    def _decimate(self, time, samples):
        downsampling_factor = int(
            self._ideal_sample_frequency / self._nyquist_frequency
        )
        decimated_samples = signal.decimate(samples, downsampling_factor)
        decimated_time = time[::downsampling_factor]

        return decimated_time, decimated_samples

    def measure_noise(self):
        """
        Run this to measure and analyze environmental noise when the 5G hat is powered
        off.
        """
        self.start(2)
        voltages = self._retrieve_voltage_differences()
        time = self._oscilloscope.time_vector

        plot = Plot(subplot_count=2)

        plot.add_subplot(
            time,
            voltages,
            x_label="t [s]",
            y_label="U_diff [V]",
            y_min=0,
            y_max=0.15,
        )

        resampled_time, resampled_voltages = self._resample_to_ideal_sample_frequency(
            self._oscilloscope.time_vector,
            voltages,
        )

        filtered_voltages = self._filter(resampled_voltages)
        decimated_time, decimated_voltages = self._decimate(
            resampled_time, filtered_voltages
        )

        print("Noise offset [V]:", round(np.mean(filtered_voltages), 6))
        print("Noise std deviation [V]:", round(np.std(filtered_voltages), 6))

        plot.add_subplot(
            decimated_time,
            decimated_voltages,
            x_label="t [s]",
            y_label="U_diff [V]",
            y_min=0,
            y_max=0.15,
        )

        plot.show()

    def get_measurements(self, decimate=True):
        currents = (
            self._retrieve_voltage_differences() - NOISE_OFFSET
        ) / SHUNT_RESISTANCE

        time, currents = self._resample_to_ideal_sample_frequency(
            self._oscilloscope.time_vector,
            currents,
        )

        if decimate:
            time, currents = self._decimate(time, self._filter(currents))

        return time, currents

    def plot(self, time, currents, condition={}):
        plot = Plot(subplot_count=2)
        plot.add_subplot_object(
            SlotDualSubPlot(
                time,
                currents * 1e3,
                x_label="t [s]",
                y_label="U [mA]",
                y_min=0,
                y_max=1000,
                condition=condition,
            )
        )

        plot.show()


if __name__ == "__main__":
    recorder = CurrentRecorder()
    recorder.measure_noise()

    # recorder.start(2)
    # recorder.get_measurements(show_plot=True)
