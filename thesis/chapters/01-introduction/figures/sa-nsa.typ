#import "/cetz.typ": canvas

#figure(caption: [LTE vs 5G NSA vs 5G SA Architectures (left-to-right), based on @moraisNrOverview2023])[
  #canvas(length: 4cm, {
    import "/cetz.typ": *

    setStyle()

    labeledRect(0.25, 0.75, 0.65, 0.45, "LTE Core", name: "lteCore1")
    labeledRect(1.5, 2, 0.65, 0.45, "LTE Core", name: "lteCore2")
    labeledRect(2.75, 3.25, 0.65, 0.45, "5G Core", name: "5gCore")

    // Base Stations
    gNB((0.5,0), name: "bs1")
    content("bs1.west", [LTE eNB], anchor: "east")

    gNB((1.5,0), name: "bs2")
    content("bs2.west", [LTE eNB], anchor: "east")

    gNB((2,0), name: "bs3")
    content("bs3.east", [5G gNB], anchor: "west")

    gNB((3,0), name: "bs4")
    content("bs4.east", [5G gNB], anchor: "west")

    // UEs
    UE((0.5, -0.65), name: "ue1")
    content("ue1.south", [@ue], anchor: "north")

    UE((1.75, -0.65), name: "ue2")
    content("ue2.south", [@ue], anchor: "north")

    UE((3, -0.65), name: "ue3")
    content("ue3.south", [@ue], anchor: "north")

    // Connections
    line("ue1.north", "bs1.south")
    line("bs1.north", "lteCore1")

    line("ue2.north-west", "bs2.south")
    line("ue2.north-east", "bs3.south", stroke: (dash: "dashed"))
    line("bs2.north", "lteCore2")
    line("bs3.north", "lteCore2", stroke: (dash: "dashed"))
    line("bs2.east", "bs3.west", stroke: (dash: "dashed"))

    line("ue3.north", "bs4.south")
    line("bs4.north", "5gCore")

    // Legend
    line((1.1,-1.05), (1.3,-1.05), name: "controlPlane")
    content("controlPlane.100%", [Control & Data Plane], anchor: "west")

    line((1.1,-1.2), (1.3,-1.2), stroke: (dash: "dashed"), name: "dataPlane")
    content("dataPlane.100%", [Data Plane Only], anchor: "west")
  })
]<figSaNsa>
