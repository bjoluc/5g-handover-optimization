# Inspired by the setup at
# https://gitlab.freedesktop.org/mobile-broadband/libqmi/-/blob/23f3c070c69f940c3ecb1c599b13fd1289bcc1c1/examples/simple-tester-python/simple-tester-python

# libqmi GLib docs at https://www.freedesktop.org/software/libqmi/libqmi-glib/1.34.0/

import logging
from functools import reduce
from operator import ior
from pathlib import Path
from time import sleep
from typing import Any, Callable, List, Literal

import gi

gi.require_version("Qmi", "1.0")
from contextlib import contextmanager

from gi.repository import Gio, GLib, Qmi

logger = logging.getLogger(__name__)

main_loop = GLib.MainLoop()

TIMEOUT = 5  # s


def combinde_flags(flags):
    return reduce(ior, flags)


def decode_plmn(bcd: bytes):
    # Based on
    # https://gitlab.freedesktop.org/mobile-broadband/libqmi/-/blob/main/src/qmicli/qmicli-nas.c?ref_type=heads#L3120
    bcd_chars = "0123456789*#abc\0\0"

    return "".join(
        [bcd_chars[byte & 0xF] + bcd_chars[(byte >> 4) & 0xF] for byte in bcd]
    ).replace("\0", "")


@contextmanager
def error_prefix(prefix: str):
    try:
        yield
    except GLib.GError as error:
        error.message = f"{prefix}: {error.message}"
        raise error


def run_qmi_call(
    runner: Callable[[Callable], Any],
    callback: Callable = lambda unused1, result, unused2: result,
) -> Any:
    callback_result = None

    def enhanced_callback(*args, **kwargs):
        nonlocal callback_result

        try:
            callback_result = callback(*args, **kwargs)
        finally:
            main_loop.quit()

    runner(enhanced_callback)
    main_loop.run()

    return callback_result


class QmiDevice:
    def __init__(self, path: str):
        if not Path(path).exists():
            raise Exception(f"Device {path} does not exist.")

        with error_prefix("Couldn't create QMI device"):
            file = Gio.File.new_for_path(path)
            self._device = Qmi.Device.new_finish(
                run_qmi_call(
                    lambda callback: Qmi.Device.new(file, None, callback, None),
                )
            )

    def __enter__(self):
        with error_prefix("Couldn't open QMI device"):
            self._device.open_finish(
                run_qmi_call(
                    lambda callback: self._device.open(
                        Qmi.DeviceOpenFlags.NET_RAW_IP
                        | Qmi.DeviceOpenFlags.NET_NO_QOS_HEADER,
                        TIMEOUT,
                        None,
                        callback,
                        None,
                    ),
                )
            )

        return self

    def __exit__(self, type, value, traceback):
        with error_prefix("Couldn't close QMI device"):
            self._device.close_finish(
                run_qmi_call(
                    lambda callback: self._device.close_async(
                        TIMEOUT, None, callback, None
                    )
                )
            )

    def allocate_client(self, qmi_service):
        with error_prefix("Couldn't allocate QMI client"):
            return self._device.allocate_client_finish(
                run_qmi_call(
                    lambda callback: self._device.allocate_client(
                        qmi_service, Qmi.CID_NONE, TIMEOUT, None, callback, None
                    ),
                )
            )

    def release_client(self, qmi_client):
        with error_prefix("Couldn't release QMI client"):
            self._device.release_client_finish(
                run_qmi_call(
                    lambda callback: self._device.release_client(
                        qmi_client,
                        Qmi.DeviceReleaseClientFlags.RELEASE_CID,
                        TIMEOUT,
                        None,
                        callback,
                        None,
                    )
                )
            )

    def get_wwan_interface(self):
        return self._device.get_wwan_iface()


class BaseClient:
    def __init__(self, device: QmiDevice, qmi_service):
        self._device = device
        self._client = self._device.allocate_client(qmi_service)

    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        self._device.release_client(self._client)

    def _perform_call(self, method_name: str, input=None):
        result = getattr(self._client, f"{method_name}_finish")(
            run_qmi_call(
                lambda callback: getattr(self._client, method_name)(
                    input, TIMEOUT, None, callback, None
                )
            )
        )
        result.get_result()

        return result


class PinVerificationError(Exception):
    pass


