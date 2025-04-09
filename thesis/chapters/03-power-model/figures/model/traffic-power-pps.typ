#import "/cetz.typ": canvas
#import "@preview/cetz-plot:0.1.1": plot

#let dataTx0Bwp80 = ((0.0,6.3442),(1.0,20.1548),(2.0,30.6222),(3.0,39.3599),(4.0,46.6481),(5.0,52.758),(6.0,57.9317),(7.0,62.4319),(8.0,66.3319),(9.0,69.7073),(10.0,72.6169),(11.0,75.2521),(12.0,77.4785),(13.0,79.246),(14.0,81.012),(15.0,82.2186),(16.0,83.3588),(17.0,84.5006),(18.0,85.3497),(19.0,86.1714),(20.0,86.8532),(21.0,87.4861),(22.0,88.0492),(23.0,88.4944),(24.0,88.9003),(25.0,89.2493),(26.0,89.6568),(27.0,89.9566),(28.0,90.2805),(29.0,90.5858),(30.0,90.8492),(31.0,91.104),(32.0,91.3491),(33.0,91.5982),(34.0,91.8376),(35.0,92.0622),(36.0,92.2858),(37.0,92.5046),(38.0,92.7284),(39.0,92.9479),(40.0,93.152),(41.0,93.3736),(42.0,93.5838),(43.0,93.7949),(44.0,94.003),(45.0,94.204),(46.0,94.4146),(47.0,94.6244),(48.0,94.8309),(49.0,95.0363),(50.0,95.2423),(51.0,95.4507),(52.0,95.6568),(53.0,95.8614),(54.0,96.0656),(55.0,96.2728),(56.0,96.4772),(57.0,96.684),(58.0,96.8889),(59.0,97.0938),(60.0,97.2984),(61.0,97.5039),(62.0,97.709),(63.0,97.9141),(64.0,98.1196),(65.0,98.3245),(66.0,98.5295),(67.0,98.7349),(68.0,98.9398),(69.0,99.1446),(70.0,99.3497),(71.0,99.5548),(72.0,99.7595),(73.0,99.9646),(74.0,100.1695),(75.0,100.3745),(76.0,100.5798),(77.0,100.7848),(78.0,100.9896),(79.0,101.1946),(80.0,101.3999),(81.0,101.6049),(82.0,101.8098),(83.0,102.0145),(84.0,102.2195),(85.0,102.425),(86.0,102.63),(87.0,102.8349),(88.0,103.04),(89.0,103.245),(90.0,103.4497),(91.0,103.655),(92.0,103.8597),(93.0,104.0648),(94.0,104.27),(95.0,104.4749),(96.0,104.6798),(97.0,104.885),(98.0,105.0897),(99.0,105.295),(100.0,105.5))

#let dataTx20Bwp80 = ((0.0,6.3448),(1.0,20.211),(2.0,31.0665),(3.0,39.7662),(4.0,47.0296),(5.0,53.3551),(6.0,58.6239),(7.0,63.6319),(8.0,67.4065),(9.0,71.1925),(10.0,74.1586),(11.0,76.8867),(12.0,79.1144),(13.0,81.2236),(14.0,82.9562),(15.0,84.409),(16.0,85.7596),(17.0,87.0103),(18.0,88.035),(19.0,88.9231),(20.0,89.7546),(21.0,90.5161),(22.0,91.2384),(23.0,91.8557),(24.0,92.4006),(25.0,92.8679),(26.0,93.452),(27.0,93.8813),(28.0,94.372),(29.0,94.8126),(30.0,95.2098),(31.0,95.6217),(32.0,96.0224),(33.0,96.4067),(34.0,96.8057),(35.0,97.1673),(36.0,97.5462),(37.0,97.9053),(38.0,98.2725),(39.0,98.6286),(40.0,98.9893),(41.0,99.3511),(42.0,99.7131),(43.0,100.0609),(44.0,100.4192),(45.0,100.7723),(46.0,101.129),(47.0,101.482),(48.0,101.8345),(49.0,102.1864),(50.0,102.5356),(51.0,102.8908),(52.0,103.2388),(53.0,103.5924),(54.0,103.9431),(55.0,104.2961),(56.0,104.6456),(57.0,104.997),(58.0,105.3487),(59.0,105.6993),(60.0,106.0505),(61.0,106.402),(62.0,106.7525),(63.0,107.1029),(64.0,107.4536),(65.0,107.8054),(66.0,108.1563),(67.0,108.5074),(68.0,108.8581),(69.0,109.2092),(70.0,109.56),(71.0,109.911),(72.0,110.2618),(73.0,110.6129),(74.0,110.9636),(75.0,111.3143),(76.0,111.6652),(77.0,112.016),(78.0,112.367),(79.0,112.7175),(80.0,113.0688),(81.0,113.4194),(82.0,113.7706),(83.0,114.1214),(84.0,114.4721),(85.0,114.8233),(86.0,115.1737),(87.0,115.5249),(88.0,115.8758),(89.0,116.2265),(90.0,116.5774),(91.0,116.9281),(92.0,117.2793),(93.0,117.6301),(94.0,117.9809),(95.0,118.3318),(96.0,118.6825),(97.0,119.0336),(98.0,119.3845),(99.0,119.7353),(100.0,120.086))

