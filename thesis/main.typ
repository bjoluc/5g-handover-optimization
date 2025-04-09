#import "cs-thesis/index.typ": cs-thesis, preface
#import "glossary.typ": glossary
#import "@preview/glossarium:0.5.3": make-glossary, register-glossary, print-glossary

#show: make-glossary
#register-glossary(glossary)

#show: cs-thesis.with(
  universityLogo: image("upb-logo.svg", width: 50%, height: 6em),
  documentName: [Master's Thesis],
  title: [Enhancing Cellular Handovers: Optimizing Quality of Experience using Machine Learning],
  facultyAndGroup: [
    Faculty of Computer Science, Electrical Engineering and Mathematics\
    Computer Networks Group
  ],
  degree: "Master of Science",
  author: "Björn Luchterhandt",
  advisor: "Marvin Illian",
  reviewers: ("Prof. Dr. Lin Wang", "Dr. Simon Oberthür"),
  city: "Paderborn",
  submissionDate: "February 26, 2025",
  // disclaimerSignature: image("signature.png", height: 2.5em) + v(-1em),
  preface: {
    preface(title: "Abstract")[
      Cellular handovers ensure the continuous connectivity of mobile devices as they move through various mobile network cells.
      Handover decisions in mobile networks can significantly impact the Quality of Experience of mobile device users as they influence both the achievable data rate and the power consumption of a mobile device.
      This thesis optimizes cellular handovers using a machine learning technique (Reinforcement Learning), considering both power consumption and data rates.
      To quantify power consumption of mobile devices, a power model is developed and validated with power measurements in a commercial mobile network.
      The model is subsequently integrated into a system-level simulator for cellular handovers and applied to jointly optimize data rates and power consumption of mobile network devices with respect to Quality of Experience.
      Both the developed model and the handover simulation environment are publicly available and can be applied and extended in future network research.
    ]
    preface(title: "Acknowledgements")[
      The power measurements in this work have been supported by Deutsche Telekom AG.
      I would like to thank the team at Deutsche Telekom for their support and cooperation -- gaining insights into the configuration of radio access networks has been a fascinating experience.
      I would further like to thank everyone who has supported my research through ideas, perspectives, and resources:
      Marvin Illian for always having a sympathetic ear and offering a second perspective when I was unsure about the best approach.
      The Computer Networks Group for the friendly and supportive environment, a workplace, coffee, and a 5G modem for the power measurements.
      Tim Hetkämper and the Measurement Engineering Group for providing me with hardware, know-how, and an awesome Python library to abstract the low-level hardware communication out of the way.
      The E-Lab of the Electrical Engineering Student Council for borrowing me their hardware.
      Prof. Dr. Thomas Richthammer from the Stochastics working group in the Department of Mathematics, who spontaneously took the time to offer his extensive expertise.
      Finally, the team at actiVita Paderborn for offering their gym as a measurement location, even for over-night measurements -- your christmas punch has made the measurements far more enjoyable.
      
      Thank you, all!
    ]
  },
)

// Custom citation style to use "et al." for more than two authors in author/prose citations (does not affect bibliography)
#set cite(style: "ieee_custom.csl")

#include "chapters/01-introduction/index.typ"
#include "chapters/02-related-work/index.typ"
#include "chapters/03-power-model/index.typ"
#include "chapters/04-handover-optimization/index.typ"
#include "chapters/05-discussion/index.typ"
#include "chapters/06-conclusion/index.typ"

// Appendixes
#counter(heading).update(0)
#set heading(numbering: "A1.1")
#include("chapters/appendix/index.typ")

// List of Acronyms
#heading(numbering: none)[List of Acronyms]
#print-glossary(glossary, disable-back-references: true)

// Bibliography
#bibliography("literature.bib")
