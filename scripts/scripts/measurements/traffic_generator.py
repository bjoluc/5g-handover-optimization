import json
import logging
import socket
import threading
import time
from contextlib import contextmanager
from typing import Callable

import numpy as np

random_number_generator = np.random.default_rng()

UDP_PORT = 33098

logger = logging.getLogger(__name__)


@contextmanager
def udp_socket(ip):
    logger.debug(f"Binding UDP port {ip}:{UDP_PORT}")
    my_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    my_socket.bind((ip, UDP_PORT))

    yield my_socket

    logger.debug(f"Releasing UDP port {ip}:{UDP_PORT}")
    my_socket.close()


def receiver(socket, on_data_packet_received: Callable = None):
    logger.info("Starting receiver")

    while True:
        packet, address = socket.recvfrom(1024)  # buffer size is 1024 bytes

        if packet.startswith(bytes("{", "utf8")):
            request = json.loads(packet)
            logger.info(
                f"Received traffic request from {address[0]}:{address[1]}: {request}"
            )
            threading.Thread(
                target=sender,
                args=[
                    socket,
                    address,
                    request["duration"],
                    request["size"],
                    request["iat"],
                    request["randomize_iats"],
                ],
            ).start()

        else:
            if on_data_packet_received is not None:
                on_data_packet_received()
            else:
                logger.info(
                    f"Received data packet from {address[0]}:{address[1]}: {len(packet)} bytes"
                )


def sender(socket, target_address, duration=10, size=32, iat=1, randomize_iats=True):
    logger.debug(f"Starting sender with target {target_address[0]}:{target_address[1]}")

    end_time = time.time() + duration

    while time.time() < end_time:
        time.sleep(np.random.exponential(iat) if randomize_iats else iat)
        socket.sendto(b"\0" + random_number_generator.bytes(size - 1), target_address)

    logger.debug("Sender finished")


def send_traffic_request(
    socket, target_ip, duration=10, size=32, iat=1, randomize_iats=True
):
    logger.debug(f"Sending traffic request to {target_ip}:{UDP_PORT}")
    socket.sendto(
        bytes(
            json.dumps(
                {
                    "duration": duration,
                    "size": size,
                    "iat": iat,
                    "randomize_iats": randomize_iats,
                }
            ),
            "utf8",
        ),
        (target_ip, UDP_PORT),
    )


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    received_packets_count = 0

    def on_packet_received():
        global received_packets_count
        received_packets_count += 1
        logger.info(f"Received {received_packets_count} packets")

    with udp_socket("0.0.0.0") as socket:
        receiver_thread = threading.Thread(
            target=receiver, args=[socket, on_packet_received]
        )
        receiver_thread.start()

        send_traffic_request(
            socket, "45.136.30.120", iat=0.01, duration=10, randomize_iats=True
        )

        try:
            receiver_thread.join()
        except KeyboardInterrupt:
            pass
