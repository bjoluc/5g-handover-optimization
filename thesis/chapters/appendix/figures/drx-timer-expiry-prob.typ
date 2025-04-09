#import "/cetz.typ": canvas

#figure(caption: [Partition of a Time Interval $T$])[
  #canvas(length: 4cm, {
    import "/cetz.typ": *

    setStyle()
    drawAxisX(02.75, [])
    set-viewport((0, 0), (2.75, 0.25), bounds: (14.5, 2))

    measure((2, 3), (12, 3), [$T$])

    measure((2, 1.5), (4, 1.5), $t_1$)
    measure((4, 1.5), (6, 1.5), $t_2$)
    measure((6, 1.5), (7.5, 1.5), $t_3$)
    measure((7.5, 1.5), (10, 1.5), $t_N$)
    measure((10, 1.5), (12, 1.5), $t_(N+1)$)

    drawXAxisLabels(((2,$0$),(4,$X_1$),(6,$X_2$),(7.5,$X_3$),(10,$X_N$),(12,$t$)), height: 0.25)
  })
] <figDrxTimerExpiryProb>
