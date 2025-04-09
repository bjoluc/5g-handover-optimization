== Measurement-Based Validation <secPowerModelValidation>

As mentioned at the beginning of this chapter, the configuration of commercial 5G deployments is operator-defined and does not exhibit sufficient variability to fit an empirical power model.
Yet, the theoretical power model that was designed in the previous section can be compared against @ue power measurements obtained in a commercial 5G deployment to evaluate the model's accuracy.
For this purpose, the mobile operator Deutsche Telekom AG has volunteered to provide the necessary resources, including SIM cards that are enabled for @sa and @nsa, respectively.
This way, the power model predictions can be validated for a specific set of network parameters.
Furthermore, the model's applicability to @nsa, which is the prevalent mode of operation in commercial 5G deployments~@fezeuUnveiling2024, can be evaluated.

Conducting @ue power measurements requires a suitable @ue.
Because the power consumption of the baseband processor in a commercially available mobile phone cannot easily be measured in isolation, #cite(<jensenPowerModelLte2012>, form: "prose") have applied an "@lte @usb dongle" @jensenPowerModelLte2012 for their empirical power model.
Such a product is not readily available with 5G support.
However, there are external 5G modules with an M.2 form factor which can be controlled via a @usb connection.
Therefore, the decision has been made to use a Waveshare SIM8202G-M2 5G HAT
#footnote[https://www.waveshare.com/sim8202g-m2-5g-hat.htm], which consists of a @pcb providing various external interfaces to a Simcom SIM8202G-M2 5G module.
The 5G module, in turn, features a Qualcomm Snapdragon x55 5G baseband processor
#footnote[
  https://www.qualcomm.com/products/technology/modems/snapdragon-x55-5g-modem
]
which is also used in a number of commodity mobile phones, including Samsung's Galaxy~S20 and Apple's iPhone~12.
Hence, the considered baseband processor is likely to be representative for a broad number of @ue:pl.

In order to enable isolated power measurements of the radio module, the @pcb has been modified to separate the module's power supply from the @pcb's 4.2~V rail#footnote[denoted as "VBAT" in the schematic @simcom5gHatSchematic] @simcom5gHatSchematic.
External sockets have been mounted to separately access the 4.2~V rail and the module's power supply pins.
Given the near constant voltage supply of 4.2~V, the module's power consumption can be assumed to be proportional to its current draw.
Thus, measuring @ue power consumption translates to measuring the @ue's electrical current.
In an initial attempt, a Siglent SDM~3045X digital multimeter has been used to measure the current draw of the radio module.
However, the multimeter's maximum sampling rate of 150~Hz has proved to be too coarse to capture short current peaks and gain sufficient insight into the @ue's activities.
For this reason, the multimeter has been replaced with a TiePie Handyscope HS3 @usb oscilloscope with a maximum sampling rate of up to 100~MHz.
To infer the module's current draw from the oscilloscope's voltage measurements, a 0.5~Ohms shunt resistor is applied.
Two channels of the oscilloscope are used to record the voltage between ground and both sides of the shunt.
Subsequently, a Python-based measurement script is applied to compute currents from the measured voltage differences.
To obtain sufficiently detailed measurements, a sampling frequency of 32~kHz is used, resulting in 16 samples per 5G @nr slot at 30~kHz @scs.
Notably, due to the use of a @usb oscilloscope, the measurement setup is portable and can be powered by a notebook.

For the experiments, the modem is connected to a notebook via two @usb cables for power supply and data transfer, respectively.
The data @usb connection serves two purposes.
First, it is used to transfer data plane traffic.
Second, control plane messages can be exchanged with the modem via the @qmi.
This allows to configure the modem, control radio connections, and retrieve metadata about the modem's state
#footnote[
  This has been implemented using the `libqmi` library (https://www.freedesktop.org/wiki/Software/libqmi/) via its GLib Python bindings.
].
For the generation of payload data in compliance with the power model's traffic assumptions, fixed-size random-byte @udp packets with exponentially distributed inter-arrival times are exchanged between the @ue and an external server.
The @udp protocol has been chosen to avoid transport-layer communication overhead.

An initial set of current measurements has been obtained without payload traffic#footnote[A @dl packet has been received every four seconds to keep the @ue in @rrc connected mode during the measurements.] to estimate @ran parameters and analyze the @ue's power states.
The measurements have been performed with a 5G @nr cell on the n78 frequency band (@tdd) using a center frequency of 3626.4~MHz. 
The cell's bandwidth is not exposed via the @qmi protocol
#footnote[
  The @qmi protocol specifies a response field for the channel bandwidth, but the given @ue does not return this information for 5G @nr cells. 
], but the mobile operator is known to support a bandwidth of 90~MHz on the given band @fezeuUnveiling2024.
@bs and @ue were in line of sight and the @ue reported an @rsrp of -62~dBm.

