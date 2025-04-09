#import "@preview/cetz:0.3.4": canvas, draw
#import "@preview/cetz-plot:0.1.1": plot

#figure(caption: [Comparison of QoE Probability Density Functions], placement: none)[
  #canvas({
    import draw: *

    set-style(
      axes: (stroke: .5pt, tick: (stroke: .5pt)),
      legend: (stroke: none, spacing: 0.25, fill: none)
    )

    plot.plot(size: (24, 10),
      x-label: [QoE],
      y-label: [PDF],
      legend: "inner-north-east",
      y-min:  0,
      y-max:  1.25,
      y-tick-step: 0.2,
      x-min: -1,
      x-max: 1,
      {
        plot.add(
          json("qoe-rsrp.json"),
          style: (stroke: (dash: "dotted")),
          label: [RSRP],
        )
        plot.add(
          json("qoe-rl.json"),
          style: (stroke: black),
          label: [RL],
        )
      })
  })
]
