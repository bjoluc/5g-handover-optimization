#import "utils.typ": cetz, touying-cetz-canvas, pause

#figure(caption: [UE Power Modeling Approaches])[
  #touying-cetz-canvas(length: 7.5cm, {
    import "/thesis/cetz.typ": *
    setStyle()

    content((0, 1), [Theoretical], anchor: "south")
    content((1, 1), [Empirical], anchor: "south")

    (pause,)

    line((-.5, 0), (rel: (0,1)), mark: (end: "stealth", scale: 2), name: "granAx")
    content("granAx.start", [Granularity], anchor: "north", padding: .7em)
    content((-.6, .7), [System-Level], anchor: "east")
    content((-.6, .3), [Slot-Level], anchor: "east")
    
    (pause,)

    content(
      (1, .7),
      align(center)[
        LTE:\ #cite(<jensenPowerModelLte2012>, form: "prose")
      ],
    )

    (pause,)

    content((0, .76), text(1.8em, emoji.person.shrug), name: "new")

    (pause,)

    content(
      (.5, .3),
      align(center)[
        5G NR:\ #cite(<3gppPowerStudy2019>, form: "prose")
      ],
      name: "3gpp"
    )

    (pause,)

    line("3gpp", "new", mark: (end: "straight", scale: 2), name: "granAx")
  })
]