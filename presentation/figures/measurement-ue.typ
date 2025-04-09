#import "utils.typ": cetz, touying-cetz-canvas, pause, utils

#let animatedUeFigure(self) = [
  #let (uncover, only) = utils.methods(self)

  #figure(caption: [UE Hardware])[
    #touying-cetz-canvas(length: 7.5cm, {
      import "/thesis/cetz.typ": *
      setStyle()

      rect((-1, -.6),(1, .6), name: "hat")
      content("hat.south", [Waveshare SIM8202G-M2 5G HAT], anchor: "south", padding: 0.5em)

      (pause,)

      rect((-.8, -.4),(.8, .4), name: "modem")
      content("modem.south", [Simcom SIM8202G M2 5G Module], anchor: "south", padding: 0.5em)

      (pause,)

      rect((-.6, -.2),(.6, .2), name: "ue")
      content("ue", align(center)[
        Baseband Processor\
        (Qualcomm Snapdragon x55)
      ])
    })
  ]
]