#include "./figures/measurements/idle-drx.typ"

@figCurrentIdleDrx shows the @ue's current in @rrc connected mode over a period of 1.28~seconds.
Because the signal has been reduced for plotting, very short high-current peaks are not depicted accurately.
The current curve indicates a periodic activity, alternating with a low-power state, characterized by a current of 37~mA.
It must be assumed that the activity is caused by the @drx On duration and the low-power state represents the @ue's deep sleep state.
Presuming a @drx cycle duration of $T_C = 320 "ms"$, it is evident that the @ue wakes up a variable time before the beginning of the On duration. 
This may be required to maintain the @ue's synchronization or perform @rrm measurements and is not considered by the developed power model.  
To examine the @ue's active power states, the third On duration from @figCurrentIdleDrx is depicted on a finer time scale in @figCurrentIdleDrxOn.
Apparently, the @drx On duration starts at 15~ms in the plot and ends a bit after 35~ms, followed by the deep-sleep ramp-down procedure.
This indicates that -- according to the #[@3gpp]-specified set of configurable timer values -- the On duration timer has been configured to $T_"On"=20 "ms"$.
The operator has confirmed these @drx settings and furthermore provided the inactivity timer value $T_I=100 "ms"$.
It has also been noted that a minimum On duration of 10~ms has been configured to the @bs which, in turn, adapts this value as needed for channel estimation (eg., @srs or @csi-rs).
With respect to channel estimation, the recurring current peaks in @figCurrentIdleDrxOn (starting at 17~ms) have proven to be @srs:pl, as a group of @srs:pl (four in this plot) occurs every 80~slots, which is the operator-confirmed @srs periodicity for @tdd cells.

#include "./figures/measurements/idle-drx-on-duration.typ"

During the On duration, the @ue is required to monitor the @pdcch.
This can be observed as a recurring current peak at slot frequency, i.e., every 0.5~ms.
In #[@pdcch]-only slots, this peak is followed by a micro-sleep period for the rest of the slot duration.
Notably, according to the currents in @figCurrentIdleDrxOn, every fifths slot does not seem to be configured for a @pdcch transmission.
These are also the slots in which a @srs is transmitted.
Further measurements involving @ul transmissions -- which are not detailed here for brevity -- indicate that every fifths slot is configured as #[@ul]-only, preceded by four #[@dl]-only slots.

A number of slots do not involve micro-sleep periods.
Particularly, in every 10th slot~(starting at 15~ms in @figCurrentIdleDrxOn), the @pdcch reception is followed by another activity at a similar power level.
Since the @drx inactivity timer is not triggered by these activities, payload @pdsch transmissions can be ruled out as a reason.
A possible cause, however, may be the frequent processing of received @csi-rs signals.
Additionally, @figCurrentIdleDrxOn shows prolonged activity at 17.5~ms and at 22~ms.
The activity at 17.5~ms may be caused by a less frequent #[@rrc]-related @dl event that does not trigger the inactivity timer, like the reception of an @sib or a dedicated @rrc message on the @pdsch @3gppMac2024.
By contrast, the activity at 22~ms causes a slightly higher current and is located after the @srs in an #[@ul]-only slot.
It might therefore be a low-transmit-power @ul (@pusch or long @pucch) transmission.


In the previous paragraphs, relevant #[@ran]-configured parameters have been derived from fine-grained @ue current measurements and the currents have been linked to specific activities at the slot level.
In order to evaluate the accuracy of the previous section's power model, a mapping of the model's relative @pu values to absolute @ue currents is required.
This can be established using the slot-average currents of the individual slot activities.
For this purpose, @figCurrentIdleDrxOnSlots averages the currents from @figCurrentIdleDrxOn per slot to enable a direct comparison with the @pu values from the @3gpp power model.
Moreover, the plot also marks the slot-average current for each of the observed activities.

#include "./figures/measurements/idle-drx-on-duration-slots.typ"

Per the @3gpp power model's definition of a power unit, 1~@pu represents the deep sleep power.
Hence, the linear mapping of @pu:pl to Milliamperes can be expressed as 

$
I(p) = a (p-1) + I_s_"deep"
$ <eqPowerMapping1>

where $I_s_"deep" = 40 "mA"$ is the @ue's deep sleep current.
The scaling factor $a$ in @eqPowerMapping1 may be obtained by substitution, using one of the determined slot-average current values and its corresponding @pu value.
In @figCurrentIdleDrxOnSlots, the most frequently observed non-sleep power state is $P_r_"CCH"$ with an equivalent current of 182~mA.
It is therefore used to obtain the value of $a$ in @eqPowerMapping2 below.

