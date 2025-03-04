import numpy as np

# fmt: off
sa_measurements = np.array([115.4602, 139.0985, 160.0563, 173.2765, 183.0962, 192.4323, 199.2686, 202.7234, 207.0157, 208.6554, 210.5917, 210.7421, 211.7082, 216.2422, 216.3792, 215.8083, 216.2099, 214.07, 215.0249, 213.7783, 217.8301, 208.6734, 215.033, 220.4057, 215.659, 218.4174, 216.9303, 220.4876, 216.1379, 218.3307, 216.6918, 219.203, 218.8535, 214.1774, 218.029, 215.846, 218.7675, 214.3489, 215.74, 215.196, 214.8611, 215.4751, 214.7808, 215.4536, 215.9204, 217.2222, 216.7415, 218.8244, 222.5106, 221.5784, 220.7356, 215.773, 218.9445, 218.5629, 218.2647, 215.7604, 216.2012, 217.0071, 218.8433, 218.7282, 218.294, 218.5455, 216.7062, 217.5429, 221.9342, 222.0903, 216.8819, 218.5564, 217.2748, 217.8389, 220.0043, 221.688, 215.7296, 220.8391, 220.4354, 219.502, 222.4922, 219.6061, 217.6383, 217.6585, 217.5546, 219.0921, 217.8399, 216.5327, 220.7255, 220.4406, 217.6735, 216.2139, 221.7901, 217.8756, 220.734, 216.9126, 219.8234, 218.8092, 216.853, 218.5901, 221.8451, 221.2542, 218.0983, 223.109, 221.6858, 222.3092, 216.6897, 219.1769, 219.1609, 222.6355, 218.5112, 228.0792, 218.6181, 218.797, 218.2757, 218.0765, 217.4, 221.0156, 217.2109, 222.0538, 218.3258, 226.71, 219.9978, 221.5286, 219.2664, 222.5683, 219.5053, 219.702, 221.7847, 219.7353, 222.556, 220.9579, 218.7958, 220.8879, 223.9, 218.793, 221.9979, 222.7292, 221.3551, 220.2945, 219.3093, 227.0126, 219.2051, 219.5042, 222.7289, 222.1409, 219.0264, 222.7987, 219.2785, 220.2283, 222.9613, 220.2393, 218.4007, 222.5165, 221.8845, 218.797, 219.7635, 221.3252, 220.6075, 225.9033, 220.3652, 220.0967, 220.5957, 219.3682, 220.5992, 224.661, 222.762, 223.9676, 227.6865, 220.4186, 221.2469, 223.8528, 220.2235, 220.9102, 221.9711, 227.0624, 221.8418, 222.1197, 225.6145, 226.416, 221.5604, 223.2313, 220.6849, 224.2684, 220.635, 221.9777, 221.6874, 220.9555, 221.0867, 224.4277, 221.7121, 227.2564, 223.7858, 220.8445, 225.0081, 222.0277, 220.963, 221.4229, 222.1012, 222.2657, 225.1524, 221.3361, 224.2785])
nsa_measurements = np.array([161.2955, 196.19, 215.3033, 229.4057, 243.3337, 249.0609, 257.789, 258.2305, 263.2225, 266.9528, 272.4142, 272.4048, 267.0578, 273.0442, 274.8418, 272.0077, 277.034, 270.8663, 274.5001, 278.9038, 276.2345, 277.2797, 280.6088, 274.7044, 285.271, 276.5425, 282.4637, 271.1415, 283.4772, 284.3716, 284.1011, 285.2079, 283.9015, 281.5871, 275.7008, 281.8427, 282.1517, 279.7531, 278.0146, 280.0758, 290.327, 282.7182, 290.0903, 280.892, 275.6984, 288.3503, 276.4474, 285.3209, 278.719, 286.9405, 282.9427, 284.6317, 284.6179, 288.8574, 288.762, 280.6628, 281.8704, 281.6302, 285.2323, 274.8338, 289.3593, 276.3872, 283.4021, 289.3407, 284.0306, 278.7357, 284.5293, 286.2108, 282.4468, 285.1754, 290.0238, 290.4884, 283.096, 284.7398, 287.7551, 285.055, 284.9243, 287.1751, 292.9625, 286.9124, 279.0075, 281.3936, 288.1269, 274.8543, 290.6992, 287.0776, 277.8592, 283.1904, 291.0435, 292.3773, 288.3314, 284.41, 282.3042, 284.5697, 288.9488, 284.9186, 285.0985, 284.1902, 285.3355, 283.4672, 284.8435, 273.02, 287.0762, 286.3433, 287.9974, 286.2121, 280.948, 288.1535, 293.2368, 287.356, 290.9585, 289.2474, 282.0015, 275.6999, 284.0286, 289.6797, 280.4293, 286.1193, 289.3708, 290.8684, 291.2509, 289.7002, 287.0592, 290.2473, 285.4183, 291.8183, 287.603, 290.4935, 280.1739, 279.058, 276.8359, 289.4246, 290.3903, 292.5214, 288.2505, 286.3231, 280.2442, 285.367, 295.1189, 283.5663, 294.2788, 286.7687, 292.2428, 282.6188, 287.1553, 293.0375, 295.9789, 289.7703, 291.297, 285.0335, 280.2801, 296.6188, 285.7622, 287.2806, 289.341, 293.8273, 289.9404, 288.1845, 284.0098, 283.2967, 286.5702, 295.4781, 289.5904, 287.1888, 290.3805, 288.7703, 292.8083, 289.4134, 282.4854, 291.6267, 282.562, 284.7549, 291.6514, 290.1679, 292.9312, 293.4208, 285.3679, 286.2255, 287.2372, 289.3571, 287.6437, 288.7146, 290.4865, 295.6506, 291.1225, 292.0046, 289.136, 290.0826, 292.4834, 282.8978, 287.0621, 283.0056, 288.3486, 289.3705, 263.7625, 283.8225, 287.9078, 290.4034, 298.2154])
prediction = np.array([20.8969, 31.377, 40.0551, 47.4299, 53.9715, 59.7976, 65.0692, 69.6691, 73.7317, 77.0267, 80.2588, 82.8608, 85.1009, 87.056, 88.6039, 89.9617, 91.3211, 92.2744, 93.206, 94.0081, 94.7162, 95.3444, 95.8964, 96.3306, 96.7083, 97.1557, 97.4803, 97.8177, 98.1295, 98.4216, 98.6859, 98.9396, 99.2049, 99.4429, 99.6679, 99.909, 100.136, 100.3653, 100.5815, 100.7972, 101.0232, 101.2379, 101.4532, 101.6646, 101.8769, 102.0902, 102.2995, 102.5102, 102.7218, 102.9318, 103.1411, 103.3513, 103.5612, 103.7682, 103.9784, 104.1878, 104.3967, 104.6066, 104.8157, 105.024, 105.233, 105.442, 105.6505, 105.8598, 106.0684, 106.2772, 106.4862, 106.695, 106.9037, 107.1124, 107.3212, 107.53, 107.7386, 107.9472, 108.1562, 108.365, 108.5737, 108.7825, 108.9912, 109.1999, 109.4088, 109.6175, 109.8262, 110.035, 110.2437, 110.4525, 110.6612, 110.87, 111.0788, 111.2875, 111.4962, 111.705, 111.9138, 112.1225, 112.3312, 112.54, 112.7487, 112.9575, 113.1662, 113.375, 113.5837, 113.7924, 114.0012, 114.21, 114.4188, 114.6275, 114.8362, 115.045, 115.2537, 115.4625, 115.6712, 115.88, 116.0888, 116.2975, 116.5062, 116.715, 116.9237, 117.1325, 117.3412, 117.55, 117.7587, 117.9675, 118.1762, 118.385, 118.5937, 118.8025, 119.0112, 119.22, 119.4287, 119.6375, 119.8462, 120.055, 120.2637, 120.4725, 120.6812, 120.89, 121.0987, 121.3075, 121.5162, 121.725, 121.9338, 122.1425, 122.3512, 122.56, 122.7687, 122.9775, 123.1862, 123.395, 123.6037, 123.8125, 124.0212, 124.23, 124.4387, 124.6475, 124.8562, 125.065, 125.2737, 125.4825, 125.6912, 125.9, 126.1087, 126.3175, 126.5262, 126.735, 126.9437, 127.1525, 127.3612, 127.57, 127.7787, 127.9875, 128.1962, 128.405, 128.6137, 128.8225, 129.0312, 129.24, 129.4487, 129.6575, 129.8662, 130.075, 130.2837, 130.4925, 130.7012, 130.91, 131.1187, 131.3275, 131.5362, 131.745, 131.9537, 132.1625, 132.3712, 132.58, 132.7887, 132.9975, 133.2062, 133.415, 133.6237, 133.8325, 134.0412])
# fmt: on

prediction = prediction * 1.55 + 40

print(
    "Avg SA prediction error (percent):",
    np.mean(np.abs(sa_measurements - prediction) / sa_measurements) * 100,
)
print("Avg SA prediction error:", np.mean(np.abs(sa_measurements - prediction)))
print("Mean difference:", np.mean(nsa_measurements - sa_measurements))
print(
    "Mean reduction (percent):",
    np.mean((nsa_measurements - sa_measurements) / nsa_measurements) * 100,
)
