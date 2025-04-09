#import "/cetz.typ": canvas
#import "@preview/cetz-plot:0.1.1": plot
#import "./model.typ": handoverPower


#figure(caption: [Avg. Handover Power by UE Transmit Power], placement: auto)[
  #canvas({
    import "/cetz.typ": *

    set-style(
      axes: (stroke: .5pt, tick: (stroke: .5pt)),
    )

    plot.plot(size: (10, 5),
      x-label: [@ue @tx Power [dBm]],
      y-label: [$P_"Handover"$ [@pu]],
      x-tick-step: 5,
      y-tick-step: 20,
      y-min: 0,
      y-max: 100,
      {
        plot.add(
          handoverPower,
          domain: (0, 23),
          style: (stroke: black)
        )
      })
  })
] <figHandoverPowerPlot>
