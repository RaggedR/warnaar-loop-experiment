"""
Seed 8, Round 2, Layer 1: D_k^m and Ehrhart theory investigation.
Compute D_k^m for d=4 profile (2,1,1) and analyze structure.
"""
from sage.all import *
from itertools import combinations as combs

def compute_Dkm(d, c, k_max, m_max, PREC=None):
    if PREC is None:
        PREC = 6 * max(k_max, m_max)**2 + 100
    R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    q = R.gen()
    r = 3
    ell = gcd(d, r)
    compositions = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            compositions.append((c0, c1, d-c0-c1))
    N = len(compositions)
    comp_idx = {comp: i for i, comp in enumerate(compositions)}
    ci_idx = comp_idx[c]

    def shift_profile(comp, J):
        result = list(comp)
        J_set = set(J)
        for i in range(3):
            prev = (i - 1) % 3
            if i in J_set and prev not in J_set:
                result[i] -= 1
            elif i not in J_set and prev in J_set:
                result[i] += 1
        return tuple(result)

    Rx = PolynomialRing(QQ, 'x')
    x_var = Rx.gen()
    A_poly = matrix(Rx, N, N, 0)
    for ic2, comp2 in enumerate(compositions):
        I_c = {i for i in range(3) if comp2[i] > 0}
        if not I_c:
            continue
        for size in range(1, len(I_c) + 1):
            for J in combs(sorted(I_c), size):
                J_set = set(J)
                cJ = shift_profile(comp2, J_set)
                if min(cJ) < 0:
                    continue
                sign = (-1)**(size - 1)
                jcJ = comp_idx[cJ]
                A_poly[ic2, jcJ] += sign * x_var**size

    def eval_A(val):
        A_eval = matrix(R, N, N)
        for i in range(N):
            for j in range(N):
                poly = A_poly[i,j]
                v = R(0)
                for k2, coeff in enumerate(poly.list()):
                    v += coeff * val**k2
                A_eval[i,j] = v
        return A_eval

    I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
    v_all = [vector(R, [R(1)] * N)]
    for m in range(1, m_max + 1):
        Am = eval_A(q**m)
        Bm = I_mat - Am
        v_next = Bm.inverse() * v_all[-1]
        v_all.append(v_next)

    g_all = [R(1)]
    for m in range(1, m_max + 1):
        g_all.append(v_all[m][ci_idx] - v_all[m-1][ci_idx])

    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result

    h_all = [R(1)]
    for m in range(1, m_max + 1):
        h_all.append(qpoch(m) * g_all[m])

    D = {}
    for m in range(m_max + 1):
        D[(0, m)] = h_all[m]
    for k in range(1, k_max + 1):
        for m in range(k, m_max + 1):
            D[(k, m)] = D[(k-1, m)] - q**k * D[(k-1, m-1)]

    return D, R, q

# Main computation
print("=" * 80)
print("D_k^m for d=4, c=(2,1,1)")
print("=" * 80)

d = 4; c = (2, 1, 1); k_max = 6; m_max = 6
D, R, q = compute_Dkm(d, c, k_max, m_max, PREC=400)

for k in range(k_max + 1):
    for m in range(max(k, 1), m_max + 1):
        Dkm = D[(k, m)]
        coeffs = [Dkm[i] for i in range(min(200, Dkm.prec()))]
        max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
        poly = coeffs[:max_d2+1]
        is_nonneg = all(coeff >= 0 for coeff in poly)
        eval1 = sum(poly)
        status = "OK" if is_nonneg else f"NEG(min={min(poly)})"
        if k == 0 and m >= 2:
            neg_terms = [(i, poly[i]) for i in range(len(poly)) if poly[i] < 0]
            status += f" negs={neg_terms[:5]}"
        print(f"D({k},{m}): deg={max_d2}, eval(1)={eval1}, [{status}]")
        if max_d2 <= 25 and is_nonneg:
            print(f"   coeffs: {poly}")