#let dataTx23Bwp80 = ((0.0,6.3438),(1.0,20.4148),(2.0,31.4302),(3.0,40.2357),(4.0,47.7381),(5.0,54.107),(6.0,59.7222),(7.0,64.4528),(8.0,68.7589),(9.0,72.3445),(10.0,75.5556),(11.0,78.4433),(12.0,80.9068),(13.0,83.0938),(14.0,85.0526),(15.0,86.6035),(16.0,88.1114),(17.0,89.4873),(18.0,90.6669),(19.0,91.7461),(20.0,92.6701),(21.0,93.5832),(22.0,94.4444),(23.0,95.2307),(24.0,95.9295),(25.0,96.5538),(26.0,97.2474),(27.0,97.8548),(28.0,98.4593),(29.0,99.0572),(30.0,99.605),(31.0,100.1779),(32.0,100.7091),(33.0,101.2448),(34.0,101.7788),(35.0,102.2902),(36.0,102.8287),(37.0,103.3286),(38.0,103.8436),(39.0,104.3481),(40.0,104.8519),(41.0,105.3625),(42.0,105.8707),(43.0,106.375),(44.0,106.8725),(45.0,107.3685),(46.0,107.8735),(47.0,108.3695),(48.0,108.8728),(49.0,109.3724),(50.0,109.8689),(51.0,110.366),(52.0,110.8667),(53.0,111.3647),(54.0,111.8625),(55.0,112.3607),(56.0,112.8574),(57.0,113.3561),(58.0,113.8534),(59.0,114.3513),(60.0,114.8492),(61.0,115.3466),(62.0,115.8436),(63.0,116.3415),(64.0,116.8391),(65.0,117.3372),(66.0,117.8349),(67.0,118.3316),(68.0,118.8297),(69.0,119.3269),(70.0,119.8248),(71.0,120.3223),(72.0,120.8197),(73.0,121.317),(74.0,121.8146),(75.0,122.3121),(76.0,122.8096),(77.0,123.3074),(78.0,123.8049),(79.0,124.3023),(80.0,124.7998),(81.0,125.2973),(82.0,125.7947),(83.0,126.2924),(84.0,126.7898),(85.0,127.2874),(86.0,127.7846),(87.0,128.2823),(88.0,128.7798),(89.0,129.2771),(90.0,129.7747),(91.0,130.2722),(92.0,130.7698),(93.0,131.2674),(94.0,131.7649),(95.0,132.2623),(96.0,132.7598),(97.0,133.2575),(98.0,133.7549),(99.0,134.2524),(100.0,134.7499))

