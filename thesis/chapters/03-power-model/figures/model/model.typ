#let handoverPower(txPowerDbm) = {
  return 0.064 * calc.pow(10, (txPowerDbm/10)) + 60.46
}
