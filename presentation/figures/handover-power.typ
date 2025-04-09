#import "utils.typ": cetz, touying-cetz-canvas, pause

#figure()[
  #touying-cetz-canvas(length: 3cm, {
    import "/thesis/cetz.typ": *
    setupPlot("ms", [Power [PU]], (3.5, 1.5), (130, 3))

    drawXAxisLabels((
      (0, [0]),
      (50, [25]),
      (100, [50]),
    ), height: 6pt)

    drawYAxisLabels((
      (0, [0]),
      (1.0, [100]),
      (2.0, [200]),
    ), width: 90pt)

    let brace = xBrace.with(amplitude: 0.2, y: -0.5)
    let bwpScaling = 0.4 + 0.6 * (10 - 20) / 80

    let transmitBar() = bar([], 2.5)
    let receiveBar() = bar([], 3*bwpScaling)
    let pdcchBar(duration, label: []) = {
      bar(label, 0.5, width: duration, isTextHorizontal: true)
    }
    let microSleepBar(duration, label: []) = { 
      bar(label, 0.45, width: duration, isTextHorizontal: true)
    }

    bar([], 0.75, width: 20, isTextHorizontal: true)

    bar(align(center)[], 1.7*bwpScaling, width: 19, isTextHorizontal: true)
    receiveBar()

    microSleepBar(20)
    transmitBar()
    pdcchBar(4)
    receiveBar()

    microSleepBar(3)
    transmitBar()
    pdcchBar(40)
    receiveBar()

    bar([], 0.3 * 3.5)
    pdcchBar(1)
    microSleepBar(3)
    transmitBar()
  })
]