# User Identity Module Client
class UimClient(BaseClient):
    def __init__(self, device):
        super().__init__(device, Qmi.Service.UIM)

    def get_pin_state(self, pin_id: Literal[1, 2] = 1):
        status = self._perform_call("get_card_status").get_card_status()
        primary_slot = status.value_card_status_cards_ptr[
            status.value_card_status_index_gw_primary
        ]
        pin_state = getattr(primary_slot.applications[0], f"pin{pin_id}_state")

        return pin_state.get_string(pin_state)

    def is_pin_verified(self) -> bool:
        """
        Returns whether at least one PIN is verified (PIN 1 or PIN 2).
        """
        return (
            self.get_pin_state(1) == "enabled-verified"
            or self.get_pin_state(2) == "enabled-verified"
        )

    def verify_pin(self, pin: str):
        """
        Verifies PIN 1 with the given PIN string. If PIN 1 is disabled, verifies PIN 2
        instead.
        """
        pin_id = 2 if self.get_pin_state(1) == "disabled" else 1
        input = Qmi.MessageUimVerifyPinInput()
        input.set_info(Qmi.UimPinId(pin_id), pin)
        input.set_session(Qmi.UimSessionType.CARD_SLOT_1, [])

        self._perform_call("verify_pin", input)

    def try_pins(self, pins: List[str]):
        """
        Attempts PIN verification with all of the provided PINs until a PIN is verified
        successfully or all PINs have been tried.
        """
        is_pin_verified = False
        error_messages = []
        for pin in pins:
            try:
                self.verify_pin(pin)
                is_pin_verified = True
                break
            except GLib.GError as error:
                error_messages.append(f"PIN {pin} didn't work: {error}")
                pass

        if not is_pin_verified:
            raise PinVerificationError(
                "Pin not verified.\n" + "\n".join(error_messages)
            )


# Network Access Service
class NasClient(BaseClient):
    def __init__(self, device):
        super().__init__(device, Qmi.Service.NAS)

    def get_technology_preference(self) -> str:
        return Qmi.NasRadioTechnologyPreference.build_string_from_mask(
            self._perform_call("get_technology_preference")
            .get_active()
            .value_active_technology_preference
        )

    def get_system_selection_preference(self):
        # https://www.freedesktop.org/software/libqmi/libqmi-glib/1.34.0/libqmi-glib-NAS-Get-System-Selection-Preference-response.html
        return self._perform_call("get_system_selection_preference")

    def get_mode_preference(self) -> List[str]:
        return Qmi.NasRatModePreference.build_string_from_mask(
            self.get_system_selection_preference().get_mode_preference()
        ).split(", ")

    def set_mode_preference(
        self,
        modes: List[Literal["umts", "lte", "5gnr"]],
    ):
        input = Qmi.MessageNasSetSystemSelectionPreferenceInput()
        input.set_mode_preference(
            combinde_flags(
                [getattr(Qmi.NasRatModePreference, mode.upper()) for mode in modes]
            )
        )

        self._perform_call("set_system_selection_preference", input)

    def get_lte_cell_info(self):
        try:
            cell_info = self._perform_call("get_cell_location_info")
            lte_cell_info = cell_info.get_intrafrequency_lte_info_v2()
        except GLib.GError:
            return None

        cells = lte_cell_info.value_intrafrequency_lte_info_v2_cell_ptr
        primary_cell = cells[0]

        try:
            nr_arfcn = cell_info.get_nr5g_arfcn()
        except GLib.GError:
            nr_arfcn = None

        return {
            "mode": "LTE",
            "cid": lte_cell_info.value_intrafrequency_lte_info_v2_serving_cell_id,
            "rsrq": round(primary_cell.rsrq * 0.1, 1),  # db
            "rsrp": round(primary_cell.rsrp * 0.1, 1),  # dbm
            "rssi": round(primary_cell.rssi * 0.1, 1),  # dbm
            "global_cell_id": lte_cell_info.value_intrafrequency_lte_info_v2_global_cell_id,
            "plmn": decode_plmn(lte_cell_info.value_intrafrequency_lte_info_v2_plmn),
            "ca_cell_count": len(cells),
            "nr_arfcn": nr_arfcn,
        }

    def get_5g_cell_info(self):
        try:
            cell_info = self._perform_call("get_cell_location_info")
            nr_cell_info = cell_info.get_nr5g_cell_information()
        except GLib.GError:
            return None

        return {
            "mode": "5G",
            "cid": nr_cell_info.value_nr5g_cell_information_physical_cell_id,
            "rsrq": nr_cell_info.value_nr5g_cell_information_rsrq * 0.1,  # db
            "rsrp": nr_cell_info.value_nr5g_cell_information_rsrp * 0.1,  # dbm
            "snr": nr_cell_info.value_nr5g_cell_information_snr * 0.1,  # db
            "global_cell_id": nr_cell_info.value_nr5g_cell_information_global_cell_id,
            "plmn": decode_plmn(nr_cell_info.value_nr5g_cell_information_plmn),
            "arfcn": cell_info.get_nr5g_arfcn(),
        }

    def get_active_bands(self):
        try:
            band_info = self._perform_call("get_rf_band_information")
        except GLib.GError:
            return None

        return {
            "channels": [
                {
                    "channel": info.active_channel,
                    "band": Qmi.NasActiveBand.get_string(info.active_band_class),
                }
                for info in band_info.get_extended_list()
            ],
            "bandwidths": [
                Qmi.NasDLBandwidth.get_string(bandwidth.bandwidth)
                for bandwidth in band_info.get_bandwidth_list()
            ],
        }

    def get_signal_info(self):
        return {
            "cell": self.get_5g_cell_info() or self.get_lte_cell_info(),
            "bands": self.get_active_bands(),
        }


