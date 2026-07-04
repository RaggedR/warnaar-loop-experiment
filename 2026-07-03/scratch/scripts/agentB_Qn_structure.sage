"""
Agent B: Structure of Q_n in terms of the EMD path formula.

We have: P_n(c) = (q^3;q^3)_n * F_{c,n} = sum_{paths} q^{weighted EMD}

And: Q_n(c) = sum_{j=0}^n (-1)^{n-j} q^{T_{n-j}} [n,j]_q * F_{c,j}

Let me look at Q_n from a different angle.

F_c(z,q) = e_c^T * (sum_m z^m * prod_{k=1}^m (I - A(q^k))^{-1}) * v_0

Now (I - A(q^k))^{-1} = adj(I-A(q^k)) / (1 - q^{3k})

So F_c(z,q) = e_c^T * sum_m z^m * prod_{k=1}^m adj(q^k) / (1-q^{3k}) * v_0

And (zq;q)_inf * F_c(z,q) involves multiplying by prod_{j>=1}(1-zq^j).

KEY OBSERVATION: Since the adjugate has monomial entries q^{k*EMD(c,c')},
the inverse (I-A(q^k))^{-1} = M_k / (1-q^{3k}) where M_k[c,c'] = q^{k*EMD(c,c')}.

Consider the formal "transfer matrix" product:
T(z,q) = sum_m z^m * prod_{k=1}^m M_k / (1-q^{3k})

F_c(z,q) = e_c^T * T(z,q) * v_0

(zq;q)_inf * F_c(z,q) = (zq;q)_inf * e_c^T * T(z,q) * v_0

[z^n] of this times (q;q)_n gives Q_n.

Now, the specific structure of M_k (entries are q^{k*D(c,c')}) means:
prod_{k=1}^m M_k = M^{(m)} where M^{(m)}[c,c'] = sum_{paths c=c_m -> c_{m-1} -> ... -> c_0}
                     q^{m*D(c_m,c_{m-1}) + (m-1)*D(c_{m-1},c_{m-2}) + ... + 1*D(c_1,c_0)}

The total exponent for a path is: sum_{k=1}^m k * D(c_k, c_{k-1}).

Now, the key identity for the EMD:
EMD(c,c') on Z/3Z decomposition:

For any path c = c_m -> c_{m-1} -> ... -> c_0 of compositions, 
sum_{k=1}^m k * EMD(c_k, c_{k-1}) >= sum_{k=1}^m k * 0 = 0

But can we say more? The minimum over paths for FIXED endpoints?

Actually, let me try a completely different approach to Q_n.

APPROACH: Direct Q_n formula via the MATRIX (I-A(x)).

Since det(I - zA(q)) involves the characteristic polynomial of A(q),
and the eigenvalues of A(q) are related to the cube roots of unity...

Wait, I had det(I - A(x)) = 1-x^3 where x is a single formal variable.
But now I want det(I - z*M) where M is a matrix with entries that are power series in q.
These are different!

Let me think about this differently.

The generating function (zq;q)_inf * F_c(z,q) = sum_n z^n * Q_n/(q;q)_n.
Since Q_n is a polynomial, this is a well-defined power series in z.

Now, F_c(z,q) satisfies the CW functional equation:
F_c(z,q) = sum_J (-1)^{|J|-1} F_{c(J)}(zq^{|J|},q) / (1-zq^{|J|})

Multiplying both sides by (zq;q)_inf:
(zq;q)_inf * F_c(z,q) = sum_J (-1)^{|J|-1} (zq;q)_inf * F_{c(J)}(zq^{|J|},q) / (1-zq^{|J|})

Now: (zq;q)_inf = (1-zq) * (zq^2;q)_inf
And (zq;q)_inf / (1-zq) = (zq^2;q)_inf

More generally: (zq;q)_inf / (1-zq^j) = (zq;q)_inf * sum_{k>=0} z^k q^{jk} / (but diverges?)

Actually: (zq;q)_inf / (1-zq) = (zq^2;q)_inf (just removes the first factor)

And F_{c(J)}(zq^{|J|}, q) uses z -> zq^{|J|}, so (zq^{|J|}*q;q)_inf = (zq^{|J|+1};q)_inf.

Let H_c(z,q) = (zq;q)_inf * F_c(z,q).

Then: H_c(z,q) = sum_J (-1)^{|J|-1} (zq;q)_inf * F_{c(J)}(zq^{|J|},q) / (1-zq^{|J|})

For |J|=1: (zq;q)_inf / (1-zq) = (zq^2;q)_inf
  And F_{c(J)}(zq,q): H_{c(J)}(zq,q) = (zq^2;q)_inf * F_{c(J)}(zq,q)
  So: (zq;q)_inf * F_{c(J)}(zq,q) / (1-zq) = (zq^2;q)_inf * F_{c(J)}(zq,q) = H_{c(J)}(zq,q)

For |J|=2: (zq;q)_inf / (1-zq^2) = (zq;q)_inf / (1-zq^2) 
  Hmm, (1-zq^2) is already a factor of (zq;q)_inf = (1-zq)(1-zq^2)(1-zq^3)...
  So (zq;q)_inf / (1-zq^2) = (1-zq) * (zq^3;q)_inf
  And F_{c(J)}(zq^2,q): the (zq^2*q;q)_inf = (zq^3;q)_inf factor.
  H_{c(J)}(zq^2,q) = (zq^3;q)_inf * F_{c(J)}(zq^2,q)
  So: (zq;q)_inf * F_{c(J)}(zq^2,q) / (1-zq^2) = (1-zq) * H_{c(J)}(zq^2,q)

For |J|=3: (zq;q)_inf / (1-zq^3) = (1-zq)(1-zq^2) * (zq^4;q)_inf
  And F_{c(J)}(zq^3,q) with c(J) = c.
  H_c(zq^3,q) = (zq^4;q)_inf * F_c(zq^3,q)
  So: (zq;q)_inf * F_c(zq^3,q) / (1-zq^3) = (1-zq)(1-zq^2) * H_c(zq^3,q)

So the functional equation for H_c becomes:
H_c(z) = sum_{|J|=1} H_{c(J)}(zq) 
        - sum_{|J|=2} (1-zq) H_{c(J)}(zq^2)
        + sum_{|J|=3} (1-zq)(1-zq^2) H_c(zq^3)

This is a functional equation for H in terms of H at shifted z values!

Since H_c(z,q) = sum_n z^n Q_n(c) / (q;q)_n, we can extract coefficient of z^n:

[z^n] H_c(z) = Q_n(c) / (q;q)_n

[z^n] H_{c(J)}(zq) = q^n * Q_n(c(J)) / (q;q)_n

[z^n] (1-zq) H_{c(J)}(zq^2) = q^{2n} Q_n(c(J))/(q;q)_n - q^{2(n-1)+1} Q_{n-1}(c(J))/(q;q)_{n-1}
  = q^{2n} Q_n(c(J))/(q;q)_n - q^{2n-1} Q_{n-1}(c(J))/(q;q)_{n-1}

[z^n] (1-zq)(1-zq^2) H_c(zq^3) = more complex, involves Q_n, Q_{n-1}, Q_{n-2}

This gives a RECURRENCE for Q_n in terms of Q_m at shifted profiles!

Let me compute this recurrence for specific cases.
"""
from sage.all import *

