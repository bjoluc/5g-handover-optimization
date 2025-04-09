#import "/cetz.typ": canvas

#figure(caption: [DRX Active Period with UL/DL Packet Arrivals])[
  #canvas(length: 4cm, {
    import "/cetz.typ": *
    setupPlot("Time", [@ue Activity], (2.75, 0.5), (14.5, 4))

    moveBarStartAnchor(2)
    bar([], 2, width: 10)

    measure((9, 1), (12, 1), [$T_I$])
    measure((2, 3), (12, 3), [$t_a$])

    let arrival(at) = {
      line((at,-1),(at,0), mark: (end: "straight"))
    }

    arrival(2)
    measure((2, 1), (4, 1), [$T_P_1$])
    arrival(4)
    measure((4, 1), (6, 1), [$T_P_2$])
    arrival(6)
    measure((6, 1), (7.5, 1), [$T_P_3$])
    arrival(7.5)
    measure((7.5, 1), (9, 1), [$T_P_N$])
    arrival(9)

    line((12,2), (rel: (0.5,1)), mark: (start: "straight"))
    content((), anchor: "west", [$T_I$ expired])
  })
] <figDrxActivePeriod>
