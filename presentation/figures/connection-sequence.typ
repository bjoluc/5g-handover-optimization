#import "utils.typ": cetz, touying-cetz-canvas, pause

#figure(caption: [Connection Sequence @synchronizationProcedure2019 @3gppRRCProtocol2024])[
  #touying-cetz-canvas(length: 4cm, {
    import "/thesis/cetz.typ": *

    setStyle()

    let message(from, to, label, angle: 0deg) = {
      line(from, to, name: "message", mark: (end: "stealth"))
      content(
        ("message.end", 50%, "message.start"),
        anchor: "south",
        padding: 0.1em,
        angle: angle,
        label
      )
    }

    let a2b(time, label) = {
      message((0, time), (1, time + 0.5), label, angle: -4deg)
    }

    let b2a(time, label) = {
      message((1, time), (0, time + 0.5), label, angle: 4deg)
    }

    line((0, 0), (0, 3))
    UE((), anchor: "south")

    line((2, 0), (2, 3))
    gNB((), anchor: "south")

    set-viewport((0, 3), (2, 0), bounds: (1, 10))

    b2a(0.25, [SSB])
    b2a(1, [MIB])
    b2a(1.75, [SIB1])
    a2b(2.875, [Random Access Preamble])
    b2a(4, [Random Access Response])
    a2b(5, [RRC Setup Request])
    b2a(6, [RRC Setup])
    a2b(7, [Scheduling Request])
    b2a(8, [UL Grant])
    a2b(9, [RRC Setup Complete])
  })
]<figConnectionSequence>
