#import "@preview/cetz:0.3.4"
#import "@preview/touying:0.6.1": *

#let touying-cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
