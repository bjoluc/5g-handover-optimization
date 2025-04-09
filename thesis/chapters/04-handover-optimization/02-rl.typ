#import "/utils.typ": hline

== Reinforcement Learning <secHandoverOptimizationRl>

Based on the #[@ue]-power-aware cellular handover simulation environment developed above, this section examines the application of @rl algorithms to optimize @qoe via data rates and @ue power consumption.
While off-the-shelf #[@rsrp]-driven cell selection does not necessarily yield optimal data rates @icellspeed2020 @hassanCase2024 @yajnanarayanaHandoversRl2020, the power model developed in this thesis suggests that -- within the domain of 5G @nr cells -- it may nevertheless yield an optimal power consumption due to low transmit powers.
This is underlined by the power measurements in @figPowerOverRsrp, which indicate reduced power consumption for higher @rsrp:pl.
Therefore, by deviating from #[@rsrp]-based handover decisions, an #[@rl]-driven handover algorithm may unintentionally increase @ue power consumption, despite optimizing @qoe as a function of data rates and @ue power.
An example for a situation with conflicting data rate and power consumption is provided in @figTradeoffExample, where the @ue:pl are distributed unevenly across the two cells.
When the leftmost @ue stays connected with the left cell, all @ue:pl can achieve higher data rates than by sharing a single cell, yet the leftmost @ue has to use increased transmit power.
By comparison, an #[@rsrp]-based handover mechanism would already have handed the leftmost @ue over to the right cell.

Applying the developed #[@ue]-power-aware cellular handover simulation environment allows to jointly evaluate and compare the effects of an @rl agent's decisions on data rates and @ue power consumption.
This section is organized in three parts, as follows.
Section~@secRlInterface handles the definition of actions, observations, and rewards.
Subsequently, incremental improvements to optimize the @rl agent's performance are discussed and applied in Section~@secRlEvolution.
Finally, the best policy is compared against a conventional #[@rsrp]-driven handover approach in Section~@secRlEvaluation.

#include "figures/scenarios/tradeoff-example.typ"

=== Interface <secRlInterface>

In Chapter~@chapterRelatedWork, three distinct #[@rl]-based cell selection solutions have been presented -- among them two data-rate-driven handover optimizations @yajnanarayanaHandoversRl2020 @mollelDeepRlHandovers2021 and one #[@qoe]-driven cooperative multi-point solution @deepcomp2023.
Despite the different scope of each approach, a common baseline is their observation space.
Notably, all three approaches rely on an observation vector that, for each @ue, contains the measured signal strength (either @rsrp or @snr) of each cell.
This data is readily available at the @ran, since the @ue:pl provide it via their @rrm measurement reports.
The combination of all cell @snr:pl for a given @ue allows an @rl agent to estimate the @ue's physical location and therefore take appropriate handover actions.
Furthermore, #cite(<mollelDeepRlHandovers2021>, form: "prose") and #cite(<deepcomp2023>, form: "prose") also include one-hot-encoded connection vectors for each @ue in their observation space, informing the agent about the current cell choices.
Based on the promising results of the presented approaches, the same observation space will initially be applied in the next section's @rl experiments.

To consider @qoe as a function of data rates, #cite(<deepcomp2023>, form: "author") rely on a logarithmic @ue utility function, inspired by empirical research indicating such effects @fiedlerQoE2010 @hossfeldQoE2010.
The function is included in `mobile-env` and depicted in @figLogUtility.
Motivated by the observations of #cite(<fiedlerQoE2010>, form: "prose"), it will likewise be used as an estimation for @qoe based on the simulated data rates in the following @rl experiments.
For consistency with the approach of #cite(<deepcomp2023>, form: "author"), each @ue's @qoe value will also be included in the observation.
Similarly, the mean @ue @qoe will serve as the reward signal.
Finally, the agent's action space is chosen as a vector of cell ids, where each vector element represents the selected cell of a specific @ue.

#include "figures/log-utility.typ"

=== Evolution <secRlEvolution>

