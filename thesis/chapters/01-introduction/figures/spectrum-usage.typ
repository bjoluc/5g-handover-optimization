#import "/cetz.typ": canvas

#figure(caption: [Spectrum Usage of 5G New Radio @primerOnBandwidthParts], placement: auto)[
  #canvas(length: 4cm, {
    import "/cetz.typ": *

    setStyle()
    drawAxisX(3, "Freq.")
    for (x, label) in (
      (0.3*0.5, "410 MHz"),
      (0.3*5.5, "7.125 GHz"),
      (0.3*7.5, "24.25 GHz"),
      (0.3*9, "52.6 GHz"),
    ) {
      line((x, -3pt), (x, 3pt))
      content((), anchor: "south", label)
    }

    set-viewport((0, 0), (3, -20em), bounds: (10, 12))

    labeledRect(0.5, 5.5, 1, 2, "FR1", name: "fr1")
    labeledRect(1, 1.9, 1, 2, "Band", name: "band")
    labeledRect(7.5, 9, 1, 2, "FR2", name: "fr2")

    labeledRect(0.5, 9, 3, 4, "Operating Band", name: "operating-band")
    labeledRect(1, 3, 3, 4, "Operator", name: "operator")
    
    labeledRect(0.5, 9, 5, 6, "Cell-Specific Channel Bandwidth", name: "cell")
    labeledRect(1.5, 8, 7, 8, "UE-Specific Channel Bandwidth")
    labeledRect(3, 6.5, 9, 10, "Bandwidth Part")

    dashedLine((0.5, 0), "fr1.south-west")
    dashedLine((5.5, 0), "fr1.south-east")

    dashedLine((7.5, 0), "fr2.south-west")
    dashedLine((9, 0), "fr2.south-east")

    dashedLine("band.north-west", "operating-band.south-west")
    dashedLine("band.north-east", "operating-band.south-east")

    dashedLine("operator.north-west", "cell.south-west")
    dashedLine("operator.north-east", "cell.south-east")

    dashedLine("cell.north-west", (0.5,10))
    dashedLine("cell.north-east", (9,10))

    yBrace(3, 4, "Operator")
    yBrace(5, 6, "BS")
    yBrace(7, 10, "UE")
  })
]<figSpectrum>