// @dl activities depend on BWP size (not exposed by modem in 5G SA mode).

#let getBwpScaling(bw) = 0.4 + 0.6*(bw - 20)/80
#let bwpScaling = getBwpScaling(90)

#let idlePowerMa = 40 // mA

#let referencePowerPu = 100 * bwpScaling // PU
#let referencePowerMa = 182 // mA

#let a = (referencePowerMa - idlePowerMa) / (referencePowerPu - 1)

#let powerUnitsToMilliamps(p) = a*(p - 1) + idlePowerMa

$
I(S_"BWP" (90 "MHz") P_r_"CCH") = #referencePowerMa space
=> space a approx #(calc.round(a, digits: 2))
$ <eqPowerMapping2>

The @bwp scaling for 90~MHz is applied to represent the considered cell's bandwidth in the @3gpp power model's @pu value.
Notably, the @3gpp model does not specify $S_"BWP"$ for 90~MHz.
Nevertheless, the linear definition of $S_"BWP"$ for other bandwidths suggests that the scaling is not substantially inaccurate for 90~MHz either.

Finally, the resulting #[@pu]-to-mA mapping $I(p)$ can be used to compare predictions of the system-level @ue power model with the average measured @ue currents for various conditions.
Due to the complexity of accurately timing and measuring the synchronization and connection establishment procedure, the handover power model from Section~@secPowerModelDesignHandover is not validated in this work.
By contrast, the traffic power model from Section~@secPowerModelDesignTraffic can be validated more easily by exposing the @ue to varying traffic patterns and averaging the measured @ue current.
Because @drx and @bwp settings, as well as the @tx power, are #[@ran]-configured, only traffic patterns can be fully controlled in the given experiment setup.
Hence, the measurements in this section primarily consider the avg. @ul/@dl packet rate, in analogy to the power model plots in @figTrafficPowerPpsPlot.

As mentioned above, in accordance with the model assumptions, the generated payload traffic consists of Poisson-distributed, fixed-size @udp packets with a configurable inter-arrival time.
Regarding the packet size, the #[@3gpp]-defined FTP~3 traffic model assumes the transmission of files with a fixed size of 512~kB.
Payloads of this size cannot be transmitted in a single @udp packet.
Introducing multiple subsequent @udp packets, however, does not comply with the exponential inter-arrival time assumption and therefore might affect the @drx sleep time.  
Furthermore, a typical network-enforced @mtu is 1500~Bytes, resulting in fragmentation of larger packets @3gppSystemArchitecture2024.
Hence, to avoid fragmentation, the payload size of a @dl @udp packet has been fixed to 1~kB.
Furthermore, to mimic typical downlink-heavy traffic, the @ul packet size has been set to 0.25~kB.
A preliminary measurement series at 200~packets per second has shown that a varying packet size in the range from 16~Bytes to 1~kB has no noticeable impact on the average @ue power consumption.

Due to the oscilloscope's limited buffer size, current measurements at the given sample rate can only last up to four seconds.
To determine the @ue's average current for a given packet rate, the oscilloscope is therefore used to repeatedly measure a four-second interval, followed by a gap of about 250~ms, respectively, to transfer, process, and average the measurements.
For each considered packet rate, a total time of #(4*4)~seconds is measured as a batch of four-second measurements.
For packet rates below 21~packets per second, this time has been increased to #(16*4)~seconds to account for the large current variance stemming from infrequent packet arrivals and @drx.
To further reduce variance due to varying cell loads and #[@bs]-configured @ue transmit powers, the above measurements have been repeated nine times#footnote[
This number was chosen due to practical time constraints. Thanks to the team of actiVita Paderborn for offering their gym as a measurement location for several nights!
]
per packet rate, for rates from 1~to 200~packets per second, yielding a total measurement time of #(9*4*(20*16 + 180*4)/60/60)~hours.
The order of measured packet rates was further randomized in each iteration to avoid capturing time-related effects in the resulting average power curve. 
The measurement procedure has been performed once for a @sa setup and once for a @nsa setup in the same cell (n78, 3626.4~MHz), at the same location (-62~dBm @rsrp), and at the same time of day (over night).
Notably, the @rsrp of the primary @lte cell (band~3, @fdd, 1720~MHz @ul, 1815~MHz @dl, 20~MHz bandwidth) in @nsa mode was only reported as -79~dBm.

#include "./figures/measurements/pps.typ"

The resulting current measurements have been plotted in @figPowerOverPps, including the corresponding mapped traffic power model predictions $I(P_"traffic")$ for an assumed transmit power of 0~dBm#footnote[
  The @ue does not expose its transmit power for 5G NR cells via its @qmi interface. The assumption of 0~dBm is motivated by the high @rsrp values resulting from the line-of-sight communication with the @bs. 
] and a @bwp size $B_D = 90 "MHz"$.
Compared to the @sa measurements, the power model predictions exhibit a mean error of 7.8% for the given parameters.
Four key observations can be made:

