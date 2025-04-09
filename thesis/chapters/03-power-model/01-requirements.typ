== Requirements <secPowerModelRequirements>

To be applicable to handover optimization, the @ue power model developed in this thesis must consider handover/synchronization procedures, as well as payload traffic in @rrc connected mode.
By contrast, the power consumed by a @ue in @rrc idle mode is not relevant for handover optimization as handovers only apply to connected @ue:pl.
It can therefore be omitted from the power model.
Finally, @ue:pl also consume power for @rrm measurements.
However, this power heavily depends on the @ran configuration and network deployment while only accounting for a small fraction of @ue power consumption~@3gppPowerStudy2019.
It~is therefore omitted to reduce model complexity.
In addition to the previous considerations, the following enumeration motivates further model requirements.

+ *System-Level Granularity*:
  @rl research on handovers is commonly performed using system-level simulations @yajnanarayanaHandoversRl2020 @mollelDeepRlHandovers2021 @deepcomp2023 @mobileEnv2022.
  Because system-level simulations for cellular handovers do not model every component of a system in-depth and especially do not operate on a millisecond scale, a slot-level power model cannot easily be integrated into a system-level simulation.
  Therefore, the developed power model must be able to predict average @ue power consumption on a coarser time scale, i.e., a system-level power model is required.
+ *Accuracy*:
  The model should accurately represent the effects of its input parameters on @ue power consumption to enable realistic predictions.
+ *Configurability*:
  In order for the power model to prove useful in handover-driven @ue power optimization, it must adequately represent @ran and cell configurations that impact @ue power consumption.
  This requires the model to be configurable with those parameters.
  However, if there are multiple options for deployment parameters which effect power consumption and one option is predominantly found in today's deployments, that option shall be assumed to reduce model complexity.
+ *Efficiency*:
  The model should minimize time- and resource-intensive computations, s.t. it can be embedded in a system-level simulation without significantly impacting simulation performance.
+ *Extensibility*:
  The model should be extensible to account for further parameters and mechanisms in future research.
