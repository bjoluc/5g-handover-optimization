import math
import pickle
import tkinter as tk
import warnings
from pathlib import Path
from sys import argv
from tkinter import filedialog, simpledialog
from typing import List

import matplotlib
import matplotlib.pyplot as pyplot
import numpy as np
from matplotlib.axes import Axes
from matplotlib.backend_managers import ToolEvent, ToolManager
from matplotlib.backend_tools import ToolBase
from scipy import signal

from scripts.utils import copy_data_as_typst

root = tk.Tk()
root.withdraw()

with warnings.catch_warnings():
    warnings.filterwarnings("ignore")
    matplotlib.rcParams["toolbar"] = "toolmanager"

PLOTS_DIRECTORY = Path(__file__).parent / "plots"
PLOTS_DIRECTORY.mkdir(exist_ok=True)

FILETYPES = ["Plot {.plot}"]


def ask_save_path():
    return Path(
        filedialog.asksaveasfilename(
            defaultextension=".plot",
            initialdir=PLOTS_DIRECTORY,
            filetypes=FILETYPES,
        )
    )


def ask_open_path():
    return Path(
        filedialog.askopenfilename(
            defaultextension=".plot",
            initialdir=PLOTS_DIRECTORY,
            filetypes=FILETYPES,
        )
    )


class PlotButtonTool(ToolBase):
    @classmethod
    def add_to_plot(cls, plot: "Plot"):
        tool_manager = plot.figure.canvas.manager.toolmanager
        tool_manager.add_tool(cls.tool_name, cls, plot)
        plot.figure.canvas.manager.toolbar.add_tool(
            tool_manager.get_tool(cls.tool_name), group="custom"
        )

    tool_name = ""

    def __init__(self, toolmanager: ToolManager, name: str, plot: "Plot"):
        super().__init__(toolmanager, name)
        self._plot = plot
        self._subplot: SubPlot = None

    def trigger(self, sender, event: ToolEvent, data):
        if self._subplot is None:
            self._subplot = self._plot.subplots[0]
        self.on_clicked()

    def on_clicked(self):
        pass


class SaveTool(PlotButtonTool):
    tool_name = "Save"

    def on_clicked(self):
        path = ask_save_path()
        self._subplot.save(path)


class SetXMinTool(PlotButtonTool):
    tool_name = "Set X Min"

    def on_clicked(self):
        x_min, x_max = self._subplot.axes.get_xlim()
        self._subplot.x_min = x_min


class SetXMaxTool(PlotButtonTool):
    tool_name = "Set X Max"

    def on_clicked(self):
        self._subplot.x_max = simpledialog.askfloat(
            "Set X Max",
            "Please enter the new X Max value:",
            initialvalue=self._subplot.x_max,
            minvalue=0,
        )


class AlignSlotBoundaries(PlotButtonTool):
    tool_name = "Align Slots"

    def on_clicked(self):
        if hasattr(self._subplot, "adjust_slot_boundaries"):
            left_xlim = self._subplot.axes.get_xlim()[0]
            self._subplot.adjust_slot_boundaries(left_xlim)


class CopyTypstTool(PlotButtonTool):
    tool_name = "Copy as Typst"

    def on_clicked(self):
        subplot = self._subplot
        x_values, y_values = subplot.get_truncated_data()

        # Decimate data if applicable
        target_sample_count = 1000
        downsampling_factor = round(len(x_values) / target_sample_count)
        if downsampling_factor > 1:
            y_values = signal.decimate(y_values, downsampling_factor)
            x_values = x_values[::downsampling_factor]

        copy_data_as_typst(x_values, y_values)


class CopySlotsTypstTool(PlotButtonTool):
    tool_name = "Copy Slots as Typst"

    def on_clicked(self):
        if hasattr(self._subplot, "get_truncated_slot_averaged_data"):
            copy_data_as_typst(*self._subplot.get_truncated_slot_averaged_data())


