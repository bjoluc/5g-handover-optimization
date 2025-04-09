#import "/cetz.typ": canvas, draw
#import "@preview/cetz-plot:0.1.1": plot
#import "@preview/subpar:0.2.1"

#let makeSubFigure(
  metric,
  caption,
  yMin: auto,
  yMax: auto,
  yTickStep: auto,
  legend: none,
) = {
  figure(
    canvas({
      draw.set-style(
        axes: (stroke: .5pt, tick: (stroke: .5pt)),
        legend: (stroke: none, fill: none)
      )
      plot.plot(
        size: (6.5, 4),
        x-label: [Training Steps (millions)],
        x-tick-step: 0.1,
        y-label: caption,
        y-min: yMin,
        y-max: yMax,
        y-tick-step: yTickStep,
        legend: legend,
        {
          let sessions = (
            (
              file: "final-small-8ues-nopens_1",
              label: "Init",
              style: (
                stroke: (
                  dash: "dotted",
                )
              )
            ),
            (
              file: "final-small-8ues-novel_1",
              label: "Penalty",
              style: (
                stroke: (
                  paint: luma(180),
                  dash: "dotted",
                )
              )
            ),
            (
              file: "final-small-8ues-noglobalpen_1",
              label: "Pen. & SNR Vel.",
              style: (
                stroke: (
                  paint: luma(160),
                  thickness: 0.8pt,
                  dash: "dashed",
                )
              )
            ),
            (
              file: "final-small-8ues-nofair_1",
              label: "Collective Penalty",
              style: (
                stroke: (
                  paint: luma(140),
                  thickness: 0.8pt,
                  dash: "dash-dotted",
                )
              )
            ),
            (
              file: "final-small-8ues-nosugg_1",
              label: "Jain's fairness",
              style: (
                stroke: (
                  paint: luma(120),
                  thickness: 0.8pt,
                  dash: "densely-dash-dotted",
                )
              )
            ),
            (
              file: "final-small-8ues-nohps_1",
              label: "Better SNR Flag",
              style: (
                stroke: (
                  paint: luma(100),
                  thickness: 0.8pt,
                )
              )
            ),
            (
              file: "final-small-8ues-hps2_1",
              label: "HP Opt.",
              style: (
                stroke: (
                  paint: luma(0),
                  thickness: 0.8pt,
                )
              )
            ),
          )

          for session in sessions {
            let rawData = json(metric + "/" + session.file + ".json")
            plot.add(
              rawData.map(
                ((time, step, value)) => (step*10e-7, value)
              ),
              label: session.label,
              style: session.style,
              line: "spline",
            )
          }
        }
      )
    }),
    caption: caption,
  )
}

#subpar.grid(
  makeSubFigure(
    "connected-ues",
    "Connected UEs",
    yMin: 7.8,
    yTickStep: 0.05,
    legend: "inner-south-east",
  ), <a>,
  makeSubFigure(
    "mean-utility",
    "Mean Utility",
  ), <a>,
  makeSubFigure(
    "mean-data-rate",
    "Mean Data Rate [Mbps]",
    yMin: 8,
    yTickStep: 2,
  ), <a>,
  makeSubFigure(
    "mean-power",
    "Mean Power [PU]",
    yMax: 150,
    yMin:147,
    yTickStep: 1,
  ), <a>,
  columns: (1fr, 1fr),
  caption: [Training-Period Evaluation Metric Averages over Training Steps],
  label: <figRlSessions>,
  placement: auto,
)
