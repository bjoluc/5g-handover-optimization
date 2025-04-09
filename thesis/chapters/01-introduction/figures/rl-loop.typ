#import "/cetz.typ": canvas

#figure(caption: [Reinforcement Learning Loop])[
  #canvas(length: 4cm, {
    import "/cetz.typ": *

    setStyle()

    labeledRect(0,0.75,0.75,1,"Agent", name: "agent")
    labeledRect(0,0.75,0,0.25,"Environment", name: "env")

    line("agent.east", (rel: (0.5,0)), (rel: (0,-0.75)), "env.east", name: "r", mark: (end: ">"))
    content("r.50%", [Action], frame: "rect", stroke: none, fill: white)

    line("env.west", (rel: (-0.5,0)), (rel: (0,0.75)), "agent.west", name: "l", mark: (end: ">"))
    content("l.50%", [Observation, Reward], frame: "rect", stroke: none, fill: white)
  })
]<figRlLoop>
