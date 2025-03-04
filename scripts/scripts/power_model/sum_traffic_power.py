from sympy import *

s = symbols("S")
r_sleep, n_sleep = symbols("r_sleep, n_sleep")
t, t_c, t_P_D, t_P_U = symbols("T, T_C, T_P_D, T_P_U")
x = symbols("x")
epsilon = 450 / (10 ** (23 / 10) - 1)

s_PUSCH = t / t_P_U
s_PDCCH_PUCCH = s_PUSCH

s_PDCCH_PDSCH = t / t_P_D

s_sleep = r_sleep * s

s_PDCCH = (1 - r_sleep) * s - (s_PDCCH_PUCCH + s_PUSCH + s_PDCCH_PDSCH)

s_sum = s_sleep + s_PDCCH_PUCCH + s_PUSCH + s_PDCCH + s_PDCCH_PDSCH

# Check that the sum of all parts is S:
assert simplify(s_sum) == s

p_s_deep, p_transition, p_r_CCH, p_r, p_t_short, p_t, s_bwp, b_d = symbols(
    "P_s_deep, P_transition, P_r_CCH, P_r, P_t_short, P_t, S_BWP, B_D"
)


p_data = (
    p_s_deep * s_sleep
    + p_transition * n_sleep * t / t_c
    + s_bwp * (p_r_CCH * (s_PDCCH + s_PDCCH_PUCCH) + p_r * s_PDCCH_PDSCH)
    + p_t_short * s_PDCCH_PUCCH
    + p_t * s_PUSCH
) / s

p_data = p_data.subs(
    {
        s: 2 * t,
        p_s_deep: 1,
        p_transition: 450,
        p_r_CCH: 100,
        p_r: 300,
        p_t_short: 0.3 * p_t,
    }
)

print(collect(simplify(p_data), r_sleep))

p_data = p_data.subs(
    {
        s_bwp: 0.4 + 0.6 * (b_d - 20) / 80,
        p_t: 250 + epsilon * (10 ** (x / 10) - 1),
    }
)

p_data = collect(simplify(p_data), [r_sleep, t_P_U, t_P_D])
print(p_data)