class SubPlot:
    @staticmethod
    def load(path: Path) -> "SubPlot":
        with path.open("rb") as file:
            return pickle.load(file)

    @staticmethod
    def get_index_by_value(values, value):
        return (np.abs(values - value)).argmin()

    @staticmethod
    def quantize_value(values, value):
        return values[SubPlot.get_index_by_value(values, value)]

    def __init__(
        self,
        x_values: np.ndarray,
        y_values: np.ndarray,
        x_label="",
        y_label="",
        y_min=None,
        y_max=None,
        condition=dict(),
    ):
        self._x_values = x_values
        self._y_values = y_values
        self._x_label = x_label
        self._y_label = y_label
        self._y_min = y_min
        self._y_max = y_max
        self._condition = condition

        self.axes: Axes = None
        self._x_min = 0
        self._x_max = x_values[-1]

    def __getstate__(self):
        state = self.__dict__.copy()
        # Don't pickle self.axes
        del state["axes"]
        return state

    @property
    def x_min(self):
        return self._x_min

    @x_min.setter
    def x_min(self, x_min):
        new_x_min = SubPlot.quantize_value(self._x_values, self._x_min + x_min)
        self._pan_x(self._x_min - new_x_min)
        self._x_min = new_x_min
        self._replot()

    @property
    def x_max(self):
        return self._x_max

    @x_max.setter
    def x_max(self, x_max):
        self._x_max = x_max
        self._set_plot_limits()
        self._replot()

    def get_truncated_data(self):
        """
        Returns all data between `self.x_min` and `self.x_max`
        """
        first_index = SubPlot.get_index_by_value(self._x_values, self.x_min)
        last_index = SubPlot.get_index_by_value(self._x_values - self.x_min, self.x_max)

        return (
            self._x_values[first_index:last_index] - self.x_min,
            self._y_values[first_index:last_index],
        )

    def _plot_data(self):
        self.axes.plot(
            self._x_values - self.x_min, self._y_values, linewidth=1, color="#1f77b4"
        )

    def _set_plot_limits(self):
        if self.axes:
            self.axes.set_xlim(0, self.x_max)
            self.axes.set_ylim(bottom=self._y_min, top=self._y_max)

    def _pan_x(self, offset):
        if self.axes:
            x_min, x_max = self.axes.get_xlim()
            self.axes.set_xlim(x_min + offset, x_max + offset)

    def plot(self, axes: Axes):
        self.axes = axes
        self._plot_data()
        self._set_plot_limits()

        axes.set_xlabel(self._x_label)
        axes.set_ylabel(self._y_label)
        axes.grid()

        # Display `condition` dict
        axes.text(
            0.5,
            1.25,
            str(self._condition),
            transform=axes.transAxes,
            ha="center",
            va="top",
            wrap=True,
        )

    def _replot(self):
        if self.axes:
            for artist in self.axes.lines:
                artist.remove()

            self._plot_data()
            self.axes.get_figure().canvas.draw_idle()

    def save(self, path: Path):
        with path.open("wb") as file:
            pickle.dump(self, file)


