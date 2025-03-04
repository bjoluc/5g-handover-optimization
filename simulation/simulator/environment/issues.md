# Issues (or potential issues) with mobile-env

- Invalid observations after moving UEs and re-computing datarates: Broken connections are not removed immediately after moving UEs (but at the beginning of the next step), leading to invalid observations (availability of BSs) (?)
- Physical stuff:
  - Channel model takes km, not m
  - Bandwidth needs to be taken into account for noise power calculation – invalid noise power value (not per Hertz)
  - Highly unrealistic UE SNR threshold
  - Okumura-Hata model not applicable in chosen frequency range, as per the Wikipedia page
  - SNR threshold is a UE property. However, the Shannon bound which is used for the datarate calculations involves the channel bandwidth. The SNR threshold thus needs to incorporate the bandwidth (which is a BS property in the data model) to make the cell edge depend on the channel bandwidth. Better drop `snr_threshold`, rely on the Shannon bound, and introduce `minimal_datarate` (in bits per second).
- Visualization performance can be improved significantly by reusing static "actors" across frames
- Simulation performance:
  - Creating Point objects is terribly slow (0.01 s per point on my notebook)
  - Working with numpy for scalars is on the slow-ish side too
  - SNR and utility values are redundantly computed multiple times; can be cached
- Not sure if this is an issue (or true at all; I might as well have introduced this while refactoring): The utilities in the observation and reward did not reflect the same UE positions as the observation, but the previous positions
