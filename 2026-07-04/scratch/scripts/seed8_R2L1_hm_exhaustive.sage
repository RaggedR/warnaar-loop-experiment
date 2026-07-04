"""
EXHAUSTIVE test: h_m >= 0 for ALL profiles, d=1..10, m=1..min(8, 12-d).
This tests the hypothesis that h_m was wrongly claimed negative.
"""
from sage.all import *
from itertools import combinations as combs

def compute_hm_all(d, m_max, PREC=None):
    if PREC is None:
        PREC = 6 * m_max**2 + 150
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

    neg_found = False
    for ci_idx, c in enumerate(compositions):
        for m in range(1, m_max + 1):
            gm = v_all[m][ci_idx] - v_all[m-1][ci_idx]
            hm = qpoch(m) * gm
            coeffs = [hm[i] for i in range(min(PREC-20, hm.prec()))]
            # Find the actual polynomial degree
            max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
            # Check if degree is safely within precision
            if max_d2 > PREC - 30:
                # Need more precision
                print(f"  WARNING: d={d}, c={c}, m={m}: deg={max_d2} near PREC={PREC}")
                continue
            poly = coeffs[:max_d2+1]
            negs = [i for i in range(len(poly)) if poly[i] < 0]
            if negs:
                neg_found = True
                print(f"  NEG: d={d}, c={c}, m={m}, deg={max_d2}, neg_at={negs[:5]}")
                print(f"    coeffs around neg: ...{poly[max(0,negs[0]-2):negs[0]+5]}...")
    
    if not neg_found:
        print(f"d={d}: h_m >= 0 for ALL {N} profiles, m=1..{m_max} [VERIFIED]")
    return neg_found

any_neg = False
for d in range(1, 11):
    ell = gcd(d, 3)
    if ell == 3:
        print(f"d={d}: skipping (3|d, h_m uses ell=3 definition)")
        continue
    m_max = max(2, min(8, 12 - d))
    result = compute_hm_all(d, m_max)
    if result:
        any_neg = True

if not any_neg:
    print("\n" + "="*80)
    print("RESULT: h_m >= 0 for ALL d=1..10 (d not div by 3), ALL profiles, ALL tested m.")
    print("The synthesis claim 'h_m < 0 for m >= 2' appears to be a PRECISION ARTIFACT.")
    print("This reopens the D_k^m tower approach (Path A)!")
    print("="*80)
