#import "/utils.typ": hline, hgap

== Design of a System-Level Power Model for 5G NR UEs <secPowerModelDesign>

As motivated in the previous section, the power model to be developed is required to operate on a system-level granularity.
Section~@secRelWorkPowerLte has presented an @lte power model that fulfills this requirement.
Yet, without further work, this model is not applicable to 5G @nr, which features larger, dynamic cell bandwidths, as well as a variety of power-impacting configuration options.
Nevertheless, the linear-regression-based framework that was used to obtain the presented model may be adapted and applied using practical 5G @nr @ue power measurements.
An issue with this approach, however, is that it would require access to a 5G @nr @bs emulator (in analogy to the @lte @bs emulator used in~@jensenPowerModelLte2012) to practically observe @ue powers for the parameter combinations that are necessary to meet the configurability requirement.
Such a @bs emulator is not easily available and out of scope for this thesis.
While commercial 5G @nr deployments are available, their configured parameters are fixed by the network operators and do not exhibit sufficient variability to fit an empirical power model @fezeuUnveiling2024.  
Moreover, with respect to the extensibility requirement, an empirically obtained power model can only be extended via further power measurements.
This reduces the scope of feasible model extensions to those mechanisms that are readily available in commercial 5G deployments.
Based on these limitations, obtaining an empirical power model is impractical in this work.

An alternative approach is the development of a theoretical system-level model based on @3gpp's slot-level @nr power model from Section~@secRelWorkPower5g.
This can be achieved by considering the @ue activities resulting from a given set of system-level parameters and averaging their power values to predict the expected @ue power consumption for the given parameters.
This way, the obtained system-level model is highly configurable and remains extensible.
The accuracy then depends on the conformity of the deployment parameters with the model's assumptions.
If necessary, the model can also be fine-tuned to better represent a particular deployment based on @ue power measurements.
The derivation of a theoretical system-level power model from the @3gpp model can therefore fulfill the requirements from Section~@secPowerModelRequirements.

The following two sections cover the design of the desired power model.
Specifically, the synchronization and connection establishment procedure involved in handovers is handled in Section~@secPowerModelDesignHandover, while payload traffic in @rrc connected mode is addressed in Section~@secPowerModelDesignTraffic.
As previously mentioned, the prevalent 5G deployment mode is @tdd on #[@fr]1 @fezeuUnveiling2024, which will hence be presumed in both sections.


=== Synchronization and Connection Establishment <secPowerModelDesignHandover>

During a handover, the @ue synchronizes with and connects to a new cell, temporarily interrupting any payload data transmissions @ericsson5GAdvancedHandover.
Therefore, in the context of handover optimization, two metrics are relevant:
The time required for the handover, and the average @ue power during the handover.
Both metrics can be derived by tracing the @ue's activity during the synchronization and connection establishment procedure (as outlined in Section~@sec5gIntroChannels and illustrated in @figConnectionSequence).
The time $T_"Handover"$ can then be computed as the number of slots occupied by the procedure, and the average @ue power consumption $P_"Handover"$ (in @pu) as the mean of all slot-average powers.
In the following paragraphs, the duration (number of slots) and corresponding sum of slot-average powers is derived for each step of the synchronization and connection establishment procedure.
The results are listed in @tabHandoverPower.

*Initial Synchronization*:
During initial synchronization, the @ue repeatedly attempts to receive an @ssb (modeled by $P_"1SSB"$) to synchronize with the cell and decode the @mib.
The @3gpp power saving study suggests assuming one @ssb/@pbch transmission every 20~ms for power consumption evaluations @3gppPowerStudy2019.
Each @ssb/@pbch block is also repeated a specific number of times, depending on the carrier frequency and whether the spectrum is shared with another radio access technology @3gppPhyProceduresControl2024. The power model assumes 2~SSBs per slot @3gppPowerStudy2019.
Repeated @ssb:pl are transmitted via distinct beams from the @bs, enabling the @ue to choose the strongest beam @synchronizationProcedure2019.
Thus, despite the @ssb/@pbch block being repeated several times, the UE might only be able to synchronize once per @ssb periodicity.
With a periodicity of 20~ms, for 30~kHz @scs, the maximum synchronization time for a @ue therefore amounts to 40~slots.
Assuming the target cell is not synchronized with the source cell (i.e., the @ue attempts synchronization at a random time between two @ssb/@pbch transmissions in the target cell), the mean synchronization time is 20~slots.
At the end of this step, the @ue has synchronized with the cell and decoded the @mib.

