"""
Agent C: The FULL recurrence:
  Q_n(c) = sum_{c'} q^{n*EMD(c,c')} / (1-q^{3n}) * RHS(c')

where RHS involves Q_{n-1} and Q_{n-2} (which are nonneg by induction).

Question: Is the NUMERATOR sum_{c'} q^{n*EMD(c,c')} * RHS(c') divisible by (1-q^{3n}),
and is the quotient nonneg?
"""
from sage.all import *
from itertools import combinations as combs

R = PowerSeriesRing(QQ, 'q', default_prec=80)
q = R.gen()

d = 4
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

# Compute F_{c,m} vectors 
v_all = [vector(R, [R(1)] * N)]
for m in range(1, 6):
    Am = eval_A(q**m)
    Bm = I_mat - Am
    v_next = Bm.inverse() * v_all[-1]
    v_all.append(v_next)

g_all = [vector(R, [R(1)] * N)]
for m in range(1, 6):
    g_all.append(v_all[m] - v_all[m-1])

def qpoch(n):
    result = R(1)
    for i in range(1, n+1):
        result *= (1 - q**i)
    return result

Qn_all = {}
for c in compositions:
    Qn_all[(c, 0)] = R(1)

for n in range(1, 5):
    for ci, c in enumerate(compositions):
        Qn = R(0)
        for j in range(n+1):
            sign = (-1)**(n-j)
            tri = (n-j)*(n-j+1)//2
            coeff = sign * q**tri / qpoch(n-j)
            Qn += coeff * g_all[j][ci]
        Qn *= qpoch(n)
        Qn_all[(c, n)] = Qn

# Compute EMD
def EMD(c, cp):
    """EMD(c, c') = 3*max(0, c'_1 - c_1, c_0 - c'_0) + (c'_0 - c_0) - (c'_1 - c_1)"""
    return 3*max(0, cp[1] - c[1], c[0] - cp[0]) + (cp[0] - c[0]) - (cp[1] - c[1])

# Compute RHS for given n
def compute_RHS(n):
    rhs = vector(R, N)
    for ci, c in enumerate(compositions):
        I_c = [i for i in range(3) if c[i] > 0]
        val = R(0)
        for J in combs(I_c, 2):
            cJ = shift_profile(c, set(J))
            if min(cJ) < 0 or cJ not in comp_idx:
                continue
            val += q**(2*n-1) * (1-q**n) * Qn_all[(cJ, n-1)]
        if len(I_c) == 3:
            val -= (q**(3*n-2) + q**(3*n-1)) * (1-q**n) * Qn_all[(c, n-1)]
            if n >= 2:
                val += q**(3*n-3) * (1-q**n) * (1-q**(n-1)) * Qn_all[(c, n-2)]
        rhs[ci] = val
    return rhs

# For n=2, 3: check if adj(I-A(q^n)) * RHS is divisible by (1-q^{3n}) and nonneg
for n in [1, 2, 3, 4]:
    print(f"\n{'='*60}")
    print(f"n = {n}")
    print(f"{'='*60}")
    
    rhs = compute_RHS(n)
    
    # Compute sum_{c'} q^{n*EMD(c,c')} * RHS(c')
    for ci, c in enumerate(compositions):
        numerator = R(0)
        for cpi, cp in enumerate(compositions):
            emd = EMD(c, cp)
            numerator += q**(n * emd) * rhs[cpi]
        
        # Check divisibility by (1 - q^{3n})
        num_poly = numerator.truncate(70)
        divisor = 1 - q**(3*n)
        
        # Use polynomial division
        Rp = PolynomialRing(QQ, 'q')
        qp = Rp.gen()
        num_p = sum(num_poly[i] * qp**i for i in range(70) if num_poly[i] != 0)
        div_p = 1 - qp**(3*n)
        
        if div_p == 0:
            print(f"  c={c}: divisor is 0 (n=0 case)")
            continue
            
        quo, rem = num_p.quo_rem(div_p)
        
        if rem == 0:
            quo_coeffs = [quo[i] for i in range(quo.degree()+1)]
            is_nonneg = all(c >= 0 for c in quo_coeffs)
            
            # Verify against actual Q_n
            actual = Qn_all[(c, n)].truncate(60)
            
            if is_nonneg:
                status = "NONNEG"
            else:
                neg_terms = [(i, quo_coeffs[i]) for i in range(len(quo_coeffs)) if quo_coeffs[i] < 0]
                status = f"HAS NEGATIVES at {neg_terms[:3]}"
            
            # Only print for representative profiles
            if c in [(2,1,1), (3,1,0), (4,0,0), (2,2,0), (3,0,1)]:
                print(f"  c={c}: quotient {status}")
                if quo.degree() <= 30:
                    print(f"    = {quo}")
                print(f"    Actual Q_{n}({c}) = {actual}")
                actual_coeffs = [actual[i] for i in range(60)]
                max_d = max((i for i in range(60) if actual_coeffs[i] != 0), default=0)
                actual_nonneg = all(actual_coeffs[i] >= 0 for i in range(max_d+1))
                print(f"    Actual Q_{n} nonneg = {actual_nonneg}")
        else:
            if c in [(2,1,1), (3,1,0), (4,0,0)]:
                print(f"  c={c}: NOT DIVISIBLE, rem = {rem}")