To experimentally investigate different reward functions and observation space extensions, a series of training sessions with varying configurations has been carried out.
In each session, a policy is learned using the state-of-the-art @rl algorithm @ppo @schulmanPPO2017#footnote[
  The @ppo implementation of Stable Baselines 3 was used in this work.
] in a small simulation environment comprising two @bs:pl and eight @ue:pl.
Similar to the experiments by #cite(<deepcomp2023>, form: "author"), each episode is truncated after 100 time steps.
All @ue:pl are configured to move with a velocity of 15~meters per time step.
The environment simulates an area of $2.6 times 1.6 "km"$, which is fully covered by the two cells, yet contains cell-edge regions for each cell.
The horizontal distance between the @bs:pl is $1.2 "km"$ and the @bs:pl are centered on the map.
Both cells are operated on the 5G @nr band n78 with a bandwidth of 90~MHz and a center frequency of 3600~MHz.
The @bs und @ue height are set to 15~m and 1.5~m, respectively.
Resource-fair scheduling is applied and the @bs:pl' transmit power is configured to 30~dBm.
A standard thermal noise density of -173.8~dBm/Hz is assumed for @ue receptions.
During the training sessions, every 100 trained episodes, the agent's policy has been evaluated for a duration of 20 episodes.
Evaluation metrics include the average number of connected @ue:pl, the mean data rates, @qoe:pl, and connected @ue power consumption.
The following paragraphs detail the challenges and solutions involved in optimizing @qoe via handover decisions.

Notably, training a @ppo agent for 0.6~million training steps with observation and rewards configured as described in the previous section already yields an intelligent policy that significantly improves the evaluation metrics over the course of the training period.
This can be observed via the dotted "Init" curves in @figRlSessions.
For each evaluation metric, the average value in an evaluation period has been plotted as a curve over the training step count.
A single evaluation period is only 20~episodes (i.e., 2000~steps) long.
Therefore, the average values in each evaluation period are subject to noise caused by varying @ue movement patterns in each evaluation period.
Namely, in one evaluation, @ue movements may lead to shorter average #[@bs]-to-@ue distances and therefore enable higher data rates than in another evaluation.
For easier comparison of the curves in @figRlSessions, the lines have been interpolated.

Despite the agent's improvement on the considered metrics, the obtained policy is not yet ideal.
Specifically, when observing the policy using the environment's rendering feature, a number of flaws can be identified.
In the following paragraphs, each of these flaws is presented and solutions are developed by adapting the reward function and observation space.
The training evaluation curves for each adaption are included in @figRlSessions, respectively. 

#include "figures/rl-sessions/sessions.typ"

*Repeated Handovers*:
When a @ue is within the range of two cells, the obtained initial policy occasionally shows an alternating handover behavior where a @ue is repeatedly handed over between two cells.
While this may increase the agent's total reward by equally sharing cell bandwidths, it must be prevented in practice to avoid service interruptions for the @ue.
A natural approach involves penalizing handovers, as applied by #cite(<mollelDeepRlHandovers2021>, form: "prose").
Therefore, for each handover action in a step, the @qoe in that step is set to~-1.
In successive steps without handovers, the @qoe values remain unchanged.
Intuitively, this represents the drop of a user's @qoe during a handover where application traffic is interrupted for a short time.

By applying this change (denoted as "Penalty" in @figRlSessions) to the reward function, the amount of repeated handovers is reduced.
Yet, repeated handovers still occasionally occur shortly before reaching a cell edge.
On closer examination, it becomes evident that the agent can only infer a @ue's position from its @snr measurements, yet cannot know the movement direction and velocity of the @ue.
Therefore, the agent cannot be certain whether a @ue at the cell edge has just arrived in the cell or is about to leave the cell.
A solution to this is the inclusion of an @snr velocity vector in the observation space.
Due to the variance of @snr values in real systems, this velocity vector would likely require the use of a moving average to avoid strong influence of temporary @snr fluctuations.
Yet, the movement and channel model in the `mobile-env`-based simulation environment do not exhibit short-term variations.
Therefore, in the context of this work, an @snr velocity vector can be computed as the difference of the previous and the next @snr vector.
Adding a per-@ue velocity vector to the observation space finally solves the repeated handover issue.
Notably, @snr velocities alone, without penalizing handovers, are not sufficient to prevent repeated handovers.

*Starvation*:
It can be observed that, occasionally, in loaded cells, the agent does not connect an individual @ue.
This may optimize the average @qoe under certain conditions, by "sacrificing" an individual @ue to avoid reducing the @qoe of all other @ue:pl in the cell.
Yet, this behavior is inacceptable in practice.
The issue can be solved by penalizing the agent with the maximum negative reward (-1) in any step in which at least one @ue is not connected, but in reach of a @bs.
The resulting evaluation curves are listed as "Collective Penalty" in @figRlSessions.

*Fairness*:
Another issue with the obtained policies is that, in some situations, they are inherently unfair, e.g., by excluding a @ue from a loaded cell and connecting it to a neighboring cell to optimize overall @ue @qoe, as depicted in @figTradeoffExample.
Apparently, optimizing mean @qoe and optimizing @qoe fairness pose a trade-off in certain situations.
To control the amount of desired fairness -- at the cost of overall @qoe, the mean @qoe reward signal can be weighted with a dedicated fairness reward signal.
A commonly used fairness metric is "Jain's fairness index" @jainsFairness1998.
To improve @qoe fairness, Jain's fairness index can be computed, normalized to the reward range $[-1,1]$, and subsequently be weighted with the mean @qoe reward signal.
Several training sessions with various fairness weights have shown a fairness weight of 0.5 to yield the best results with respect to the average @ue @qoe in evaluation episodes.

