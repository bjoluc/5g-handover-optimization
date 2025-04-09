= Introduction <chapterIntroduction>

Over the past decade, traffic demands on mobile radio networks have been rapidly increasing @cisco2020annual.
Not only is the number of mobile subscribers steadily growing, but with 5G deployments on the rise, the average per-device mobile data rate is also increasing significantly.
Network operators are striving to achieve high customer satisfaction by providing high data rates, oftentimes deploying more mobile network infrastructure.
However, recent studies have shown that there are unutilized data rate gains in many existing deployments due to a suboptimal assignment of mobile devices to radio cells @hassanCase2024 @icellspeed2020.

A cell is uniquely identifiable via a broadcasted cell ID and is powered by a single base station on a specific carrier frequency @3gppVocabulary2024, meaning one base station can provide cells on various frequencies, and cells from various base stations can share the same carrier frequency.
As a mobile device, subsequently referred to as @ue, is moving, it has to switch between various cells to maintain connectivity.
The choice of cells heavily impacts a @ue's achievable data rate due to varying cell bandwidths, traffic loads, and signal strengths.

// Come to power consumption and why it is important
Since @ue:pl are typically battery-powered and the technological enhancements in battery energy densities do not keep up with the increasing demands @coughlinMoores2015, @ue power consumption is an important aspect of mobile radio networks too.
The power consumed for cellular data transmissions depends on a variety of factors, including transmission power and radio bandwidth.
From a @ue's perspective, these parameters can wildly vary for different cells due to diverse radio channel conditions.
Hence, cell selection plays a major role in power consumption of mobile devices.

// Cell selection in detail: (Re)selection vs Handovers
The @3gpp differentiates between cell reselection and handovers @3gppUeProceduresIdleMode2025 @3gppProcedures2020.
Cell reselection is performed by @ue:pl in the @rrc idle state, i.e., when no @rrc connection is established, and denotes the #[@ue]-initiated process of selecting another cell for future connections @3gppUeProceduresIdleMode2025.
Reselection follows a #[@3gpp]-specified algorithm which measures @rsrp for available cells and autonomously decides which cell to use, based on parameters broadcasted by the base station.
A handover, on the other hand, is initiated by the @ran and hands an existing @rrc connection over to another cell while a @ue is in @rrc connected mode @3gppProcedures2020.
In order to make informed handover decisions, the @ran can configure @ue:pl to collect measurements about alternative cells in @rrc connected mode and report them back to the base station @3gppRRCProtocol2024.

Cell reselection and handovers complement each other to ensure connectivity throughout all @rrc states.
However, they differ fundamentally in the amount of control a network operator has about their outcomes.
Because the cell reselection algorithm is provided by the @3gpp specification and implemented in the @ue's modem chip, a @ran can only tune the parameters it provides to it, without customizing the algorithm itself.
Handovers, on the other hand, are #[@ran]-initiated and network operators can freely implement custom handover decision logic in their networks.
Hence, they provide a mechanism to optimize cell selection for various metrics without requiring changes to the @3gpp specification.

// Mention QoE and relate it to power consumption and data rates
Mobile operators strive to maximize users' perceived @qoe, i.e., how satisfied a user is with the provided network service.
Another common optimization metric in mobile networking research is the data rate that a @ue can achieve @icellspeed2020 @roadrunner2022 @yajnanarayanaHandoversRl2020 @mollelDeepRlHandovers2021.
Yet, it has been shown that data rates do not linearly impact @qoe @fiedlerQoE2010 @hossfeldQoE2010.
Therefore, maximizing @ue data rates in a cellular network does not necessarily optimize the @qoe of individual users.
Moreover, a user's @qoe is also impacted by @ue battery life @ickinQoE2012 which, in turn, depends on power consumption.
Since handover decisions affect both data rates and @ue power consumption, optimizing handover decisions can improve @qoe.
A thorough literature review yielded no existing approaches for #[@qoe]-driven multi-metric handover optimization with respect to data rates and @ue power consumption.
This thesis therefore focuses on optimizing handovers to improve @qoe, based on data rates and @ue power consumption.

A popular approach to handover optimization is the use of @rl @yajnanarayanaHandoversRl2020 @mollelHandoversRlSurvey2021, which is able to dynamically adapt handover decisions to the observed system behavior.
Considering the complex dynamic environment at hand, this is preferable over static expert-designed algorithms which can be challenging to develop and hard to extend for additional metrics in future work.
The work in this thesis hence consists of two major parts:

+ The design and validation of a power model to estimate @ue power consumption
+ The training and evaluation of an @rl agent for handover decisions, including the development of a system-level simulator for 5G handovers

In the following sections, an introduction is given to relevant concepts and mechanisms in 5G (Section~@sec5gIntro) and the core concepts of @rl (Section~@secRlIntro).
Chapter~@chapterRelatedWork presents related work in both fields of this thesis: Handover optimization and power modeling.
Based on this, Chapter~@chapterPowerModeling focuses on the design and validation of a power model, and Chapter~@chapterHandoverOptimization deals with handover optimization using @rl.
Finally, the results of this thesis are discussed in Chapter~@chapterDiscussion, and a conclusion is drawn in Chapter~@chapterConclusion.

#include "01-new-radio.typ"
#include "02-rl.typ"
