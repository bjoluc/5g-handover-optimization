#import "/utils.typ": hline, nobreak
#import "@preview/glossarium:0.5.3": gls, glspl

#let nPlusOne = [$n$#nobreak()$+$#nobreak()$1$]

== An Introduction to 5G New Radio <sec5gIntro>

The 5th Generation (5G) mobile network, standardized by the @3gpp, enables significantly higher data rates than its predecessor @lte and supports a wider frequency spectrum @dahlman5gBook2020.
These changes to the physical layer have been introduced via a new radio access technology, 5G @nr @moraisNrOverview2023.
5G @nr's physical layer is built around many of the concepts of @lte's physical layer, but enhancing it with more flexible configuration options @dahlman5gBook2020 @lteInANutshell2010.
Therefore, if @nr and @lte cells are synchronized, they can be operated alongside each other on the same frequency range without interfering with each other.

5G also specifies a new core network, providing a gradual adoption path @moraisNrOverview2023 as illustrated in @figSaNsa.
Perspectively, 5G @bs:pl are designed to be operated with a 5G core network.
This mode of operation is called @sa.
However, 5G @bs:pl (and therefore 5G @nr) can also be used in conjunction with an @lte core network to offer more bandwidth in an existing @lte deployment by combining @lte and @nr carrier frequencies.
This mode of operation is called @nsa.

#include "./figures/sa-nsa.typ"

Developing a 5G @ue power model requires a detailed understanding of the processes involved in 5G @nr communication to model the @ue's activity and power states.
The following sections therefore cover the basic functionality of 5G @nr by elaborating on the time and frequency domains (Sections~@sec5gIntroTime and @sec5gIntroFrequency, respectively), physical channel concepts and operation (Section~@sec5gIntroChannels), and common power saving mechanisms (Section~@sec5gIntroPower).

=== Time Domain and Numerologies <sec5gIntroTime>

5G @nr utilizes @ofdm, both for @dl and @ul transmissions @3gppPhysicalChannels2022.
This translates to transmitting multiple symbols in parallel on multiple subcarrier frequencies.
These subcarrier frequencies are distributed evenly across the desired frequency spectrum.
While the @dl in @lte relies on @ofdm too, its subcarrier frequencies are always (with a single exception) spaced 15 kHz apart from each other @moraisNrOverview2023.
By contrast, @nr makes the @scs configurable based on an integer $mu$, referred to as _Numerology_ @3gppPhysicalChannels2022:

$ "SCS" = 2^mu dot 15 "kHz" $

Based on the numerology, the @nr time domain is structured via a number of units (depicted in @figFrameStructure), as follows.
The largest unit is a _Frame_, denoting a duration of 10 ms.
One frame contains 10 _Subframes_, where each subframe is one millisecond long.
A subframe, in turn, consists of a number of _Slots_.
The precise number of slots in a subframe depends on the numerology.
Namely, for a given numerology $mu$, each subframe comprises $2^mu$ slots.
For instance, at 15~kHz @scs ($mu = 0$), one subframe contains one slot, while at 60~kHz @scs ($mu = 2$), a subframe contains four slots.
Finally, a slot allows for 14~@ofdm symbols to be transmitted (optionally only 12~@ofdm symbols for $mu = 2$) @3gppPhysicalChannels2022.
Transmitting one @ofdm symbol, in this context, means transmitting one symbol on each of a set of @ofdm subcarrier frequencies. 

#include "./figures/frame-structure.typ"

Complementing @figFrameStructure, the correlation between numerology, @scs, and slots is listed in @tabNumerology.
In practice, the prevalent numerology in mid-band 5G deployments is $mu = 1$, i.e., 30~kHz @scs @fezeuUnveiling2024.

#figure(caption: [Impact of the Numerology on SCS and Slots @3gppPhysicalChannels2022])[
  #table(
    columns: 5,
    align: (center, center),
    table.header(
      [$mu$],
      [@scs],
      [Slots per Subframe],
      [Slots per Frame],
      [Slot Duration],
    ),
    
    ..hline(columns: 5),

    [0], [15 kHz], [1], [10], [1 ms],
    [1], [30 kHz], [2], [20], [0.5 ms],
    [2], [60 kHz], [4], [40], [0.25 ms],
    [3], [120 kHz], [8], [80], [0.125 ms],
  )
]<tabNumerology>