class SlotDualSubPlot(SubPlot):
    SLOT_DURATION = 0.5e-3

    @classmethod
    def get_closest_slot_boundary(cls, x_value, rounding_function=round):
        return rounding_function(x_value / cls.SLOT_DURATION) * cls.SLOT_DURATION

    def __getstate__(self):
        state = self.__dict__.copy()
        del state["axes"]
        del state["slot_axes"]
        return state

    @property
    def samples_per_slot(self):
        """
        The number of samples per slot, assuming the x values start with 0 and include
        an integer number of samples per slot)
        """
        return SlotDualSubPlot.get_index_by_value(
            self._x_values, SlotDualSubPlot.SLOT_DURATION
        )

    @property
    def slot_averaged_data(self):
        time = self._x_values
        current = self._y_values

        samples_per_slot = self.samples_per_slot

        first_sample_index = SlotDualSubPlot.get_index_by_value(
            time - self._x_min,
            SlotDualSubPlot.get_closest_slot_boundary(
                time[0] - self._x_min, rounding_function=math.ceil
            ),
        )

        last_sample_index = (
            first_sample_index
            + ((len(time) - first_sample_index) // samples_per_slot) * samples_per_slot
        )

        slotted_time = time[first_sample_index:last_sample_index:samples_per_slot]
        slot_averaged_current = np.mean(
            current[first_sample_index:last_sample_index].reshape(-1, samples_per_slot),
            axis=1,
        )

        return slotted_time, slot_averaged_current

    def get_truncated_slot_averaged_data(self):
        """
        Returns all slot-averaged data between `self.x_min` and `self.x_max`
        """
        x_values, y_values = self.slot_averaged_data

        first_index = SubPlot.get_index_by_value(x_values, self.x_min)
        last_index = SubPlot.get_index_by_value(x_values - self.x_min, self.x_max)

        return (
            x_values[first_index:last_index] - self.x_min,
            y_values[first_index:last_index],
        )

    def adjust_slot_boundaries(self, boundary_x_value):
        """
        Adjusts `x_min` s.t. the given `boundary_x_value` is positioned at the beginning
        of a slot
        """
        offset = boundary_x_value - SlotDualSubPlot.get_closest_slot_boundary(
            boundary_x_value
        )
        self.x_min = offset

    def _plot_data(self):
        # Plot per-slot averages
        time, currents = self.slot_averaged_data

        time = time - self.x_min

        # Simulate bar plot using `fill_between` (because native bar plots render too
        # slowly)
        self.slot_axes.fill_between(
            np.dstack((time, time + SlotDualSubPlot.SLOT_DURATION)).reshape((1, -1))[0],
            0,
            np.dstack((currents, currents)).reshape((1, -1))[0],
            color="#ff7f0e",
        )

        super()._plot_data()

    def _set_plot_limits(self):
        self.slot_axes.set_xlim(0, self.x_max)
        self.slot_axes.set_ylim(bottom=self._y_min)

        super()._set_plot_limits()

    def plot(self, axes):
        # Plot additional slot-averaged subplot
        if "slot_axes" not in self.__dict__:
            self.slot_axes = axes.figure.add_subplot(2, 1, 2)

        slot_axes = self.slot_axes
        slot_axes.set_xlabel(self._x_label)
        slot_axes.set_ylabel(self._y_label)
        slot_axes.grid()

        slot_axes.sharex(axes)

        # Plot primary subplot
        super().plot(axes)

    def _replot(self):
        if self.slot_axes:
            for artist in self.slot_axes.collections:
                artist.remove()

        super()._replot()


class Plot:
    def __init__(self, subplot_count=2):
        self._subplot_count = subplot_count

        self.figure = pyplot.figure()
        self.subplots: List[SubPlot] = []

        # Add custom tools
        for tool in [
            SaveTool,
            SetXMinTool,
            SetXMaxTool,
            AlignSlotBoundaries,
            CopyTypstTool,
            CopySlotsTypstTool,
        ]:
            tool.add_to_plot(self)

    def add_subplot(self, *args, **kwargs):
        subplot = SubPlot(*args, **kwargs)
        self.add_subplot_object(subplot)
        return subplot

    def add_subplot_object(self, subplot: SubPlot):
        self.subplots.append(subplot)
        axes = pyplot.subplot(self._subplot_count, 1, len(self.subplots))
        subplot.plot(axes)

    def show(self):
        pyplot.show()


if __name__ == "__main__":
    path = Path(argv[1]) if len(argv) > 1 else ask_open_path()
    plot = Plot(subplot_count=2)
    subplot = SubPlot.load(path)
    plot.add_subplot_object(subplot)
    plot.show()
