"""
Check h_m negativity across ALL profiles for d=4.
Agent A claimed h_2 has negative coefficients for d=4, c=(2,1,1).
But we just found it's nonneg! Let's check carefully.
"""
from sage.all import *
from itertools import combinations as combs

def compute_hm_all_profiles(d, m_max, PREC=None):
    if PREC is None:
        PREC = 6 * m_max**2 + 100
    R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    q = R.gen()
    
    compositions = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            compositions.append((c0, c1, d-c0-c1))
    N = len(compositions)
    comp_idx = {comp: i for i, comp in enumerate(compositions)}

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

    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result

    results = {}
    for ci_idx, c in enumerate(compositions):
        for m in range(1, m_max + 1):
            gm = v_all[m][ci_idx] - v_all[m-1][ci_idx]
            hm = qpoch(m) * gm
            results[(c, m)] = hm
    
    return results, compositions, R, q

# Check d=4
print("d=4, all profiles, h_m for m=1..5:")
PREC = 500
results4, comps4, R4, q4 = compute_hm_all_profiles(4, 5, PREC)
for c in comps4:
    for m in range(1, 6):
        hm = results4[(c, m)]
        coeffs = [hm[i] for i in range(min(250, hm.prec()))]
        max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
        poly = coeffs[:max_d2+1]
        negs = [(i, poly[i]) for i in range(len(poly)) if poly[i] < 0]
        if negs:
            print(f"  c={c}, h_{m}: NEG at {negs[:5]}")
            if m <= 3:
                print(f"    full: {poly}")

# Check d=5
print("\nd=5, all profiles, h_m for m=1..4:")
results5, comps5, R5, q5 = compute_hm_all_profiles(5, 4, PREC)
for c in comps5:
    for m in range(1, 5):
        hm = results5[(c, m)]
        coeffs = [hm[i] for i in range(min(250, hm.prec()))]
        max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
        poly = coeffs[:max_d2+1]
        negs = [(i, poly[i]) for i in range(len(poly)) if poly[i] < 0]
        if negs:
            print(f"  c={c}, h_{m}: NEG at {negs[:5]}")

print("\nIf no NEG lines printed, h_m is nonneg for all profiles tested.")
print("This would CONTRADICT the synthesis claim that h_m < 0 for m >= 2.")
