"""
Agent C: Test the inductive positivity hypothesis.

THEOREM ATTEMPT (The Adjugate Recurrence Theorem):
  Q_n(c) = (1/(1-q^{3n})) * sum_{c'} q^{n*EMD(c,c')} * R_n(c')

where R_n(c') depends only on Q_{n-1} and Q_{n-2} at various profiles.

CONJECTURE: If Q_{n-1} >= 0 (all profiles) and Q_{n-2} >= 0 (all profiles),
then Q_n >= 0.

This would prove the conjecture by induction (base cases Q_0 = 1, Q_1 >= 0 known).

To make this work, we need R_n decomposed into its positive and negative parts,
and we need the adjugate convolution to produce a nonneg result.

KEY INSIGHT: The adjugate monomials q^{n*EMD(c,c')} are always nonneg.
So the convolution is a POSITIVE COMBINATION of R_n values, weighted by EMD.
If R_n itself could be made nonneg, we'd be done.
But R_n has negative terms (from the (1-zq)(1-zq^2) factors).

ALTERNATIVE APPROACH: Don't try to prove Q_n >= 0 from the recurrence directly.
Instead, find the RIGHT decomposition of Q_n.

Actually, let me reconsider. The recurrence gives:
  (I - A(q^n)) * Q_n = RHS(Q_{n-1}, Q_{n-2})

This is EXACTLY the same structure as the transfer matrix for F_{c,m}:
  (I - A(q^m)) * F_m = F_{m-1}  (simplified)

The difference is that for F_m, the RHS is just F_{m-1} (simple positive terms),
while for Q_n, the RHS has mixed signs from the (zq;q)_inf corrections.

IDEA: What if we define INTERMEDIATE quantities that satisfy a simpler recurrence?

For F_{c,m}: F_m = (I-A(q^m))^{-1} * F_{m-1} is manifest from the matrix inverse.
P_m = (q^3;q^3)_m * F_m is the product of adjugates divided by (q^3;q^3) factors.

For Q_n: Q_n = (q;q)_n * [z^n] ((zq;q)_inf * sum F_m z^m)

What if we EXPAND (zq;q)_inf = prod(1-zq^j) and use the product structure?

(zq;q)_inf * sum_m z^m F_m = prod_{j>=1} (1-zq^j) * sum_m z^m F_m

The coefficient of z^n in this product involves an inclusion-exclusion over 
subsets of {q, q^2, ..., q^n, ...}. The key observation is that only finitely 
many terms contribute (those with j-sum <= n).

Q_n / (q;q)_n = [z^n] prod_{j>=1}(1-zq^j) * sum_m F_m z^m
              = sum_{S subset of Z_+, |S| <= n} (-1)^|S| q^{sum S} * F_{n-|S|}

where the sum is over all finite subsets S of positive integers with |S| <= n
and sum(S) counted with appropriate multiplicity...

Actually, the exact formula is:
[z^n] prod(1-zq^j) * sum F_m z^m = sum_{m=0}^n e_{n-m}(q, q^2, ...) * (-1)^{n-m} * F_m

where e_k is the k-th elementary symmetric function of {q, q^2, q^3, ...}.

Hmm, this doesn't simplify. Let me try yet another angle.

ANGLE: The (zq;q)_inf sieve as a NONINTERSECTING LATTICE PATH constraint.

In the GV/Lindstrom theory, (zq;q)_n appears as a weight for nonintersecting paths.
If we can interpret Q_n as counting nonintersecting lattice paths on the 
profile graph, the positivity would be manifest.

Let me explore this computationally for d=4.
"""
from sage.all import *
from itertools import combinations as combs

# First: test the inductive hypothesis for d=5 and d=7.

R = PowerSeriesRing(QQ, 'q', default_prec=80)
q = R.gen()

def build_system(d, PREC=80):
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
    n_max = 4
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
    
    Qn_all = {}
    for c in compositions:
        Qn_all[(c, 0)] = R(1)
    
    for n in range(1, n_max + 1):
        for ci, c in enumerate(compositions):
            Qn = R(0)
            for j in range(n+1):
                sign = (-1)**(n-j)
                tri = (n-j)*(n-j+1)//2
                coeff = sign * q**tri / qpoch(n-j)
                Qn += coeff * g_all[j][ci]
            Qn *= qpoch(n)
            Qn_all[(c, n)] = Qn
    
    return Qn_all, compositions, comp_idx

# Test for d=5
print("Testing positivity for d=5:")
Q5, comp5, ci5 = build_system(5, PREC=80)
for n in range(1, 5):
    all_nonneg = True
    for c in comp5:
        Qn = Q5[(c, n)].truncate(70)
        coeffs = [Qn[i] for i in range(70)]
        max_d = max((i for i in range(70) if coeffs[i] != 0), default=0)
        if max_d > 0 and any(coeffs[i] < 0 for i in range(max_d+1)):
            all_nonneg = False
            print(f"  NEGATIVE: Q_{n}({c})")
            neg_terms = [(i, coeffs[i]) for i in range(max_d+1) if coeffs[i] < 0]
            print(f"    neg at: {neg_terms[:5]}")
    if all_nonneg:
        # Check Q_n(1) values
        evals = set()
        for c in comp5:
            Qn = Q5[(c, n)].truncate(70)
            coeffs = [Qn[i] for i in range(70)]
            evals.add(sum(coeffs))
        print(f"  n={n}: ALL NONNEG, Q_n(1) values = {evals}")