5G @nr supports both @tdd -- where @ul and @dl transmissions share the same frequency range, but do not occur at the same time -- and @fdd, where @ul and @dl transmissions occur simultaneously using distinct frequency ranges.
Which mode is used depends on the authority-defined properties of the allocated spectrum (paired or unpaired spectrum) @moraisNrOverview2023.

When @tdd is applied, the @ran configures slot formats, dictating which symbols of a slot are reserved for @dl transmissions, @ul transmissions, or can be used for either of both~@3gppPhyProceduresControl2024.
As demonstrated in @figSlotFormats, a slot can be configured as entirely @dl, entirely @ul, or a combination of both, defined by a number of @dl symbols at the beginning of the slot, a number of subsequent flexible symbols, and a number of @ul symbols at the end of the slot @3gppPhyProceduresControl2024.

#include "./figures/slot-formats.typ"

=== Frequency Domain and Resource Grid <sec5gIntroFrequency>

@nr can be operated on a wider range of frequencies than @lte, most notably adding a new @fr, _FR2_, for millimeter-wave communication @dahlman5gBook2020, as illustrated on the frequency axis in @figSpectrum.
Within a @fr, @3gpp specifies multiple _Operating Bands_, portions of which may be assigned to specific mobile operators @primerOnBandwidthParts.
A mobile operator, in turn, may use its portion of an operating band to deploy cells on various frequencies and with various bandwidths.
In the EU, the predominant 5G band is n78, i.e., @tdd with frequencies in the range of 3.3 to 3.8 GHz and a cell bandwidth of at most 100 MHz @fezeuUnveiling2024.

Some @ue:pl only support limited bandwidths, which is why a dedicated #[@ue]-specific channel bandwidth is included in @figSpectrum @primerOnBandwidthParts.
Moreover, within the #[@ue]-specific channel bandwidth, the @ran can configure the @ue to only use specific @bwp:pl~@primerOnBandwidthParts.
@ul and @dl @bwp:pl are configured separately, but need to be centered around the same frequency in @tdd mode @primerOnBandwidthParts.

#include "./figures/spectrum-usage.typ"

Combining the physical resources in the time and frequency domains, the smallest allocatable resource unit is one @re, i.e., the bandwidth of one subcarrier for the duration of one symbol @3gppPhysicalChannels2022.
When multiple @re:pl are visualized in the time and frequency domains, the individual @re:pl compose a grid structure, the _Resource Grid_, as depicted in @figResourceGrid.
Moreover, in the frequency domain, a bandwidth of 12 subcarriers is denoted as a @rb @3gppPhysicalChannels2022.

#include "./figures/resource-grid.typ"


=== Physical Channels and Physical/MAC Layer Operation <sec5gIntroChannels>

5G @nr builds upon the concept of physical channels @3gppPhysicalChannels2022.
A physical channel can be thought of as a set of @re:pl used for a designated function.
@bs:pl and @ue:pl adhere to #[@3gpp]-defined rules to determine which physical channels they transmit on or decode at a given time, i.e., how resource elements are mapped to sending and receiving devices.   
This section provides an overview of @nr's physical channels, their purposes, and their interplay in the physical and @mac layers to serve @ue:pl with wireless network access.
All physical channels are listed in @tabPhysicalChannels, intended to serve as a reference in the remainder of this thesis.
In the following paragraphs, the channels and their interaction will be detailed based on a practical example, namely, the process of initial synchronization and @rrc connection establishment of a @ue with a @bs, outlined in @figConnectionSequence.

In order for a @ue to be able to connect to a cell, the @ue needs to gather basic information about the cell, such as the timing and numerology.
For this purpose, each cell periodically broadcasts a @ssb using a group ("block") of neighboring @re:pl @3gppPhyProceduresControl2024.
The @ssb contains a reference signal that the @ue also uses to measure a cell's #gls("rsrp", long: true).
Once a @ue is synchronized to a cell, it can decode basic information from it, which is broadcasted on the @pbch.
The @pbch comprises a periodic block of @re:pl known as the @mib.
A @mib is sent alongside each @ssb and indicates the cell's numerology, current system frame number, and other details required for further interaction with the cell @3gppRRCProtocol2024.

