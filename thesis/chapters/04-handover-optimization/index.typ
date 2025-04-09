= Handover Optimization <chapterHandoverOptimization>

As described in Chapter~@chapterIntroduction, handover decisions affect @qoe via data rates and @ue power consumption.
Therefore, optimizing handovers can improve @qoe.
The related work presented in Chapter~@chapterRelatedWork (Section~@secRelWorkHandovers) has identified suboptimal cell selection as a frequent cause for reduced @ue data rates.
In this regard, @rl has been used to optimize cell selection for data rates, yet not considering @qoe.
An exception to this is the #[@qoe]-maximizing #[@rl]-based cooperative multi-point optimization by #cite(<deepcomp2023>, form: "prose").
Nevertheless, this does not explicitly determine a @ue's serving cell and therefore does not consider handovers.
Furthermore, none of the available solutions evaluate the impact on @ue power consumption.
Therefore, in this section, an #[@rl]-based handover optimization approach is developed that specifically considers @qoe while taking @ue power consumption into account.

Due to the advantages of simulation-based @rl prototyping (as motivated in Chapter~@chapterIntroduction, Section~@secRlIntro) and the inaccessibility of a practical 5G environment for experimentation, the work in this chapter relies on a system-level cellular network simulator.
In the following section, the development of this simulator will be detailed.
Subsequently, Section~@secHandoverOptimizationRl investigates the application of @rl to the developed simulation environment and evaluates the impact of the resulting policies on @qoe, data rates, and power consumption.

#include "01-simulation.typ"
#include "02-rl.typ"