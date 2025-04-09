#import "/utils.typ": hline
#import "@preview/glossarium:0.5.3": gls

== Handover Optimization <secRelWorkHandovers>

A considerable amount of research has been conducted on optimizing cellular hand\-overs~@handoverSurvey @mollelHandoversRlSurvey2021.
A relevant selection of these works is presented in this section.
The approaches can be grouped into two categories: Those using conventional algorithms~(Section~@secRelWorkHandoversConventional) and those based on @rl~(Section~@secRelWorkHandoversRL).
All presented approaches are summarized and compared in @tabRelatedWorkConventionalHandovers and @tabRelatedWorkRlHandovers at the end of each section, respectively.

=== Conventional Approaches <secRelWorkHandoversConventional>

#cite(<icellspeed2020>, form: "prose") have conducted @ue data rate measurements with several US mobile operators, finding that among all the cells available to a @ue at a given time, the selected cell(s) oftentimes did not provide the best data rate in comparison with other available cells.
Specifically, at 79% of measurement locations, data rate gains of at least 10~Mbps could be achieved by selecting alternative cells.
To prototypically improve the cell selection and increase @ue data rates, #cite(<icellspeed2020>, form: "author") develop a #[@ue]-local software approach which they call "Device-Assisted Cell Selection" @icellspeed2020.
It is highlighted that, following the #[@3gpp]-defined handover procedures, the final handover decision is still made by the @ran.
The precise approach taken for "assisting" the @ran with handover decisions is not detailed, however, it is likely that @ue capability settings are utilized to dynamically exclude frequency bands~@3gppUeCapabilities2025 @3gppRRCProtocol2024.
To decide between available frequency bands, a profiling mechanism is applied that tracks past data rates for each frequency band and uses this information to predict the frequency band promising the best data rate. 
In their measurements, #cite(<icellspeed2020>, form: "author") find that their approach significantly improves data rates, despite occasionally interrupting connectivity for several seconds, thus reducing @qoe.

Motivated by the findings of #cite(<icellspeed2020>, form: "prose"), #cite(<roadrunner2022>, form: "prose") implement a bandwidth-aware handover algorithm that can be deployed by the @ran to improve data rates similarly to~#cite(<icellspeed2020>, form: "author"), but for all @ue:pl, without requiring additional @ue applications or degrading @ue connectivity.
#cite(<roadrunner2022>, form: "author") base their implementation on the O-RAN architecture #footnote[https://www.o-ran.org/] which provides open interfaces for softwarized @ran:pl, improving interoperability and speeding up the evolution of @ran:pl.
The O-RAN architecture features a "@ric" which handles real-time network decisions based on a multi-@bs central network view @roadrunner2022.
The resource allocation decisions of the @ric, in turn, can be customized by deploying modular applications called _xApps_.
#cite(<roadrunner2022>, form: "author") utilize this solution by implementing an O-RAN xApp that optimizes handover decisions for @ue data rates, based on the measurement reports the @ran receives from the @ue:pl.
They evaluate their solution in a testbed setup and note improved data rates and network fairness in comparison to an off-the-shelf implementation.

Similar to #cite(<icellspeed2020>, form: "prose"), #cite(<hassanCase2024>, form: "prose") have conducted extensive data rate measurements, observing a significant data rate gap between the #[@ran]-selected frequency band and other available bands.
The measurements have been taken in five countries (US and Europe) over the course of one year, furthermore including a variety of distinct mobility patterns.
In a static mobility setting, the median of the measured data rate gap amounts to 34 Mbps, whereas it comes to 64 Mbps at walking speeds.
This indicates that the issue of suboptimal handover decisions has not been solved in practice in the past few years and, furthermore, is significantly impacted by @ue mobility patterns.
 #cite(<hassanCase2024>, form: "author") consider data rates with respect to @qoe and highlight the impact of taking mobile applications into account to improve @qoe via handover decisions.
They sketch an O-RAN-based solution, but only implement a #[@ue]-local proof of concept similar to the approach of #cite(<icellspeed2020>, form: "prose").
They further bring up the option to incorporate other metrics, such as energy efficiency, into handover decisions -- which is approached in this thesis.

#figure(caption: [Handover Optimization Approaches using Conventional Algorithms])[
  #table(
    columns: 3,
    align: (left,) * 3,
    table.header(
      [Work],
      [Objective],
      [Deployment Strategy],
    ),

    ..hline(columns: 3),

    ["iCellSpeed" @icellspeed2020],
    [Optimize data rates for individual @ue:pl],
    [#[@ue]-local: Mobile App],

    ["Roadrunner" @roadrunner2022],
    [Optimize data rates for all @ue:pl],
    [@ran: O-RAN xApp],

    cite(<hassanCase2024>, form: "prose"),
    [Optimize @ue QoE (via data rates)],
    [@ran (suggested), #[@ue]-local (#gls("poc", long: false))],
  )
] <tabRelatedWorkConventionalHandovers>

=== RL-Based Approaches <secRelWorkHandoversRL>

#[@rl]-based handover solutions have been successfully demonstrated for various optimization aspects in different mobile network setups @mollelHandoversRlSurvey2021 @yajnanarayanaHandoversRl2020 @mollelDeepRlHandovers2021 @deepcomp2023.
This section presents three relevant approaches, the concepts of which can be built upon in this thesis.
The core design choices of each approach are summarized in @tabRelatedWorkRlHandovers.