+ While the power model's current predictions have a strong linear dependency on the average packet rate, the measurements only show a minor trend.
+ The general effect of the @drx mechanism on @ue power consumption is adequately represented.
+ The #[@drx]-based average current reduction at low packet rates is less significant than predicted by the model.
+ @sa operation consistently exhibits lower average currents than @nsa operation in the considered setup. The mean difference is 65~mA and the mean @sa power reduction compared to @nsa is 23%.

Notably, all effects predicted by the model can also be observed in the measurements for both @sa and @nsa.
However, the intensity of these effects does not match the experiment results, as described in observations~(1) and~(3).
With respect to Observation~(1), the different effect sizes may partially stem from dynamically configured bandwidth parts, intelligent @bs scheduling decisions (e.g., combining multiple successive small packets into one transmission), or the use of an overly small packet size in the measurement setup.
Regarding Observation~(3), the reduced effect size of #[@drx]-induced sleep time on the @ue power consumption is likely related to the @ue's activities before the @drx On duration~(as observed in @figCurrentIdleDrx and @figCurrentIdleDrxOn).
It is also impacted by active-mode activities such as @csi-rs processing and @srs transmissions, which are not considered by the power model.
Furthermore, the ratios between the #[@3gpp]-defined power values for various slot activities are not guaranteed to equally apply to every @ue, introducing further inaccuracy and possibly further impacting the effect sizes in observations~(1) and~(3).
With regard to Observation~(4), the reduced power consumption of @sa compared to @nsa is likely caused by additional @ue activities in @nsa mode, introduced by the carrier aggregation of an @lte frequency band with a 5G @nr band.


Another power-relevant model parameter worth validating is the @ue's transmit power~$x$.
Unlike packet rates, however, the transmit power cannot be chosen arbitrarily by the @ue as it is ultimately configured by the @bs @3gppMac2024.
Yet, the path loss can be increased incrementally by stepwise moving the @ue away from the @bs, leading the @bs to configure a higher @ue transmit power.
@figPowerOverRsrp plots the results of such an experiment
#footnote[
  Winter poses unique challenges for outdoor experiments.
  @figPowerOverRsrp combines data from two experiments on separate days.
]
with a fixed packet rate of 100~packets per second (for @ul and @dl).
At that rate, under the Poisson assumption for packet arrivals, it is highly unlikely to trigger the @drx inactivity timer of 100~ms.
Hence, the Poisson assumption has no notable impact on @ue power consumption and the packet inter-arrival time has been fixed to 10~ms to reduce traffic-based @ue power variance in the measurements.
The experiment has been conducted by repeatedly measuring four-second current averages, each followed by a short interval to move the @ue further away from the @bs, until the @ue was handed over to another cell by the @ran.
As mentioned before, the configured transmit power is not exposed by the particular @ue and therefore has not been captured.
Instead, the measurements have been plotted over the #[@ue]-determined @rsrp.
Furthermore, the current-mapped power model predictions at the given traffic rate have been plotted for the model's minimum and maximum transmit power. 
The maximum transmit power of 23~dBm matches the @ue's power class for the cell's frequency band @simcom5gHatHardwareDesign.

#include "./figures/measurements/rsrp.typ"

It can be observed that the measured @ue powers primarily lie within the model-predicted power range.
Yet, several individual measurements exceed the predicted maximal power.
Apart from model inaccuracy, this may also be caused by retransmissions due to fading effects resulting from unintended @ue movements.
Because specific @tx power values are not available, the measurements cannot be compared with detailed model predictions.

To conclude the validation section, based on the conducted experiments, the developed traffic power model has been proven to conceptually capture the power impact of its parameters, although the specific effect sizes are not accurate and vary depending on the @ue and @ran configuration.
Further measurements with varying @ran parameters, especially @bwp sizes, would be required to evaluate the model in greater detail.
Yet, this cannot easily be achieved with commercial 5G deployments.
Furthermore, the validation performed in this section is limited by the lack of access to the @ue's @bwp size and @tx power values.
While more detailed measurements -- including parameter variations such as higher data rates -- can still be achieved with the current setup, an in-depth analysis is not within the scope of this thesis.
If more accurate predictions for a given @ue and @ran are required, the developed power model may also be adopted via scaling of individual power values to better represent a specific @ue.
Nevertheless, without further changes, the obtained model predicts the effects of relevant system-level parameters on @ue power consumption with sufficient accuracy to be used for @ue power estimation in system-level simulations. 