#let dataTx0Bwp20 = ((0.0,4.2344),(1.0,10.756),(2.0,15.7261),(3.0,19.872),(4.0,23.171),(5.0,26.0876),(6.0,28.4778),(7.0,30.6776),(8.0,32.494),(9.0,34.0857),(10.0,35.5102),(11.0,36.7645),(12.0,37.8382),(13.0,38.7528),(14.0,39.5611),(15.0,40.2216),(16.0,40.824),(17.0,41.4238),(18.0,41.8744),(19.0,42.3014),(20.0,42.7105),(21.0,43.0542),(22.0,43.3951),(23.0,43.6817),(24.0,43.9527),(25.0,44.2041),(26.0,44.4662),(27.0,44.6937),(28.0,44.9193),(29.0,45.1475),(30.0,45.3465),(31.0,45.5546),(32.0,45.7516),(33.0,45.9603),(34.0,46.155),(35.0,46.3405),(36.0,46.5346),(37.0,46.7198),(38.0,46.9127),(39.0,47.0957),(40.0,47.2825),(41.0,47.4693),(42.0,47.654),(43.0,47.8392),(44.0,48.0243),(45.0,48.2041),(46.0,48.3893),(47.0,48.5734),(48.0,48.7569),(49.0,48.9397),(50.0,49.1233),(51.0,49.3053),(52.0,49.4886),(53.0,49.6715),(54.0,49.8538),(55.0,50.037),(56.0,50.2194),(57.0,50.4019),(58.0,50.5844),(59.0,50.7673),(60.0,50.9496),(61.0,51.1324),(62.0,51.3148),(63.0,51.4973),(64.0,51.6797),(65.0,51.8623),(66.0,52.045),(67.0,52.2274),(68.0,52.4099),(69.0,52.5923),(70.0,52.7749),(71.0,52.9574),(72.0,53.1398),(73.0,53.3224),(74.0,53.5049),(75.0,53.6874),(76.0,53.8699),(77.0,54.0525),(78.0,54.235),(79.0,54.4174),(80.0,54.5999),(81.0,54.7825),(82.0,54.9649),(83.0,55.1474),(84.0,55.3299),(85.0,55.5124),(86.0,55.695),(87.0,55.8775),(88.0,56.06),(89.0,56.2424),(90.0,56.425),(91.0,56.6072),(92.0,56.79),(93.0,56.9725),(94.0,57.155),(95.0,57.3374),(96.0,57.52),(97.0,57.7025),(98.0,57.8849),(99.0,58.0675),(100.0,58.2499))

#let dataTx20Bwp20 = ((0.0,4.2344),(1.0,10.8739),(2.0,15.9865),(3.0,20.1916),(4.0,23.7216),(5.0,26.8076),(6.0,29.4173),(7.0,31.6936),(8.0,33.6981),(9.0,35.467),(10.0,36.9468),(11.0,38.3788),(12.0,39.5702),(13.0,40.626),(14.0,41.5793),(15.0,42.4391),(16.0,43.1587),(17.0,43.9204),(18.0,44.5013),(19.0,45.0876),(20.0,45.5959),(21.0,46.1008),(22.0,46.6193),(23.0,47.0467),(24.0,47.4441),(25.0,47.8484),(26.0,48.2614),(27.0,48.6239),(28.0,48.9954),(29.0,49.3727),(30.0,49.7283),(31.0,50.0763),(32.0,50.4266),(33.0,50.7687),(34.0,51.1105),(35.0,51.4441),(36.0,51.7868),(37.0,52.1197),(38.0,52.4578),(39.0,52.786),(40.0,53.1159),(41.0,53.451),(42.0,53.7818),(43.0,54.1115),(44.0,54.4411),(45.0,54.7695),(46.0,55.0994),(47.0,55.4288),(48.0,55.758),(49.0,56.0864),(50.0,56.4164),(51.0,56.7436),(52.0,57.0729),(53.0,57.4021),(54.0,57.7299),(55.0,58.0589),(56.0,58.3881),(57.0,58.7162),(58.0,59.0443),(59.0,59.3729),(60.0,59.7015),(61.0,60.0298),(62.0,60.3581),(63.0,60.6866),(64.0,61.0149),(65.0,61.3433),(66.0,61.6716),(67.0,62.0001),(68.0,62.3286),(69.0,62.6569),(70.0,62.9851),(71.0,63.3137),(72.0,63.642),(73.0,63.9703),(74.0,64.2986),(75.0,64.6271),(76.0,64.9555),(77.0,65.2837),(78.0,65.6122),(79.0,65.9404),(80.0,66.2689),(81.0,66.5972),(82.0,66.9257),(83.0,67.2538),(84.0,67.5824),(85.0,67.9108),(86.0,68.2391),(87.0,68.5674),(88.0,68.8959),(89.0,69.2241),(90.0,69.5525),(91.0,69.8809),(92.0,70.2093),(93.0,70.5377),(94.0,70.866),(95.0,71.1943),(96.0,71.5227),(97.0,71.8511),(98.0,72.1795),(99.0,72.5079),(100.0,72.8362))