*Receiving #[@sib]1*:
The @ue monitors the @pdcch for a @dci announcing #[@sib]1 on the @pdcch @3gppRRCProtocol2024 @3gppPhyProceduresControl2024 and at the same time compares the @rsrp:pl of the available beams (determined via the beams' @ssb:pl) to decide on the best beam @synchronizationProcedure2019.
Thus, the average power for these slots is modeled by $P_(r_"CCH"+2"SSB")$.
The periodicity for #[@sib]1 transmissions defaults to 20~ms @3gppRRCProtocol2024, therefore receiving the @sib can be assumed to take at most 40~slots.
Again, an average duration of 20~slots will be assumed (19~slots @pdcch/@ssb:pl and 1~slot @pdsch).

*Random Access*
#footnote[
  Random access occasions in the target cell can be configured individually for each @ue via @rrc signalling before performing the handover, hence a contention-free random access procedure is assumed~@3gppRRCProtocol2024.
]:
Depending on the @prach configuration and assuming a short @prach format, a @prach preamble occupies between 2 and 12 symbols @3gppPhysicalChannels2022.
The power model does not specify dedicated @prach power values, therefore the slot-average power $P_t$ of a long @pucch transmission is used in this work.
The number of @prach occasions per @ssb is decided by the operator and communicated via #[@sib]1 @3gppRRCProtocol2024.
@prach resources are aligned with @ssb:pl @3gppPhysicalChannels2022.
For brevity, the average waiting time to receive an @ssb (20~slots) will be assumed as the duration between the reception of #[@sib]1 and the configured @prach occasion.
The @ue may spend the waiting time before the @prach occasion in the micro sleep state ($P_s_"Micro"$).
Following the @ue's @prach preamble transmission, the @bs announces a random access response via the @pdcch and sends it on the @pdsch @3gppPhyProceduresControl2024.
The random access response is likely delayed by several slots due to the processing time and scheduling delay at the @bs.
It will be assumed that the @bs requires four slots (2~ms) from receiving the @prach preamble to responding to it.
During these slots, the @ue monitors the @pdcch, waiting for the announcement of the response and its subsequent transmission on the @pdsch.

*@rrc Setup*:
The random access response includes an upload grant for the @rrc connection request @3gppPhyProceduresControl2024.
Assuming the default @pusch time domain resource allocation table
#footnote[
  "Default @pusch Time Domain Resource Allocation A for Normal @cp" @3gppPhyProceduresData2024
]
is used, the @pusch slot is scheduled at least four slots and at most seven slots after the reception of the random access response @3gppPhyProceduresData2024.
A scheduling time of four slots will be assumed in this work, i.e., the @ue may spend three slots in the micro sleep state before transmitting the connection request on the @pusch.
Following the reception of the connection request at the @bs, the @ran sets up the @rrc connection.
This involves #[@ran]-internal control plane communication and may take a comparably long time.
The shortest configurable @ue timeout duration for this is 100~ms @3gppRRCProtocol2024.
Without detailed timing measurements, only an educated guess can be made about the precise network timing.
Therefore, the #[@ran]-internal connection setup will be assumed to take 20~ms (40~slots), i.e., one fifths of the shortest configurable timeout duration.
During this time, the @ue monitors the @pdcch waiting for the announcement of the @bs's @rrc setup message transmission~@3gppRRCProtocol2024.
Subsequently, the setup message is transmitted on the @pdsch.