# Check D_k^m(1) table
print("\nD_k^m(1) table:")
header = f"{'k\\m':>5}"
for m in range(m_max + 1):
    header += f"{m:>10}"
print(header)
for k in range(k_max + 1):
    row = f"{k:>5}"
    for m in range(m_max + 1):
        if (k, m) in D and m >= k:
            Dkm = D[(k, m)]
            coeffs = [Dkm[i] for i in range(min(200, Dkm.prec()))]
            max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
            val = sum(coeffs[:max_d2+1])
            row += f"{int(val):>10}"
        else:
            row += f"{'':>10}"
    print(row)

# Check symmetry and unimodality
print("\n--- Structure tests for D_k^m (k >= 1) ---")
for k in range(1, min(5, k_max+1)):
    for m in range(k, min(6, m_max+1)):
        Dkm = D[(k, m)]
        coeffs = [Dkm[i] for i in range(min(200, Dkm.prec()))]
        max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
        poly = coeffs[:max_d2+1]
        if len(poly) <= 1:
            continue
        rev = list(reversed(poly))
        is_sym = (poly == rev)
        # Unimodal?
        peak = False; uni = True
        for i in range(1, len(poly)):
            if poly[i] < poly[i-1]:
                peak = True
            elif peak and poly[i] > poly[i-1]:
                uni = False; break
        # log-concave?
        lc = True
        for i in range(1, len(poly)-1):
            if poly[i]**2 < poly[i-1]*poly[i+1]:
                lc = False; break
        print(f"D({k},{m}): deg={max_d2}, sym={is_sym}, uni={uni}, log-concave={lc}")

# KEY TEST: D_1^m coefficients
print("\n--- D_1^m coefficients in detail ---")
for m in range(1, m_max+1):
    Dkm = D[(1, m)]
    coeffs = [Dkm[i] for i in range(min(200, Dkm.prec()))]
    max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
    poly = coeffs[:max_d2+1]
    print(f"D(1,{m}): {poly}")

# Test: D_1^m = h_m - q * h_{m-1}. Can we express this as lattice point count?
# h_m = (q;q)_m * g_m. So D_1^m = (q;q)_m * g_m - q * (q;q)_{m-1} * g_{m-1}
# = (q;q)_{m-1} * [(1-q^m) * g_m - q * g_{m-1}]
# The injection lemma says g_m >= q * g_{m-1}, so (1-q^m)*g_m - q*g_{m-1}
# = g_m - q^m * g_m - q * g_{m-1}
# = (g_m - q * g_{m-1}) - q^m * g_m
# where g_m - q*g_{m-1} >= 0 by injection lemma.
# But q^m * g_m could be large, so this doesn't immediately give positivity.

# Actually wait: D_1^m = h_m - q*h_{m-1} = (q;q)_m*g_m - q*(q;q)_{m-1}*g_{m-1}
# (q;q)_m = (q;q)_{m-1} * (1-q^m)
# So D_1^m = (q;q)_{m-1} * [(1-q^m)*g_m - q*g_{m-1}]
# Since (q;q)_{m-1} has alternating signs, this is not obviously nonneg.

# But D_1^m IS nonneg! So the cancellation must work.
# Let's compute (1-q^m)*g_m - q*g_{m-1} and see if it has a sign pattern
# that cancels nicely with (q;q)_{m-1}.

print("\n--- Analyzing (1-q^m)*g_m - q*g_{m-1} ---")
g_all2 = [R(1)]
v_all2 = [vector(R, [R(1)] * len(D[(0,0)].parent().gens()) if False else 1)]
# Recompute g from D
# Actually, let me just extract from D:
# D_0^m = h_m = (q;q)_m * g_m => g_m = h_m / (q;q)_m
# But g_m is not a polynomial. Let me compute the "remainder" differently.

print("\nDone.")