# Wireless Data Service
class WdsClient(BaseClient):
    def __init__(self, device):
        super().__init__(device, Qmi.Service.WDS)

    def _get_default_profile_number(self) -> int:
        input = Qmi.MessageWdsGetDefaultProfileNumberInput()
        input.set_profile_type(
            getattr(Qmi.WdsProfileType, "3GPP"), Qmi.WdsProfileFamily.EMBEDDED
        )

        return self._perform_call("get_default_profile_number", input).get_index()

    def start_network(self) -> int:
        input = Qmi.MessageWdsStartNetworkInput()
        input.set_profile_index_3gpp(self._get_default_profile_number())
        input.set_ip_family_preference(Qmi.WdsIpFamily.IPV4)
        input.set_enable_autoconnect(False)

        return self._perform_call("start_network", input).get_packet_data_handle()

    def stop_network(self, packet_data_handle: int):
        input = Qmi.MessageWdsStopNetworkInput()
        input.set_packet_data_handle(packet_data_handle)
        input.set_disable_autoconnect(True)

        self._perform_call("stop_network", input)

    def get_dormancy_status(
        self,
    ) -> Literal["unknown", "traffic-channel-dormant", "traffic-channel-active"]:
        return Qmi.WdsDormancyStatus.get_string(
            self._perform_call("get_dormancy_status").get_dormancy_status()
        )

    def go_active(self):
        self._perform_call("go_active")

    def go_dormant(self):
        self._perform_call("go_dormant")


class NetworkConnection:
    def __init__(self, wds_client: WdsClient):
        self._wds_client = wds_client

    def __enter__(self):
        self._packet_data_handle: int = None
        while self._packet_data_handle is None:
            try:
                self._packet_data_handle = self._wds_client.start_network()
            except GLib.GError as error:
                if "'CallFailed'" in error.message:
                    logger.warning("Couldn't register to network, retrying in 1 s")
                sleep(5)

        return self

    def __exit__(self, type, value, traceback):
        self._wds_client.stop_network(self._packet_data_handle)

    def is_dormant(self):
        return self._wds_client.get_dormancy_status() == "traffic-channel-dormant"

    def go_active(self):
        self._wds_client.go_active()

    def go_dormant(self):
        self._wds_client.go_dormant()


class UnlockedQmiDevice(QmiDevice):
    """
    A QmiDevice that automatically verifies its SIM PIN (given a list of possible PINs)
    and sets its mode preference.
    """

    def __init__(
        self,
        path,
        sim_pins: List[str],
        mode_preference: List[Literal["umts", "lte", "5gnr"]],
    ):
        super().__init__(path)
        self._sim_pins = sim_pins
        self._mode_preference = mode_preference

    def __enter__(self):
        super().__enter__()

        with UimClient(self) as client:
            if not client.is_pin_verified():
                logger.debug("Verifying PIN")
                client.try_pins(self._sim_pins)

        with NasClient(self) as client:
            if set(client.get_mode_preference()) != set(self._mode_preference):
                logger.warning(
                    f"Changing mode preference to {self._mode_preference}. Please restart the device."
                )
                client.set_mode_preference(self._mode_preference)
                exit(0)

        return self

    def get_signal_info(self):
        """
        Shortcut to create a NAS client and call its `get_signal_info` method.
        """
        with NasClient(self) as client:
            return client.get_signal_info()


if __name__ == "__main__":
    with QmiDevice("/dev/cdc-wdm1") as device:
        with UimClient(device) as client:
            print("is_pin_verified:", client.is_pin_verified())
