#import "/cetz.typ": UE, gNB, line, circle

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
