#import "@preview/cetz:0.3.4"

#figure(caption: [Reinforcement Learning Loop])[
  #cetz.canvas(length: 6cm, {
    import "/thesis/cetz.typ": *
    setStyle()

    labeledRect(0,0.8,0.6,0.8,"Agent", name: "agent")
    labeledRect(0,0.8,0,0.2,"Environment", name: "env")

    line("agent.east", (rel: (0.3,0)), (rel: (0,-0.6)), "env.east", name: "r", mark: (end: "straight", scale: 2))
    content("r.50%", [Action], frame: "rect", stroke: none, fill: rgb("#fafafa"))

    line("env.west", (rel: (-0.3,0)), (rel: (0,0.6)), "agent.west", name: "l", mark: (end: "straight", scale: 2))
    content("l.50%", [Observation, Reward], frame: "rect", stroke: none, fill: rgb("#fafafa"))
  })
]