*@rrc Setup Complete*:
To acknowledge the @rrc connection setup, the @ue needs to transmit an @rrc Setup Complete message @3gppRRCProtocol2024.
The transmission is initiated by the @ue via a @sr @3gppPhyProceduresControl2024, which can be modelled by $P_t_"short"$.
Finally, the @ue receives the UL grant via the @pdcch, waits for its @pusch resource allocation (again assuming a scheduling time of 4~slots), and transmits the @rrc Setup Complete message on the @pusch.

#figure(caption: [Sync. and Conn. Establishment Slot Power Summation])[
  #table(
    columns: 3,
    align: (left, center, center),
    table.header(
      [Step],
      [Duration [slots]],
      [@ue Energy [@pu $dot$ slots]],
    ),

    ..hline(columns: 3),
    
    [Initial Synchronization],
    [20],
    [$20 P_"1SSB"$],
    
    [#[@sib]1 Reception],
    [20],
    [$19 P_(r_"CCH"+2"SSB") + P_r_"SCH"$],

    [Random Access],
    [26],
    [$20 P_s_"micro" + P_t + 4 P_r_"CCH" + P_r$],

    [@rrc Setup],
    [45],
    [$3 P_s_"micro" + P_t + 40 P_r_"CCH" + P_r$],

    [@rrc Setup Complete],
    [6],
    [$P_t_"short" + P_r_"CCH" + 3 P_s_"micro" + P_t$],

    ..hgap(columns: 3),
  )
] <tabHandoverPower>

#let slotSum = 20+20+26+45+6

Summing up the individual slot durations from @tabHandoverPower yields $T_"Handover" = #(slotSum) "slots"$, which translates to #(slotSum/2)~ms at 30~kHz @scs.
This is consistent with a blog post published by the telecommunication company Ericsson, mentioning that handovers can interrupt connections for up to 90~ms @ericsson5GAdvancedHandover.

When deriving the average handover power $P_"Handover"$, one relevant consideration is @bwp switching.
By default, the @3gpp power model considers a 100~MHz @dl @bwp.
Yet, as illustrated in @figBwpSwitching, the @bwp used for the connection establishment is substantially smaller @primerOnBandwidthParts.
Initially, #[@sib]1 is received using only 24 @rb:pl @primerOnBandwidthParts, i.e., #(24*12*30/1000)~MHz bandwidth at 30~kHz @scs. 
A comparably small initial @bwp can be assumed for random access and @rrc connection establishment.
The smallest @bwp considered by the @3gpp power model is 10~MHz.
Therefore, @dl power values need to be multiplied with a 10~MHz @bwp scaling factor.
One exception in the @3gpp power study is that the minimum scaled value for $P_r_"CCH"$ is fixed at 50~@pu, regardless of whether the scaling would result in a lower power value.
This applies when using a 10~MHz @bwp, allowing to substitute $P_r_"CCH"$ for 50~@pu.
The sum of all slot-average handover powers can thus be derived as

$
E_"Handover"
=& E_"Initial Sync." + E_"SIB1" + E_"RA" + E_"RRC Seup" + E_"RRC Setup Complete" \

=& 20 P_"1SSB" + 45 P_r_"CCH" + 26 P_s_"micro" + 3.3 P_t + \
& S_"BWP" (10 "MHz") (2 P_r + 19 P_(r_"CCH"+2"SSB") + P_r_"SCH") \

=& 3.3 P_t + 6255.75
$

Based on this, @eqHandoverPower defines the average @ue power $P_"Handover"$, given the @ue's transmit power $x$.

$
P_"Handover" (x "dBm")
=& E_"Handover" / T_"Handover"
= (3.3 P_t (x) + 6255.75) / #slotSum
approx 0.064 dot 10^(x/10) + 60.46
$ <eqHandoverPower>

