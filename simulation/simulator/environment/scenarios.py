from simulator.environment.core.base_station import BaseStation
from simulator.environment.core.environment import BaseEnvironment
from simulator.environment.core.user_equipment import UserEquipment


class MComSmall(BaseEnvironment):
    def __init__(self, **kwargs):
        super().__init__(
            stations=[
                BaseStation(bs_id, position)
                for bs_id, position in enumerate([(110, 130), (65, 80), (120, 30)])
            ],
            ues=[UserEquipment(ue_id) for ue_id in range(5)],
            size=(200, 200),
            **kwargs
        )


class MComMedium(BaseEnvironment):
    def __init__(self, **kwargs):
        super().__init__(
            stations=[
                BaseStation(bs_id, position)
                for bs_id, position in enumerate(
                    [
                        (95, 240),
                        (100, 140),
                        (105, 60),
                        (35, 200),
                        (40, 95),
                        (165, 220),
                        (160, 110),
                    ]
                )
            ],
            ues=[UserEquipment(ue_id) for ue_id in range(15)],
            size=(200, 300),
            **kwargs
        )


class MComLarge(BaseEnvironment):
    def __init__(self, **kwargs):
        super().__init__(
            stations=[
                BaseStation(bs_id, position)
                for bs_id, position in enumerate(
                    [
                        (50, 100),
                        (60, 210),
                        (90, 60),
                        (120, 130),
                        (130, 215),
                        (140, 190),
                        (160, 70),
                        (200, 250),
                        (210, 135),
                        (230, 70),
                        (250, 240),
                        (255, 170),
                        (265, 50),
                    ]
                )
            ],
            ues=[UserEquipment(ue_id) for ue_id in range(30)],
            size=(300, 300),
            **kwargs
        )
