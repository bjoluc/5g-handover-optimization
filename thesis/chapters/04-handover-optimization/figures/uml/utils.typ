#import "@preview/fletcher:0.5.6" as fletcher: diagram, node, edge

#let divider() = {
  block(spacing: 0.5em,
    line(
      start: (0% - 0.5em, 0%),
      end: (100% + 0.5em, 0%),
      stroke: .5pt,
    )
  )
}

#let class(name, at, lines) = {
  node(at,
    block(spacing: 0em,
      align(left, {
        align(center, raw(name))
        if(lines.len() > 0) {
          divider()
        }
        for line in lines {
          if line == "-" {
            divider()
          } else {
            {
              block(above: 0em, below: 0.75em)[#text(style: "italic", raw(line)) \ ]
            }
          }
        }
      }),
    ),
    name: label(lower(name)),
    shape: "rect",
    defocus: 1
  )
}

#let aggregates(owner, property) = {
  edge(owner, property,  marks: (
    (inherit: "diamond", scale: 2),
  )) // `1`, label-pos: 0.2,
}

#let composes(owner, property) = {
  edge(owner, property, marks: (
    (inherit: "diamond", scale: 2.25, fill: black),
    (inherit: "straight", scale: 1.5),
  ))
}

#let calls(who, whom) = {
  edge(who, whom, marks: (
    none,
    (inherit: "straight", scale: 1.5),
  ))
}
