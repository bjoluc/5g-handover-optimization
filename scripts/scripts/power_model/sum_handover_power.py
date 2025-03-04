from sympy import *

P_1SSB, P_r_SCH, P_s_micro, P_t, P_r_CCH, P_r_CCH_2SSB, P_r, S_BWP, x = symbols(
    "P_1SSB, P_r_SCH, P_s_micro, P_t, P_r_CCH, P_r_CCH_2SSB, P_r, S_BWP, x"
)
Ptshort = 0.3 * P_t
epsilon = 450 / (10 ** (23 / 10) - 1)
slots = 117


sum = (
    20 * P_1SSB
    + (19 * P_r_CCH_2SSB + P_r_SCH) * S_BWP
    + (20 * P_s_micro + P_t + 4 * P_r_CCH + P_r * S_BWP)
    + (3 * P_s_micro + P_t + 40 * P_r_CCH + P_r * S_BWP)
    + (Ptshort + P_r_CCH + 3 * P_s_micro + P_t)
)

sum = collect(simplify(sum), S_BWP)
print(sum)

sum = sum.subs(
    {
        P_1SSB: 75,
        P_r_SCH: 280,
        P_s_micro: 45,
        P_r_CCH: 50,  # BWP scaling included
        P_r_CCH_2SSB: 170,
        P_r: 300,
        S_BWP: 0.4 + 0.6 * (10 - 20) / 80,
    }
)
print(sum)

mean = sum.subs({P_t: 250 + epsilon * (10 ** (x / 10) - 1)}) / 117
print(simplify(mean))