@figHandoverPowerPlot plots the predicted average handover power over the @ue transmit power range.
It can be observed that a large portion of the handover power is constant, whereas the transmit power only has a notable impact in the high power range.
To obtain a deeper insight into the handover power consumption of a @ue, the slot-average powers are plotted over time in @figHandoverPower, assuming a transmit power of 0~dBm.
The relatively small transmit time explains the low impact of transmit power on the average handover power.
It also becomes evident that a considerable amount of time and @ue energy is consumed by waiting for external events, especially in the @rrc setup phase.
Since the @ue spends a relatively large fraction of the handover time in low power states compared to shared channel activity, performing a handover likely consumes less @ue energy than actively transmitting and receiving payload data in the same amount of time.

#include "./figures/model/handover-power-plot.typ"
#include "./figures/handover-power.typ"


=== Payload Traffic <secPowerModelDesignTraffic>

The @ue power consumed by payload traffic depends on the @ue's transmit power, data rate, and the payload traffic pattern, i.e., how packet arrivals are distributed over time.
Moreover, a system-level power model must also incorporate the parameters of power saving mechanisms like @drx and @bwp switching.
In the following paragraphs, the assumptions made for model development are motivated and the set of model parameters is derived.

The @3gpp power study suggests assuming Poisson-distributed packet arrivals of fixed-size packets for power evaluation
#footnote[
  @3gpp calls this traffic model "FTP 3" and assumes a packet size of 0.5 MB @3gppPowerStudy2019 @3gppFtp3TrafficModel2010.
].
This is not representative for many specific traffic patterns @perezCharacterizingTraffic2023, especially considering bursty traffic @navarroTrafficModelSurvey2020.
However, Poisson-distributed packet arrivals represent an acceptable trade-off between model complexity and accuracy.
With respect to @drx, they can be considered a conservative assumption, as their complete randomness likely makes @drx less effective than with bursty traffic patterns.
For the scheduling decisions of the @bs, the simplifying assumption is made that traffic is scheduled dynamically on a slot-by-slot basis, which is consistent with the randomness of the considered Poisson-distributed packet arrivals.
Furthermore, same-slot scheduling is assumed, i.e., a @dci transmission and its corresponding @pdsch allocation occur in the same slot.
Regarding @harq operation, it is presumed that there is enough @ul traffic to piggy-back @dl acknowledgements without distinct @pucch transmissions.
This is realistic when higher-layer protocols with an acknowledgement mechanism are applied.
Specifically, in addition to potential transport-layer acknowledgements, the @rlc protocol @3gppRadioLinkControlProtocol can also be configured to include a link-layer acknowledgement mechanism.

#figure(
  caption: [Traffic Power Model Input Parameters],
  placement: auto,
)[
  #table(
    columns: 3,
    align: (left, center, center),
    table.header([Parameter], [Symbol], [Unit]),
    ..hline(columns: 3),

    [Mean @dl packet inter-arrival time], [$T_P_D$], [ms],
    [Mean @ul packet inter-arrival time], [$T_P_U$], [ms],
    [Average @tx power], [$x$], [dBm],
    [@drx cycle length], [$T_C$], [ms],
    [@drx inactivity timer duration], [$T_I$], [ms],
    [@drx On duration], [$T_"On"$], [ms],
    [
      @dl @bwp size
      #footnote[
        According to the @3gpp power study, $S_"BWP"$ is only valid for $B_D in {10, 20, 40, 80, 100}$~@3gppPowerStudy2019.
      ]
    ], [$B_D$], [MHz],
  )
] <tabPowerModelParameters>