*Missed Handover Chances*:
Based on the given observation space, the agent sometimes waits to apply handover actions that, intuitively, seem to optimize both mean @qoe and @qoe fairness.
In case the agent misses information to consider a specific @ue's immediate handover, it can be helpful to include a flag in the observation space that indicates when a better choice may be available for the given @ue.
To evaluate this approach, each @ue's observation vector has been extended with a flag that is set to `true` as soon as a cell with a higher @snr than the serving cell is available.
Notably, this mechanism -- listed as "Better @snr Flag" in @figRlSessions -- has further improved the agent's reward. 

Finally, to further optimize the results of the @rl agent, the hyper parameter tuning framework Obtuna#footnote[https://optuna.org/] has been applied to automatically optimize the hyper parameters of the @ppo algorithm for increased rewards.
Primarily, this has shown that a decreased learning rate (approximately~0.00008, as opposed to Stable Baselines' default value of~0.0003) yields better results for the given task.
In @figRlSessions, the final and best result obtained by combining all above methods with tuned hyper parameters is denoted "HP Opt." and plotted as a black line.


=== Evaluation <secRlEvaluation>

With regard to the training evaluation metrics from the previous section, a broad evaluation and comparison among the various @rl policies has already been obtained.
Contrary to the previous approach, this section only considers the last and best policy and evaluates it in greater detail.
While the evaluation metric averages in @figRlSessions were obtained by applying each policy for only 2000 steps, the evaluation in this section collects the metrics over a duration of one million simulation steps to reduce the impact of random @ue movements.

#let differencePercent(rsrpValue, rlValue) = {
  let relativeDifference = (rlValue - rsrpValue) / rsrpValue
  [
    #(if relativeDifference > 0 {"+"} else {""})#(calc.round(relativeDifference * 100, digits: 3))~%
  ]
}

#figure(
  caption: [Average Evaluation Metrics for RL vs. RSRP-based Handovers],
  placement: auto,
)[
  #table(
    columns: 4,
    align: (left,center,center,right),
    table.header(
      [Metric],
      [@rsrp Mean (std.)],
      [@rl Mean (std.)],
      [Difference [%]],
    ),

    ..hline(columns: 4),

    [@ue @qoe $in[-1,1]$],
    [$0.242 space (0.138)$],
    [$0.244 space (0.135)$],
    differencePercent(0.2417, 0.2436),

    [@ue @qoe Fairness Index (Jain)],
    [$0.919 space (0.049)$],
    [$0.921 space (0.046)$],
    differencePercent(0.9191, 0.9209),

    [@ue Data Rate [Mbps]],
    [$14.707 space (12.673)$],
    [$14.486 space (12.077)$],
    differencePercent(14.7074, 14.4858),

    [\# Connected @ue:pl],
    [$8.000 space (0.000)$],
    [$7.999 space (0.028)$],
    differencePercent(8.0000, 7.9992),

    [Connected @ue Power [@pu]],
    [$148.078 space (2.314)$],
    [$148.082 space (2.312)$],
    differencePercent(148.0784, 148.0821),
  )
] <tabRlSnrEvaluation>

@tabRlSnrEvaluation details the average metrics of the evaluated #[@rl]-based handover policy in direct comparison with the values obtained by an off-the-shelf #[@rsrp]-based handover algorithm.
Both approaches have been tested with an identically seeded environment.
Therefore, the comparison involves no movement-induced noise. 
It can be observed that both algorithms do not yield significantly different results in the given simulation environment.
Yet, the @rl policy has managed to achieve a slightly better @ue @qoe and fairness of @qoe, at the cost of a minor average data rate reduction.
The improvement of @qoe, however, only totals less than one percent of the #[@rsrp]-based @qoe average. 
With respect to @ue power consumption, no significant relative difference can be observed.

#include "figures/kde-pdfs/qoe.typ"

To enable an in-depth analysis of the achieved @qoe improvement, @figQoePdf plots the probability density function of all @ue:pl' @qoe values throughout the simulation.
While the overall distribution does not vary significantly between the two approaches, the #[@rl]-based approach has slightly reduced the probability of low @qoe values and instead concentrated it in the medium @qoe region.
In the following chapter, the obtained results will be discussed in the broader context of this thesis.
