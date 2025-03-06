from math import inf, log10, tanh

from simulator.environment.core.util import clip
from ue_power_model_5g import DrxConfig, TrafficPattern

default_drx = DrxConfig(320, 20, 100)


class Application:
    def __init__(
        self,
        name: str,
        traffic_pattern: TrafficPattern,
        desired_data_rate=inf,
    ):
        self.name = name
        self.traffic_pattern = traffic_pattern
        self.desired_data_rate = desired_data_rate

    def __str__(self):
        return f'Application("{self.name}")'

    def get_qoe_by_data_rate(self, data_rate: float):
        if data_rate <= 0.0:
            return -1

        # Log utility if desired data rate is infinite
        if self.desired_data_rate == inf:
            return clip(0.5 * log10(data_rate * 1e-6), -1, 1)

        # Scaled sigmoidal utility if desired data rate is definite
        k = 3
        return clip(
            tanh(k * (data_rate / self.desired_data_rate - 0.5)) / tanh(k / 2), -1, 1
        )


generic_data_heavy = Application(
    "Generic Data-Heavy Application",
    TrafficPattern(10, 10, default_drx),  # 100 pps
)
web_browsing = Application(
    "Browsing",
    TrafficPattern(250, 250, default_drx),  # 4 pps
    500e3,  # 500 Kbps
)
messaging = Application(
    "Messaging",
    TrafficPattern(1000, 1000, default_drx),  # 1 pps
    250e3,  # 250 Kbps
)
video_streaming = Application(
    "Streaming",
    TrafficPattern(10, 10, default_drx),  # 100 pps
)
