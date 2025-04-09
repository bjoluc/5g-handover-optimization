#import "/cetz.typ": canvas

#figure(caption: [5G NR Resource Grid Concept], placement: auto)[
  #canvas(length: 4cm, {
    import "/cetz.typ": *

    setStyle()
    drawAxisX(1.1, "Time")

    line((0, 0), (0, -2.1), mark: (end: "stealth", scale: 2))
    content((), "Freq.", anchor: "north")

    set-viewport((0, 0), (10cm, -10cm), bounds: (25, 25))
    
    xBrace(9, 1, "Subframe", amplitude: 0.8, flip: false)
    yBrace(1, 13, "Resource Block", amplitude: 3.5)
    yBrace(14.5, 15.5, "SCS", amplitude: 2.5)
    xBrace(9, 8, "1 Symbol", y: 19.5, amplitude: 0.5)

    rect((8,8), (rel: (1,1)), stroke: none, fill: silver)
    content((12, 10), "Resource Element", anchor: "west")
    line((), (8.5, 8.5))

    // The Grid
    for x in range(1, 6) + (8,) {
      for y in range(1, 16) + (18,) {
        rect((x, y), (x+1, y+1))
      }
    }

    // Ellipsis dots for the grid
    for y in (1.5, 10.5, 18.5) {
      content((7, y), $dots.c.h$)
    }

    for x in (1.5, 8.5) {
      content((x, 17), $dots.v$)
    }

    content((7, 17), $dots.down$)
  })
]<figResourceGrid>
