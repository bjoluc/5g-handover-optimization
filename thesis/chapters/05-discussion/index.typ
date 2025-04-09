= Discussion <chapterDiscussion>

The work in both topics of this thesis -- @ue power prediction and #[@rl]-based handover optimization -- has led to a number of findings which are summarized in Section~@secDiscussionFindings.
Based on these findings, options for future work are discussed in Section~@secDiscussionFutureWork.

== Key Findings <secDiscussionFindings>

The development of a system-level @ue power model in Chapter~@chapterPowerModeling has enabled a detailed understanding of the factors influencing @ue power in 5G @nr deployments.
Most importantly, @ue power is significantly impacted by the network-configured bandwidth part.
Intelligent dynamic adaption of a @ue's @bwp can result in major @ue power savings.
Furthermore, a large amount of @ue power is consumed solely for staying connected, more specifically, to monitor the radio channel for transmissions by the @bs.
Only a comparably small fraction of @ue power can be saved by optimizing cellular handovers.
Notably, these power savings only rely on the varying transmit powers required for different cells. 
By contrast, the optimization of @ran parameters has a far larger impact on @ue power consumption.

With respect to handover optimization for @qoe, the diversity of radio environments has a significant impact on the performance gains enabled by @rl.
Specifically, related work using more realistic physical channel simulations for #[@rl]-based handover optimization has consistently outperformed traditional handover algorithms, despite involving similar observation spaces as the approaches in this thesis.
In comparison, the #[@rsrp]-based handover algorithm used for the evaluation in Section~@secRlEvaluation has, without further ado, achieved close-to-optimal results in the simplistic simulation environment of this thesis, leaving not much room for improvement.
The comparably weak performance gain of the obtained @rl policy is comprehensible, considering that a key strength of @rl approaches lies in the exploitation of subtle environment dynamics that are not captured by many conventional algorithms.
Yet, applying #[@rl]-based handovers to more diverse radio environments -- such as the ones observed by #cite(<hassanCase2024>, form: "prose") -- may be an impactful step in closing the gap between practically observed maximum data rates and those achievable by optimal cell selection.


== Future Work <secDiscussionFutureWork>

Several topics qualify for future work.
In regard to power modeling, the system-level power model developed in this thesis -- despite yielding several promising results in the measurements performed in Section~@secPowerModelValidation -- does not accurately predict @ue power.
Specifically, it is based on vastly simplified assumptions regarding physical resource scheduling.
While a further in-depth theoretical refinement of the developed model may not significantly improve power predictions, the observed effects of the model's input parameters on @ue power consumption may form the foundation for a hybrid approach.
Namely, a simplified parameterized mathematical model may be derived by generalizing the theoretical model and -- in a similar approach to the empirical power modeling of #cite(<jensenPowerModelLte2012>, form: "prose") -- may be fitted with measured power values.
This way, the various effect sizes of model parameters on the power prediction may be captured more accurately.

Concerning the cell-selection-induced data rate gap in today's mobile radio networks, network operators may profit from an online learning solution that can be deployed in existing mobile networks.
Most @rl networking research relies on network simulations.
Yet, as observed in Chapter~@chapterHandoverOptimization, despite carefully modeling relevant system dynamics, simulations may deviate significantly from the behavior of real networks.
By utilizing the O-@ran platform, a hybrid online-learning #[@rl]-based handover solution may be developed that learns policies based on the data retrieved from a real network.
To avoid service disruptions by such an application, a conventional control algorithm might serve as a safety measure to control disruptive actions. 
Ultimately, such a system may yield more impactful results than abstract simulation-based @rl solutions, which need to be carefully evaluated with respect to their applicability to real systems.
