#import "@preview/cetz:0.3.4": canvas, draw
#import "@preview/cetz-plot:0.1.1": plot
#import "/thesis/chapters/03-power-model/figures/model/model.typ": handoverPower

#figure()[
  
  #canvas({
    import draw: *

    set-style(
      axes: (stroke: .5pt, tick: (stroke: .5pt)),
    )

    plot.plot(size: (11.75, 4.5),
      x-label: [UE Tx Power [dBm]],
      y-label: [Power [PU]],
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
]
