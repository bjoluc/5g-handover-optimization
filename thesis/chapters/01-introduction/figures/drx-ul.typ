#import "/cetz.typ": canvas

#figure(caption: [UL Traffic Handling in a DRX Sleep Period], placement: none)[
  #canvas(length: 4cm, {
    import "/cetz.typ": *
    setupPlot("Time", [@ue Power], (3.1, 1.6), (25, 3.5))

    let brace = xBrace.with(amplitude: 0.25)

    moveBarStartAnchor(3)
    brace(3, 19, [@drx Cycle])

    brace(3, 5, [onDuration], y: 1, flip: false)
    bar([@pdcch], 1, width: 2)
    moveBarStartAnchor(3)

    bar([@pucch], 1.5)
    content("bar.north", [@sr], anchor: "south")

    bar([@pdcch], 1, width: 2)
    bar([@pusch], 2.5)
    bar([@pdcch], 1, width: 3)
    moveBarStartAnchor(4)

    content((7.5, 2.3), [@ul Grant], name: "ulGrant")
    brace(10, 15, [inactivityTimer], y: 2.6, flip: false)
    line("ulGrant.south-east", (10, 1))
    dashedLine("xBrace.start", (10, 1))
    dashedLine("xBrace.end", (15, 1))
    
    bar([@pdcch], 1, width: 2)
  })
]<figDrxUl>
