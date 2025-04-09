#import "/thesis/utils.typ": hline

#let differencePercent(rsrpValue, rlValue) = {
  let relativeDifference = (rlValue - rsrpValue) / rsrpValue
  [
    #(if relativeDifference > 0 {"+"} else {""})#(calc.round(relativeDifference * 100, digits: 3))~%
  ]
}

#figure(caption: [Average Evaluation Metrics for RL vs. RSRP-based Handovers])[
  #table(
    columns: 4,
    align: (left,center,center,right),
    table.header(
      [Metric],
      [RSRP Mean (std.)],
      [RL Mean (std.)],
      [Difference [%]],
    ),

    ..hline(columns: 4),

    [UE QoE $in[-1,1]$],
    [$0.242 space (0.138)$],
    [$0.244 space (0.135)$],
    [*#differencePercent(0.2417, 0.2436)*],

    [UE QoE Fairness Index (Jain)],
    [$0.919 space (0.049)$],
    [$0.921 space (0.046)$],
    differencePercent(0.9191, 0.9209),

    [UE Data Rate [Mbps]],
    [$14.707 space (12.673)$],
    [$14.486 space (12.077)$],
    differencePercent(14.7074, 14.4858),

    [Connected UE Power [PU]],
    [$148.078 space (2.314)$],
    [$148.082 space (2.312)$],
    differencePercent(148.0784, 148.0821),
  )
]