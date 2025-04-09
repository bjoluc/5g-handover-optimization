# Enhancing Cellular Handovers: Optimizing Quality of Experience using Machine Learning

This repository hosts the source code of and assets related to my [Master's Thesis](/thesis.pdf) about 5G Handover Optimization w.r.t. Quality of Experience.
Here's the abstract:

> Cellular handovers ensure the continuous connectivity of mobile devices as they move through various mobile network cells.
> Handover decisions in mobile networks can significantly impact the Quality of Experience of mobile device users as they influence both the achievable data rate and the power consumption of a mobile device.
> This thesis optimizes cellular handovers using a machine learning technique (Reinforcement Learning), considering both power consumption and data rates.
> To quantify power consumption of mobile devices, a power model is developed and validated with power measurements in a commercial mobile network.
> The model is subsequently integrated into a system-level simulator for cellular handovers and applied to jointly optimize data rates and power consumption of mobile network devices with respect to Quality of Experience.
> Both the developed model and the handover simulation environment are publicly available and can be applied and extended in future network research.

The repository contains the following projects:

- `power-model`: A Python implementation of the system-level 5G NR UE power model developed in the thesis
- `scripts`: All the measurement, plotting, and symbolic computation scripts used for the power model and its measurement-based validation
- `simulation`: A UE-power-aware, simplified and extended fork of the system-level cellular network simulator [`mobile-env`](https://github.com/stefanbschneider/mobile-env), plus a bunch of scripts for training and testing Reinforcement Learning agents on the environment.
- `thesis`: The [Typst](https://typst.app/) code of the thesis
- `presentation`: The Typst code of the thesis presentation
