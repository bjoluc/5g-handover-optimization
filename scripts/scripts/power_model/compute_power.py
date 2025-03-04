from ue_power_model_5g import DrxConfig, TrafficPattern

if __name__ == "__main__":
    pps = 100
    iat = 1000 / pps
    tx_power = 23  # dBm

    power_estimate = TrafficPattern(
        iat,
        iat,
        DrxConfig(320, 20, 100),
        bwp_mhz=90,
    ).estimate_power(tx_power)

    print("Power estimate:", power_estimate)
    print("Current estimate:", power_estimate * 1.55 + 40)
