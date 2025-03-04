import numpy as np


class AbstractTimer:
    def _on_timer_expired(self):
        pass

    def __init__(self):
        self._timer_value = 0

    def is_running(self):
        return self._timer_value > 0

    def step(self):
        """
        Advances the timer and returns True if it expires, False otherwise
        """
        if self.is_running():
            self._timer_value -= 1
            if self._timer_value == 0:
                self._on_timer_expired()
                return True

        return False


class Timer(AbstractTimer):
    def __init__(self, duration: int):
        super().__init__()
        self._duration = duration

    def set(self):
        self._timer_value = self._duration


class PoissonArrivals(AbstractTimer):
    def _sample_iat(self):
        self._timer_value = max(round(np.random.exponential(scale=self._iat)), 1)

    def _on_timer_expired(self):
        self._sample_iat()

    def __init__(self, iat: int):
        super().__init__()
        self._iat = iat
        self._sample_iat()


class UE:
    def __init__(
        self,
        iat_ul: int,
        iat_dl: int,
        on_duration: int,
        inactivity_timer: int,
    ):
        self._on_duration_timer = Timer(on_duration)
        self._inactivity_timer = Timer(inactivity_timer)
        self._ul_arrivals = PoissonArrivals(iat_ul)
        self._dl_arrivals = PoissonArrivals(iat_dl)

        self.is_active = True
        self._is_dl_packet_buffered_at_bs = False

    def start_new_cycle(self):
        # On duration starts in this slot
        self._on_duration_timer.set()
        self.is_active = True

        # UE receives buffered DL traffic, if any
        if self._is_dl_packet_buffered_at_bs:
            self._inactivity_timer.set()
            self._is_dl_packet_buffered_at_bs = False

    def step(self):
        does_on_duration_timer_expire = self._on_duration_timer.step()
        does_inactivity_timer_expire = self._inactivity_timer.step()
        does_ul_packet_arrive = self._ul_arrivals.step()
        does_dl_packet_arrive_at_bs = self._dl_arrivals.step()

        # Handle on duration and inactivity timer expiry
        if (does_on_duration_timer_expire or does_inactivity_timer_expire) and not (
            self._inactivity_timer.is_running() or self._on_duration_timer.is_running()
        ):
            self.is_active = False

        if does_ul_packet_arrive:
            if not self.is_active:
                self.is_active = True

                # UE receives any buffered DL traffic too:
                self._is_dl_packet_buffered_at_bs = False

            self._inactivity_timer.set()

        if does_dl_packet_arrive_at_bs:
            if self.is_active:
                self._inactivity_timer.set()
            else:
                self._is_dl_packet_buffered_at_bs = True


def estimate_activity_probabilities(
    cycles: int,
    cycle_duration: int,
    on_duration: int,
    inactivity_timer: int,
    iat_ul: int,
    iat_dl: int,
):
    """
    All times are provided as number of slots (0.5ms)
    """
    ue = UE(iat_ul, iat_dl, on_duration, inactivity_timer)
    slot_activities = np.zeros(cycle_duration)

    for _ in range(cycles):
        ue.start_new_cycle()
        for slot in range(cycle_duration):
            ue.step()
            if ue.is_active:
                slot_activities[slot] += 1

    return slot_activities / cycles


def estimate_sleep_ratio(
    cycles: int,
    cycle_duration: int,
    on_duration: int,
    inactivity_timer: int,
    iat_ul: int,
    iat_dl: int,
):
    """
    Returns a tuple of the sleep ratio and the average number of sleep periods per DRX
    cycle.

    All times are provided as number of slots (0.5ms).
    """
    sleep_periods_count = 0
    sleep_slots = 0

    ue = UE(iat_ul, iat_dl, on_duration, inactivity_timer)
    was_ue_active_in_previous_slot = True

    for _ in range(cycles):
        ue.start_new_cycle()
        for _ in range(cycle_duration):
            ue.step()
            if ue.is_active:
                if not was_ue_active_in_previous_slot:
                    was_ue_active_in_previous_slot = True
            else:
                sleep_slots += 1
                if was_ue_active_in_previous_slot:
                    sleep_periods_count += 1
                    was_ue_active_in_previous_slot = False

    return (
        sleep_slots / (cycles * cycle_duration),
        sleep_periods_count / cycles,
    )