#figure(caption: [5G NR Physical Channels @3gppPhysicalChannels2022], placement: auto)[
  #table(
    columns: 2,
    align: (left, left),
    table.header(
      [Channel],
      [Purpose],
    ),
    
    ..hline(columns: 2),

    [#gls("pbch", long: true)], [
      Broadcasting the @mib to @ue:pl
    ],
    [#gls("pdcch", long: true)], [
      Announcing resource assignments (#gls("dci", long: false)) to @ue:pl
    ],
    [#gls("pdsch", long: true)], [
      - Transmitting payload data to @ue:pl
      - Broadcasting @sib:pl to @ue:pl
    ],

    ..hline(columns: 2),

    [#gls("prach", long: true)], [
      Initiating cell access
    ],
    [#gls("pucch", long: true)], [
      - Sending @sr:pl for @ul data
      - Acknowledging @dl data
      - Sending @csi reports
    ],
    [#gls("pusch", long: true)], [
      Transmitting payload data to @bs
    ],
  )
]<tabPhysicalChannels>

With the @mib decoded, the @ue can access the cell's #gls("pdsch", long: true), which carries @dl payload transmissions and a number of #glspl("sib", long: true) for all @ue:pl.
To further interact with the cell, the @ue then needs to decode the periodically transmitted #[@sib]1 from the @pdsch @synchronizationProcedure2019.
Among other information, #[@sib]1 lists the resources allocated for the #gls("prach", long: true), allowing the @ue to initially request cell access by transmitting a _Random Access Preamble_ on the @prach.

The next steps require a basic understanding of how the @bs announces @dl and @ul transmissions.
Central to this is the #gls("pdcch", long: true) @3gppPhysicalChannels2022.
It is transmitted by the @bs and received by all active @ue:pl in a cell.
The @pdcch carries #gls("dci", long: true) messages, which announce the scheduling decisions of the @bs, i.e., which @ue may transmit which @re:pl to the @bs and which @ue shall receive and decode which @re:pl from the @bs.
A single @dci message only announces scheduling decisions to one @ue at a time.
Thus, multiple @dci messages may need to be transmitted in parallel on the @pdcch, requiring a mechanism to multiplex @dci messages.
@nr solves this by applying @cdma @3gppMultiplexingAndCoding2024.
Each @ue has a cell-unique ID, the @rnti, which is used to generate a pseudo-random bit sequence for @cdma, known to both the @ue and the @bs.
The @dci message signal is then "scrambled" (XORed) with the bit sequence by the @bs, transmitted in parallel with all other @dci:pl on the @pdcch, and finally retained at the @ue again by applying the bit sequence to the received signal @3gppMultiplexingAndCoding2024.
In addition to the resource assignments for a @ue, a @dci message also dictates the @mcs for @dl and @ul transmissions.
#footnote[
  Available modulation techniques are @qpsk and 16/64/256~@qam @3gppMultiplexingAndCoding2024.
]

#include "./figures/connection-sequence.typ"

Upon receiving the @ue's Random Access Preamble, the @bs replies with a _Random Access Response_.
#footnote[
  This description assumes that the random access preamble does not collide with another @ue's access attempt at the @bs. The collision handling can be considered irrelevant within the scope of this thesis.
]
Like other @dl transmissions, the Random Access Response is first announced via a @dci on the @pdcch and subsequently transmitted on the @pdsch @3gppPhyProceduresControl2024.
The random access procedure has completed when the @ue receives the Random Access Response.
At this point, the @bs is aware of the @ue and takes responsibility for scheduling resources for its @ul and @dl transmissions.
Therefore, further @ul messages are transmitted on the #gls("pusch", long: true), and the @prach is no longer used by the @ue.

Before the @ue can send and receive payload data, it needs to establish an @rrc connection by sending an _@rrc Setup Request_.
The @bs has already included a @pusch resource assignment ("uplink grant") for the @rrc Setup Request transmission in its Random Access Response @3gppPhyProceduresControl2024.
Once the @bs has received the @rrc Setup Request, the @ran handles the connection establishment and -- upon success -- announces the @rrc connection to the @ue in an _@rrc Setup_ message @3gppRRCProtocol2024.
Like all further @dl transmissions, the transmission of the @rrc Setup message is announced on the @pdcch and carried out on the @pdsch @3gppPhyProceduresControl2024.