# Test for d=7
print("\nTesting positivity for d=7:")
Q7, comp7, ci7 = build_system(7, PREC=80)
for n in range(1, 4):
    all_nonneg = True
    for c in comp7:
        Qn = Q7[(c, n)].truncate(70)
        coeffs = [Qn[i] for i in range(70)]
        max_d = max((i for i in range(70) if coeffs[i] != 0), default=0)
        if max_d > 0 and any(coeffs[i] < 0 for i in range(max_d+1)):
            all_nonneg = False
            print(f"  NEGATIVE: Q_{n}({c})")
    if all_nonneg:
        evals = set()
        for c in comp7:
            Qn = Q7[(c, n)].truncate(70)
            coeffs = [Qn[i] for i in range(70)]
            evals.add(sum(coeffs))
        print(f"  n={n}: ALL NONNEG, Q_n(1) values = {evals}")

# Test for d=3 (SHOULD have negatives)
print("\nTesting for d=3 (should be negative):")
Q3, comp3, ci3 = build_system(3, PREC=50)
for n in range(1, 4):
    neg_profiles = []
    for c in comp3:
        Qn = Q3[(c, n)].truncate(40)
        coeffs = [Qn[i] for i in range(40)]
        max_d = max((i for i in range(40) if coeffs[i] != 0), default=0)
        if max_d > 0 and any(coeffs[i] < 0 for i in range(max_d+1)):
            neg_profiles.append(c)
    if neg_profiles:
        print(f"  n={n}: NEGATIVES at {len(neg_profiles)} profiles")
    else:
        print(f"  n={n}: all nonneg (unexpected?)")

# Now: THE KEY STRUCTURAL QUESTION.
# For d not equiv 0 mod 3, what makes the recurrence produce nonneg results?
# For d equiv 0 mod 3, what causes negatives?
# 
# HYPOTHESIS: When d equiv 0 mod 3, gcd(d,3) = 3, so l = 3 and 
# Q_n uses (q^3;q^3)_n instead of (q;q)_n. Wait -- no!
# The definition says Q_n = (q^l;q^l)_n * [z^n] H where l = gcd(d,3).
# For d not equiv 0 mod 3: l = 1, Q_n = (q;q)_n * [z^n] H.
# For d equiv 0 mod 3: l = 3, Q_n = (q^3;q^3)_n * [z^n] H.
# 
# So the d=3 computation above uses l=3. Let me check if my code handles this!

print("\n\nCRITICAL CHECK: Does the code use the correct l?")
print("For d=3: l = gcd(3,3) = 3. Q_n should use (q^3;q^3)_n, not (q;q)_n!")
print("But the code uses (q;q)_n. This is WRONG for d=3!")
print("However, for d=4,5,7: l=1, so (q;q)_n is correct.")
print()
print("Let me recompute d=3 with the CORRECT l=3:")

def compute_Qn_correct(d, c_target, n_max, PREC=80):
    """Compute Q_n with the correct ell = gcd(d, 3)."""
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
    
    def qpoch_ell(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**(ell*i))
        return result
    
    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result
    
    idx = comp_idx[c_target]
    Q_vals = []
    for n in range(1, n_max + 1):
        # Q_n = (q^ell;q^ell)_n * [z^n] ((zq;q)_inf * sum g_m z^m)
        # [z^n] = sum_{m=0}^n g_m * (-1)^{n-m} q^{binom(n-m+1,2)} / (q;q)_{n-m}
        Qn = R(0)
        for j in range(n+1):
            sign = (-1)**(n-j)
            tri = (n-j)*(n-j+1)//2
            coeff = sign * q**tri / qpoch(n-j)
            Qn += coeff * g_all[j][idx]
        Qn *= qpoch_ell(n)
        Q_vals.append(Qn)
    
    return Q_vals

# Recompute d=3 with correct ell=3
print("d=3, c=(1,1,1) with ell=3:")
Qs3 = compute_Qn_correct(3, (1,1,1), 3, PREC=50)
for i, Q in enumerate(Qs3):
    n = i + 1
    coeffs = [Q[j] for j in range(50)]
    max_d = max((j for j in range(50) if coeffs[j] != 0), default=0)
    poly = coeffs[:max_d+1]
    is_nonneg = all(c >= 0 for c in poly)
    print(f"  Q_{n}(1) = {sum(poly)}, nonneg = {is_nonneg}")
    if not is_nonneg:
        neg_terms = [(j, poly[j]) for j in range(len(poly)) if poly[j] < 0]
        print(f"    neg at: {neg_terms[:5]}")
    if n <= 2 and max_d <= 30:
        print(f"    Q_{n} = {poly}")

# Check: with ell=3, does (q^3;q^3)_n differ from (q;q)_n?
# (q^3;q^3)_1 = (1-q^3) vs (q;q)_1 = (1-q).
# So (q^3;q^3)_n = (1-q^3)(1-q^6)...(1-q^{3n}).
# While (q;q)_n = (1-q)(1-q^2)...(1-q^n).
# Different! So the Q_n computation changes significantly.

print("\n\nFor comparison, d=3 with WRONG ell=1:")
Qs3_wrong = compute_Qn_correct.__wrapped__(3, (1,1,1), 3, PREC=50) if hasattr(compute_Qn_correct, '__wrapped__') else None

# Actually Agent B's code already uses ell=1 for all d.
# The conjecture says d not equiv 0 mod 3. So for d=3 (equiv 0 mod 3),
# the conjecture does NOT claim positivity.
# The question is whether with ell=3, Q_n is still negative.

