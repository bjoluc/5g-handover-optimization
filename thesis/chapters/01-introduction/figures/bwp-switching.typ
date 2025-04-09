#import "/cetz.typ": canvas

#figure(caption: [BWP Switching Example @primerOnBandwidthParts], placement: auto)[
  #canvas(length: 4cm, {
    import "/cetz.typ": *

    let bwp = labeledRect

    let xBrace = xBrace.with(amplitude: 0.75)

    setupPlot("Time", "Frequency", (3, 1.4), (10, 12))

    yBrace(8, 9, [24 @rb:pl])
    yBrace(0, 5, [120 @rb:pl])

    bwp(0, 1, 8 + 4/24, 9, [@ssb])
    xBrace(0, 1, [Sync., \ @mib])

    bwp(1, 3, 8, 9, [Coreset \#0])
    xBrace(1, 3, [#[@sib]1])

    bwp(3, 5, 8, 9, [@dl @bwp \#0])
    bwp(3, 5, 2, 3, [@ul @bwp \#0])
    xBrace(3, 5, [Connection \ Establishment])

    bwp(5, 7, 6, 11, [@dl @bwp \#1])
    bwp(5, 7, 0, 5, [@ul @bwp \#1])
    xBrace(5, 7, [Data \ Transfer])

    bwp(7, 9, 7.5, 9.5, [@dl @bwp \#2])
    bwp(7, 9, 0, 5, [@ul @bwp \#1])
    xBrace(7, 9, [Inactivity \ Timer \ Expired])
  })
]<figBwpSwitching>
