#import "@preview/fletcher:0.5.6": diagram
#import "./utils.typ": *

#figure(
  caption: [Gymnasium Environment Interface @gymnasium2024],
  placement: auto,
)[
  #diagram(
    // debug: true,
    spacing: (1.5cm, 1cm),
    node-stroke: 0.5pt, {
      class("Env", (0,0), (
        "+ action_space",
        "+ observation_space",
        "+ reset(seed): observation, info",
        "+ step(action): observation, reward, terminated, truncated, info",
        "+ render()",
      ))
    }
  )
] <figGymnasiumInterface>