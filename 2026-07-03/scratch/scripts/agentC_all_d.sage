"""
Agent C: Check positivity with correct ell = gcd(d,3) for ALL d.

POTENTIAL NEW DISCOVERY: Q_n may be nonneg for ALL d, not just d not equiv 0 mod 3,
when using the correct ell!
"""
from sage.all import *
from itertools import combinations as combs

def compute_all_Qn(d, n_max=3, PREC=80):
    """Compute Q_n for ALL profiles with correct ell."""
    r = 3
    ell = gcd(d, r)
    R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    q = R.gen()
    
    compositions = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            compositions.append((c0, c1, d-c0-c1))
    N = len(compositions)
    comp_idx = {c: i for i, c in enumerate(compositions)}
    
    def shift_profile(c, J):
        result = list(c)
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
    for ic, c in enumerate(compositions):
        I_c = {i for i in range(3) if c[i] > 0}
        if not I_c:
            continue
        for size in range(1, len(I_c) + 1):
            for J in combs(sorted(I_c), size):
                J_set = set(J)
                cJ = shift_profile(c, J_set)
                if min(cJ) < 0:
                    continue
                sign = (-1)**(size - 1)
                jcJ = comp_idx[cJ]
                A_poly[ic, jcJ] += sign * x_var**size
    
    def eval_A(val):
        A_eval = matrix(R, N, N)
        for i in range(N):
            for j in range(N):
                poly = A_poly[i,j]
                v = R(0)
                for k, coeff in enumerate(poly.list()):
                    v += coeff * val**k
                A_eval[i,j] = v
        return A_eval
    
    I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
    
    v_all = [vector(R, [R(1)] * N)]
    for m in range(1, n_max + 1):
        Am = eval_A(q**m)
        Bm = I_mat - Am
        v_next = Bm.inverse() * v_all[-1]
        v_all.append(v_next)
    
    g_all = [vector(R, [R(1)] * N)]
    for m in range(1, n_max + 1):
        g_all.append(v_all[m] - v_all[m-1])
    
    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result
    
    def qpoch_ell(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**(ell*i))
        return result
    
    results = {}
    for n in range(1, n_max + 1):
        for ci, c in enumerate(compositions):
            Qn = R(0)
            for j in range(n+1):
                sign = (-1)**(n-j)
                tri = (n-j)*(n-j+1)//2
                coeff = sign * q**tri / qpoch(n-j)
                Qn += coeff * g_all[j][ci]
            Qn *= qpoch_ell(n)
            results[(c, n)] = Qn
    
    return results, compositions, ell

# Check d = 1 through 12
for d in range(1, 13):
    ell = gcd(d, 3)
    results, compositions, ell_val = compute_all_Qn(d, n_max=min(3, 4-d//4), PREC=max(50, 20*d))
    
    n_max_actual = min(3, 4-d//4)
    all_ok = True
    q1_vals = set()
    
    for n in range(1, n_max_actual + 1):
        for c in compositions:
            Qn = results[(c, n)]
            coeffs = [Qn[i] for i in range(min(200, Qn.prec()))]
            max_d = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
            poly = coeffs[:max_d+1]
            if any(coeff < 0 for coeff in poly):
                all_ok = False
                if n == 1:
                    print(f"  d={d}, ell={ell_val}: NEGATIVE at c={c}, n={n}")
                    neg_terms = [(i, poly[i]) for i in range(len(poly)) if poly[i] < 0]
                    print(f"    neg at: {neg_terms[:3]}")
            
            if n == 1:
                q1_vals.add(sum(poly))
    
    if all_ok:
        print(f"d={d}, ell={ell_val}: ALL NONNEG (n=1..{n_max_actual}), Q_1(1) = {q1_vals}")
    elif all_ok == False and d > 6:
        print(f"d={d}: some negatives found")

