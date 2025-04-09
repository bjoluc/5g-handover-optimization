#import "utils.typ": plotCurrentOverTime

#let data = ((0.0,140.506),(0.0013,160.7318),(0.0026,198.3793),(0.0038,206.9138),(0.0051,225.443),(0.0064,191.983),(0.0077,197.8081),(0.009,251.6692),(0.0103,198.348),(0.0115,177.2562),(0.0128,214.0224),(0.0141,193.3597),(0.0154,184.4064),(0.0167,195.6658),(0.0179,208.1554),(0.0192,200.458),(0.0205,172.4221),(0.0218,212.9645),(0.0231,202.807),(0.0243,138.1818),(0.0256,130.1053),(0.0269,69.929),(0.0282,29.2442),(0.0295,41.8162),(0.0308,32.9699),(0.032,37.6855),(0.0333,36.8419),(0.0346,33.7275),(0.0359,45.8498),(0.0372,45.4511),(0.0384,36.0217),(0.0397,36.8481),(0.041,38.4556),(0.0423,36.9064),(0.0436,38.5049),(0.0448,37.6065),(0.0461,36.8438),(0.0474,37.2624),(0.0487,37.5877),(0.05,38.7498),(0.0513,37.4513),(0.0525,42.6779),(0.0538,46.0129),(0.0551,38.583),(0.0564,36.1635),(0.0577,36.7787),(0.0589,37.2766),(0.0602,36.6394),(0.0615,36.4638),(0.0628,42.1292),(0.0641,40.4227),(0.0653,35.7119),(0.0666,36.3254),(0.0679,36.0367),(0.0692,36.7137),(0.0705,36.6991),(0.0718,35.8416),(0.073,36.3177),(0.0743,36.2671),(0.0756,36.0773),(0.0769,36.0393),(0.0782,36.5659),(0.0794,36.8481),(0.0807,36.9326),(0.082,37.8303),(0.0833,37.6974),(0.0846,37.4951),(0.0858,37.487),(0.0871,37.2377),(0.0884,37.9229),(0.0897,38.082),(0.091,37.8082),(0.0923,37.3029),(0.0935,37.063),(0.0948,37.4743),(0.0961,37.2029),(0.0974,36.711),(0.0987,36.5335),(0.0999,37.2292),(0.1012,37.6849),(0.1025,36.8779),(0.1038,37.099),(0.1051,38.1418),(0.1063,38.2199),(0.1076,37.7671),(0.1089,37.3604),(0.1102,37.4566),(0.1115,37.8473),(0.1128,37.4694),(0.114,38.2754),(0.1153,38.2678),(0.1166,36.8115),(0.1179,38.1835),(0.1192,38.903),(0.1204,38.8748),(0.1217,38.4109),(0.123,37.8685),(0.1243,37.7061),(0.1256,36.9197),(0.1268,38.2846),(0.1281,36.4831),(0.1294,38.1986),(0.1307,37.793),(0.132,36.6011),(0.1333,40.2881),(0.1345,33.912),(0.1358,53.215),(0.1371,65.2823),(0.1384,42.0222),(0.1397,39.9005),(0.1409,39.4179),(0.1422,35.9963),(0.1435,38.7443),(0.1448,36.5749),(0.1461,38.0831),(0.1473,37.6565),(0.1486,37.6967),(0.1499,38.0394),(0.1512,36.5813),(0.1525,42.2158),(0.1538,43.2033),(0.155,37.8366),(0.1563,38.569),(0.1576,38.2093),(0.1589,38.1623),(0.1602,37.5699),(0.1614,36.9658),(0.1627,43.7673),(0.164,41.7908),(0.1653,36.474),(0.1666,37.781),(0.1678,36.3272),(0.1691,36.3117),(0.1704,36.7424),(0.1717,36.1365),(0.173,36.3983),(0.1743,36.5519),(0.1755,36.918),(0.1768,36.6821),(0.1781,37.2697),(0.1794,37.0961),(0.1807,36.3936),(0.1819,36.8022),(0.1832,36.2174),(0.1845,36.2752),(0.1858,36.5657),(0.1871,35.9419),(0.1883,36.5625),(0.1896,37.4245),(0.1909,37.7692),(0.1922,37.9414),(0.1935,38.1051),(0.1948,38.0519),(0.196,38.0022),(0.1973,38.4401),(0.1986,38.182),(0.1999,38.1263),(0.2012,38.043),(0.2024,37.591),(0.2037,38.3669),(0.205,39.305),(0.2063,38.7028),(0.2076,38.4593),(0.2088,38.9927),(0.2101,38.0972),(0.2114,37.5229),(0.2127,37.983),(0.214,37.7717),(0.2153,37.7056),(0.2165,37.7867),(0.2178,37.7257),(0.2191,37.6594),(0.2204,36.8375),(0.2217,37.0494),(0.2229,37.5306),(0.2242,37.2843),(0.2255,37.266),(0.2268,37.1945),(0.2281,37.5229),(0.2293,37.8179),(0.2306,38.1433),(0.2319,37.9939),(0.2332,38.8376),(0.2345,38.0337),(0.2358,38.4953),(0.237,43.6471),(0.2383,40.4075),(0.2396,36.3623),(0.2409,38.3302),(0.2422,37.2303),(0.2434,37.0876),(0.2447,37.8143),(0.246,37.4323),(0.2473,37.4975),(0.2486,37.4987),(0.2498,37.6475),(0.2511,37.0407),(0.2524,37.341),(0.2537,37.5691),(0.255,36.2932),(0.2563,36.9162),(0.2575,36.2465),(0.2588,36.3399),(0.2601,36.277),(0.2614,36.0338),(0.2627,43.9375),(0.2639,43.0774),(0.2652,37.9254),(0.2665,37.8708),(0.2678,36.637),(0.2691,40.0917),(0.2703,38.7487),(0.2716,38.1031),(0.2729,39.5715),(0.2742,37.4859),(0.2755,34.3025),(0.2768,36.7709),(0.278,37.3701),(0.2793,33.6824),(0.2806,41.2908),(0.2819,37.4371),(0.2832,38.5881),(0.2844,33.5822),(0.2857,36.6638),(0.287,40.3348),(0.2883,29.0553),(0.2896,62.8719),(0.2908,55.4379),(0.2921,166.1785),(0.2934,274.0473),(0.2947,143.6406),(0.296,128.2513),(0.2973,146.0799),(0.2985,127.8878),(0.2998,151.4104),(0.3011,138.4984),(0.3024,226.8803),(0.3037,242.8255),(0.3049,154.3447),(0.3062,144.4742),(0.3075,131.3612),(0.3088,129.6152),(0.3101,139.6455),(0.3113,131.1973),(0.3126,134.3396),(0.3139,129.8144),(0.3152,133.724),(0.3165,135.8885),(0.3178,134.1985),(0.319,138.059),(0.3203,126.9342),(0.3216,170.063),(0.3229,206.8328),(0.3242,208.7181),(0.3254,217.0896),(0.3267,178.3779),(0.328,212.6115),(0.3293,245.036),(0.3306,176.3124),(0.3318,183.9016),(0.3331,208.2542),(0.3344,180.9296),(0.3357,180.6137),(0.337,190.2111),(0.3383,204.7419),(0.3395,188.4659),(0.3408,171.055),(0.3421,214.4741),(0.3434,178.5022),(0.3447,129.4225),(0.3459,122.0168),(0.3472,54.0431),(0.3485,33.0186),(0.3498,41.6349),(0.3511,34.68),(0.3523,40.8507),(0.3536,37.2572),(0.3549,39.1159),(0.3562,37.9362),(0.3575,37.4168),(0.3588,39.5823),(0.36,36.9278),(0.3613,38.1893),(0.3626,37.2383),(0.3639,37.6491),(0.3652,38.3082),(0.3664,37.3486),(0.3677,38.1142),(0.369,37.9378),(0.3703,37.8956),(0.3716,38.4005),(0.3728,38.0464),(0.3741,37.4986),(0.3754,38.0414),(0.3767,38.2388),(0.378,38.3524),(0.3793,38.2109),(0.3805,37.0366),(0.3818,35.8685),(0.3831,35.4141),(0.3844,36.2787),(0.3857,35.8461),(0.3869,35.4252),(0.3882,36.3923),(0.3895,36.5936),(0.3908,36.4426),(0.3921,37.0462),(0.3933,37.239),(0.3946,35.484),(0.3959,36.0227),(0.3972,36.362),(0.3985,36.0402),(0.3998,37.6184),(0.401,35.8258),(0.4023,40.2854),(0.4036,42.5935),(0.4049,36.2452),(0.4062,37.4944),(0.4074,37.7282),(0.4087,37.5147),(0.41,37.4524),(0.4113,36.5916),(0.4126,42.9497),(0.4138,41.6531),(0.4151,36.9939),(0.4164,37.9169),(0.4177,37.6228),(0.419,37.223),(0.4203,36.9019),(0.4215,37.3388),(0.4228,37.3194),(0.4241,37.5241),(0.4254,37.1723),(0.4267,37.4059),(0.4279,36.1696),(0.4292,36.5052),(0.4305,37.5563),(0.4318,35.3159),(0.4331,40.7109),(0.4343,34.0959),(0.4356,44.0628),(0.4369,65.3272),(0.4382,43.3632),(0.4395,36.0732),(0.4408,41.6089),(0.442,36.2423),(0.4433,40.0194),(0.4446,38.1725),(0.4459,38.3436),(0.4472,38.3998),(0.4484,37.056),(0.4497,38.2158),(0.451,36.4636),(0.4523,36.9839),(0.4536,37.1763),(0.4548,37.7838),(0.4561,38.7476),(0.4574,37.6808),(0.4587,38.3681),(0.46,38.4171),(0.4613,38.0093),(0.4625,38.6499),(0.4638,38.3306),(0.4651,38.1485),(0.4664,37.7236),(0.4677,37.9401),(0.4689,38.7454),(0.4702,38.1942),(0.4715,37.9374),(0.4728,37.7856),(0.4741,37.0561),(0.4753,36.4746),(0.4766,36.563),(0.4779,36.6988),(0.4792,36.8049),(0.4805,37.0729),(0.4818,36.9854),(0.483,36.7332),(0.4843,36.4941),(0.4856,37.0081),(0.4869,37.287),(0.4882,37.4882),(0.4894,37.995),(0.4907,37.6001),(0.492,36.9926),(0.4933,36.8438),(0.4946,36.205),(0.4959,36.2949),(0.4971,36.8703),(0.4984,36.6635),(0.4997,37.4236),(0.501,36.7279),(0.5023,40.6619),(0.5035,45.7486),(0.5048,40.413),(0.5061,37.5814),(0.5074,37.7667),(0.5087,37.2644),(0.5099,37.6574),(0.5112,36.5519),(0.5125,42.7655),(0.5138,43.715),(0.5151,37.1984),(0.5164,38.5604),(0.5176,38.727),(0.5189,36.8692),(0.5202,37.7854),(0.5215,37.7614),(0.5228,37.3703),(0.524,38.0368),(0.5253,37.9616),(0.5266,37.3166),(0.5279,37.5259),(0.5292,37.9229),(0.5304,38.4657),(0.5317,37.5382),(0.533,38.518),(0.5343,37.6737),(0.5356,37.25),(0.5369,43.8868),(0.5381,40.7116),(0.5394,35.9948),(0.5407,38.2938),(0.542,36.8143),(0.5433,37.1542),(0.5445,37.3299),(0.5458,37.2393),(0.5471,37.9699),(0.5484,36.6016),(0.5497,36.8677),(0.5509,37.395),(0.5522,38.0716),(0.5535,38.8778),(0.5548,38.1596),(0.5561,38.3944),(0.5574,38.3236),(0.5586,37.6521),(0.5599,38.2167),(0.5612,37.9187),(0.5625,37.4618),(0.5638,38.1231),(0.565,38.2543),(0.5663,37.6496),(0.5676,37.2052),(0.5689,37.6975),(0.5702,38.4487),(0.5714,38.6789),(0.5727,38.1876),(0.574,37.4137),(0.5753,37.0987),(0.5766,36.7648),(0.5779,36.9699),(0.5791,37.3207),(0.5804,37.1121),(0.5817,36.9944),(0.583,37.3055),(0.5843,37.7531),(0.5855,37.5077),(0.5868,37.2299),(0.5881,36.7611),(0.5894,37.0638),(0.5907,37.9633),(0.5919,37.1154),(0.5932,37.885),(0.5945,38.4674),(0.5958,37.8128),(0.5971,37.7774),(0.5984,38.0112),(0.5996,39.5443),(0.6009,37.425),(0.6022,40.3109),(0.6035,43.3178),(0.6048,37.6145),(0.606,37.6666),(0.6073,38.1473),(0.6086,37.1625),(0.6099,37.7788),(0.6112,36.9323),(0.6124,40.2895),(0.6137,43.549),(0.615,37.6682),(0.6163,36.6348),(0.6176,38.905),(0.6189,34.5698),(0.6201,40.7032),(0.6214,35.9382),(0.6227,38.3338),(0.624,40.1462),(0.6253,32.6197),(0.6265,46.2665),(0.6278,27.2624),(0.6291,52.2613),(0.6304,57.1388),(0.6317,104.8539),(0.6329,263.8974),(0.6342,189.2383),(0.6355,106.7854),(0.6368,145.2049),(0.6381,125.6148),(0.6394,137.8477),(0.6406,143.5661),(0.6419,178.2175),(0.6432,203.3324),(0.6445,215.2926),(0.6458,216.6718),(0.647,178.5342),(0.6483,230.625),(0.6496,233.5026),(0.6509,171.4486),(0.6522,200.8056),(0.6534,208.1136),(0.6547,184.9631),(0.656,192.5058),(0.6573,204.4174),(0.6586,214.7112),(0.6599,184.4179),(0.6611,188.9951),(0.6624,225.4592),(0.6637,165.8461),(0.665,134.562),(0.6663,110.6591),(0.6675,41.0184),(0.6688,37.1124),(0.6701,39.3587),(0.6714,35.5559),(0.6727,39.5529),(0.6739,35.1814),(0.6752,38.2403),(0.6765,36.3841),(0.6778,37.3808),(0.6791,38.4383),(0.6804,37.3025),(0.6816,37.8886),(0.6829,36.9527),(0.6842,38.0523),(0.6855,38.1804),(0.6868,37.9546),(0.688,38.7339),(0.6893,38.2764),(0.6906,38.2604),(0.6919,39.068),(0.6932,38.2292),(0.6944,37.2398),(0.6957,37.0372),(0.697,37.448),(0.6983,37.9199),(0.6996,37.4814),(0.7009,37.6562),(0.7021,37.3015),(0.7034,37.7052),(0.7047,37.8717),(0.706,37.806),(0.7073,38.0472),(0.7085,38.062),(0.7098,39.037),(0.7111,36.8307),(0.7124,41.0167),(0.7137,43.6097),(0.7149,37.5001),(0.7162,37.3828),(0.7175,36.8636),(0.7188,39.7752),(0.7201,41.379),(0.7214,38.393),(0.7226,40.874),(0.7239,39.6272),(0.7252,36.9257),(0.7265,37.8233),(0.7278,37.721),(0.729,36.5403),(0.7303,39.2369),(0.7316,41.1778),(0.7329,41.4531),(0.7342,34.3352),(0.7354,41.7576),(0.7367,63.5906),(0.738,46.3702),(0.7393,34.107),(0.7406,40.4985),(0.7419,36.2025),(0.7431,43.4796),(0.7444,45.7061),(0.7457,41.8007),(0.747,41.5904),(0.7483,40.0915),(0.7495,39.9705),(0.7508,37.5953),(0.7521,40.6298),(0.7534,42.3509),(0.7547,37.8007),(0.7559,40.3817),(0.7572,43.5064),(0.7585,40.4538),(0.7598,36.0053),(0.7611,39.0905),(0.7624,41.7085),(0.7636,36.4696),(0.7649,35.9231),(0.7662,36.7171),(0.7675,36.3231),(0.7688,37.0497),(0.77,37.0395),(0.7713,37.8165),(0.7726,37.5131),(0.7739,37.1778),(0.7752,37.9163),(0.7764,37.5856),(0.7777,37.4634),(0.779,37.802),(0.7803,37.1487),(0.7816,36.8638),(0.7829,37.5265),(0.7841,38.0939),(0.7854,37.727),(0.7867,37.0502),(0.788,36.6686),(0.7893,37.0075),(0.7905,37.7343),(0.7918,37.3042),(0.7931,37.1605),(0.7944,37.2991),(0.7957,37.4851),(0.7969,37.8225),(0.7982,37.826),(0.7995,37.7932),(0.8008,37.3931),(0.8021,37.648),(0.8034,37.4503),(0.8046,37.3598),(0.8059,37.1834),(0.8072,36.731),(0.8085,37.7475),(0.8098,37.0461),(0.811,36.7633),(0.8123,37.666),(0.8136,37.2393),(0.8149,37.771),(0.8162,38.0268),(0.8174,37.9771),(0.8187,37.892),(0.82,37.6394),(0.8213,38.2556),(0.8226,37.8154),(0.8239,38.0235),(0.8251,38.4176),(0.8264,37.8564),(0.8277,38.4679),(0.829,38.288),(0.8303,37.6857),(0.8315,36.7365),(0.8328,37.6565),(0.8341,37.8114),(0.8354,36.5073),(0.8367,42.7223),(0.8379,42.4654),(0.8392,36.884),(0.8405,38.3243),(0.8418,37.7576),(0.8431,37.4341),(0.8444,37.9008),(0.8456,38.4978),(0.8469,38.4228),(0.8482,37.9079),(0.8495,39.2637),(0.8508,36.6619),(0.852,40.7397),(0.8533,44.6648),(0.8546,38.1039),(0.8559,38.0321),(0.8572,38.4251),(0.8584,38.0154),(0.8597,39.1773),(0.861,36.6077),(0.8623,41.821),(0.8636,42.7399),(0.8649,36.8429),(0.8661,37.9608),(0.8674,36.2681),(0.8687,39.6104),(0.87,43.1578),(0.8713,37.4995),(0.8725,37.4746),(0.8738,38.2033),(0.8751,37.9974),(0.8764,38.2205),(0.8777,37.0819),(0.8789,38.0045),(0.8802,37.8506),(0.8815,37.9947),(0.8828,37.9696),(0.8841,36.8772),(0.8854,37.1389),(0.8866,37.2263),(0.8879,37.6087),(0.8892,38.0568),(0.8905,37.9171),(0.8918,38.1179),(0.893,38.3869),(0.8943,38.6813),(0.8956,38.5702),(0.8969,38.1989),(0.8982,38.1048),(0.8994,38.0886),(0.9007,37.4133),(0.902,37.8483),(0.9033,38.3341),(0.9046,37.2454),(0.9059,37.4847),(0.9071,36.6642),(0.9084,36.8053),(0.9097,36.8473),(0.911,36.3745),(0.9123,37.7958),(0.9135,36.0138),(0.9148,38.535),(0.9161,37.4298),(0.9174,36.7107),(0.9187,39.9497),(0.9199,35.5123),(0.9212,40.8525),(0.9225,35.887),(0.9238,38.0893),(0.9251,38.3494),(0.9264,32.286),(0.9276,44.2792),(0.9289,26.7041),(0.9302,56.949),(0.9315,58.4659),(0.9328,119.4839),(0.934,270.3249),(0.9353,177.0166),(0.9366,113.9822),(0.9379,146.5252),(0.9392,124.8373),(0.9404,147.3754),(0.9417,137.3185),(0.943,195.8539),(0.9443,206.972),(0.9456,136.8649),(0.9469,142.183),(0.9481,133.2276),(0.9494,137.5175),(0.9507,136.7072),(0.952,135.9493),(0.9533,150.4649),(0.9545,132.7783),(0.9558,138.3605),(0.9571,139.1336),(0.9584,141.0215),(0.9597,135.8312),(0.961,142.2751),(0.9622,198.1195),(0.9635,210.4619),(0.9648,221.7107),(0.9661,202.2771),(0.9674,184.5332),(0.9686,246.0763),(0.9699,214.5818),(0.9712,171.1619),(0.9725,211.0206),(0.9738,203.9094),(0.975,182.1926),(0.9763,185.0805),(0.9776,200.9331),(0.9789,207.0789),(0.9802,172.7812),(0.9815,197.9322),(0.9827,214.2456),(0.984,147.1057),(0.9853,133.1122),(0.9866,91.0462),(0.9879,31.7859),(0.9891,38.756),(0.9904,36.2307),(0.9917,37.684),(0.993,39.0773),(0.9943,35.9466),(0.9955,38.5566),(0.9968,35.6161),(0.9981,37.5067),(0.9994,37.1989),(1.0007,36.2936),(1.002,36.7492),(1.0032,36.5358),(1.0045,37.0941),(1.0058,36.2826),(1.0071,37.3985),(1.0084,38.3182),(1.0096,37.0309),(1.0109,37.5854),(1.0122,37.7143),(1.0135,36.1543),(1.0148,37.1223),(1.016,37.3232),(1.0173,37.4102),(1.0186,37.8509),(1.0199,37.1232),(1.0212,38.4518),(1.0225,37.2983),(1.0237,37.0877),(1.025,36.9068),(1.0263,37.0817),(1.0276,38.5856),(1.0289,36.5207),(1.0301,38.3176),(1.0314,36.1638),(1.0327,38.2793),(1.034,35.6949),(1.0353,36.4754),(1.0365,61.3772),(1.0378,50.2789),(1.0391,31.4807),(1.0404,38.293),(1.0417,34.8255),(1.043,35.5494),(1.0442,36.069),(1.0455,35.7044),(1.0468,37.3961),(1.0481,35.6332),(1.0494,37.3228),(1.0506,35.6733),(1.0519,37.6638),(1.0532,41.6908),(1.0545,36.9483),(1.0558,35.9927),(1.057,36.6732),(1.0583,36.0014),(1.0596,37.2827),(1.0609,35.2836),(1.0622,39.2825),(1.0635,42.473),(1.0647,36.5432),(1.066,35.7984),(1.0673,36.7884),(1.0686,35.7867),(1.0699,35.9148),(1.0711,35.9555),(1.0724,36.4383),(1.0737,35.8257),(1.075,35.8404),(1.0763,36.2552),(1.0775,35.7703),(1.0788,36.3612),(1.0801,36.0871),(1.0814,36.9152),(1.0827,38.2207),(1.084,37.5074),(1.0852,37.8257),(1.0865,37.5562),(1.0878,37.3207),(1.0891,37.5457),(1.0904,37.0764),(1.0916,37.398),(1.0929,37.6331),(1.0942,37.8821),(1.0955,37.9766),(1.0968,37.8885),(1.098,37.7364),(1.0993,37.6452),(1.1006,37.6956),(1.1019,37.7375),(1.1032,38.1794),(1.1045,38.3929),(1.1057,38.153),(1.107,37.8746),(1.1083,37.7768),(1.1096,37.6861),(1.1109,37.4613),(1.1121,36.9849),(1.1134,37.4821),(1.1147,38.0672),(1.116,38.3697),(1.1173,38.5547),(1.1185,38.154),(1.1198,38.3674),(1.1211,37.8196),(1.1224,37.6894),(1.1237,38.1418),(1.125,38.0393),(1.1262,38.8492),(1.1275,38.7672),(1.1288,38.3778),(1.1301,38.1796),(1.1314,37.9128),(1.1326,38.3863),(1.1339,36.7937),(1.1352,40.9972),(1.1365,48.4871),(1.1378,46.4171),(1.139,42.2029),(1.1403,39.3317),(1.1416,38.0982),(1.1429,38.8513),(1.1442,38.9396),(1.1455,39.3781),(1.1467,39.0825),(1.148,38.765),(1.1493,38.9983),(1.1506,38.7764),(1.1519,38.5908),(1.1531,39.1763),(1.1544,39.1859),(1.1557,39.8481),(1.157,39.4042),(1.1583,38.7038),(1.1595,40.2879),(1.1608,37.5732),(1.1621,41.1399),(1.1634,44.5242),(1.1647,37.4205),(1.166,37.589),(1.1672,37.4602),(1.1685,38.659),(1.1698,40.7748),(1.1711,37.4109),(1.1724,40.1997),(1.1736,39.9638),(1.1749,37.3876),(1.1762,36.676),(1.1775,37.4418),(1.1788,37.4609),(1.18,37.5842),(1.1813,42.2298),(1.1826,39.5915),(1.1839,36.9689),(1.1852,37.8595),(1.1865,37.7696),(1.1877,37.069),(1.189,36.0924),(1.1903,37.8717),(1.1916,35.8064),(1.1929,39.9337),(1.1941,45.0512),(1.1954,40.8623),(1.1967,41.0033),(1.198,40.9469),(1.1993,38.9333),(1.2005,37.294),(1.2018,37.7931),(1.2031,40.8678),(1.2044,39.02),(1.2057,39.2122),(1.207,42.0772),(1.2082,40.957),(1.2095,36.9084),(1.2108,39.4621),(1.2121,42.4461),(1.2134,37.4096),(1.2146,36.7861),(1.2159,37.2739),(1.2172,36.9476),(1.2185,37.9992),(1.2198,37.268),(1.221,37.1275),(1.2223,36.7246),(1.2236,36.5447),(1.2249,36.649),(1.2262,37.0556),(1.2275,38.1287),(1.2287,37.9369),(1.23,38.3599),(1.2313,37.7143),(1.2326,37.5875),(1.2339,38.7013),(1.2351,36.6767),(1.2364,41.8297),(1.2377,44.8225),(1.239,38.0579),(1.2403,37.7888),(1.2415,38.6729),(1.2428,37.3623),(1.2441,37.8388),(1.2454,37.7487),(1.2467,38.1195),(1.248,38.6817),(1.2492,38.0126),(1.2505,38.9545),(1.2518,37.9041),(1.2531,37.4434),(1.2544,39.1255),(1.2556,36.3887),(1.2569,38.9894),(1.2582,37.362),(1.2595,38.0329),(1.2608,39.3815),(1.262,35.8433),(1.2633,41.578),(1.2646,33.1942),(1.2659,42.318),(1.2672,35.6023),(1.2685,36.296),(1.2697,62.1682),(1.271,58.8237),(1.2723,190.0728),(1.2736,253.9076),(1.2749,133.179),(1.2761,114.7694),(1.2774,153.7615),(1.2787,161.2186),(1.28,161.2186))


#figure(caption: [RRC Connected Mode Current without Payload Traffic])[
  #plotCurrentOverTime(
    data,
    xTickStep: 0.16,
    plotHeight: 6,
    plotWidth: 20,
    yMax: 300,
    yTickStep: 50,
  )
]
