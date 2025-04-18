#import "/cetz.typ": canvas, draw
#import "@preview/cetz-plot:0.1.1": plot
#import "@preview/subpar:0.2.1"

#let analyticalApproximation(x, N: 1) = {
  return calc.pow(1 - calc.pow(1 - x, N), N+1)
}

#let dataN1 = ((0.0,0.0),(0.0204,0.0),(0.0408,0.0),(0.0612,0.0),(0.0816,0.0),(0.102,0.0),(0.1224,0.0),(0.1429,0.0),(0.1633,0.0),(0.1837,0.0),(0.2041,0.0),(0.2245,0.0),(0.2449,0.0),(0.2653,0.0),(0.2857,0.0),(0.3061,0.0),(0.3265,0.0),(0.3469,0.0),(0.3673,0.0),(0.3878,0.0),(0.4082,0.0),(0.4286,0.0),(0.449,0.0),(0.4694,0.0),(0.4898,0.0),(0.5102,0.0206),(0.5306,0.0612),(0.551,0.1007),(0.5714,0.1426),(0.5918,0.1837),(0.6122,0.2246),(0.6327,0.2664),(0.6531,0.3057),(0.6735,0.3461),(0.6939,0.3873),(0.7143,0.4285),(0.7347,0.4693),(0.7551,0.5098),(0.7755,0.5506),(0.7959,0.5913),(0.8163,0.634),(0.8367,0.6754),(0.8571,0.7145),(0.8776,0.7559),(0.898,0.7969),(0.9184,0.8357),(0.9388,0.8772),(0.9592,0.9183),(0.9796,0.9593),(1.0,1.0))

#let dataN2 = ((0.0,0.0),(0.0204,0.0),(0.0408,0.0),(0.0612,0.0),(0.0816,0.0),(0.102,0.0),(0.1224,0.0),(0.1429,0.0),(0.1633,0.0),(0.1837,0.0),(0.2041,0.0),(0.2245,0.0),(0.2449,0.0),(0.2653,0.0),(0.2857,0.0),(0.3061,0.0),(0.3265,0.0),(0.3469,0.0017),(0.3673,0.0104),(0.3878,0.0266),(0.4082,0.0505),(0.4286,0.0826),(0.449,0.1198),(0.4694,0.1683),(0.4898,0.2201),(0.5102,0.2803),(0.5306,0.3384),(0.551,0.3946),(0.5714,0.449),(0.5918,0.5001),(0.6122,0.5473),(0.6327,0.5946),(0.6531,0.6379),(0.6735,0.6793),(0.6939,0.7173),(0.7143,0.7554),(0.7347,0.7891),(0.7551,0.8198),(0.7755,0.8495),(0.7959,0.8744),(0.8163,0.8984),(0.8367,0.9196),(0.8571,0.9384),(0.8776,0.9553),(0.898,0.9682),(0.9184,0.9793),(0.9388,0.9887),(0.9592,0.9948),(0.9796,0.9988),(1.0,1.0))

#let dataN4 = ((0.0,0.0),(0.0204,0.0),(0.0408,0.0),(0.0612,0.0),(0.0816,0.0),(0.102,0.0),(0.1224,0.0),(0.1429,0.0),(0.1633,0.0),(0.1837,0.0),(0.2041,0.0),(0.2245,0.0003),(0.2449,0.0025),(0.2653,0.0115),(0.2857,0.0315),(0.3061,0.0669),(0.3265,0.1152),(0.3469,0.1798),(0.3673,0.249),(0.3878,0.3228),(0.4082,0.3977),(0.4286,0.4714),(0.449,0.5411),(0.4694,0.6037),(0.4898,0.6608),(0.5102,0.7122),(0.5306,0.7583),(0.551,0.7964),(0.5714,0.8311),(0.5918,0.862),(0.6122,0.888),(0.6327,0.9089),(0.6531,0.9273),(0.6735,0.943),(0.6939,0.9561),(0.7143,0.9665),(0.7347,0.9747),(0.7551,0.9818),(0.7755,0.9874),(0.7959,0.9912),(0.8163,0.9943),(0.8367,0.9965),(0.8571,0.998),(0.8776,0.9989),(0.898,0.9995),(0.9184,0.9998),(0.9388,0.9999),(0.9592,1.0),(0.9796,1.0),(1.0,1.0))

#let dataN8 = ((0.0,0.0),(0.0204,0.0),(0.0408,0.0),(0.0612,0.0),(0.0816,0.0),(0.102,0.0),(0.1224,0.0),(0.1429,0.0),(0.1633,0.0016),(0.1837,0.0133),(0.2041,0.049),(0.2245,0.1169),(0.2449,0.2119),(0.2653,0.3202),(0.2857,0.4311),(0.3061,0.5337),(0.3265,0.6252),(0.3469,0.7057),(0.3673,0.7692),(0.3878,0.8226),(0.4082,0.8642),(0.4286,0.8972),(0.449,0.9236),(0.4694,0.9438),(0.4898,0.9584),(0.5102,0.97),(0.5306,0.9791),(0.551,0.9852),(0.5714,0.9896),(0.5918,0.9931),(0.6122,0.9955),(0.6327,0.997),(0.6531,0.9982),(0.6735,0.9988),(0.6939,0.9994),(0.7143,0.9996),(0.7347,0.9998),(0.7551,0.9999),(0.7755,1.0),(0.7959,1.0),(0.8163,1.0),(0.8367,1.0),(0.8571,1.0),(0.8776,1.0),(0.898,1.0),(0.9184,1.0),(0.9388,1.0),(0.9592,1.0),(0.9796,1.0),(1.0,1.0))

#let makeSubFigure(N, simulationData, legend: none) = {
  let approximation = analyticalApproximation.with(N: N)

  figure(
    canvas({
      draw.set-style(
        axes: (stroke: .5pt, tick: (stroke: .5pt)),
        legend: (stroke: none, spacing: 0.25, item: (spacing: .5em), fill: none)
      )
      plot.plot(
        size: (6.5, 4),
        x-label: $T_I\/t$,
        x-tick-step: 0.2,
        y-label: [$PP(t_i<= T_I)$],
        y-min: 0,
        y-tick-step: 0.5,
        y-max: 1,
        legend: legend,
        {
          let add = plot.add.with(domain: (0, 1))
          add(
            approximation,
            label: [Analytical Approximation],
            style: (stroke: (dash: "dashed"))
          )
          add(
            simulationData,
            label: [Monte-Carlo Simulation],
            style: (stroke: black),
          )

          add(
            simulationData.map(((x, y)) => {
              return (x, calc.abs(approximation(x) - y))
            }),
            label: [Approximation Error],
            style: (stroke: (dash: "dotted"))
          )
          
        }
      )
    }),
    caption: $N=#N$,
  )
}

#subpar.grid(
  makeSubFigure(1, dataN1, legend: "inner-north-west"), <a>,
  makeSubFigure(2, dataN2), <a>,
  makeSubFigure(4, dataN4), <a>,
  makeSubFigure(8, dataN8), <a>,
  columns: (1fr, 1fr),
  caption: [Analytical Approximation vs. Monte-Carlo Simulation of $PP(max{t_1,dots,t_(N+1)} <= T_I)$  for $0 <= T_I/t <= 1$ and $N={1,2,4,8}$],
  label: <figDirichletMonteCarlo>,
  placement: auto,
)