The final step for establishing an @rrc connection is an acknowledgement from the @ue via an _@rrc Setup Complete_ message to the @bs @3gppRRCProtocol2024.
This involves a channel which has not previously been used up to this point, the #gls("pucch", long: true)~@3gppPhysicalChannels2022.
The @pucch provides a mechanism for @ue:pl to transmit a fixed set of small control messages to the @bs without explicit scheduling by the @bs.
Most notably, this is required for #glspl("sr", long: true).
A @sr is sent by a @ue on the @pucch to indicate that it has buffered @ul data to be transmitted on the @pusch and is awaiting an @ul grant from the @bs @3gppPhyProceduresControl2024.
Messages on the @pucch are multiplexed using frequency hopping, i.e., while transmitting a @pucch message, the @ue switches between different subcarriers according to a unique pattern known by both the @ue and the @bs @3gppPhysicalChannels2022.
This pattern is provided to the @ue in the @pucch configuration.
Because it is unique for each @ue in a cell, the @pucch configuration is communicated to each @ue individually in the @rrc Setup message @3gppRRCProtocol2024.
In the previous paragraph, it was mentioned that the @bs includes an @ul grant for the @rrc Setup Request in its Random Access Response.
This is necessary because the @ue sends the @rrc Setup Request prior to receiving the @rrc Setup message with the @pucch configuration from the @bs.
Therefore, the @pucch configuration is not yet available to the @ue when sending the @rrc Setup Request, and the @ue cannot send a @sr for the transmission.
By contrast, when acknowledging the @rrc setup with an @rrc Setup Complete message, the @ue already has @pucch access and thus uses a @sr to receive an @ul grant for transmitting the @rrc Setup Complete message @3gppPhyProceduresControl2024.
The @bs, in turn, reacts to the @sr by scheduling @pusch resources for the @rrc Setup Complete message and communicating them to the @ue in a @dci via the @pdcch.
Once the @ue receives the @ul grant, it transmits the @rrc Setup Complete message on the @pusch, completing the @rrc setup upon reception at the @bs.

In addition to the basic functionality described in the previous paragraphs, the physical and @mac layers also provide a number of mechanisms that have not been mentioned in the given example, but are nonetheless relevant in the context of this thesis.
The following list briefly presents these mechanisms.

- *#gls("mimo", long: false) and Beamforming*:
  5G @nr supports #gls("mimo", long: true), a technology which exploits spacial diversity by using multiple @ue @rx and @tx antennas in parallel to increase bandwidth utilization @ahmedBeamforming2018.
  This is combined with _beamforming_ at the @bs.
  Beamforming uses an array of antennas to concentrate the intensity of individual radio signals ("beams") in specific directions, based on constructive and destructive interference between phase-shifted, amplitude-scaled radio signals transmitted on several antennas in parallel @ahmedBeamforming2018.
  Notably, the @bs transmits @ssb:pl as a burst of beams in various directions, allowing the @ue to report its preferred beam to the @bs  @synchronizationProcedure2019 @3gppPhyProceduresControl2024.
  The @bs can use this information to adapt its beam for @pdsch transmissions to the @ue, referred to as a "link beam" in some literature @yajnanarayanaHandoversRl2020.
- *@csi Measurements and Reporting*:
  The @bs periodically transmits a @csi-rs which the @ue uses to gather information about the radio conditions and report them back to the @bs @3gppPhyProceduresData2024.
  The reporting conditions, frequency, and which metrics the @ue reports are determined by the @ran and provided to the @ue via @rrc messages @3gppPhyProceduresData2024.
  Measurement reports can be transmitted via the @pucch or the @pusch @3gppPhyProceduresData2024.
- *@srs:pl*:
  @srs:pl are periodically transmitted by connected @ue:pl based on #[@rrc]-configured settings provided by the @ran @3gppPhysicalChannels2022.
  They complement @csi reports by allowing the @bs to perform detailed channel estimation measurements itself, as opposed to receiving measurement results from the @ue.
- *#gls("rrm", long: false) Measurements and Reporting*:
  Similar to @csi measurements, the @ran can configure #gls("rrm", long: true) measurements @3gppRRCProtocol2024.
  While @csi measurements consider the serving cell, @rrm measurements gather information about neighboring cells to enable the @ran to make informed handover decisions.
  @rrm measurements can be triggered on specified conditions, e.g., if the serving cell @rsrp drops below a configured threshold @3gppRRCProtocol2024.
