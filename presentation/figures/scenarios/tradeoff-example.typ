#import "@preview/cetz:0.3.4"
#import "utils.typ": *

#figure(caption: [Example for Conflicting Data Rate and Power Consumption])[
  #cetz.canvas(length: 7.5cm, {
    import "/thesis/cetz.typ": setStyle
    setStyle()

    cell((-0.5,0), "a")
    cell((0.5,0), "b")

    ue((0.17,-0.2), ("a",))
    ue((0.35,0.3), ("b",))
    ue((0.8,-0.4), ("b",))
    ue((0.9,0.2), ("b",))
    ue((1.1,-0.1), ("b",))
  })
]
