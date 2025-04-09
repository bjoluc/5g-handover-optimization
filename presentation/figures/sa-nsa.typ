#import "utils.typ": cetz, touying-cetz-canvas, pause

#figure(caption: [LTE vs 5G NSA vs 5G SA Architectures @moraisNrOverview2023])[
  #touying-cetz-canvas(length: 6.5cm, {
    import "/thesis/cetz.typ": *
    setStyle()

    // Legend
    line((1.1,-1.05), (1.3,-1.05), name: "controlPlane")
    content("controlPlane.100%", [Control & Data Plane], anchor: "west")

    line((1.1,-1.2), (1.3,-1.2), stroke: (dash: "dashed"), name: "dataPlane")
    content("dataPlane.100%", [Data Plane Only], anchor: "west")

    // 5G SA
    gNB((3,0), name: "bs4")
    content("bs4.east", [5G gNB], anchor: "west")

    UE((3, -0.65), name: "ue3")
    content("ue3.south", [UE], anchor: "north")
    line("ue3.north", "bs4.south")

    (pause,)

    labeledRect(2.75, 3.25, 0.65, 0.45, "5G Core", name: "5gCore")
    line("bs4.north", "5gCore")

    (pause,)

    // LTE
    gNB((0.5,0), name: "bs1")
    content("bs1.west", [LTE eNB], anchor: "east")

    UE((0.5, -0.65), name: "ue1")
    content("ue1.south", [UE], anchor: "north")
    line("ue1.north", "bs1.south")

    labeledRect(0.25, 0.75, 0.65, 0.45, "LTE Core", name: "lteCore1")
    line("bs1.north", "lteCore1")

    (pause,)

    // 5G NSA
    gNB((1.5,0), name: "bs2")
    content("bs2.west", [LTE eNB], anchor: "east")
    gNB((2,0), name: "bs3")
    content("bs3.east", [5G gNB], anchor: "west")
    line("bs2.east", "bs3.west", stroke: (dash: "dashed"))

    UE((1.75, -0.65), name: "ue2")
    content("ue2.south", [UE], anchor: "north")
    line("ue2.north-west", "bs2.south")
    line("ue2.north-east", "bs3.south", stroke: (dash: "dashed"))

    labeledRect(1.5, 2, 0.65, 0.45, "LTE Core", name: "lteCore2")
    line("bs2.north", "lteCore2")
    line("bs3.north", "lteCore2", stroke: (dash: "dashed"))
  })
]
