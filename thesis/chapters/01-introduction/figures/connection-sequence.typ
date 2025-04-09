#import "/cetz.typ": canvas

#figure(caption: [Synchronization and RRC Connection Sequence @synchronizationProcedure2019 @3gppRRCProtocol2024], placement: auto)[
  #canvas(length: 4cm, {
    import "/cetz.typ": *

    setStyle()

    let message(from, to, label, angle: 0deg) = {
      line(from, to, name: "message", mark: (end: "stealth"))
      content(
        ("message.end", 50%, "message.start"),
        anchor: "south",
        angle: angle,
        label
      )
    }

    let a2b(time, label) = {
      message((0, time), (1, time + 0.5), label, angle: -5deg)
    }

    let b2a(time, label) = {
      message((1, time), (0, time + 0.5), label, angle: 5deg)
    }

    line((0, 0), (0, 3.75))
    UE((), anchor: "south")

    line((2, 0), (2, 3.75))
    gNB((), anchor: "south")

    set-viewport((0, 3.75), (2, 0), bounds: (1, 10))

    b2a(0.25, [@ssb])
    b2a(1, [@mib (@pbch)])
    b2a(1.75, [#[@sib]1 (@pdsch)])
    a2b(2.875, [Random Access Preamble (@prach)])
    b2a(4, [Random Access Response (@pdcch, @pdsch)])
    a2b(5, [@rrc Setup Request (@pusch)])
    b2a(6, [@rrc Setup (@pdcch, @pdsch)])
    a2b(7, [@sr (@pucch)])
    b2a(8, [@ul Grant (@pdcch)])
    a2b(9, [@rrc Setup Complete (@pusch)])
  })
]<figConnectionSequence>
