#import "/cetz.typ": canvas

#figure(caption: [5G New Radio Frame Structure])[
  #canvas(length: 4cm, {
    import "/cetz.typ": *

    setStyle()

    let durationLine(from, to, label) = {
      line(from, to, mark: (symbol: ("|", "straight")), name: "durationLine")
      content("durationLine.50%", label, frame: "rect", stroke: none, fill: white)
    }


    let leftLabel(targetName, label) = {
      content((name: targetName, anchor: "west"), label, anchor: "east", padding: 1em)
    }

    set-viewport((0, 0), (2.5, -18em), bounds: (10, 10))

    // Frame
    durationLine((0, -0.5), (10, -0.5), [10 ms])
    rect((0, 0), (10 , 1), name: "frame")
    leftLabel("frame", [Frame])

    for x in range(1, 10) {
      line((x, 0), (x, 1), stroke: (dash: "dotted"))
    }

    for x in range(0, 10) {
      content((x + 0.5, 0.5), [#x])
    }

    // Subframe
    line("frame.north-west", (0, 2.25), stroke: (dash: "dashed"))
    line((1,1), (1, 1.25), (10, 2), (10, 2.25), stroke: (dash: "dashed"))

    durationLine((0, 2.5), (10, 2.5), [1 ms])
    rect((0, 3), (10 , 4), name: "subframe")
    leftLabel("subframe", [Subframe])

    // Slots
    let slot(from, to, name: "slot") = {
      rect(from, to, name: name)
      for symbolNo in range(1,14) {
        let x = from.at(0) + (to.at(0) - from.at(0)) / 14 * symbolNo
        line((x, from.at(1)), (x, to.at(1)), stroke: (dash: "dotted"))
      }
    }

    slot((0, 4.5), (10 , 5.5))
    leftLabel("slot", [1 Slot \@ 15 kHz SCS])

    slot((0, 6), (5 , 7), name: "slot30kHz")
    slot((5, 6), (10, 7))
    leftLabel("slot30kHz", [2 Slots \@ 30 kHz SCS])

    slot((0, 7.5), (2.5 , 8.5), name: "slot60kHz")
    slot((2.5, 7.5), (5, 8.5))
    slot((5, 7.5), (7.5, 8.5))
    slot((7.5, 7.5), (10, 8.5))
    leftLabel("slot60kHz", [4 Slots \@ 60 kHz SCS])

    xBrace(10, 7.5, [1 Slot = 14 Symbols], y: 8.5)
  })
]<figFrameStructure>
