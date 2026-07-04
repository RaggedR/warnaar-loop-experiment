"""
Agent B: Understand D(c,c') and formulate Q_n in terms of it.

KEY THEOREM (discovered computationally, needs proof):
  adj(I-A(q))[c,c'] = q^{D(c,c')} for all compositions c, c' of d into 3 parts.
  D(c,c') is an asymmetric nonneg integer-valued function.
  adj(I-A(q^k))[c,c'] = q^{k*D(c,c')} for all k >= 1.

This gives: P_n(c) = (q^3;q^3)_n * F_{c,n} = sum_{paths} q^{weighted sum of D values}

Now: Q_n(c) = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
            = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * F_{c,j}

And F_{c,j} = P_j / (q^3;q^3)_j.

So Q_n involves an alternating sum over P_j values, divided by q-factorials.

NEW IDEA: Instead of using the matrix product, express Q_n directly as a 
coefficient extraction from a MATRIX generating function.

F_c(z,q) = sum_m z^m * v_m[c] where v_m = prod_{k=1}^m (I-A(q^k))^{-1} * v_0.
This is the c-component of (I - zA(q))^{-1}... wait, no, because the A matrix
changes at each level (A(q^k) depends on k).

Actually, F_c(z,q) = e_c^T * sum_m z^m * prod_{k=1}^m B_k^{-1} * v_0
where B_k = I - A(q^k).

This is NOT a simple geometric series because the B_k change.

Let me try a different approach: directly compute Q_n as a function of the
adjugate monomial structure.

The fact that adj(I-A(x)) is a monomial matrix means that
(I-A(x))^{-1} = adj(I-A(x)) / det(I-A(x)) = M(x) / (1-x^3)
where M(x)[c,c'] = x^{D(c,c')}.

So F_c(z,q) involves a PRODUCT of terms 1/(1-q^{3k}) * M(q^k).

Let me think about what (zq;q)_inf * F_c(z,q) looks like.

(zq;q)_inf = prod_{j>=1} (1 - zq^j)

F_c(z,q) = sum_n z^n * F_{c,n}(q)
         = sum_n z^n * e_c^T * prod_{k=1}^n (I-A(q^k))^{-1} * v_0

(zq;q)_inf * F_c(z,q) = prod_{j>=1}(1-zq^j) * sum_n z^n F_{c,n}

Q_n(q) = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
       = (q;q)_n * [z^n](sum_n z^n F_{c,n} * prod_{j>=1}(1-zq^j))

Let me think about what happens when we compute [z^n] of the product.

[z^n]((zq;q)_inf * sum_m z^m F_{c,m})
= sum_{m=0}^n F_{c,m} * [z^{n-m}](zq;q)_inf
= sum_{m=0}^n F_{c,m} * (-1)^{n-m} q^{binom(n-m+1,2)} / (q;q)_{n-m}
  (since (zq;q)_inf = sum_k (-z)^k q^{binom(k+1,2)} / (q;q)_k)

Actually (zq;q)_inf = sum_{k>=0} (-1)^k z^k q^{binom(k+1,2)} / (q;q)_k

So [z^{n-m}](zq;q)_inf = (-1)^{n-m} q^{binom(n-m+1,2)} / (q;q)_{n-m}

Q_n = (q;q)_n * sum_{m=0}^n (-1)^{n-m} q^{binom(n-m+1,2)} / (q;q)_{n-m} * F_{c,m}
    = sum_{m=0}^n (-1)^{n-m} q^{binom(n-m+1,2)} * [n choose m]_q * F_{c,m}

Now substitute F_{c,m} = e_c^T * prod_{k=1}^m B_k^{-1} * v_0:

Q_n = sum_{m=0}^n (-1)^{n-m} q^{binom(n-m+1,2)} * [n choose m]_q * 
      e_c^T * prod_{k=1}^m B_k^{-1} * v_0

Can we interchange the sum and the matrix product?

DIFFERENT APPROACH: Compute the generating function
H(z) = (zq;q)_inf * F_c(z,q) = sum_n z^n * Q_n / (q;q)_n

This is a formal power series in z with POLYNOMIAL coefficients Q_n/(q;q)_n.
But actually Q_n/(q;q)_n might not be a polynomial.

Let me just compute Q_n numerically for several profiles and several d values,
and look for structure.
"""
from sage.all import *
from itertools import combinations

