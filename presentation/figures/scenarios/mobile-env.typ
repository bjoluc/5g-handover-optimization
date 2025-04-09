#import "@preview/cetz:0.3.4"
#import "utils.typ": *

#figure(caption: [Example `mobile-env` Scenario\ (Two BSs, Five UEs)])[
  #cetz.canvas(length: 5.5cm, {
    import "/thesis/cetz.typ": setStyle
    setStyle()

    cell((-0.5,0), "a")
    cell((0.5,0), "b")

    ue((-0.9,-0.05), ("a",))
    ue((-0.07,0.3), ("a", "b"))
    ue((0.1,-0.25), ("a", "b"))
    ue((0.55,0.5), ("b",))
    ue((1,-0.1), ("b",))
  })
]