#cite(<yajnanarayanaHandoversRl2020>, form: "prose") present an @rl algorithm for the optimization of 5G handovers using Q-learning @suttonBartoRl2020.
Their motivation is to improve handover decisions with respect to the achievable data rate, which they quantify via the @ue's received link beam @snr.
Unlike the @rsrp measurements typically used in handover decisions, the link beam @snr is more directly related to @pdsch data rates @yajnanarayanaHandoversRl2020.
This is because @rsrp values are determined using the @bs's @ssb bursts.
Those are primarily intended for cell discovery and beamforming adaption and do not directly mirror the respective link beam @snr @yajnanarayanaHandoversRl2020.
Unlike @rsrp:pl, however, the effective link beam @snr can only be reported when a @ue is already connected to a cell.
Thus, it is not directly available to be used in conventional handover algorithms.
#cite(<yajnanarayanaHandoversRl2020>, form: "author") apply @rl to bridge this gap.
They train a central handover agent that is rewarded by a @ue's link beam @snr after each handover, thus optimizing this metric via handover decisions.
The observation space of the agent consists of the @rsrp:pl reported by each @ue.
#cite(<yajnanarayanaHandoversRl2020>, form: "author") apply the @rl algorithm in simulations and observe an improved link beam gain compared to a conventional #[@rsrp]-driven handover algorithm.
The precise system simulation software components are not mentioned.

While #cite(<yajnanarayanaHandoversRl2020>, form: "author") optimize data rates in general 5G systems, #cite(<mollelDeepRlHandovers2021>, form: "prose") specifically consider millimeter wave (#[@fr]2) deployments with a high cell density.
Given the relatively small range of high-frequency cells, frequent handovers may negatively impact @ue data rates by temporarily interrupting payload data transfers.
Therefore, #cite(<mollelDeepRlHandovers2021>, form: "author") focus on reducing the number of handovers while maximizing data rates.
They apply deep Q-learning @mnihDeepRl2015 with a data-rate-based reward function that penalizes handovers by temporarily reducing the reward signal in each time step in which a handover action has been taken by the @rl agent.
The agent's observation space includes the @snr:pl measured by each @ue for each cell, as well as the one-hot-encoded serving cell ID of each @ue.
An evaluation using a commercial radio wave propagation simulator
#footnote[Remcom Wireless InSite] results in increased data rates and 70% less handover procedures compared to a conventional rate-based handover algorithm.

In contrast to the previously presented solutions, #cite(<deepcomp2023>, form: "prose") do not explicitly focus on handovers.
Instead, they consider the cell selection in a coordinated multi-point scenario where multiple @bs:pl can cooperate to improve @pdsch coverage ("Multiple Transmit/Receive Point Operation") @3gppRANDescription2024.
This cell selection problem is a superset of the handover optimization problem, involving both handovers and coordination between @bs:pl.
It extends the handover problem by allowing the simultaneous selection of multiple cells from different @bs:pl.
#cite(<deepcomp2023>, form: "author") apply a @ppo algorithm~@schulmanPPO2017 to a simplistic Python-based system-level simulation, explicitly optimizing @qoe, which they model as a logarithmic function of the @ue data rate.
The reward function therefore is the average @qoe of all @ue:pl.
Similar to #cite(<mollelDeepRlHandovers2021>, form: "prose"), the observation space involves the #[@ue]-measured @snr:pl, as well as -- in analogy to the one-hot-encoded serving cell used by #cite(<mollelDeepRlHandovers2021>, form: "author") -- a binary connection vector for each @ue, indicating which cells the @ue is connected to.
Furthermore, the data-rate-based @qoe value of each @ue is also included in the observation space.
Compared to other heuristic-based coordinated multi-point algorithms, the presented solution achieves a significant improvement of @ue @qoe.
Notably, #cite(<deepcomp2023>, form: "author") have made their simulation environment available as open-source software under the MIT license and published it in a conference paper @mobileEnv2022.
This makes their environment a useful starting point for the development of a customized, #[@ue]-power-aware simulation environment in this thesis.

// What's the motivation?
// Which metric is optimized / reward function?
// Observation space?
// Which RL alg.?
// Which simulator?

#figure(caption: [Handover Optimization Approaches using RL])[
  #table(
    columns: 4,
    align: (left,) * 4,
    table.header(
      [Work],
      [Optimization Metric],
      [RL Algorithm],
      [Observation Space],
    ),

    ..hline(columns: 4),

    cite(<yajnanarayanaHandoversRl2020>, form: "prose"),
    [Data rate \ (link beam @snr)],
    [Q-Learning @suttonBartoRl2020],
    [@rsrp for each #[@ue]-cell combination],

    ..hline(columns: 4),

    cite(<mollelDeepRlHandovers2021>, form: "prose"),
    [Data rate (max.), \ Handovers (min.)],
    [Deep Q-Network @mnihDeepRl2015],
    [For each @ue: @snr:pl for all cells, serving cell ID],

    ..hline(columns: 4),

    cite(<deepcomp2023>, form: "prose"),
    [@ue @qoe \ (based on data rates)],
    [@ppo @schulmanPPO2017],
    [For each @ue: @snr:pl for all cells, serving cells, @qoe],
  )
] <tabRelatedWorkRlHandovers>
