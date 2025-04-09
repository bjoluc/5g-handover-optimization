#import "/cetz.typ": canvas

#figure(caption: [LTE UE Physical Layer Hardware Model (According to and Based on @jensenPowerModelLte2012)], placement: auto)[
  #canvas(length: 4cm, {
    import "/cetz.typ": *

    setStyle()

    labeledRect(0,0.75,1,1.25,[@tx Baseband], name: "txBb")
    labeledRect(0,0.75,0,0.25,[@rx Baseband], name: "rxBb")

    labeledRect(1.25,2,1,1.25,[@tx @rf], name: "txRf")
    labeledRect(1.25,2,0,0.25,[@rx @rf], name: "rxRf")

    labeledRect(0.65,1.35,0.5,0.75,[Power Supply], name: "supply")
    labeledRect(2,2.5,0.5,0.75,[Duplex], name: "duplex")

    let labeledArrow = (from, to, label) => {
      straightArrow(from, to, name: "arrow")
      content("arrow.40%", label, frame: "rect", stroke: none, fill: white, padding: 2pt)
    }

    labeledArrow("supply.north-west", "txBb.south", [$P_"TxBB"$])
    labeledArrow("supply.north-east", "txRf.south", [$P_"TxRF"$])
    labeledArrow("supply.south-west", "rxBb.north", [$P_"RxBB"$])
    labeledArrow("supply.south-east", "rxRf.north", [$P_"RxRF"$])

    straightArrow((rel: (-0.2,0), to: "txBb.west"), "txBb.west")
    straightArrow("rxBb.west", (rel: (-0.2,0), to: "rxBb.west"))
    content((rel: (-0.2,0), to: "txBb.west"), [@ul Data], anchor: "east")
    content((rel: (-0.2,0), to: "rxBb.west"), [@dl Data], anchor: "east")

    straightArrow("txBb", "txRf")
    straightArrow("rxRf", "rxBb")

    manhattanArrow("txRf.east", "duplex.north")
    manhattanArrow("duplex.south", "rxRf.east", flip: true)

    line("duplex.east", (rel: (0.2, 0)), mark: (symbol: ">"))
    content((), [Antenna], anchor: "west")
  })
]<figLteUeHardwareModel>
