#import "@preview/fletcher:0.5.6": diagram
#import "./utils.typ": *

#figure(
  caption: [Adapted Simulation Data Model],
  placement: auto,
)[
  #diagram(
    // debug: true,
    spacing: (1cm, 1cm),
    node-stroke: 0.5pt, {
      class("BaseStation", (0,0), (
        "+ schedule()",
      ))
      class("Scheduler", (-0.6,-0.7), (
        "+ update_data_rates(Connection[])",
      ))
      class("Channel", (-0.6,0.7), (
        "+ compute_snr(UserEquipment)",
      ))

      class("UserEquipment", (1,0), (
        "+ connect(BaseStation)",
        "+ disconnect(BaseStation)",
        "+ move()",
        "+ get_snr(BaseStation)",
        "+ estimate_power()",
        "+ get_utility()",
      ))
      class("Movement", (1,-1), (
        "+ position: (Float, Float)",
        "+ move()",
      ))

      class("Connection", (0.8,1), (
        "+ snr: Float",
        "+ maximal_data_rate: Float",
        "+ current_data_rate: Float",
      ))

      aggregates(<connection>, <userequipment>)
      aggregates(<connection>, <basestation>)
      composes(<userequipment>, <movement>)
      composes(<basestation>, <scheduler>)
      composes(<basestation>, <channel>)
      calls(<userequipment>, <channel>)
      calls(<userequipment>, <basestation>)
    }
  )
] <figNewModelUml>
