#import "/cetz.typ": canvas

#figure(caption: [Duration of a DRX Sleep Period])[
  #canvas(length: 4cm, {
    import "/cetz.typ": *
    setupPlot("Time", [@ue Activity], (2.75, 0.5), (15, 4))

    bar([], 2, width: 2)
    moveBarStartAnchor(10)
    bar([], 2, width: 2)

    measure((2, 1), (12, 1), [$t_s$])

    let arrival(at) = {
      line((at,-1),(at,0), mark: (end: "straight"))
    }

    line((12,0), (12, -1), mark: (start: "straight"))

    content((2, -1.75), anchor: "east", [Case 1:])
    measure((2, -1.75), (12, -1.75), [$t_P_U$])
    content((12, -1.75), anchor: "west", [@ul arrival])

    content((2, -3), anchor: "east", [Case 2:])
    measure((2, -3), (12, -3), [$t_"On"$])
    content((12, -3), anchor: "west", [On duration])
    
  })
] <figDrxSleepPeriod>
