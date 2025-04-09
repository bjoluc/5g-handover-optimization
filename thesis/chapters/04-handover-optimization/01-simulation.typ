== Simulation Environment <secRlSimulation>

The work of #cite(<deepcomp2023>, form: "prose") is based on a simplistic system-level cellular network simulator developed in Python.
The authors have termed their simulation environment `mobile-env` and published it as open-source software under the permissive terms of the MIT license @mobileEnv2022.
Thus, unlike the closed-source simulation environments of several #[@rl]-based handover optimization approaches @mollelDeepRlHandovers2021 @yajnanarayanaHandoversRl2020, it can be freely applied and modified in related research.
#cite(<deepcomp2023>, form: "author") study a mobile radio network environment that is strongly related to the cellular handover environment considered in this thesis.
Therefore, `mobile-env` may serve as a baseline for the simulation environment.
In line with this approach, the following section describes the design and simulation model of `mobile-env`. Subsequently, the adaption of `mobile-env` for this thesis is addressed in Section~@secRlSimulationAdaption.


=== `mobile-env` <secRlSimulationEnvironment>

`mobile-env` is an abstract, system-level mobile radio network simulator.
It supports configurable simulation scenarios, where each scenario represents a fixed number of @bs:pl and @ue:pl that are positioned on a two-dimensional map.
An example scenario with two~@bs:pl and five~@ue:pl is depicted in @figMobileEnvExample.
The positions of the @bs:pl are fixed, while the @ue:pl move across the map according to a configurable movement pattern.
By default, a random-waypoint movement is used where each @ue repeatedly chooses a random point on the map and moves to it with a constant (configurable) velocity.
Each @ue can connect or disconnect to the various @bs:pl in its reach and -- in line with coordinated multi-point communication -- can be served by multiple @bs:pl simultaneously.
In @figMobileEnvExample, connections are represented by dashed lines and the maximum range of each @bs is indicated by a dotted circle.

#include "./figures/scenarios/mobile-env-example.typ"

Notably, the simulation makes the simplifying assumption that cells are omnidirectional and each @bs only operates one cell.
Furthermore, no distinction between @ul and @dl transmissions is made and @ue:pl are assumed to have unlimited data demands#footnote[
  The given assumptions may represent a file download scenario when core network speed is no limiting factor.
].
The data rate between a @ue and a @bs is determined as follows.
First, a channel model~(Okumura-Hata by default) is used to calculate the distance-based path loss between the @ue and the @bs.
Subsequently, the @snr of the @bs's signal at the @ue is computed by subtracting the calculated path loss from the @bs's fixed transmit power and relating it to the @ue's thermal noise level.
Inter-cell interference is not considered.
Based on the @snr, the Shannon--Hartley theorem is applied to obtain the @ue's maximum channel capacity.
Finally, the @bs schedules its resources to all connected @ue:pl.
By default, a resource-fair scheduling is assumed, i.e., the data rate for each of $N$ @ue:pl is calculated as a fraction $1/N$ of the @ue's maximum channel capacity.
When a @ue is connected to multiple @bs:pl, the @ue's total data rate is derived as the sum of all #[@bs]-scheduled data rates.

`mobile-env` has been designed specifically for @rl research.
For this reason, it has been implemented as a Gymnasium#footnote[https://github.com/Farama-Foundation/Gymnasium] environment.
Gymnasium is a Python library which defines an interface for agent-environment interactions in @rl setups @gymnasium2024.
It achieves this by providing an environment base class that can be extended by specific @rl environment implementations.
The interface of Gymnasium's environment class is outlined as a @uml diagram in @figGymnasiumInterface.
As depicted in @figRlLoop, an @rl agent interacts with its environment by repeatedly supplying an action to it and, in return, obtaining an observation and a numeric reward.
To communicate the shapes of expected actions and returned observations to the @rl agent, a Gymnasium environment exposes the definitions of action and observation spaces via its `action_space` and `observation_space` properties.
By using these definitions, @rl algorithms of various compatible frameworks can be trained with Gymnasium environments without any configuration overhead.

#include "figures/uml/gym-interface.typ"

@rl algorithms base their actions on observations and rewards.
To initialize the environment and obtain an initial observation, Gymnasium environments implement a `reset()` method.
This method can optionally be supplied with a random number generator seed to make the environment's behavior deterministic and therefore reproducible.
In subsequent interactions, the environment's `step()` method is used repeatedly to supply an action to the environment and retrieve the corresponding observation and reward.
Additionally, the `step()` method also returns the boolean flags `terminated` and `truncated`, indicating whether the task has reached a natural end or has been truncated (as eventually required for continuing tasks), respectively.
Finally, Gymnasium environments can be visualized in each step if they implement the `render()` method.
Rendering enables researchers to visually observe an agent's interactions with the environment and to intuitively assess learned policies.

