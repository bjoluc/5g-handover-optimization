#import "/cetz.typ": canvas

#figure(caption: [UE Activity over Several DRX Cycles], placement: auto)[
  #canvas(length: 4cm, {
    import "/cetz.typ": *
    setupPlot("Time", [@ue Power], (3.6, 1.25), (29, 2.75))

    let brace = xBrace.with(amplitude: 0.25)

    moveBarStartAnchor(3)

    brace(3, 13, [@drx Cycle $n$])
    brace(3, 6, [], y: 1, flip: false)
    content((4.5, 2), [onDuration], name: "onDuration", padding: 0.2em)
    line("xBrace.content", "onDuration.south")
    bar([@pdcch], 1, width: 3)
    moveBarStartAnchor(7)

    brace(13, 23, [@drx Cycle $n+1$])
    brace(13, 16, [], y: 1, flip: false)
    line("xBrace.content", "onDuration.south-east")

    brace(15, 19, [inactivityTimer], y: 2, flip: false)
    dashedLine("xBrace.end", (19, 1))
    bar([@pdcch], 1, width: 2)
    bar([@pdcch + @pdsch], 2)
    bar([@pdcch], 1, width: 3)
    moveBarStartAnchor(4)

    bar([@pdcch], 1, width: 3)
  })
]<figDrx>
