"""
Agent C: The key identity.

We verified: (I - A(q^n)) * Q_n_vec = RHS(Q_{n-1}, Q_{n-2})

Therefore: Q_n_vec = adj(I-A(q^n)) / (1-q^{3n}) * RHS

The adjugate has entries q^{n*EMD(c,c')}, so:
Q_n(c) = (1/(1-q^{3n})) * sum_{c'} q^{n*EMD(c,c')} * RHS(c')

Now, RHS(c') = sum_{|J|=2} q^{2n-1}(1-q^n) Q_{n-1}(c'(J))
             - sum_{|J|=3, if applicable} (q^{3n-2}+q^{3n-1})(1-q^n) Q_{n-1}(c')
             + sum_{|J|=3, if applicable} q^{3n-3}(1-q^n)(1-q^{n-1}) Q_{n-2}(c')

The factor (1-q^n) appears everywhere. And we need to divide by (1-q^{3n}).
Now (1-q^{3n}) = (1-q^n)(1+q^n+q^{2n}).

So Q_n(c) = (1/(1+q^n+q^{2n})) * sum_{c'} q^{n*EMD(c,c')} * RHS'(c')

where RHS' = RHS / (1-q^n) = sum_{|J|=2} q^{2n-1} Q_{n-1}(c'(J))
                              - sum_{|J|=3} (q^{3n-2}+q^{3n-1}) Q_{n-1}(c')
                              + sum_{|J|=3} q^{3n-3}(1-q^{n-1}) Q_{n-2}(c')

This is simpler! Now we need:
(1/(1+q^n+q^{2n})) * sum_{c'} q^{n*EMD(c,c')} * RHS'(c') >= 0

Since 1/(1+q^n+q^{2n}) = sum_{k>=0} (-1)^k q^{kn} * ... this has alternating signs.

Hmm, this approach still has mixed signs.

ALTERNATIVE: Maybe the sum over c' of q^{n*EMD(c,c')} * RHS'(c') is itself
divisible by (1+q^n+q^{2n}), and the quotient is nonneg.

Let me check this numerically.
"""
from sage.all import *
from itertools import combinations as combs

R = PowerSeriesRing(QQ, 'q', default_prec=100)
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

def EMD(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

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

# For each n, compute the "reduced RHS" = RHS / (1-q^n)
# and then the adjugate-convolved sum, and check divisibility by (1+q^n+q^{2n})

Rp = PolynomialRing(QQ, 'q')
qp = Rp.gen()

for n in [2, 3, 4]:
    print(f"\n{'='*60}")
    print(f"n = {n}")
    print(f"{'='*60}")
    
    # Compute RHS'(c') for each c'
    rhs_prime = {}
    for ci, c in enumerate(compositions):
        I_c = [i for i in range(3) if c[i] > 0]
        val = R(0)
        
        # |J|=2 contribution (divided by (1-q^n))
        for J in combs(I_c, 2):
            cJ = shift_profile(c, set(J))
            if min(cJ) < 0 or cJ not in comp_idx:
                continue
            val += q**(2*n-1) * Qn_all[(cJ, n-1)]
        
        # |J|=3 contribution (divided by (1-q^n))
        if len(I_c) == 3:
            val -= (q**(3*n-2) + q**(3*n-1)) * Qn_all[(c, n-1)]
            if n >= 2:
                val += q**(3*n-3) * (1-q**(n-1)) * Qn_all[(c, n-2)]
        
        rhs_prime[c] = val
    
    # For each target c, compute sum_{c'} q^{n*EMD(c,c')} * RHS'(c')
    # and check if divisible by (1+q^n+q^{2n})
    for c in [(2,1,1), (4,0,0), (3,1,0)]:
        numerator = R(0)
        for cp in compositions:
            emd = EMD(c, cp)
            numerator += q**(n*emd) * rhs_prime[cp]
        
        num_trunc = numerator.truncate(80)
        num_p = sum(num_trunc[i] * qp**i for i in range(80) if num_trunc[i] != 0)
        
        # Divide by (1 + q^n + q^{2n})
        divisor = 1 + qp**n + qp**(2*n)
        quo, rem = num_p.quo_rem(divisor)
        
        if rem == 0:
            quo_coeffs = [quo[i] for i in range(quo.degree()+1)]
            is_nonneg = all(c >= 0 for c in quo_coeffs)
            
            actual = Qn_all[(c, n)].truncate(60)
            actual_p = sum(actual[i] * qp**i for i in range(60) if actual[i] != 0)
            
            match = (quo == actual_p)
            
            print(f"  c={c}: divisible by 1+q^n+q^{2*n}={match}, nonneg={is_nonneg}")
            if quo.degree() <= 30:
                print(f"    quotient = {quo}")
            if not match:
                print(f"    actual Q_{n} = {actual_p}")
        else:
            print(f"  c={c}: NOT divisible, rem = {rem}")

# NOW THE BIG QUESTION: What structure makes the quotient nonneg?
# The quotient = Q_n(c) by construction.
# We need to understand WHY the sum over EMD-weighted RHS' values,
# divided by (1+q^n+q^{2n}), gives nonneg coefficients.

# OBSERVATION: The EMD values depend on the PROFILE GEOMETRY.
# When d is not div by 3, the EMD values are NOT all multiples of 3.
# This means the sum over q^{n*EMD} * RHS' can be "mixed" enough to
# produce positive results after dividing by 1+q^n+q^{2n}.

# When d IS div by 3, ALL EMD values are multiples of 3!
# (Because EMD uses the cyclic structure on Z/3Z.)
# So q^{n*EMD} = q^{3n * (EMD/3)} and (1+q^n+q^{2n}) | (1+q^{...}).
# Wait, that's not right either.

# Let me check: are all EMD values multiples of 3 when d is divisible by 3?
print("\n\nEMD values for d=3:")
d3_comps = [(a,b,3-a-b) for a in range(4) for b in range(4-a)]
for c in d3_comps:
    for cp in d3_comps:
        emd = EMD(c, cp)
        if emd % 3 != 0 and emd != 0:
            print(f"  EMD({c}, {cp}) = {emd} (NOT div by 3!)")

print("\nEMD values for d=4:")
d4_comps = [(a,b,4-a-b) for a in range(5) for b in range(5-a)]
for c in d4_comps[:5]:
    emds = [EMD(c, cp) for cp in d4_comps]
    print(f"  c={c}: EMD values = {sorted(set(emds))}")

print("\nEMD values for d=6:")
d6_comps = [(a,b,6-a-b) for a in range(7) for b in range(7-a)]
for c in [(2,2,2), (3,2,1), (6,0,0)]:
    emds = [EMD(c, cp) for cp in d6_comps]
    print(f"  c={c}: EMD values = {sorted(set(emds))}")