As a subclass of Gymnasium's `Env` class, `mobile-env` implements the core simulation logic in its `step()` method.
This involves applying an action (i.e., connecting/disconnecting @ue:pl to/from @bs:pl), moving the @ue:pl according to their configured velocities, computing the updated channel capacities for each #[@ue]-@bs connection, scheduling the resources of each @bs between the connected @ue:pl, deriving each @ue's aggregated data rate, and finally assembling an observation vector and computing a reward value.
In addition to Gymnasium's required environment methods, `mobile-env` also implements the `render()` method in a similar manner as depicted in @figMobileEnvExample.


=== Environment Adaption <secRlSimulationAdaption>

This section elaborates on the steps that have been involved in adapting `mobile-env` to a #[@ue]-power-aware cellular handover simulation environment for the application of #[@rl] to handover optimization in this thesis.
To be applicable in this work, the environment has to (1)~restrict each @ue to a single serving cell and (2) integrate the developed system-level power model.
While the general assumptions of the `mobile-env` simulation do not enable the same level of detail as the simulations by #cite(<yajnanarayanaHandoversRl2020>, form: "prose") and #cite(<mollelDeepRlHandovers2021>, form: "prose"), implementing a more realistic physical simulation model is out of the scope of this thesis.
Based on the object-oriented architecture of `mobile-env`, the adaption was therefore planned as two actionable items:

+ 
  Create a subclass of the `mobile-env` environment that overrides the simulation's `apply_action` method to limit each @ue to one @bs at a time.
  Specifically, this can be achieved by disconnecting the @ue from the active @bs when the supplied action demands a handover to another @bs. 
+
  Create a `UserEquipment` subclass that adds a method to retrieve a @ue's current power consumption based on the power model from Chapter~@chapterPowerModeling.
  Regarding the model's input parameters, the @dl @bwp size $B_D$ is known from the configured @bs bandwidth in the `mobile-env` simulation.
  Yet, all other model parameters are not explicitly simulated by `mobile-env`.
  Therefore, assumptions have to be made for the remaining model parameters, as detailed below.
    - *@drx*:
      The operator-defined @drx parameters depend on a @ue's @5qi.
      In a general web traffic @5qi, @drx parameters similar to those observed in Section~@secPowerModelValidation can be assumed ($T_C = 320 "ms"$, $T_I = 100 "ms"$, $T_"On" = 20 "ms"$).
    - *@tx Power*:
      The @ue's @tx power can be estimated based on the simulation environment's @snr values.
      Recent measurements by #cite(<joerkeRedCapPower2025>, form: "prose") have shown a linear trend between a @ue's @snr and its #[@ran]-configured @tx power.
      The trend can be formulated as $x ("SNR" ["dB"]) = 23 "dBm" dot (1 - "SNR" / 40)$ for $"SNR" in [0,40]$.
    - *Mean @ul/@dl @iat:pl*:
      The average packet @iat depends on a @ue's application and is not simulated in `mobile-env`.
      However, based on the assumption of data-demanding @ue:pl, @dl file transfers using @tcp may be a plausible application.
      The @iat:pl of @tcp packets depend on the @rtt between the sender and receiver of a data stream.
      Assuming that the @rtt does not vary significantly, using a fixed average @iat for the power model is plausible in the considered environment.
      Varying payload data rates can be expected to affect @tcp's packet sizes without significantly impacting @iat:pl.
      Motivated by the power model's accurate validation results at 100~packets per second, a value of $T_P_D = T_P_U = 10 "ms"$ will be assumed.

While the implementation of Item~(1) resulted in the desired changes, during the implementation of Item~(2), highly unrealistic @snr values in the order of -76~dB were encountered.
The process of locating and solving the underlying issues in the physical simulation of `mobile-env` was accompanied by several iterations of refactoring in which the data model was adapted to enable the implementation of Item~(2).
Specifically, the simulation state in `mobile-env` is primarily stored in environment-global dictionary objects and handled by environment methods.
This requires extensions to be implemented globally at the environment level and prohibits fine-grained object-oriented model extensions as planned in Item~(2).
While `mobile-env` follows an object-oriented approach, model objects like `BaseStation` and `UserEquipment` primarily hold static parameters (e.g., @bs bandwidth, @ue velocity) while their simulated state (e.g., connections, scheduled data rates, @snr) is maintained globally by the environment.

#include "./figures/uml/new-model.typ"

The refactoring process involved in identifying simulation inconsistencies ultimately resulted in a more object-oriented, decentralized data model, as detailed in @figNewModelUml.
By introducing the new data model, the complexity of the environment's `step()` method has been reduced and the readability and extensibility of the simulation environment have been improved.
In the `step()` method, the environment now invokes each @ue's `move()` method, causing the @ue to change its position (maintained by its `Movement` object) and recompute the @snr and `maximal_data_rate` (channel capacity) of each of its `Connection`s.
Subsequently, the environment invokes each @bs's `schedule()` method, thereby updating the `current_data_rate` of each connection.
The adaption of the presented data model has reduced redundant @snr computations via caching and the overall simulation speed has been improved by a factor of seven in a two-@bs, five-@ue scenario.
Ultimately, the new data model has enabled the integration of the @ue power model as detailed in Item~(2).
The resulting environment is available online in the repository of this thesis and may be used for future upstream contributions.
