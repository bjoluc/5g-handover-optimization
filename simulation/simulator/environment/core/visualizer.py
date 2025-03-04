from __future__ import annotations

from typing import TYPE_CHECKING

from matplotlib.artist import Artist
from matplotlib.figure import Figure
from simulator.environment.core import metrics
from simulator.environment.core.default_constants import MINIMAL_UE_DATARATE
from simulator.environment.core.util import BS_SYMBOL

if TYPE_CHECKING:
    from simulator.environment.core.environment import BaseEnvironment

from string import ascii_uppercase

import matplotlib.patheffects as pe
import matplotlib.pyplot as plt
import numpy as np
import pygame
from matplotlib import cm
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from pygame import Surface

SCALE = 0.35


class Visualizer:
    utility_colormap = cm.get_cmap("RdYlGn")

    @staticmethod
    def normalize_utility(utility: float):
        return (utility + 1) / 2

    def __init__(self, environment: BaseEnvironment, render_mode: str):
        assert render_mode in ["rgb_array", "human"]
        self.environment = environment
        self.mode = render_mode

        # Add metrics used by the visualization
        for metric in {
            "connected_ues": metrics.connected_ues,
            "mean_utility": metrics.mean_utility,
            "mean_datarate": metrics.mean_datarate,
        }.items():
            self.environment.monitor.add_metric(*metric)

        fig = plt.gcf()
        self.dpi = fig.dpi
        plt.close()

        self.figure: Figure = None
        self.canvas: FigureCanvas = None
        self.removable_objects: list[Artist] = []
        self.window = None
        self.clock = None

    def _setup(self):
        # set up matplotlib figure & axis configuration
        self.figure = plt.figure(
            figsize=(
                max(8.0, 3 / 2 * self.environment.size[0] * SCALE / self.dpi),
                max(5.0, self.environment.size[1] * SCALE / self.dpi),
            )
        )
        gridspec = self.figure.add_gridspec(
            ncols=2,
            nrows=3,
            width_ratios=(4, 2),
            height_ratios=(2, 3, 3),
            hspace=0.45,
            wspace=0.2,
            top=0.95,
            bottom=0.15,
            left=0.025,
            right=0.955,
        )

        self.simulation_ax = self.figure.add_subplot(gridspec[:, 0])
        self.dashboard_ax = self.figure.add_subplot(gridspec[0, 1])

        for ax in [self.simulation_ax, self.dashboard_ax]:
            # remove simulation axis's ticks and spines
            ax.get_xaxis().set_visible(False)
            ax.get_yaxis().set_visible(False)

            for pos in ["top", "bottom", "right", "left"]:
                ax.spines[pos].set_visible(False)

        self.utility_ax = self.figure.add_subplot(gridspec[1, 1])
        self.utility_ax.set_ylabel("Avg. Utility")
        self.utility_ax.set_xlim([0.0, self.environment.episode_duration])
        self.utility_ax.set_ylim([-1, 1])

        self.connected_ax = self.figure.add_subplot(gridspec[2, 1])
        self.connected_ax.set_xlabel("Time")
        self.connected_ax.set_ylabel("#Conn. UEs")
        self.connected_ax.set_xlim([0.0, self.environment.episode_duration])
        self.connected_ax.set_ylim([0.0, len(self.environment.ues)])

        # align plots' y-axis labels
        self.figure.align_ylabels((self.utility_ax, self.connected_ax))
        self.canvas = FigureCanvas(self.figure)

        self._setup_simulation()

        if self.mode == "human":
            # set up pygame window to display matplotlib figure
            pygame.init()
            self.clock = pygame.time.Clock()

            # set window size to figure's size in pixels
            window_size = tuple(map(int, self.figure.get_size_inches() * self.dpi))
            self.window = pygame.display.set_mode(window_size)

            # remove pygame icon from window; set icon to empty surface
            pygame.display.set_icon(Surface((0, 0)))

            # set window's caption and background color
            pygame.display.set_caption("MComEnv")

    def render(self):
        if not self.figure:
            self._setup()
        else:
            for artist in self.removable_objects:
                try:
                    artist.remove()
                except:
                    # The errors here seem to be a bug with matplotlib. Objects are
                    # removed regardless.
                    pass

        # render simulation, metrics and score if step() was called
        # i.e. this prevents rendering in the sequential environment before
        # the first round of actions is finalized
        if self.environment.time > 0:
            self._render_simulation()
            self._render_dashboard()
            self._render_mean_utility()
            self._render_ues_connected()

        self.canvas.draw()

        if self.mode == "rgb_array":
            # render RGB image for e.g. video recording
            data = np.frombuffer(self.canvas.tostring_rgb(), dtype=np.uint8)
            # reshape image from 1d array to 2d array
            return data.reshape(self.canvas.get_width_height()[::-1] + (3,))

        if self.mode == "human":
            # render RGBA image on pygame surface
            data = self.canvas.buffer_rgba()
            size = self.canvas.get_width_height()

            # plot matplotlib's RGBA frame on the pygame surface
            screen = pygame.display.get_surface()
            plot = pygame.image.frombuffer(data, size, "RGBA")
            screen.blit(plot, (0, 0))

            # update the full display surface to the window
            pygame.display.flip()

            # handle pygame events (such as closing the window)
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.quit()

    def _setup_simulation(self):
        ax = self.simulation_ax
        ax.set_xlim([0, self.environment.size[0]])
        ax.set_ylim([0, self.environment.size[1]])

        for bs in self.environment.stations:
            # plot BS symbol and annonate by its BS ID
            ax.plot(
                bs.position.x,
                bs.position.y,
                marker=BS_SYMBOL,
                markersize=30,
                markeredgewidth=0.1,
                color="black",
            )
            ax.annotate(
                ascii_uppercase[bs.id],
                xy=(bs.position.x, bs.position.y),
                xytext=(0, -25),
                ha="center",
                va="bottom",
                textcoords="offset points",
            )

            # Plot BS ranges where UEs may connect or can receive at most 5 Mbps
            for datarate, color in [(MINIMAL_UE_DATARATE, "gray"), (5e6, "black")]:
                ax.scatter(
                    *bs.channel.isoline(self.environment.size, datarate),
                    color=color,
                    s=3,
                )

    def _render_simulation(self):
        ax = self.simulation_ax
        for ue in self.environment.ues:
            self.removable_objects.append(
                ax.scatter(
                    ue.position.x,
                    ue.position.y,
                    s=200,
                    zorder=2,
                    color=self.utility_colormap(
                        self.normalize_utility(ue.get_utility())
                    ),
                    marker="o",
                )
            )
            self.removable_objects.append(
                ax.annotate(
                    ue.id, xy=(ue.position.x, ue.position.y), ha="center", va="center"
                )
            )

        for bs in self.environment.stations:
            for connection in bs.connections.values():
                ue = connection.ue
                # color is connection's contribution to the UE's total utility
                share = connection.current_datarate / ue.get_datarate()
                color = self.utility_colormap(
                    share * self.normalize_utility(ue.get_utility())
                )

                # add black background/borders for lines for visibility
                self.removable_objects.extend(
                    ax.plot(
                        [ue.position.x, bs.position.x],
                        [ue.position.y, bs.position.y],
                        color=color,
                        path_effects=[
                            pe.SimpleLineShadow(shadow_color="black"),
                            pe.Normal(),
                        ],
                        linewidth=3,
                        zorder=-1,
                    )
                )

    def _render_dashboard(self) -> None:
        mean_utilities = self.environment.monitor.get_metric_history("mean_utility")
        mean_utility = mean_utilities[-1]
        total_mean_utility = np.mean(mean_utilities)

        mean_datarates = self.environment.monitor.get_metric_history("mean_datarate")
        mean_datarate = mean_datarates[-1]
        total_mean_datarate = np.mean(mean_datarates)

        rows = ["Current", "History"]
        cols = ["Avg. DR [Mbps]", "Avg. Utility"]
        text = [
            [f"{mean_datarate*1e-6:.3f}", f"{mean_utility:.3f}"],
            [f"{total_mean_datarate*1e-6:.3}", f"{total_mean_utility:.3f}"],
        ]

        table = self.dashboard_ax.table(
            text,
            rowLabels=rows,
            colLabels=cols,
            cellLoc="center",
            edges="B",
            loc="upper center",
            bbox=[0.0, -0.25, 1.0, 1.25],
        )
        table.auto_set_font_size(False)
        table.set_fontsize(11)
        self.removable_objects.append(table)

    def _render_mean_utility(self) -> None:
        time = np.arange(self.environment.time)
        mean_utility = self.environment.monitor.get_metric_history("mean_utility")
        self.removable_objects.extend(
            self.utility_ax.plot(time, mean_utility, linewidth=1, color="black")
        )

    def _render_ues_connected(self) -> None:
        time = np.arange(self.environment.time)
        ues_connected = self.environment.monitor.get_metric_history("connected_ues")
        self.removable_objects.extend(
            self.connected_ax.plot(time, ues_connected, linewidth=1, color="black")
        )

    def quit(self) -> None:
        pygame.quit()
        self.window = None
