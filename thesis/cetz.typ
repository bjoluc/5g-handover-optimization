#import "@preview/cetz:0.3.4": *

#import draw: * // So figures don't need to import the draw functions separately

#let setStyle() = {
  draw.set-style(
    mark: (fill: black, transform-shape: false),
    stroke: (thickness: 0.5pt, cap: "round"),
    content: (padding: 4pt),
  )
}

#let drawAxisX(size, label) = {
  draw.line((0, 0), (size, 0), mark: (end: "stealth", scale: 2))
  draw.content((), label, anchor: "west")
}

#let drawAxisY(size, label) = {
  draw.line((0, 0), (0, size), mark: (end: "stealth", scale: 2))
  draw.content((), label, anchor: "south")
}

#let drawXAxisLabels(labels, height: 3pt) = {
  for (x, label) in labels {
    draw.line((x, height), (x, -height))
    draw.content((), anchor: "north", label)
  }
}

#let drawYAxisLabels(labels, width: 3pt) = {
  for (y, label) in labels {
    draw.line((width, y), (-width, y))
    draw.content((), anchor: "east", label)
  }
}

#let gNB(position, ..groupParameters) = {
  draw.group({
    draw.set-origin(position)
    draw.anchor("default", (0,0))
    draw.scale(.2)

    draw.line((-0.25,-0.8),(0,0),(0.25,-0.8), close: true)
    draw.circle((0,0), radius: 6pt, fill: black)

    for (radius) in range(3) {
      for (deg) in (-45deg, 135deg) {
        draw.arc((0,0), start: deg, delta: 90deg, radius: radius/4, anchor: "origin")
      }
    }
  }, padding: 4pt, ..groupParameters)
}

#let UE(position, ..groupParameters) = {
  draw.group({
    draw.set-origin(position)
    draw.scale(.2)

    draw.rect((-0.2,-0.4),(0.2,0.4), radius: 6pt)
  }, padding: 4pt, ..groupParameters)
}

#let setupPlot(xLabel, yLabel, size, bounds) = {
  setStyle()

  drawAxisX(size.at(0), xLabel)
  drawAxisY(size.at(1), yLabel)

  draw.set-viewport((0,0), size, bounds: bounds)

  // Set an anchor at (0,0), to be used by the `bar` function
  draw.circle((0,0), name: "barStart", radius: 0pt)
}

#let xBrace(x1, x2, label, y: 0, amplitude: 0.5, flip: true, rotateText: false) = {
  decorations.brace(
    (x1, y),
    (x2, y),
    flip: flip,
    amplitude: amplitude,
    content-offset: 0.25 * amplitude,
    name: "xBrace",
  )
  
  draw.content(
    "xBrace.content",
    align(center)[#label],
    anchor:
      if rotateText {
        if flip {"east"} else {"west"}
      } else {
        if flip {"north"} else {"south"}
      },
    angle: if rotateText {90deg} else {0deg},
  )
}

#let yBrace(y1, y2, label, x: 0, amplitude: 1, flip: false) = {
  decorations.brace(
    (x, y1),
    (x, y2),
    flip: flip,
    amplitude: 0.25 * amplitude,
    content-offset: 0.1 * amplitude,
    name: "yBrace",
  )
  
  draw.content("yBrace.content", label, anchor: if flip {"west"} else {"east"})
}

#let dashedLine(from, to) = {
  draw.line(from, to, stroke: (dash: "dashed"))
}

#let labeledRect(x1, x2, y1, y2, label, name: "labeledRect") = {
  draw.rect((x1, y1), (x2, y2), name: name)
  draw.content((name: name, anchor: "center"), label)
}

#let moveBarStartAnchor(offset) = {
  draw.circle((rel: (offset, 0), to: "barStart"), name: "barStart", radius: 0pt)
}

#let bar(label, height, width: 1, isTextHorizontal: false) = {
  draw.rect("barStart", (rel: (width, height), to: "barStart"), name: "bar")
  if isTextHorizontal {
    draw.content("bar.center", label)
  } else {
    draw.content("bar.south", label, angle: 90deg, anchor: "west")
  }

  moveBarStartAnchor(width)
}

#let measure(from, to, content, textAnchor: "center") = {
  draw.line(from, to, name: "measure", mark: (start: "|", end: "|", scale: 2))
  if(content != none) {
    if textAnchor != "center" {
      draw.content("measure.50%", box(inset: 0.5em, fill: white, content), anchor: textAnchor)
    } else {
      draw.content("measure.50%", box(inset: 3pt, fill: white, content))
    }
  }
}

#let straightArrow(from, to, name: none) = {
  draw.line(from, to, mark: (end: ">"), name: name)
}

#let manhattanArrow(from, to, flip: false) = {
  draw.get-ctx(ctx => {
    let (ctx, fromPoint, toPoint) = coordinate.resolve(ctx, from, to)
    let viaPoint = (toPoint.at(0), fromPoint.at(1))
    if flip {
      viaPoint = (fromPoint.at(0), toPoint.at(1))
    }
    draw.line(fromPoint, viaPoint, toPoint, mark: (end: ">"), name: "arrow")
  })
}
