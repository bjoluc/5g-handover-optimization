#import "/cetz.typ": canvas
#import "./utils.typ": *

#figure(
  caption: [System State Example for Conflicting Data Rate and Power Consumption],
  placement: auto,
)[
  #canvas(length: 4cm, {
    import "/cetz.typ": setStyle
    setStyle()

    cell((-0.5,0), "a")
    cell((0.5,0), "b")

    ue((0.17,-0.2), ("a",))
    ue((0.35,0.3), ("b",))
    ue((0.8,-0.4), ("b",))
    ue((0.9,0.2), ("b",))
    ue((1.1,-0.1), ("b",))
  })
] <figTradeoffExample>