# Let me compute the recurrence coefficients and check if it preserves positivity.
PREC = 60
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

# For d=4, c=(2,1,1), the shifted profiles are:
# |J|=1 shifts: 
#   J={0}: c(J) = (1,2,1)
#   J={1}: c(J) = (2,0,2)  
#   J={2}: c(J) = (2,2,0)
# |J|=2 shifts:
#   J={0,1}: c(J) = (1,1,2) 
#   J={0,2}: c(J) = (3,1,0)
#   J={1,2}: c(J) = (3,0,1)
# |J|=3 shift:
#   J={0,1,2}: c(J) = (2,1,1)

# The functional equation for H_{(2,1,1)}(z):
# H_{211} = H_{121}(zq) + H_{202}(zq) + H_{220}(zq) 
#          - (1-zq)[H_{112}(zq^2) + H_{310}(zq^2) + H_{301}(zq^2)]
#          + (1-zq)(1-zq^2) H_{211}(zq^3)

# Extracting [z^n]:
# Q_n(211)/(q;q)_n = q^n [Q_n(121) + Q_n(202) + Q_n(220)] / (q;q)_n
#   - q^{2n} [Q_n(112) + Q_n(310) + Q_n(301)] / (q;q)_n
#   + q^{2n-1} [Q_{n-1}(112) + Q_{n-1}(310) + Q_{n-1}(301)] / (q;q)_{n-1}
#   + q^{3n} Q_n(211) / (q;q)_n
#   - q^{3n-1} Q_{n-1}(211) / (q;q)_{n-1} [from -(1-zq) term]
#   - q^{3n-2} Q_{n-1}(211) / (q;q)_{n-1} [from -(1-zq^2) term] ... 
#   wait, this is getting complicated. Let me be more careful.

# [z^n](1-zq)(1-zq^2) H(zq^3) 
# = [z^n] H(zq^3) - q*[z^{n-1}] H(zq^3) - q^2*[z^{n-1}] H(zq^3) + q^3*[z^{n-2}] H(zq^3)
# Wait: (1-zq)(1-zq^2) = 1 - zq - zq^2 + z^2 q^3
# So [z^n](1-zq)(1-zq^2) H(zq^3) 
# = q^{3n} Q_n/(q)_n - q^{3(n-1)+1} Q_{n-1}/(q)_{n-1} - q^{3(n-1)+2} Q_{n-1}/(q)_{n-1} + q^{3(n-2)+3} Q_{n-2}/(q)_{n-2}
# = q^{3n} Q_n/(q)_n - (q^{3n-2} + q^{3n-1}) Q_{n-1}/(q)_{n-1} + q^{3n-3} Q_{n-2}/(q)_{n-2}

