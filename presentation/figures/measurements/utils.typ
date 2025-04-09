#import "../utils.typ": cetz
#import "@preview/cetz-plot:0.1.1": plot

#let plotCurrentOverTime(
  data,
  yMax: 700,
  xTickStep: 0.1,
  yTickStep: 100,
  yMinorTickStep: 10,
  plotHeight: 7,
  plotWidth: 14,
  isSlotted: false,
  useMilliseconds: false,
  additionalPlotContent: {},
) = [
  #cetz.canvas({
    import cetz.draw: *

    set-style(
      axes: (
        stroke: .5pt,
        tick: (stroke: .5pt, length: 3.2pt, minor-length: 1.8pt),
        grid: (stroke: silver + 0.7pt),
      ),
      legend: (stroke: .5pt, fill: white, spacing: 0.25),
    )

    let xLabel = if useMilliseconds {$t space ["ms"]$} else {$t space [s]$}

    if useMilliseconds {
      data = data.map(((x,y)) => (x*1000, y))
    }

    plot.plot(size: (plotWidth, plotHeight),
      x-label: xLabel,
      x-tick-step: xTickStep,
      y-label: [$I space ["mA"]$],
      y-min: 0,
      y-max: yMax,
      y-tick-step: yTickStep,
      y-minor-tick-step: yMinorTickStep,
      legend: "inner-north-east",
      x-grid: true,
      y-grid: not isSlotted,
      {
        if isSlotted {
          plot.add-fill-between(
            data,
            (x) => 0,
            domain: (0, data.at(-1).at(0)),
            line: "hv",
            style: (
              fill: luma(250),
              stroke: (paint: black, thickness: .75pt)
            ),
          )
        } else {
          plot.add(data, style: (stroke: .5pt),)
        }
        additionalPlotContent
      }
    )
  })
]
