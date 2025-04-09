#import "@preview/cetz:0.3.4": canvas, draw
#import "@preview/cetz-plot:0.1.1": plot

#let logUtility(dataRate) = {
  let utility = 0.5 * calc.log(dataRate, base: 10)
  if utility < -1 {
    return -1
  }
  if utility > 1 {
    return 1
  }
  return utility
}

#figure(caption: [Logarithmic UE Utility Function @deepcomp2023])[
  #canvas({
    import draw: *

    set-style(
      axes: (stroke: .5pt, tick: (stroke: .5pt)),
    )

    plot.plot(size: (10, 5),
      x-label: [Data Rate [Mbps]],
      y-label: [QoE],
      y-min: -1,
      y-max: 1,
      y-tick-step: 1,
      x-tick-step: 20,
      {
        plot.add(
          logUtility,
          domain: (0.0001, 100),
          samples: 300,
          style: (stroke: black)
        )
      })
  })
] <figLogUtility>
