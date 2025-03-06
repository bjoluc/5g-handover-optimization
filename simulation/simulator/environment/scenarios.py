from simulator.environment.core.base_station import BaseStation
from simulator.environment.core.environment import BaseEnvironment
from simulator.environment.core.user_equipment import UserEquipment


class MComSmall(BaseEnvironment):
    def __init__(self, **kwargs):
        super().__init__(
            stations=[
                BaseStation((110, 130)),
                BaseStation((65, 80)),
                BaseStation((120, 30)),
            ],
            ues=[UserEquipment() for _ in range(5)],
            size=(200, 200),
            **kwargs
        )


class MComMedium(BaseEnvironment):
    def __init__(self, **kwargs):
        super().__init__(
            stations=[
                BaseStation((95, 240)),
                BaseStation((100, 140)),
                BaseStation((105, 60)),
                BaseStation((35, 200)),
                BaseStation((40, 95)),
                BaseStation((165, 220)),
                BaseStation((160, 110)),
            ],
            ues=[UserEquipment() for _ in range(15)],
            size=(200, 300),
            **kwargs
        )


class MComLarge(BaseEnvironment):
    def __init__(self, **kwargs):
        super().__init__(
            stations=[
                BaseStation((50, 100)),
                BaseStation((60, 210)),
                BaseStation((90, 60)),
                BaseStation((120, 130)),
                BaseStation((130, 215)),
                BaseStation((140, 190)),
                BaseStation((160, 70)),
                BaseStation((200, 250)),
                BaseStation((210, 135)),
                BaseStation((230, 70)),
                BaseStation((250, 240)),
                BaseStation((255, 170)),
                BaseStation((265, 50)),
            ],
            ues=[UserEquipment() for _ in range(30)],
            size=(300, 300),
            **kwargs
        )
