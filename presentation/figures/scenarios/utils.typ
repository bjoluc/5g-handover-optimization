#import "@preview/cetz:0.3.4"
#import "/thesis/cetz.typ": UE, gNB
#import cetz.draw: line, circle

#let ue(position, cells) = {
  UE(position, anchor: "center", name: "ue")
  for cell in cells {
    line(
      "ue",
      (name: cell, anchor: "default"),
      stroke: (dash: "dashed"),
    )
  }
}

#let cell(position, name, range: 0.8) = {
  gNB(position, name: name)
  circle(
    position,
    radius: range,
    stroke: (dash: "dotted"),
  )
}