Based on the aforementioned assumptions, the input parameters for the power model are defined in @tabPowerModelParameters.
Given the large bandwidth available in 5G @nr, it is assumed that a single fixed-size packet can always be transferred in one slot.
Hence, payload packet size is not included as a parameter.
In the following two sections, the average @ue power consumption for the given input parameters is derived from the slot-level @3gpp power model.
This is approached by estimating the ratio of #[@drx]-induced sleep time in Section~@secPowerModelDesignTrafficDrx and averaging the slot power values according to the @ue's activities in Section~@secPowerModelDesignTrafficAvg.

==== Sleep Ratio Estimation <secPowerModelDesignTrafficDrx>

The amount of #[@drx]-induced sleep time has a significant impact on the average @ue power consumption. 
Define the expected relative amount of sleep time as

$
r_"sleep" (T_C, T_"On", T_I, T_P_D, T_P_U) in [0,1]
$ <eqSleepRatioParameters>

Appendix~@appendixSleepRatio details two approaches to analytically derive $r_"sleep"$ as a function of the input parameters, finding that an analytical representation is hard to obtain.
For this reason, a Monte-Carlo simulation will be used to approximate $r_"sleep"$ computationally.
A prerequisite for this approach is that it must yield sufficiently accurate results and at the same time fulfill the efficiency requirement from Section~@secPowerModelRequirements.
Notably, $r_"sleep"$ only needs to be computed once per traffic pattern and DRX setting, which facilitates an efficient power model implementation.
One notable benefit of estimating the sleep ratio computationally is that, unlike with an analytical solution, the traffic pattern is not limited to Poisson-distributed packet arrivals.
Instead, the poisson traffic model can effortlessly be replaced with a different traffic model in the Monte-Carlo simulation, in accordance with the extensibility requirement.

The decision for a Monte-Carlo approach requires the choice of a programming language.
Because the power model is intended to be applied in a machine learning context, where the predominant programming language is Python, the Monte-Carlo simulation should be compatible with Python.
Thus, an initial version of the simulation has been written in Python.
However, an equivalent C++ implementation yields an approximate speedup of 180, making C++ a more suitable choice with respect to the efficiency requirement.
Additionally, when using C++, the simulation loop can be parallelized effortlessly by applying OpenMP.
To maintain Python compatibility, the resulting C++ function has been exposed as a Python function using Cython#footnote[https://cython.org/].
@lstSleepRatioCore details the core simulation logic.
The full code is available online in the repository of this thesis#footnote[https://github.com/bjoluc/5g-handover-optimization].

#include "figures/model/sleep-ratio-code-listing.typ"

Applying the obtained sleep ratio simulation model, $r_"sleep"$ can be approximated efficiently by simulating a configurable number of @drx cycles.
The simulation model can also be used to gain a deeper understanding of the effects of different @ul and @dl packet rates on @ue activity for a given set of @drx parameters.
The @3gpp power study suggests $T_C = 160 "ms"$, $T_I in {40, 100} "ms"$, and $T_"On" = 8 "ms"$ as a reference @drx configuration for @ue power evaluation @3gppPowerStudy2019.
In @figSleepRatioOverTime, these @drx settings (choosing $T_I = 40"ms"$) have been applied with varying packet rates and the @ue activity probability has been plotted over the @drx cycle.
It can be observed that the @ul packet rate has a direct impact on @ue activity over the entire @drx cycle, as @ul traffic wakes up the @ue on arrival.
By contrast, @dl traffic in the absence of @ul traffic primarily activates the @ue at the beginning of a @drx cycle due to #[@drx]-induced buffering at the @bs, resulting in a higher overall sleep ratio and latency.
When @dl traffic is combined with @ul traffic, the amount of sleep time is reduced and less @dl packets arrive while the @ue is inactive, decreasing the average #[@drx]-induced latency.

#include "figures/model/sleep-ratio-over-time.typ"

