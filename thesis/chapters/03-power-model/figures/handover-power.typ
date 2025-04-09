#import "/cetz.typ": canvas

#figure(caption: [UE Power Consumption for Sync. and RRC Connection Establishment], placement: auto)[
  #canvas(length: 4cm, {
    import "/cetz.typ": *
    setupPlot("Time [ms]", [Power [@pu]], (3.3, 1.25), (124, 3))

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
    let section(from, to, label) = {
      line(
        (from, -0.5),
        (to,-0.5),
        mark: (start: "|", end: "|", scale: 2),
        name: "section",
      )
      content("section", label, anchor: "north", padding: 1em)
    }

    let transmitBar() = bar([], 2.5)
    let receiveBar() = bar([], 3*bwpScaling)
    let pdcchBar(duration, label: []) = {
      bar(label, 0.5, width: duration, isTextHorizontal: true)
    }
    let microSleepBar(duration, label: []) = { 
      bar(label, 0.45, width: duration, isTextHorizontal: true)
    }

    section(0, 20, [Sync, @mib])
    bar([1 @ssb], 0.75, width: 20, isTextHorizontal: true)

    section(20, 40, [@sib 1])
    bar(align(center)[@pdcch, \ #v(-0.7em) 2@ssb:pl], 1.7*bwpScaling, width: 19, isTextHorizontal: true)
    receiveBar()

    section(40, 66, [Rand. Access])
    microSleepBar(20, label: [Micro Sleep])
    transmitBar()
    pdcchBar(4)
    receiveBar()

    section(66, 111, [@rrc Setup])
    microSleepBar(3)
    transmitBar()
    pdcchBar(40, label: [@pdcch])
    receiveBar()

    section(111, 117, [Compl.])
    bar([], 0.3 * 3.5)
    pdcchBar(1)
    microSleepBar(3)
    transmitBar()
  })
] <figHandoverPower>
