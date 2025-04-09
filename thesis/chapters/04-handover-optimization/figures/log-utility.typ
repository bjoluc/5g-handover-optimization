#import "/cetz.typ": canvas
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

#figure(
  caption: [Logarithmic UE Utility Function from @deepcomp2023], placement: auto,
)[
  #canvas({
    import "/cetz.typ": *

    set-style(
      axes: (stroke: .5pt, tick: (stroke: .5pt)),
    )

    plot.plot(size: (10, 5),
      x-label: [@ue Data Rate [Mbps]],
      y-label: [@ue @qoe],
      y-min: -1,
      y-max: 1,
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
