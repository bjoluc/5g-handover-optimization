#import "./utils.typ": plotCurrentOverTime
#import "@preview/cetz-plot:0.1.1": plot

#let data = ((3e-05,39.2211),(0.00053,38.2593),(0.00103,38.3333),(0.00153,37.5207),(0.00203,45.2901),(0.00253,51.1306),(0.00303,72.6491),(0.00353,70.9154),(0.00403,79.7222),(0.00453,128.6607),(0.00503,127.9222),(0.00553,178.1337),(0.00603,471.426),(0.00653,166.8759),(0.00703,149.0744),(0.00753,130.4033),(0.00803,134.9841),(0.00853,129.465),(0.00903,130.9298),(0.00953,131.6826),(0.01003,135.7788),(0.01053,131.6444),(0.01103,143.052),(0.01153,129.1416),(0.01203,132.3366),(0.01253,130.5183),(0.01303,165.0457),(0.01353,152.1007),(0.01403,136.9011),(0.01453,149.8153),(0.01503,248.2063),(0.01553,186.8707),(0.01603,182.5858),(0.01653,242.1731),(0.01703,170.9608),(0.01753,249.0071),(0.01803,254.4062),(0.01853,187.3143),(0.01903,176.4715),(0.01953,174.3625),(0.02003,247.2668),(0.02053,192.638),(0.02103,179.9941),(0.02153,272.0357),(0.02203,281.4709),(0.02253,199.9052),(0.02303,181.8594),(0.02353,183.2975),(0.02403,178.149),(0.02453,176.8316),(0.02503,246.9075),(0.02553,191.3128),(0.02603,184.9241),(0.02653,253.7128),(0.02703,170.0196),(0.02753,186.5212),(0.02803,185.1846),(0.02853,195.385),(0.02903,180.3822),(0.02953,190.9688),(0.03003,264.3496),(0.03053,190.8581),(0.03103,184.8897),(0.03153,263.7658),(0.03203,171.7713),(0.03253,185.7516),(0.03303,186.8571),(0.03353,186.2061),(0.03403,195.237),(0.03453,179.3411),(0.03503,268.0679),(0.03553,223.2177),(0.03603,176.7994),(0.03653,167.3606),(0.03703,143.5944),(0.03753,129.2592),(0.03803,144.6566),(0.03853,134.4443),(0.03903,109.1102),(0.03953,77.4111),(0.04003,48.8229),(0.04053,38.6178),(0.04103,38.9531),(0.04153,38.8313),(0.04203,38.2287),(0.04253,39.0327))

#let addCurrentLevel(label, current, dash) = {
  plot.add-hline(current, label: [#current mA -- #label], style: (stroke: (paint: black, dash: dash, thickness: 1pt)))
}

#figure(
  caption: [Slot-Averaged DRX On Duration Current],
  placement: auto,
)[
  #plotCurrentOverTime(
    data,
    xTickStep: 5,
    plotHeight: 8,
    plotWidth: 14,
    yMax: 500,
    yTickStep: 100,
    yMinorTickStep: 20,
    isSlotted: true,
    useMilliseconds: true,
    additionalPlotContent: {
      addCurrentLevel([@pusch/@pucch], 280, "loosely-dotted")
      addCurrentLevel([@pdcch+@csi-rs/@pdsch,~@srs], 250, "dotted")
      addCurrentLevel([@pdcch], 182, "densely-dotted")
      addCurrentLevel([Micro Sleep], 130, "dashed")
      addCurrentLevel([Deep Sleep], 40, "loosely-dashed")
    },
  )
] <figCurrentIdleDrxOnSlots>
