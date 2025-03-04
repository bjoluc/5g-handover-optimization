import logging
import re
import subprocess
from contextlib import ExitStack
from threading import Thread
from time import sleep

from scripts.measurements.qmi import NetworkConnection, UnlockedQmiDevice, WdsClient
from scripts.measurements.traffic_generator import (
    UDP_PORT,
    send_traffic_request,
    sender,
    udp_socket,
)

logger = logging.getLogger(__name__)


def obtain_ip_address(wwan_interface: str):
    udhcpc_output = subprocess.check_output(
        ["sudo", "udhcpc", "-q", "-f", "-n", "-i", wwan_interface],
        text=True,
        stderr=subprocess.STDOUT,
    )

    ip = re.search("udhcpc: lease of ([\d\.]+) obtained|$", udhcpc_output).group(1)
    assert ip != ""

    return ip


class TrafficScenario(ExitStack):
    def __init__(
        self,
        device: UnlockedQmiDevice,
        duration=4,
        stabilization_time=0.5,
        iat_ul=None,  # s
        iat_dl=None,  # s
        randomize_iats=True,
        packet_size_ul=32,
        packet_size_dl=32,
        traffic_generator_ip="",  # (IPv4) – deploy your own instance (traffic_generator.py) (:
    ):
        super().__init__()
        self._device = device
        self._traffic_generator_ip = traffic_generator_ip
        self.parameters = {
            "duration": duration,
            "stabilization_time": stabilization_time,
            "iat_ul": iat_ul,
            "iat_dl": iat_dl,
            "randomize_iats": randomize_iats,
            "packet_size_ul": packet_size_ul,
            "packet_size_dl": packet_size_dl,
        }
        self.condition = {**self.parameters}

        self.connection: NetworkConnection = None

    def __enter__(self):
        super().__enter__()
        wds_client = self.enter_context(WdsClient(self._device))
        self.connection = self.enter_context(NetworkConnection(wds_client))

        wwan_interface = self._device.get_wwan_interface()
        ip = obtain_ip_address(wwan_interface)

        self.condition["signal"] = self._device.get_signal_info()

        # Add outgoing IP route for generated traffic
        subprocess.run(
            [
                "sudo",
                "ip",
                "route",
                "add",
                self._traffic_generator_ip,
                "dev",
                wwan_interface,
            ],
            capture_output=True,
            check=True,
        )

        socket = self.enter_context(udp_socket("0.0.0.0"))

        duration = self.parameters["stabilization_time"] + self.parameters["duration"]

        if self.parameters["iat_dl"] is not None:
            send_traffic_request(
                socket,
                self._traffic_generator_ip,
                duration,
                size=self.parameters["packet_size_dl"],
                iat=self.parameters["iat_dl"],
                randomize_iats=self.parameters["randomize_iats"],
            )

        def run():
            if self.parameters["iat_ul"] is not None:
                sender(
                    socket,
                    (self._traffic_generator_ip, UDP_PORT),
                    duration,
                    size=self.parameters["packet_size_ul"],
                    iat=self.parameters["iat_ul"],
                    randomize_iats=self.parameters["randomize_iats"],
                )
            else:
                sleep(duration)

        logger.debug("Running traffic scenario")
        self._thread = Thread(target=run)
        self._thread.start()

        sleep(self.parameters["stabilization_time"])

        return self

    def __exit__(self, *args):
        self._thread.join()
        logger.debug("Traffic scenario completed")

        try:
            subprocess.run(
                ["sudo", "ip", "route", "delete", self._traffic_generator_ip],
                capture_output=True,
                check=True,
            )
        except subprocess.CalledProcessError:
            logger.warning(
                "Failed to delete outgoing traffic generator route. It seems the interface has gone down.",
            )

        return super().__exit__(*args)
