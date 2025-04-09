#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
#import "figures/utils.typ": cetz, touying-cetz-canvas
#import "/thesis/utils.typ": hline
#import emoji: ballot

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-common(
    handout: false,
  ),
  config-info(
    title: [
      Enhancing Cellular Handovers:\
      Optimizing Quality of Experience using Machine Learning
      #v(-1em)
    ],
    subtitle: [Master's Thesis Presentation],
    author: [Björn Luchterhandt],
    date: [March 12, 2025],
    institution: [Paderborn University],
  ),
  config-colors(
    primary: rgb("#eb811b"),
    secondary: rgb("#1f4061"),
    neutral-dark: rgb("#1f4061"),
    neutral-darkest: rgb("#1f4061").darken(10%),
  ),
)

#let section-counter = counter("section")
#show heading.where(level: 1): it => {
  section-counter.step()
  it
}

#show outline.entry.where(level: 1): set block(above: 1.5em)
#show outline.entry: it => {
  link(
    it.element.location(),
    it.indented(
      numbering("1.", section-counter.at(it.element.location()).at(0) + 1
      ),
      it.body(),
    ),
  )
}

#show figure: set text(size: 0.9em)
#set figure(numbering: none)

// Custom citation style to use "et al." for more than two authors in author/prose citations
#set cite(style: "/thesis/ieee_custom.csl")

// Table strokes: Draw only horizontal top and bottom line
#set table(stroke: (x, y) => (
  top: if y == 0 { 1pt } else { 0pt },
  bottom: 1pt,
))
#set table.hline(stroke: 0.5pt)

// Table captions above tables
#show figure.where(kind: table): set figure.caption(position: top)


#title-slide()

= Outline <touying:hidden>
#outline(title: none, indent: 2em, depth: 1)

= Motivation

== Elevator Pitch

- Mobile Network Operators want *satisfied customers* #pause
- "Satisfied" = Good *Quality of Experience* (QoE) #pause
- QoE involves *data rates* and *battery life* #pause

#figure()[
  #touying-cetz-canvas(length: 7.5cm, {
    import "/thesis/cetz.typ": *
    setStyle()

    gNB((0,0), name: "bs")
    content((0,-0.25), [Base Station], anchor: "north")
    (pause,)

    circle((0.8,0), radius: (0.8, 0.2), name: "cell")
    content("cell", [Cell])
    (pause,)

    UE((1.4,0), name: "ue")
    content((1.4,-0.25), [User Equipment (UE)], anchor: "north")
  })
]
#pause

- Data rates and battery life are influenced by *cell selection* #pause
- Cell selection of active UEs is controlled via *handovers* #pause
- Let's *optimize handovers for QoE* (data rates, power consumption)

== Missed Data Rate Gains in The Wild

#figure(
  image("figures/icellspeed-measurements.svg", width: 100%),
  caption: [Data rate measurements from @icellspeed2020 (AT&T, 2020)]
)

== UE Power Consumption

Battery capacities don't follow Moore's Law.

$=>$ Use battery power efficiently!
#v(1em)
#pause

=== Cell Selection and Power Consumption

- Transmission power control #pause
- Cell frequency and bandwidth #pause
- Radio access technology


= Technical Background

== 5G New Radio
#include "figures/sa-nsa.typ"

== Frequencies & Bandwidth
#include "figures/spectrum-usage.typ"

== Handovers
#import "figures/scenarios/handovers.typ": animatedHandoversFigure
#slide(repeat: 5, self => animatedHandoversFigure(self))

== Quality of Experience
#grid(
  columns: (2fr, 3fr),
  align: top,
  [
    #pause
    - User-perceived metric #pause
    - Involves
      - Data rates
      - Energy efficiency #pause
    - Depends on mobile application
    #pause
  ],
  include "figures/log-utility.typ",
)

#focus-slide[How to optimize handovers for QoE?]

== Reinforcement Learning
#pause
#grid(
  columns: (1fr, 1fr),
  gutter: 2em,
  include "figures/rl-loop.typ",
  [
    #pause
    Advantages:
    - Automatic optimization of target metric #pause
    - Adapts to environment (changes) #pause
    - Extensible
    #pause
    Disadvantages:
    - No guarantees
  ],
)

#focus-slide[
  #only(1)[Plan?] #pause

  (1) Build a UE Power Model #pause

  (2) Integrate it into a simulation environment #pause

  (3) Use RL to optimize handovers for QoE
]

= UE Power Modeling

== Approach
#include "figures/power-model-approaches.typ"

== UE Power during Handover
#grid(
  columns: (2fr, 3fr),
  rows: (1fr, 1fr),
  align: top,
  pause,
  grid.cell(
    rowspan: 2,
    include "figures/connection-sequence.typ",
  ),
  pause,
  include "figures/handover-power.typ",
  pause,
  grid.cell(
    align: bottom,
    include "figures/handover-power-plot.typ",
  ),
)

== UE Power for Payload Traffic

#import "figures/drx.typ": animatedDrxFigure
#slide(repeat: 7, self => [
  === Discontinuous Reception (DRX)
  #pause
  #animatedDrxFigure(self)
])

