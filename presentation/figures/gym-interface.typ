#import "@preview/fletcher:0.5.6": diagram
#import "/thesis/chapters/04-handover-optimization/figures/uml/utils.typ": *

#figure(caption: [Gymnasium Environment Interface @gymnasium2024], {
  set block(inset: 0.05em)
  diagram(
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
})
