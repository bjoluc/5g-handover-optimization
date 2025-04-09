#import "@preview/cetz:0.3.4"
#import "utils.typ": *
#import "../utils.typ": touying-cetz-canvas, pause, utils

#let animatedHandoversFigure(self) = [
  #let (uncover, only) = utils.methods(self)

  #figure(caption: [Handover Example])[
    #touying-cetz-canvas(length: 7.5cm, {
      import "/thesis/cetz.typ": setStyle
      setStyle()

      cell((-0.5,0), "a")
      cell((0.5,0), "b")

      only(2, ue((-0.4,0.4), ("a",)))
      only(3, ue((0,0.1), ("a",)))
      only(4, ue((0,0.1), ("b",)))
      only(5, ue((0.4,0.4), ("b",)))
    })
  ]
]