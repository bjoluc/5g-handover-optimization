#import "/cetz.typ": canvas

#figure(caption: [Example Slot Formats @moraisNrOverview2023 @3gppPhyProceduresControl2024])[
  #canvas(length: 4cm, {
    import "/cetz.typ": *

    setStyle()
    set-viewport((0, 0), (18em, -18em), bounds: (10, 10))

    let slot(y, label, symbols, boundaries: ()) = {
      rect((0, y), (14, y+1), name: "slot")
      for (symbolNo, symbol) in symbols.enumerate() {
        if symbolNo > 0 and symbolNo < 14 {
          if symbolNo in boundaries {
            line((symbolNo, y), (symbolNo, y+1))
          } else {
            line((symbolNo, y), (symbolNo, y+1), stroke: (dash: "dotted"))
          }
        }
        content((symbolNo + 0.5, y + 0.5), symbol)
      }

      content("slot.west", label, anchor: "east", padding: 1em)
    }

    slot(0, "DL-Only Slot", ($arrow.b$,) * 14)
    slot(
      2,
      "DL-Heavy Slot",
      ($arrow.b$,) * 9 + ($arrow.t.b$,) * 2 + ($arrow.t$,) * 3,
      boundaries: (9,11)
    )
    slot(
      4,
      "UL-Heavy Slot",
      ($arrow.b$,) * 3 + ($arrow.t.b$,) * 2 + ($arrow.t$,) * 9,
      boundaries: (3,5)
    )
    slot(6, "UL-Only Slot", ($arrow.t$,) * 14)

    line((0, -0.5), (14, -0.5), mark: (symbol: ("|", "straight")), name: "durationLine")
    content("durationLine.50%", [14 Symbols], frame: "rect", stroke: none, fill: white)
  })
]<figSlotFormats>