#let dataTx23Bwp20 = ((0.0,4.2344),(1.0,11.0296),(2.0,16.3469),(3.0,20.6804),(4.0,24.2866),(5.0,27.4519),(6.0,30.2078),(7.0,32.7102),(8.0,34.8501),(9.0,36.7077),(10.0,38.3871),(11.0,39.9474),(12.0,41.3458),(13.0,42.5563),(14.0,43.6935),(15.0,44.5941),(16.0,45.5187),(17.0,46.3679),(18.0,47.1367),(19.0,47.8829),(20.0,48.5119),(21.0,49.2098),(22.0,49.8466),(23.0,50.4066),(24.0,50.9689),(25.0,51.5261),(26.0,52.0662),(27.0,52.5911),(28.0,53.117),(29.0,53.6225),(30.0,54.131),(31.0,54.6187),(32.0,55.1186),(33.0,55.6048),(34.0,56.0955),(35.0,56.5764),(36.0,57.0662),(37.0,57.5466),(38.0,58.0278),(39.0,58.5026),(40.0,58.9816),(41.0,59.4634),(42.0,59.9378),(43.0,60.4173),(44.0,60.8929),(45.0,61.369),(46.0,61.8443),(47.0,62.3209),(48.0,62.7968),(49.0,63.2718),(50.0,63.747),(51.0,64.2236),(52.0,64.6981),(53.0,65.1734),(54.0,65.6486),(55.0,66.1244),(56.0,66.5993),(57.0,67.0741),(58.0,67.5492),(59.0,68.0248),(60.0,68.4996),(61.0,68.9748),(62.0,69.4498),(63.0,69.9247),(64.0,70.3996),(65.0,70.8748),(66.0,71.35),(67.0,71.8248),(68.0,72.2995),(69.0,72.7749),(70.0,73.2496),(71.0,73.725),(72.0,74.1999),(73.0,74.675),(74.0,75.1497),(75.0,75.6248),(76.0,76.1),(77.0,76.5749),(78.0,77.0498),(79.0,77.5249),(80.0,77.9999),(81.0,78.4749),(82.0,78.9499),(83.0,79.4249),(84.0,79.9),(85.0,80.375),(86.0,80.85),(87.0,81.325),(88.0,81.7999),(89.0,82.2749),(90.0,82.7498),(91.0,83.225),(92.0,83.7),(93.0,84.175),(94.0,84.65),(95.0,85.1249),(96.0,85.6),(97.0,86.075),(98.0,86.5499),(99.0,87.025),(100.0,87.5))

#figure(
  caption: [UE Power over Avg. Packet Rate ($T_C=160"ms",T_"On"=8"ms", T_I=100"ms"$)],
  placement: auto,
)[
  #canvas({
    import "/cetz.typ": *

    set-style(
      axes: (
        stroke: .5pt,
        tick: (stroke: .5pt),
        grid: (stroke: silver + 0.7pt),
      ),
      legend: (stroke: .5pt, spacing: 0.25, fill: white)
    )

    plot.plot(size: (14, 8),
      x-label: [Packets per Second (@ul and @dl)],
      y-label: [$P_"Traffic"$ [@pu]],
      y-tick-step: 25,
      y-min: 0,
      y-max: 175,
      x-grid: true,
      y-grid: true,
      legend: "inner-north-west",
      {
        plot.add(
          dataTx23Bwp80,
          label: $B_D=80 "MHz", x=23 "dBm"$,
          style: (stroke: (dash: "dotted"))
        )
        plot.add(
          dataTx20Bwp80,
          label: $B_D=80 "MHz", x=20 "dBm"$,
          style: (stroke: (dash: "dashed"))
        )
        plot.add(
          dataTx0Bwp80,
          style: (stroke: black),
          label: $B_D=80 "MHz", x= 0 "dBm"$,
        )
        plot.add(
          dataTx23Bwp20,
          style: (stroke: (dash: "densely-dotted")),
          label: $B_D=20 "MHz", x=23 "dBm"$,
        )
        plot.add(
          dataTx20Bwp20,
          style: (stroke: (dash: "densely-dashed")),
          label: $B_D=20 "MHz", x=20 "dBm"$,
        )
        plot.add(
          dataTx0Bwp20,
          style: (stroke: (dash: "dash-dotted")),
          label: $B_D=20 "MHz", x= 0 "dBm"$,
        )
      })
  })
] <figTrafficPowerPpsPlot>
