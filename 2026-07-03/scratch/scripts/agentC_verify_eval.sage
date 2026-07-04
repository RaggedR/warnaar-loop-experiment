"""Agent C: Verify Q_n(1) = base^n for d=5 and d=7, and check the n=4 anomaly."""
from sage.all import *
from itertools import combinations as combs

def compute_Qn_correct(d, c_target, n_max, PREC=150):
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
    
    idx = comp_idx[c_target]
    Q_vals = []
    for n in range(1, n_max + 1):
        Qn = R(0)
        for j in range(n+1):
            sign = (-1)**(n-j)
            tri = (n-j)*(n-j+1)//2
            coeff = sign * q**tri / qpoch(n-j)
            Qn += coeff * g_all[j][idx]
        Qn *= qpoch_ell(n)
        Q_vals.append(Qn)
    
    return Q_vals

# Verify d=5 n=4 with higher precision
print("d=5, c=(2,2,1), n=1..4:")
Qs5 = compute_Qn_correct(5, (2,2,1), 4, PREC=200)
for i, Q in enumerate(Qs5):
    n = i + 1
    coeffs = [Q[j] for j in range(180)]
    max_d = max((j for j in range(180) if coeffs[j] != 0), default=0)
    poly = coeffs[:max_d+1]
    eval1 = sum(poly)
    expected = 6**n
    nonneg = all(c >= 0 for c in poly)
    print(f"  Q_{n}(1) = {eval1}, expected = {expected}, match = {eval1 == expected}, nonneg = {nonneg}, deg = {max_d}")

# The n=4 anomaly earlier showed Q_4(1) values = {1288, 1296, 1293, 1295}
# rather than all being 6^4 = 1296. This was likely a precision issue.

print()
print("d=5 with HIGHER precision, all profiles n=4:")
comps5 = [(c0, c1, 5-c0-c1) for c0 in range(6) for c1 in range(6-c0)]
eval_set = set()
for c in comps5[:5]:  # Just check a few
    Qs = compute_Qn_correct(5, c, 4, PREC=200)
    Q4 = Qs[3]
    coeffs = [Q4[j] for j in range(180)]
    max_d = max((j for j in range(180) if coeffs[j] != 0), default=0)
    poly = coeffs[:max_d+1]
    eval1 = sum(poly)
    eval_set.add(eval1)
    nonneg = all(c >= 0 for c in poly)
    print(f"  c={c}: Q_4(1) = {eval1}, nonneg = {nonneg}, deg = {max_d}")

print(f"\n  All Q_4(1) values: {eval_set}")
print(f"  Expected: 6^4 = {6**4}")

