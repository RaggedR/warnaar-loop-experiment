#!/usr/bin/env python3
"""Independent R1 audit (Thm 7.5 and its ingredients), written from the tex only."""
import sys
from fractions import Fraction
from audit6L4 import sphere, har_local, q1coef_raw, har_inf_formula

def y(m):
    return (m + 1) // 2 if m >= 1 else 0   # ceil(m/2), 0 for m<=0

def check_ingredients():
    # Lemma 7.1(1): mu_e(v) = 1 + [v==e mod 2] - [|v|==e], |v|<=e
    for e in range(1, 121):
        cnt = {}
        for (s, t) in sphere(e):
            v = s + t
            cnt[v] = cnt.get(v, 0) + 1
        for v in range(-e - 2, e + 3):
            expect = 0
            if abs(v) <= e:
                expect = 1 + (1 if (v - e) % 2 == 0 else 0) - (1 if abs(v) == e else 0)
            assert cnt.get(v, 0) == expect, (e, v)
    print("OK Lemma7.1(1): mu_e(v) formula, e <= 120")
    # Lemma 7.1(2): #{u in S_e : u0+u1 > beta} = floor((3(e-beta)-1)/2), delta>=1
    for e in range(1, 121):
        for beta in range(0, e + 5):
            got = sum(1 for (s, t) in sphere(e) if s + t > beta)
            d = e - beta
            expect = (3 * d - 1) // 2 if d >= 1 else 0
            assert got == expect, (e, beta)
    print("OK Lemma7.1(2): tail count formula, e <= 120, all beta >= 0")
    # Lemma 7.1(3): x(m) identity
    for m in range(1, 2001):
        x = sum((3 * (m - 3 * r) - 1) // 2 for r in range(0, (m - 1) // 3 + 1))
        assert x == ((m + 1) ** 2) // 4, m
    print("OK Lemma7.1(3): x(m) = floor((m+1)^2/4), m <= 2000")
    # Lemma 7.1(4): w_k(beta) = (k+1) - y(k-beta) vs my raw Q1 coefficient
    for k in range(1, 41):
        for beta in range(0, k + 5):
            got = q1coef_raw((k + 5, k + 5, beta), k)   # first two coords inactive
            assert got == (k + 1) - y(k - beta), (k, beta)
    print("OK Lemma7.1(4): w_k(beta) closed form, k <= 40, all beta")

def mu(e, v):
    if abs(v) > e:
        return 0
    return 1 + (1 if (v - e) % 2 == 0 else 0) - (1 if abs(v) == e else 0)

def phi_mine(j, a):
    """Direct transcription of Prop 7.2 from the tex (double sum)."""
    E = (j - 1) // 2
    C1 = sum((j - 2 * e + 1) * ((3 * (e - a) - 1) // 2) for e in range(a + 1, E + 1))
    C2 = 0
    for e in range(1, E + 1):
        n = j - 2 * e - a
        for v in range(max(-e, 1 - n), min(e, a) + 1):
            C2 += mu(e, v) * y(n + v)
    C3 = sum(y(j - a - i) for i in range(1, 6))
    return har_inf_formula(j) - C1 - C2 + C3

def check_phi_vs_har(jmax=40):
    for j in range(1, jmax + 1):
        L = j + 9
        for a in range(0, j - 1):
            assert phi_mine(j, a) == har_local((L, L + 1, a), j), (j, a)
    print(f"OK Prop7.2: phi_mine(j,a) == har_j((big,big,a)) for j <= {jmax}, all a <= j-2")

def check_head():
    claimed = {0: 0, 1: 0, 3: 0, 2: -2, 4: -1}
    vals5_22 = [3, 4, 12, 17, 31, 41, 61, 76, 104, 126, 162, 191, 237, 275, 331,
                378, 446, 504]
    for j, v in zip(range(5, 23), vals5_22):
        claimed[j] = v
    for j in range(0, 23):
        m = min(phi_mine(j, a) for a in range(0, max(1, j - 1)))
        assert m == claimed[j], (j, m, claimed[j])
    print("OK head check: min_a phi_j matches all claimed values j <= 22 (incl. -2@2, -1@4)")

def check_tail(jmax=650):
    """phi > 0 and |phi - cubic| <= (5/8)j^2+7j+4 on LOW/HIGH; strips separately."""
    worst = None
    for j in list(range(23, 200)) + list(range(200, jmax + 1, 7)):
        slop = Fraction(5, 8) * j * j + 7 * j + 4
        for a in range(0, j - 1):
            p = phi_mine(j, a)
            assert p > 0, (j, a, p)
            cub = Fraction(j**3 + 6 * j * j * a - 6 * j * a * a + 2 * a**3, 24)
            dev = abs(p - cub)
            if a <= j - 4:                       # LOW/HIGH chambers
                assert dev <= slop, (j, a, float(dev - slop))
                r = float(dev / slop)
                if worst is None or r > worst[0]:
                    worst = (r, j, a)
    print(f"OK tail: phi_j(a) > 0 for all sampled j in [23,{jmax}], all a; "
          f"slop bound holds on LOW/HIGH, worst |dev|/slop = {worst[0]:.3f} at "
          f"(j,a)=({worst[1]},{worst[2]})")

def check_strips(jmax=800):
    for n in (2, 3):
        for j in range(10, jmax + 1):
            p = phi_mine(j, j - n)
            assert p > 0, (j, n, p)
    print(f"OK strips a=j-2, j-3: phi > 0 for 10 <= j <= {jmax}")

def check_slop_threshold():
    bad = [j for j in range(1, 60) if 24 * ((Fraction(5, 8) * j * j + 7 * j + 4)) >= j**3]
    assert max(bad) == 22, bad
    print("OK arithmetic: j^3/24 > (5/8)j^2+7j+4 iff j >= 23")
    bad8 = [j for j in range(1, 60) if 8 * ((Fraction(5, 8) * j * j + 7 * j + 4)) >= j**3]
    print(f"NOTE: with lead 1/8 and the SAME slop constants, positivity needs j >= {max(bad8)+1} (tex says strips 'positive for j >= 10')")

if __name__ == "__main__":
    check_ingredients()
    check_phi_vs_har(40)
    check_head()
    check_slop_threshold()
    check_strips(800)
    check_tail(650)
    print("R1 AUDIT PASSES")
