#import "/utils.typ": hline, hgap
#import "@preview/glossarium:0.5.3": gls

== UE Power Modeling <secRelWorkPower>

There are multiple approaches to modeling @ue power consumption, involving both empirical and theoretical models.
While empirical models are inferred from @ue power measurements, theoretical models base their predictions on knowledge about the involved electrical components and their operation.
Furthermore, the temporal granularity of a power model may vary depending on the model's use case.
In particular, slot-level models predict the average power consumption of a @ue in a single time slot, depending on the @ue's activity in that slot, while system-level models offer averaged power predictions for a longer period of time, based on higher-level parameters like data rates, traffic patterns, and network configuration.
The existing work in this field narrows down to one empirical system-level model for @lte @ue:pl (presented in Section~@secRelWorkPowerLte), and a slot-level model for 5G @nr @ue:pl (detailed in Section~@secRelWorkPower5g).


=== LTE System-Level Power Model <secRelWorkPowerLte>

#cite(<jensenPowerModelLte2012>, form: "prose") present an empirical system-level @lte power model which they obtain via linear regression using power measurements of an "@lte #gls("usb", long: false) dongle"~@jensenPowerModelLte2012.
The @ue has been chosen specifically to measure an @lte radio chip in isolation, as opposed to a mobile phone where the radio chip only accounts for a fraction of the overall power consumption~@jensenPowerModelLte2012.
It is noted that the power consumption of the entire device was measured, which, in addition to the radio chip, also includes a @usb driver.

The mathematical model definition is based on a simplistic model of the @lte physical layer's hardware, illustrated in @figLteUeHardwareModel.
The total @ue power is represented as the sum of individual component powers, which each depend on the model's input parameters.
The core components are baseband and @rf circuits for the #gls("tx", long: true) and #gls("rx", long: true) functionality, respectively.
The baseband components primarily handle encoding and decoding of @ul and @dl data, whereas the @rf components process radio signals @jensenPowerModelLte2012.
The input parameters of the power model, which are @tx/@rx power levels, @dl and @ul data rate, and the @rrc state (connected or idle) each influence the power values of the individual components.
The @ue power consumption is measured for variations of the input parameters supplied to an @lte @bs emulator, and linear regression is applied to estimate the impact of the input parameters on the respective component powers.  

#include "./figures/lte-ue-hardware-model.typ"

The resulting power model is evaluated by applying distinct input parameter sets, yielding an average prediction error of 2.6% and a maximum error of 6%.
Notably, the model does not consider @drx @jensenPowerModelLte2012.
However, #cite(<jensenPowerModelLte2012>, form: "author") have included @drx measurements in a follow-up work @lauridsenPowerModelLte2014 in which they adapt the model with mobile phone power measurements.
Furthermore, they compare two different @lte radio chip generations and find that the newer chip consumes less power.
They attribute this difference to reduced sleep power and improved sleep state transitioning.
Finally, their measurements indicate that the radio system accounts for 30--50% of the overall mobile phone power consumption @lauridsenPowerModelLte2014.

=== 5G NR Slot-Level Power Model <secRelWorkPower5g>