- *#gls("harq", long: false)*:
  Hybrid Automatic Repeat Requests is the mechanism responsible for acknowledging transmissions and requesting retransmissions in case of transmission errors.
  @harq utilizes forward error correction in combination with positive (ACK) and negative (NACK) acknowledgements based on checksums @3gppMultiplexingAndCoding2024.
  Acknowledgements are typically piggy-backed on @pusch/@pdsch transmissions @3gppPhyProceduresControl2024.
  Otherwise, they can also be transmitted individually on the @pucch or included in the @dci on the @pdcch, depending on the transmission direction @3gppPhyProceduresControl2024.
- *@pucch Formats*:
  There are @pucch formats with various lengths and purposes.
  Short @pucch formats only require up to two symbols and can be used for @sr:pl or @harq acknowledgements @dahlman5gBook2020.
  Longer @pucch formarts are available to increase coverage by transmitting more symbols for the same amount of payload information~@dahlman5gBook2020.
- *Semi-Persistent Scheduling*:
  Instead of announcing each @pdsch transmission individually via a @dci message on the @pdcch, the @ran can also configure a recurrent schedule via @rrc messages @3gppMac2024.
  @dci is then used to announce the activation or deactivation of a given schedule.
  A similar mechanism is also available for the @pusch, where it is called _Configured Grant_ @3gppMac2024. 

=== Power Saving Mechanisms <sec5gIntroPower>

Because @ue:pl are typically battery-powered, 5G @nr has been designed with a focus on energy efficiency.
This involves several mechanisms to reduce the power consumption of @ue:pl, most notably @drx and @bwp Switching.
Both techniques will be presented in the following two sections.

==== Discontinuous Reception <sec5gIntroPowerDrx>

