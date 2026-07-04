"""
Check h_m for d divisible by 3 using the corrected ell = gcd(d,3) = 3.
h_m = (q^3;q^3)_m * g_m for d divisible by 3.
"""
from sage.all import *
from itertools import combinations as combs

def compute_hm_ell(d, c, m_max, PREC=None):
    ell = gcd(d, 3)
    if PREC is None:
        PREC = 6 * m_max**2 + 200
    R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    q = R.gen()
    
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

    def qpoch_ell(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**(ell*i))
        return result

    results = {}
    for m in range(1, m_max + 1):
        gm = v_all[m][ci_idx] - v_all[m-1][ci_idx]
        hm = qpoch_ell(m) * gm
        results[m] = hm
    
    return results, R, q, ell

# d = 3
print("d=3, ell=3:")
for c in [(1,1,1), (2,1,0), (2,0,1), (0,2,1), (3,0,0), (0,3,0), (0,0,3), (1,2,0), (0,1,2)]:
    if sum(c) != 3:
        continue
    try:
        res, R, q, ell = compute_hm_ell(3, c, 4, PREC=400)
        for m in range(1, 5):
            hm = res[m]
            coeffs = [hm[i] for i in range(min(200, hm.prec()))]
            max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
            poly = coeffs[:max_d2+1]
            negs = [i for i in range(len(poly)) if poly[i] < 0]
            if negs:
                print("  c=%s, h_%d: NEG at %s" % (c, m, negs[:5]))
            elif m <= 2:
                print("  c=%s, h_%d: OK, deg=%d, coeffs=%s" % (c, m, max_d2, poly))
            else:
                print("  c=%s, h_%d: OK, deg=%d" % (c, m, max_d2))
    except Exception as e:
        print("  c=%s: error: %s" % (c, e))

# d = 6
print("\nd=6, ell=3:")
for c in [(2,2,2), (3,2,1), (4,1,1)]:
    try:
        res, R, q, ell = compute_hm_ell(6, c, 3, PREC=400)
        for m in range(1, 4):
            hm = res[m]
            coeffs = [hm[i] for i in range(min(200, hm.prec()))]
            max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
            poly = coeffs[:max_d2+1]
            negs = [i for i in range(len(poly)) if poly[i] < 0]
            if negs:
                print("  c=%s, h_%d: NEG at %s" % (c, m, negs[:5]))
                print("    values: %s" % [poly[i] for i in negs[:5]])
            else:
                print("  c=%s, h_%d: OK, deg=%d" % (c, m, max_d2))
    except Exception as e:
        print("  c=%s: error: %s" % (c, e))

# d = 9
print("\nd=9, ell=3:")
for c in [(3,3,3), (4,3,2), (5,2,2)]:
    try:
        res, R, q, ell = compute_hm_ell(9, c, 2, PREC=500)
        for m in range(1, 3):
            hm = res[m]
            coeffs = [hm[i] for i in range(min(300, hm.prec()))]
            max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
            if max_d2 > 280:
                print("  c=%s, h_%d: WARNING near precision" % (c, m))
                continue
            poly = coeffs[:max_d2+1]
            negs = [i for i in range(len(poly)) if poly[i] < 0]
            if negs:
                print("  c=%s, h_%d: NEG at %s" % (c, m, negs[:5]))
            else:
                print("  c=%s, h_%d: OK, deg=%d" % (c, m, max_d2))
    except Exception as e:
        print("  c=%s: error: %s" % (c, e))
