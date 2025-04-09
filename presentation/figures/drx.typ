#import "utils.typ": cetz, touying-cetz-canvas, utils, pause

#let animatedDrxFigure(self) = [
  #let (uncover, only) = utils.methods(self)
  #figure(caption: [UE Activity over Several DRX Cycles])[
    #touying-cetz-canvas(length: 6cm, {
      import "/thesis/cetz.typ": *
      setupPlot("Time", [UE Power], (3.6, 1.25), (29, 2.75))
      moveBarStartAnchor(3)

      let brace = xBrace.with(amplitude: 0.25)

      (pause,)

      brace(3, 13, [DRX Cycle $n$])
      brace(13, 23, [DRX Cycle $n+1$])

      (pause,)

      brace(3, 6, [], y: 1, flip: false)
      content((4.5, 2), [onDuration], name: "onDuration", padding: 0.2em)
      line("xBrace.content", "onDuration.south")
      bar([], 1, width: 3)
      moveBarStartAnchor(7)

      (pause,)
      
      brace(13, 16, [], y: 1, flip: false)
      line("xBrace.content", "onDuration.south-east")
      
      bar([], 1, width: 2)
      bar([], 2)

      (pause,)

      brace(15, 19, [inactivityTimer], y: 2, flip: false)
      dashedLine("xBrace.end", (19, 1))

      bar([], 1, width: 3)
      moveBarStartAnchor(4)

      (pause,)

      bar([], 1, width: 3)
    })
  ]
]