@drx exploits the fact that a large amount of @ue energy is consumed by frequently monitoring the @pdcch, checking wheter the @bs transmits a @dci message to inform the @ue of an upcoming @dl transmission.
However, mobile network user traffic is oftentimes irregular and inherently bursty @perezCharacterizingTraffic2023.
This may result in long inter-arrival times between traffic bursts, during which the @ue monitors the @pdcch without any @dl traffic being announced by the @bs.
@drx allows the @ue to enter a sleep state when no traffic is available, only periodically waking up to be informed if @dl traffic has arrived at the @bs in the meantime @3gppMac2024.
Depending on the user traffic pattern, this can significantly reduce @ue power consumption at the cost of higher maximum latencies.
To avoid disruptive latencies, the @drx parameters for a @ue thus have to be selected in alignment with the @ue's @qos requirements.
5G tracks @qos requirements via @5qi:pl~@3gppSystemArchitecture2024.
The standard @5qi for web traffic (buffered video streaming, #gls("tcp", long: false)-based web apps, etc.) dictates a packet delay budget of 300 ms @3gppSystemArchitecture2024, i.e., the @drx parameters need to be set s.t. a @ue never sleeps more than 300 ms at a time.

5G @nr defines two types of @drx: @cdrx and Idle Mode @drx.
@cdrx applies when an @rrc connection is active and, as described above, allows the @ue to temporarily enter a sleep state instead of monitoring the @pdcch @3gppMac2024. 
Idle Mode @drx, on the other hand, applies when no @rrc connection is established and controls the periodic reception of paging messages from a @bs @3gppSystemArchitecture2024.
As the focus of this thesis is on handover optimization, which does not involve the @rrc Idle state, only @cdrx will be considered in the remainder of this work.
As such, the terms "@drx" and "@cdrx" will be used synonymously.
The following paragraphs further explain the @cdrx mechanism and its parameters.

#include "./figures/drx.typ"

The @drx concept is based on cycles with a configurable cycle duration and starting time (subframe) @3gppMac2024.
@figDrx depicts the activity of a @ue over several @drx cycles.
The @ue keeps track of various timers, most importantly an _On duration timer_ and an _inactivity timer_.
#footnote[
  In addition to these timers, the @drx specification also defines timers for nested ("short") @drx cycles, as well as @harq retransmission timers for @ul and @dl @3gppMac2024.
  Those details will not be considered here, given that their impact on @ue power consumption is presumably small in relation to the added complexity.
]
Timers are set to #[@rrc]-configured values on specific events and trigger actions when they expire.
At the beginning of each cycle (or a configured number of slots after the cycle's beginning), the @ue sets its On duration timer and monitors the @pdcch while the timer is running.
This time period is also referred to as the _On duration_.
If no transmission has been announced during the On duration, the @ue enters a sleep state when the On duration timer expires.
If any @dl packet arrives at the @bs while the @ue is asleep, the @bs buffers the packet and transmits it at the beginning of the next cycle's On duration.

Additionally, whenever a transmission (@dl or @ul) is announced on the @pdcch, the @ue (re)sets its inactivity timer.
While the inactivity timer is running, the @ue keeps monitoring the @pdcch, even if the On duration timer has already expired.
If the inactivity timer expires and the On duration timer is not active, the @ue enters a sleep state again.
In @figDrx, no packet arrives during the On duration of @drx cycle $n$, allowing the @ue to sleep for the rest of the cycle.
At the beginning of the On duration in @drx cycle #nPlusOne, there is no @pdsch transmission.
It can therefore be assumed that no @dl packet has arrived at the @bs while the @ue was asleep.
Shortly before the end of the On duration in cycle #nPlusOne, the @bs schedules a @pdsch transmission, making the @ue set its inactivity timer and stay active despite the expiry of the On duration timer.
In this example, there is no follow-up transmission and the inactivity timer expires after a while, allowing the @ue to enter a sleep state for the rest of cycle #nPlusOne.
Conceptually, the inactivity timer ensures that a @ue stays active for the entire duration of a traffic burst and only becomes inactive between bursts.
Therefore, @drx does not disrupt active data flows, but saves @ue energy when no data is being transmitted.

The example in @figDrx only involves @dl traffic.
Yet, traffic bursts may also be initiated by @ul transmissions, for instance when a @ue requests a web page.
In that case, there is no need for the @ue to wait for the next On duration.
Instead, when the @ue receives @ul data from upper network layers while in a @drx sleep period, it immediately wakes up and transmits a @sr to the @bs, subsequently monitoring the @pdcch for the corresponding @ul grant @3gppMac2024.
Upon receiving the @ul grant, the @ue sets its inactivity timer and proceeds as usual.
@figDrxUl demonstrates the @ue activities when @ul traffic arrives in a @drx sleep period.
It is worth noting that the inactivity timer is set when receiving the @dci for a transmission, not upon the transmission itself.
This causes a gap between the start of the inactivity timer and the @pusch transmission in @figDrxUl, given that @pusch transmissions are announced several slots in advance @3gppPhyProceduresData2024.

#include "./figures/drx-ul.typ"


==== BWP Switching <sec5gIntroPowerBwpSwitching>

The power that a @ue requires to monitor the @pdcch is rouqhly proportional to the bandwidth across which the @pdcch is received @3gppPowerStudy2019.
Given the large cell bandwidths that 5G @nr supports, considerable amounts of @ue energy can thus be saved by reducing the bandwidth for a @ue when it does not utilize its full bandwidth.
@bwp switching denotes the practice of dynamically selecting the @dl or @ul @bwp:pl used by a @ue @primerOnBandwidthParts.
It can either be performed on behalf of the @ran via @rrc signalling, or automatically based on an inactivity timer.

#include "./figures/bwp-switching.typ"

@figBwpSwitching demonstrates @bwp switching for a @ue which connects to a @nr cell (operated in @fdd mode) and transfers a burst of payload data, followed by an idle period.
Initially, during synchronization and connection establishment, only a small @bwp (the "initial" @bwp) is used.
The initial @bwp is communicated to the @ue in #[@sib]1 @primerOnBandwidthParts.
Once the @rrc connection has been set up, however, the @dl and @ul @bwp:pl are switched via @rrc signalling, providing a larger bandwidth for the payload data transfer.
In addition to #[@rrc]-signalled @bwp switching, the @ue in this example has also been configured with an inactivity timer, similar to the @drx inactivity timer.
Once the inactivity timer expires, the @ue switches to the configured default @bwp @primerOnBandwidthParts.
In @figBwpSwitching, this mechanism is applied to the @dl @bwp to reduce the power required for @pdcch monitoring when there is no transmission activity.
The size of the @ul @bwp only impacts the power that the @ue consumes for @ul transmissions (including occasional @srs:pl) and therefore has no significant effect on @ue power consumption when there is no payload data.
Therefore, the @ul @bwp is not switched by the inactivity timer in this example.