def compute_Qn(d, c_target, n_max, PREC=100):
    """Compute Q_1, Q_2, ..., Q_{n_max} for profile c_target."""
    r = 3
    R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    q = R.gen()
    
    compositions = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            compositions.append((c0, c1, c2))
    N = len(compositions)
    comp_idx = {c: i for i, c in enumerate(compositions)}
    
    def shift_profile(c, J):
        k = len(c)
        result = list(c)
        for i in range(k):
            prev = (i - 1) % k
            if i in J and prev not in J:
                result[i] -= 1
            elif i not in J and prev in J:
                result[i] += 1
        return tuple(result)
    
    Rx = PolynomialRing(QQ, 'x')
    x_var = Rx.gen()
    A_poly = matrix(Rx, N, N, 0)
    
    for ic, c in enumerate(compositions):
        I_c = {i for i in range(r) if c[i] > 0}
        if not I_c:
            continue
        for size in range(1, len(I_c) + 1):
            for J in combinations(sorted(I_c), size):
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
    
    # Compute F_{c,m} for m = 0, 1, ..., n_max
    v = vector(R, [R(1)] * N)
    idx = comp_idx[c_target]
    F_vals = [R(1)]  # F_{c,0} = 1
    
    for m in range(1, n_max + 1):
        Am = eval_A(q**m)
        Bm = I_mat - Am
        v = Bm.inverse() * v
        F_vals.append(v[idx])
    
    # Compute g_m = F_{c,m} - F_{c,m-1}
    g_vals = [R(1)]  # g_0 = 1
    for m in range(1, n_max + 1):
        g_vals.append(F_vals[m] - F_vals[m-1])
    
    # Compute Q_n
    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result
    
    Q_vals = []
    for n in range(1, n_max + 1):
        Qn = R(0)
        for j in range(n + 1):
            sign = (-1)**(n-j)
            tri = (n-j)*(n-j+1)//2
            coeff = sign * q**tri / qpoch(n-j)
            Qn += coeff * g_vals[j]
        Qn *= qpoch(n)
        Q_vals.append(Qn)
    
    return Q_vals, g_vals, F_vals

# Test for d=4, c=(2,1,1)
print("d=4, c=(2,1,1):")
Qs, gs, Fs = compute_Qn(4, (2,1,1), 4, PREC=80)
for i, Q in enumerate(Qs):
    n = i + 1
    coeffs = list(Q)[:50]
    nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
    print(f"  Q_{n}: eval={sum(coeffs)}, nonneg={all(c >= 0 for c in coeffs)}, terms={len(nonzero)}")
    if n <= 3:
        print(f"    Polynomial: {Q.add_bigoh(30)}")

# Test for d=7, c=(3,2,2)
print("\nd=7, c=(3,2,2):")
Qs7, gs7, Fs7 = compute_Qn(7, (3,2,2), 3, PREC=100)
for i, Q in enumerate(Qs7):
    n = i + 1
    coeffs = list(Q)[:80]
    nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
    print(f"  Q_{n}: eval={sum(coeffs)}, nonneg={all(c >= 0 for c in coeffs)}, terms={len(nonzero)}")
    if n <= 2:
        print(f"    Polynomial: {Q.add_bigoh(40)}")

# Test for d=7, c=(4,2,1) - asymmetric profile
print("\nd=7, c=(4,2,1):")
Qs7b, gs7b, Fs7b = compute_Qn(7, (4,2,1), 3, PREC=100)
for i, Q in enumerate(Qs7b):
    n = i + 1
    coeffs = list(Q)[:80]
    nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
    print(f"  Q_{n}: eval={sum(coeffs)}, nonneg={all(c >= 0 for c in coeffs)}, terms={len(nonzero)}")
    if n <= 2:
        print(f"    Polynomial: {Q.add_bigoh(40)}")

# Test for d=10, c=(4,3,3) -- higher d
print("\nd=10, c=(4,3,3):")
Qs10, gs10, Fs10 = compute_Qn(10, (4,3,3), 2, PREC=120)
for i, Q in enumerate(Qs10):
    n = i + 1
    coeffs = list(Q)[:100]
    nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
    print(f"  Q_{n}: eval={sum(coeffs)}, nonneg={all(c >= 0 for c in coeffs)}, terms={len(nonzero)}")

# IMPORTANT: Check d=3 (d equiv 0 mod 3) -- should still be nonneg
print("\nd=3, c=(1,1,1):")
Qs3, gs3, Fs3 = compute_Qn(3, (1,1,1), 3, PREC=60)
for i, Q in enumerate(Qs3):
    n = i + 1
    coeffs = list(Q)[:40]
    nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
    print(f"  Q_{n}: eval={sum(coeffs)}, nonneg={all(c >= 0 for c in coeffs)}, terms={len(nonzero)}")
    if n <= 2:
        print(f"    Polynomial: {Q.add_bigoh(20)}")