In a joint effort to reduce 5G @nr @ue power consumption, the 3GPP members -- including major hardware vendors -- have conducted a "Study on @ue Power Saving" which was published as a 3GPP specification in 2019 @3gppPowerStudy2019.
Within their study, a variety of vendors have performed simulations for various power saving mechanisms.
These simulations rely on a slot-level 5G @nr @ue power model which the vendors have agreed upon and published with the study results.
Therefore, it can be assumed that the model is valid for multiple vendors' @ue:pl.
Whether the values were obtained empirically or theoretically~(using the vendors' hardware designs) is not detailed in the specification.
Its temporal granularity and variety of parameters enable the slot-level model to represent a vast amount of configurations, including various bandwidths, antenna configurations, and #[@fr]2 operation.

The power model is defined as a mapping of slot activities to slot-average @ue power values, as listed in @tab3gppModel.
The mapping varies for operation in #[@fr]1 and #[@fr]2.
Because the global majority of 5G deployments operate on #[@fr]1 (93% in January 2023 @fezeuUnveiling2024), the values for #[@fr]2 are not considered below.
All power values are measured on a linear, relative @pu scale.
Relative means that, compared to an absolute power unit like milliwatts, the @pu scale is shifted s.t. one @pu corresponds to the @ue's minimum power.
The mapping of @pu to an absolute scale may depend on the considered @ue and is not provided in the specification.

#figure(caption: [3GPP 5G NR FR1 Slot-Averaged UE Power Values @3gppPowerStudy2019 @lauridsenPowerModel5g2019])[
  #table(
    columns: 2,
    align: (left, left),
    table.header(
      [Power State],
      [Relative Power per Slot [@pu]],
    ),
    
    ..hline(),

    [Deep Sleep], [
      $P_s_"deep" = 1$ \
      $P_("s"_"deep")^"transition" = 450, t_("s"_"deep")^"transition" = 40 "slots"$
    ],
    [Light Sleep],
    [
      $P_s_"light" = 20$ \
      $P_("s"_"light")^"transition" = 100, t_("s"_"light")^"transition" = 12 "slots"$
    ],
    [Micro Sleep], [
      $P_s_"micro" = 45$ \
      $P_("s"_"micro")^"transition" = 0, t_("s"_"micro")^"transition" = 0 "slots"$
    ],

    ..hline(),
  
    [1 @ssb], [$P_(1"SSB") = 75$],
    [2 @ssb:pl or @csi-rs processing], [$P_(2"SSB") = 100$],
    [2 @ssb:pl and @csi-rs processing], [$P_(2"SSB"+"CSI-RS") = 170$],
    [@pdcch and 2 @ssb:pl], [$P_(r_"CCH"+2"SSB") = 170$],
    [@pdcch only], [$P_r_"CCH" = 100$],
    [@pdsch only], [$P_r_"SCH" = 280$],
    [@pdcch + @pdsch], [$P_r = 300$],

    ..hline(),

    [Long @pucch or @pusch],
    [
      $P_t (0 "dBm") = 250$ \
      $P_t (23 "dBm") = 700$ \
    ],

    [Short @pucch (1 symb.) or @srs], [$P_t_"short" = 0.3 P_t$],

    ..hgap(),
  )
] <tab3gppModel>

The slot-level power values in @tab3gppModel assume @tdd, 30~kHz @scs, a 100~MHz @bwp, 4~@rx antennas, and 1~@tx antenna.
This configuration is representative for European mid-band 5G deployments, except for the maximum channel bandwidth, which amounts to 80~or 90~MHz in several European countries, including Germany @fezeuUnveiling2024.
The @3gpp model provides scaling factors to adapt slot power values for other configurations.
The most relevant scaling factors are listed in @tab3gppModelScaling.
If the system configuration differs from the defaults, the $P_r$ and $P_t$ values from @tab3gppModel are multiplied with their corresponding scaling factors.

#figure(caption: [Default Configuration and Power Scaling @3gppPowerStudy2019])[
  #table(
    columns: 3,
    align: (left, left, left),
    table.header(
      [Property],
      [Default Value],
      [Scaling],
    ),
    
    ..hline(columns: 3),

    [@dl @bwp  Bandwidth], [100 MHz], [For 10, 20, 40, 80 MHz @bwp:pl: \ $S_"BWP" (X "MHz") = 0.4 + 0.6 (X - 20) / 80$],
    [@ul @bwp  Bandwidth], [100 MHz], [No scaling],
    [@dl Antennas], [4 Rx], [For 2 RX: $S_(2"Rx") = 0.7$],
    [@ul Antennas], [1 Tx], [For 2 Tx: $S_(2"Tx") (0 "dBm") = 1.4$, $S_(2"Tx") (23 "dBm") = 1.2$]
  )
] <tab3gppModelScaling>

With respect to @ul transmissions, the model only provides @ue power values for transmission powers of 0~dBm and 23~dBm, omitting the interpolation formula for intermediate @tx power values @3gppPowerStudy2019.
To obtain a mapping from @tx power values (measured in dBm) to linear-scale @ue power values, the @tx power needs to be converted to a linear scale and subsequently mapped to values between $P_t (0 "dBm")$ and $P_t (23 "dBm")$: 

$
P_t (x "dBm") =& P_t (0 "dBm") + epsilon dot
underbrace(
  (10^(x/10)-1),
  "Lin. power factor"
)
$

By substitution with $x=23 "dBm"$ and solving for the interpolation constant $epsilon$, we obtain

$
epsilon =& 450/(10^(23/10)-1) approx 2.267 \
$

Therefore, the @ue power in @pu, given the @tx power in dBm, can be expressed as

$
P_t (x "dBm") approx& 250 + 2.267 dot (10^(x/10) - 1)
$ <eqTxPowerInterpolation>

Similarly, it is not mentioned how the antenna scaling factor, $S_(2"Tx") (x "dBm")$, is interpolated.
Since the factor likely models physical characteristics of the underlying circuits, a logarithmic scaling can be assumed, in line with the definition of $P_t (x)$:

$
S_(2"Tx") (x "dBm") approx& 1.4 - 0.001 dot (10^(x/10) - 1)
$ <eqTxScalingInterpolation>