Due to the communication overhead of higher-layer protocols, @ul and @dl packet rates are likely to be related for many applications.
Hence, when estimating the practical impact of @drx settings, it is natural to consider similar @ul and @dl packet rates.
@figSleepRatioPpsPlot plots $r_"sleep"$ over the average packet rate (identical for @ul and @dl), comparing the impact of a short (40~ms) and a long (100~ms) inactivity timer on the @ue's sleep ratio.
The plot shows that for a given average packet rate, the short inactivity timer expires more frequently than the long inactivity timer, resulting in a higher average sleep ratio.
As the average packet rate increases, the sleep ratios for both inactivity timer values approach zero, since the @ue is permanently kept awake by traffic.

#include "figures/model/sleep-ratio-pps.typ"

To obtain highly accurate plots, @figSleepRatioOverTime and @figSleepRatioPpsPlot have been generated by simulating $10^7$ and $10^6$ cycles, respectively.
Nevertheless, $r_"sleep"$ can be estimated sufficiently accurate ($plus.minus 0.0023$) by only simulating $10^3$ cycles for the given @drx settings
#footnote[
  These values were obtained by running $10^4$ estimations for $T_P_D=T_P_U=80"ms"$ and computing the std. deviation of $r_"sleep"$, as well as the mean computation time.
].
On a modern notebook, this takes about 72~ms on a single core and roughly 12~ms in parallel.
The time overhead required for the sleep ratio estimation is thus acceptable with respect to the efficiency requirement.
Furthermore, $r_"sleep"$ can be cached for each considered traffic pattern and DRX setting to avoid redundant computations on subsequent power estimations.


==== Slot Power Summation and Averaging <secPowerModelDesignTrafficAvg>

In Section~@secPowerModelDesignHandover, the handover power model was obtained by considering the individual @ue activities on a slot basis and summing up their slot-average power values.
A similar approach can be used for the traffic model, based on the input parameters from @tabPowerModelParameters.
This entails summing up the slot powers for an arbitrary time interval $T$ (in ms) and dividing the sum by the number $S$ of slots in $T$ (where $S=2T$ due to the assumed @scs of 30 kHz).
The sum of slots is known to be composed of a set of distinct power states, as detailed in @eqSlotDecomposition below.
#footnote[
  This decomposition does not consider @srs transmissions and @csi-rs processing to reduce model complexity.
]

$
S = 2T = S_"sleep" + S_"PDCCH+PUCCH" + S_"PUSCH" + S_"PDCCH" + S_"PDCCH+PDSCH"
$ <eqSlotDecomposition>

The term $S_"PDCCH+PUCCH"$ in @eqSlotDecomposition assumes that every slot contains a @pdcch and therefore in every @pucch slot, the @ue also receives the @pdcch. The @3gpp power model represents this combination as the sum of $P_r_"CCH"$ and $P_t_"short"$ @3gppPowerStudy2019.
In the following paragraphs, each component of @eqSlotDecomposition will be derived individually.

*@ul Traffic*:
Per the assumptions, each @ul packet requires a short @pucch for the scheduling request and one @pusch slot.
The Poisson distribution yields the expected number of @ul packets in $T$~ms as $T/T_P_U$, thus

$
S_"PDCCH+PUCCH" = S_"PUSCH" = T/T_P_U
$

*@dl Traffic:*
Per the assumptions, one @pdcch+@pdsch slot is counted for each @dl packet. Based on the Poisson distribution, the expected number of @dl packets in $T$~ms is $T/T_P_D$, therefore

$
S_"PDCCH+PDSCH" = T/T_P_D
$

The amount of sleep time is given by $r_"sleep"$, yielding

$
S_"sleep" =& r_"sleep" dot S \
$

The remaining active time is spent either in one of the active states counted above, or by receiving @pdcch.
The amount of #[@pdcch]-only slots can therefore be expressed as the remaining number of active slots after considering all other activities:

$
S_"PDCCH" = (1 - r_"sleep") dot S - (S_"PDCCH+PUCCH" + S_"PUSCH" + S_"PDCCH+PDSCH")
$