#align(center)[
  === Input Parameters
  #pause
  #table(
    columns: 3,
    align: (left, center, center),
    table.header([Parameter], [Symbol], [Unit]),
    ..hline(columns: 3),
    [Mean DL packet inter-arrival time], [$T_P_D$], [ms],
    [Mean UL packet inter-arrival time], [$T_P_U$], [ms],
    ..hline(columns: 3),
    [DRX cycle length], [$T_C$], [ms],
    [DRX inactivity timer duration], [$T_I$], [ms],
    [DRX On duration], [$T_"On"$], [ms],
    ..hline(columns: 3),
    [Average Tx power], [$x$], [dBm],
    [DL BWP size], [$B_D$], [MHz],
  )
]

#focus-slide[How much time does the UE spend in a DRX sleep state?]
== UE Power for Payload Traffic -- DRX Sleep Ratio

=== Let's ask Math!

$
r_"sleep" :=& EE[t_s] / (EE[t_a] + EE[t_s]) \ pause

EE[t_a]
=& EE[sum_(i=1)^(N) (t_P_i) + T_I]
= EE[N] dot EE[t_P_i] + T_I 
= e^(T_I/lambda) dot (1 - e^(-lambda c) (lambda c + 1)) / (lambda (1 - e^(-lambda c))) + T_I \ pause

EE[t_s] =& space ?
$

#text(1.5em, emoji.face.diagonal)
#pagebreak()

=== Let's ask Math (Part II)!

$
EE[ |A| ] = integral_0^T_C PP(x in A) d x
$
#pause

Issue: Find $PP(x in A)$

#pause

$
PP(quote.l.double"No" &"timer expiry in time" t quote.r.double)
approx e^(-lambda) sum_(n=1)^oo (lambda^n)/n!  (1 - (1-T_I/t)^n)^(n+1)
$

#pause

#text(1.5em, emoji.face.diagonal)
#pagebreak()

=== Let's ask #strike[Math] a Monte-Carlo Simulation!
#include "figures/sleep-ratio-pps.typ"

== UE Power for Payload Traffic
#include "figures/traffic-power-pps.typ"

#focus-slide[How to validate the model?]

== Measurement-Based UE Power Model Validation
#import "figures/measurement-ue.typ": animatedUeFigure
#slide(repeat: 3, self => animatedUeFigure(self))

#include "figures/measurements/idle-drx.typ"
#include "figures/measurements/idle-drx-on-duration.typ"
#include "figures/measurements/pps.typ"
#include "figures/measurements/rsrp.typ"

#focus-slide[
  #strike[(1) Build a UE Power Model] #sym.checkmark
  
  (2) Integrate it into a simulation environment

  (3) Use RL to optimize handovers for QoE
]
= Handover Optimization
== Simulation Environment
#slide(repeat: 4, self => [
  #let (uncover, only, alternatives) = utils.methods(self)
  #grid(
    columns: (2fr, 3fr),
    align: top,
    [
      #uncover("2-", [
        `mobile-env` @mobileEnv2022:
          - System-level network simulator
          - Tailored to RL
          - Simplistic
          - Implemented in Python
          - Open source (MIT license)
      ])

      #uncover("4-", [
        === Environment Adaption
        + Limit connections to 1 BS per UE
        + Integrate power model
        + Adapt action space and observation space
      ])
    ],
    uncover("3-",  include "figures/scenarios/mobile-env.typ"),
  )
])

== Simulation Environment -- RL Interface
#include "figures/rl-loop.typ"
#pause
#include "figures/gym-interface.typ"

#focus-slide[
  #strike[(1) Build a UE Power Model] #sym.checkmark
  
  #strike[(2) Integrate it into a simulation environment] #sym.checkmark

  (3) Use RL to optimize handovers for QoE
]
== Reinforcement Learning

#slide()[
  #pause
  === Evolution
  #pause
  - Avoid repeated handovers: Penalties & SNR Velocities #pause
  - Avoid starvation: Penalty #pause
  - Increase fairness: Fairness index in reward signal #pause
  - Missed handover occasions: Binary flag when better SNR is available #pause

  === Evaluation
  #pause
  #include "figures/evaluation-table.typ"
]

#include "figures/kde-pdfs/qoe.typ"

= Conclusion
== Conclusion
Output of this Thesis#footnote[https://github.com/bjoluc/5g-handover-optimization]:
#pause
- System-level UE power model for 5G NR #pause
- Measurement setup and fine-grained UE power measurements #pause
- System-level, UE-power-aware, RL-tailored mobile network simulator #pause
- Approaches to improve RL performance in handover optimization #pause

Key Findings: #pause
- Effects of network parameters on UE power consumption #pause
- Effects of radio environment diversity on RL performance

#focus-slide[Question Time!]

#slide(title: [References])[
  #bibliography("/thesis/literature.bib", title: none)
]

#focus-slide[Thank you for your Attention!]

= Appendix <touying:hidden>

#include "figures/scenarios/tradeoff-example.typ"
