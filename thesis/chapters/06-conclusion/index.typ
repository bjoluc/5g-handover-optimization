#import "@preview/glossarium:0.5.3": gls

= Conclusion <chapterConclusion>

This thesis has investigated the optimization of handover decisions with respect to the #gls("qoe", long: true) perceived by users of mobile radio network devices.
@qoe depends on many factors, including data rates and power consumption of battery-powered mobile devices (@ue:pl).
To study the impact of handover decisions on @ue power consumption, a theoretical system-level @ue power model for 5G New Radio networks has been developed.
The model has been derived from an existing fine-grained industry-standard power model and validated with @ue power measurements obtained in a commercial 5G deployment in cooperation with the mobile network operator Deutsche Telekom AG.
While the model's predictions properly represent the effects of system-level parameters on @ue power consumption, the predicted effect sizes differ from the effect sizes that were observed in the power measurements.
Nevertheless, the developed power model is extensible and may be adapted to improve its accuracy for specific @ue:pl if more precise power predictions are required in a given network configuration.
For practical use in handover optimization, the developed power model has been implemented as a Python package and integrated into an existing system-level cellular network simulator.

To optimize handover decisions for @qoe with respect to data rates and @ue power consumption, #gls("rl", long: true) has been applied to the developed #[@ue]-power-aware network simulator.
Several approaches have been investigated to improve the performance of @rl in handover optimization.
The resulting handover decision policy has been evaluated and compared with an off-the-shelf handover mechanism, revealing a minor @qoe improvement.
Finally, the developed power model, measurement scripts, and #[@rl]-tailored #[@ue]-power-aware handover simulation environment are openly available#footnote[https://github.com/bjoluc/5g-handover-optimization] under the MIT license.
They can be built upon in future research to further enhance @qoe in mobile radio networks.