# Simplifying the full equation and multiplying by (q;q)_n:
# Q_n(211) = q^n [Q_n(121) + Q_n(202) + Q_n(220)]
#           - q^{2n} [Q_n(112) + Q_n(310) + Q_n(301)]
#           + q^{2n-1} (q;q)_n/(q;q)_{n-1} * [Q_{n-1}(112) + Q_{n-1}(310) + Q_{n-1}(301)]
#           + q^{3n} Q_n(211)
#           - (q^{3n-2}+q^{3n-1}) (q;q)_n/(q;q)_{n-1} * Q_{n-1}(211)
#           + q^{3n-3} (q;q)_n/(q;q)_{n-2} * Q_{n-2}(211)

# Note: (q;q)_n/(q;q)_{n-1} = 1-q^n, and (q;q)_n/(q;q)_{n-2} = (1-q^n)(1-q^{n-1}).

# Rearranging:
# Q_n(211)(1 - q^{3n}) = q^n sum_1 - q^{2n} sum_2 + q^{2n-1}(1-q^n) sum_2^{prev}
#                        - (q^{3n-2}+q^{3n-1})(1-q^n) Q_{n-1}(211) 
#                        + q^{3n-3}(1-q^n)(1-q^{n-1}) Q_{n-2}(211)

# Since 1-q^{3n} = (1-q^n)(1+q^n+q^{2n}), dividing by (1-q^{3n}):
# Q_n(211) = [q^n sum_1 - q^{2n} sum_2 + ...]  / (1-q^{3n})

# This recurrence involves Q_n for MULTIPLE profiles! It's a SYSTEM of recurrences.
# But all the coefficients might preserve positivity if the dominant terms are positive.

# Let me verify this numerically. First compute Q_n for ALL profiles at d=4.
from itertools import combinations

def compute_all_Qn(d, n_max, PREC=80):
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
        for size in range(1, len(I_c) + 1):
            for J in combinations(sorted(I_c), size):
                J_set = set(J)
                cJ = shift_profile(c, J_set)
                if min(cJ) < 0:
                    continue
                sign = (-1)**(size - 1)
                if cJ in comp_idx:
                    A_poly[ic, comp_idx[cJ]] += sign * x_var**size
    
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
    
    # Compute all F_{c,m}
    v = vector(R, [R(1)] * N)
    F_all = {0: list(v)}
    
    for m in range(1, n_max + 1):
        Am = eval_A(q**m)
        Bm = I_mat - Am
        v = Bm.inverse() * v
        F_all[m] = list(v)
    
    # Compute g_m and Q_n for all profiles
    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result
    
    Q_all = {}
    for ic, c in enumerate(compositions):
        Qn_list = []
        g_vals = [R(1)]
        for m in range(1, n_max + 1):
            g_vals.append(F_all[m][ic] - F_all[m-1][ic])
        
        for n in range(1, n_max + 1):
            Qn = R(0)
            for j in range(n + 1):
                sign = (-1)**(n-j)
                tri = (n-j)*(n-j+1)//2
                coeff = sign * q**tri / qpoch(n-j)
                Qn += coeff * g_vals[j]
            Qn *= qpoch(n)
            Qn_list.append(Qn)
        Q_all[c] = Qn_list
    
    return Q_all, compositions

# Compute for d=4
print("Computing Q_n for all profiles at d=4, n=1,2,3...")
Q_all, comps = compute_all_Qn(4, 3, PREC=60)

print("\nQ_1 for all profiles:")
for c in comps:
    Q1 = Q_all[c][0]
    coeffs = list(Q1)[:20]
    nonneg = all(co >= 0 for co in coeffs)
    ev = sum(coeffs)
    print(f"  c={c}: Q_1(1)={ev}, nonneg={nonneg}, poly={Q1.add_bigoh(15)}")

print("\nQ_2 for all profiles:")
for c in comps:
    Q2 = Q_all[c][1]
    coeffs = list(Q2)[:30]
    nonneg = all(co >= 0 for co in coeffs)
    ev = sum(coeffs)
    print(f"  c={c}: Q_2(1)={ev}, nonneg={nonneg}")

# Check: is there a SYMMETRY between Q_n values for different profiles?
print("\n\nSymmetry check: Q_1 values under cyclic rotation:")
for c in comps:
    c_rot1 = (c[1], c[2], c[0])
    c_rot2 = (c[2], c[0], c[1])
    Q_c = Q_all[c][0]
    Q_r1 = Q_all[c_rot1][0]
    Q_r2 = Q_all[c_rot2][0]
    if Q_c != Q_r1 or Q_c != Q_r2:
        print(f"  c={c}, rot1={c_rot1}, rot2={c_rot2}: Q differs!")
    
# Check Q_1 under reversal
print("\nReversal check: Q_1(c_0,c_1,c_2) vs Q_1(c_2,c_1,c_0):")
for c in comps:
    c_rev = (c[2], c[1], c[0])
    Q_c = Q_all[c][0]
    Q_r = Q_all[c_rev][0]
    if Q_c != Q_r:
        print(f"  c={c}: Q_1 = {Q_c.add_bigoh(10)}")
        print(f"  c_rev={c_rev}: Q_1 = {Q_r.add_bigoh(10)}")
        break