Substituting the slot counts in @eqSlotDecomposition by the derived terms above yields a formula that simplifies to $S$ as expected.
Therefore, the individual slot counts properly decompose the total number $S$ of considered slots.
In addition to the power consumption in individual slots, there is a power overhead $P^"transition"_s_"deep"$ for ramp-down and ramp-up procedures to transition into and out of a sleep state.
To account for this, the number of sleep transitions in time $T$ needs to be determined.
This can be achieved by counting the number of sleep periods in the sleep ratio simulation and normalizing it to a fixed amount of time, e.g., a cycle time.
Using this approach, define $n_"sleep" (T_P_D, T_P_U, T_C, T_"On", T_I)$ as the average number of transitions into a sleep state within a @drx cycle.    

The @ue energy consumption in $S$ slots is obtained by summing up the slot-average powers for each slot activity, as well as the additional sleep transition power.
Moreover, to respect the @dl @bwp size $B_D$, all @dl power values need to be scaled with the corresponding @bwp scaling factor. 
Dividing the energy sum by $S$ then yields the average @ue power consumption for the given input parameters, as derived in @eqTrafficPower.

$
P_"traffic" & (T_P_D, T_P_U, T_C, T_"On", T_I, x, B_D) \
=&
1 / S (
  P_s_"deep" dot S_"sleep" + P^"transition"_s_"deep" dot n_"sleep" dot T/T_C + \
  & S_"BWP" (B_D) (
    P_r_"CCH" dot (S_"PDCCH" + S_"PDCCH+PUCCH") + 
    P_r dot S_"PDCCH+PDSCH"
  ) + \
  & P_t_"short" (x) dot S_"PDCCH+PUCCH" +
  P_t (x) dot S_"PUSCH"
)
\

approx&
(1.473 dot 10^(x/10) - 0.375 B_D + 148.5)/T_P_U + (0.75 B_D + 25)/T_P_D + 0.75 B_D + 25 \
&- r_"sleep" (T_C, T_"On", T_I, T_P_D, T_P_U) (0.75 B_D + 24) \
&+ n_"sleep" (T_C, T_"On", T_I, T_P_D, T_P_U) 225/T_C \

$ <eqTrafficPower>

For further use in predictions and simulations -- specifically in the #[@rl]-based handover optimization in this thesis -- the obtained power model has been implemented as a Python module.
It includes the simulation-based sleep time estimation from Section~@secPowerModelDesignTrafficDrx, handles the caching of $r_"sleep"$ and $n_"sleep"$ estimates, and implements the power formula from @eqTrafficPower.
It has been applied to compute @ue power predictions for a variety of parameters and the results have been plotted over the average packet rate in @figTrafficPowerPpsPlot.
The considered @drx parameters have been adopted from the plots in the previous section to allow for a direct comparison of the predicted power consumption with the sleep ratio estimates in @figSleepRatioPpsPlot.
Three major effects can be observed in @figTrafficPowerPpsPlot:

#include "figures/model/traffic-power-pps.typ"

+ The #[@drx]-induced sleep time drastically decreases the average @ue power consumption at low packet rates, while having no notable impact at higher packet rates.
+ The size of the configured @dl @bwp ($B_D$) significantly impacts the overall power consumption.
  The impact of the packet rate on this effect is insignificant for the comparably low packet rates considered in @figTrafficPowerPpsPlot.
  Specifically, the power gap between a 20~MHz @bwp and an 80~MHz @bwp is almost constant for packet rates in the range of~30 to~100 packets per second.
  This can be explained by the large amount of @pdcch slots compared to only a small, packet-rate-dependent number of @pdsch slots.
  #footnote[
    At 100 @dl packets per second, on average, there is only one @pdsch slot every 20 slots.
  ]
+ The effect of a @ue's transmit power on its power consumption increases linearly with the average @ul packet rate and is independent of the @dl @bwp size. It is exponentially impacted by the given dBm transmit power value (due to the logarithmic nature of the dBm scale).
