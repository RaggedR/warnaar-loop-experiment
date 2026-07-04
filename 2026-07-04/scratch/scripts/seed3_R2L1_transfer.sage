"""
Seed 3, R2L1: Compute Q_n using transfer matrix approach.
The transfer matrix A has rows/columns indexed by compositions c' with same sum d.
Entry A[c,c'] = x^{shift} based on the CW system.

For r=3, the transfer matrix acts on profiles c = (c_0, c_1, c_2) with c_0+c_1+c_2 = d.
"""

R.<q> = PowerSeriesRing(ZZ, default_prec=200)

def profiles(d, r=3):
    """All compositions of d into r parts (nonneg)."""
    if r == 1:
        return [(d,)]
    result = []
    for i in range(d+1):
        for rest in profiles(d-i, r-1):
            result.append((i,) + rest)
    return result

def emd_cyclic(c, cp):
    """
    Earth Mover's Distance on Z/3Z with clockwise metric.
    adj(I-A(x))[c,c'] = x^{EMD(c,c')}.
    From Round 1: EMD(c,c') = sum of clockwise transport costs.
    
    Actually, let me compute this from the Bellman equation / directly.
    For r=3, the EMD is the min-cost transport to move mass distribution c to c'.
    Clockwise metric: cost to move 1 unit from position i to position j is (j-i) mod 3.
    But the actual formula from Agent B was:
    EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
    
    Let me verify this matches for a few cases.
    """
    # Simple transport calculation for r=3
    # Positions: 0, 1, 2 on cycle
    # c[i] units at position i, need to move to c'[i] units
    # Cost to move 1 unit from i to j is (j-i) mod 3
    # Minimize total cost
    
    # For r=3 this is simple: excess at position i = c[i] - c'[i]
    # We need to route excess to deficit.
    excess = [c[i] - cp[i] for i in range(3)]
    # excess sums to 0
    
    # The optimal transport on Z/3Z:
    # Flow clockwise: f_{i->i+1} for i=0,1,2 (mod 3)
    # Constraints: excess[i] = f_{i-1->i} - f_{i->i+1} (net flow into i)
    # Wait, that's wrong. Let me think again.
    # f_{i->i+1} is flow from i to i+1 (clockwise)
    # Net outflow from i = f_{i->i+1} - f_{i-1->i} = excess[i]
    # (we want to remove excess from i)
    # So f_{0->1} - f_{2->0} = excess[0]
    #    f_{1->2} - f_{0->1} = excess[1]  
    #    f_{2->0} - f_{1->2} = excess[2]
    # These are consistent (sum to 0).
    # Let f_{2->0} = t (free parameter). Then:
    # f_{0->1} = excess[0] + t
    # f_{1->2} = excess[0] + excess[1] + t
    # f_{2->0} = t
    # Total cost (all clockwise = cost 1 each):
    # = f_{0->1} + f_{1->2} + f_{2->0} = 2*excess[0] + excess[1] + 3t
    # But flows must be nonneg: t >= 0, t >= -excess[0], t >= -(excess[0]+excess[1])
    # So t >= max(0, -excess[0], -excess[0]-excess[1])
    # Minimize: 2*excess[0] + excess[1] + 3*max(0, -excess[0], -excess[0]-excess[1])
    
    e0, e1, e2 = excess
    t_min = max(0, -e0, -e0-e1)
    cost = 2*e0 + e1 + 3*t_min
    return cost

def transfer_matrix(d):
    """
    Build the transfer matrix A(x) for cylindric partitions of profile d.
    A[c,c'] = x if adding a layer of max-value transforms profile c' to c.
    
    Actually, from the CW system, the transfer matrix for F_{c,n} = sum_{c'} A[c,c'] F_{c',n-1}
    comes from the relationship between bounded CPs with max <= n and max <= n-1.
    
    From Round 1: F_{c,n} = sum_{c'} A_{c,c'}(q^n) F_{c',n-1}
    where A_{c,c'}(x) captures the contribution of a new maximal layer.
    
    The adjugate theorem says adj(I-A(x))[c,c'] = x^{EMD(c,c')}.
    And det(I-A(x)) = -(x^3-1).
    
    So (I-A(x))^{-1} = adj(I-A(x)) / det(I-A(x)) = -adj(I-A(x)) / (x^3-1)
    = adj(I-A(x)) / (1-x^3).
    
    But I need A itself. Let me compute it from the CW functional equation.
    
    The CW shift c(J) for J subset of I_c = {i : c_i > 0}:
    c_i(J) = c_i - 1 if i in J and (i-1) not in J
           = c_i + 1 if i not in J and (i-1) in J  
           = c_i otherwise
    (indices mod 3)
    
    The recurrence is:
    F_c(y,q) = sum_{J nonempty, J subset I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|},q) / (1-yq^{|J|})
    
    For bounded CPs: F_{c,n} = [y is integrated out somehow]
    
    Actually let me just use the approach from Agent B. The matrix product formula is:
    vec(F_{c,n}) = prod_{k=1}^n M(q^k) * vec(1)
    where M(x) = (I - A(x))^{-1} = adj(I-A(x))/(1-x^3)
    
    Wait, that's not right. The actual formula is:
    F_{c,n} is computed via the transfer matrix acting level by level.
    
    Let me just directly compute using the CW functional equation for bounded case.
    """
    pass

# Instead, let me compute Q_n using SageMath's power series for specific profiles.
# Use the definition: Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))

# First compute F_c(z,q) truncated.
# F_c(z,q) = sum_m g_m(q) z^m where g_m counts CPs with max exactly m.
# g_m(q) = F_{c,m}(q) - F_{c,m-1}(q)

# For F_{c,m}(q), use the Borodin product formula for the UNBOUNDED case,
# or compute directly via the Gessel-Krattenthaler determinant.

# Actually, the most reliable approach from Round 1:
# Use the transfer matrix. F_{c,n} = sum over paths in profile space.

# Let me build the transfer matrix from the CW functional equation.
# The key insight: F_c(y,q) satisfies a linear recurrence.
# For bounded CPs: define P_n(c) = (q^3;q^3)_n F_{c,n}(q).
# From Agent B: P_n(c) = sum over paths (c^(0),...,c^(n)=c) of prod q^{k*EMD(c^(k),c^(k-1))}.

# So F_{c,n}(q) = P_n(c) / (q^3;q^3)_n
# = (1/(q^3;q^3)_n) * sum over length-n paths ending at c of prod q^{k*EMD(c^(k),c^(k-1))}

# This means F_{c,n} = sum_{c'} M_n[c,c'] where M_n is the path weight matrix.
# M_1[c,c'] = q^{EMD(c,c')} / (1-q^3)
# More precisely: P_n = M^n where M[c,c'](k) depends on k... no, the weights are
# q^{k*EMD} at step k, so it's not a simple matrix power.

# Actually: P_n(c) = sum_{c_{n-1}} q^{n*EMD(c, c_{n-1})} * P_{n-1}(c_{n-1})
# So if we define M_k[c,c'] = q^{k*EMD(c,c')}, then P_n = M_n * P_{n-1} (matrix-vector product).
# And P_0(c) = 1 for all c.

# Let's compute this way.

def compute_Pn(d, n_max, prec=200):
    """Compute P_n(c) = (q^3;q^3)_n * F_{c,n}(q) for all profiles c, n <= n_max."""
    profs = profiles(d)
    N = len(profs)
    prof_idx = {p: i for i, p in enumerate(profs)}
    
    # P_0(c) = 1 for all c (since F_{c,0} = 1 and (q^3;q^3)_0 = 1)
    P = {0: {c: R(1) for c in profs}}
    
    for n in range(1, n_max + 1):
        P[n] = {}
        for c in profs:
            val = R(0)
            for cp in profs:
                e = emd_cyclic(cp, c)  # EMD from cp to c  
                val += q^(n * e) * P[n-1][cp]
            P[n][c] = val
        
    return P

def compute_Qn(d, n_max, prec=200):
    """Compute Q_n(c) for all profiles and n <= n_max."""
    profs = profiles(d)
    ell = gcd(d, 3)
    
    P = compute_Pn(d, n_max, prec)
    
    # F_{c,n} = P_n(c) / (q^3;q^3)_n
    # Wait, that's only right if ell=3 or the (q^3;q^3)_n comes from the adjugate.
    # Let me re-derive.
    # From Agent B: P_n(c) = (q^3;q^3)_n * F_{c,n}(q)
    # This is specific to r=3 (rank 3).
    # So F_{c,n}(q) = P_n(c) / (q^3;q^3)_n.
    
    # g_m(q) = F_{c,m} - F_{c,m-1}
    # h_m(q) = (q;q)_m * g_m(q)
    
    # Q_n = D_n^n where D_0^m = h_m, D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}
    # BUT we need to include the ell factor:
    # Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
    
    # Let's compute it step by step.
    # First get F_{c,m} for m = 0,...,n_max
    
    q3n = {n: prod(1 - q^(3*i) for i in range(1, n+1)) if n > 0 else R(1) for n in range(n_max + 1)}
    
    results = {}
    for c in profs:
        F = {}
        for m in range(n_max + 1):
            if q3n[m] == 0:
                F[m] = R(0)  # shouldn't happen with enough precision
            else:
                # F_{c,m} = P_m(c) / (q^3;q^3)_m
                # In power series ring, we need to be careful about division
                F[m] = P[m][c] / q3n[m]
        
        # g_m = F_m - F_{m-1}
        g = {0: F[0]}
        for m in range(1, n_max + 1):
            g[m] = F[m] - F[m-1]
        
        # h_m = (q;q)_m * g_m
        qn = {m: prod(1 - q^i for i in range(1, m+1)) if m > 0 else R(1) for m in range(n_max + 1)}
        h = {m: qn[m] * g[m] for m in range(n_max + 1)}
        
        # D_k^m
        for n in range(1, n_max + 1):
            D = {}
            for m in range(n + 1):
                D[(0, m)] = h[m]
            for k in range(1, n + 1):
                for m in range(k, n + 1):
                    D[(k, m)] = D[(k-1, m)] - q^k * D.get((k-1, m-1), R(0))
            
            # Q_n^raw = D_n^n (this is (q;q)_n * [z^n](...))
            # But conjecture uses (q^ell;q^ell)_n instead of (q;q)_n
            # Hmm, let me re-examine.
            # 
            # The iterated q-difference gives:
            # D_n^n = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q h_{j}
            # = (q;q)_n * sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} g_j
            # = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
            #
            # So D_n^n uses (q;q)_n. But the conjecture uses (q^ell;q^ell)_n.
            # When ell=1, these are the same. When ell=3:
            # Q_n^{conj} = (q^3;q^3)_n * [z^n](...) = D_n^n * (q^3;q^3)_n / (q;q)_n
            #
            # Hmm, but (q^3;q^3)_n / (q;q)_n is NOT a polynomial.
            # So the definition must be different. Let me re-read.
            #
            # From the conjecture: Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n]((zq)_inf * GK_c(z,q))
            # Note: (zq)_inf means (zq;q)_inf = prod_{i>=0}(1 - zq^{i+1})
            # Wait, is it (zq)_inf = prod_{i>=0}(1-zq^i) starting at i=0? 
            # No, standard notation: (a;q)_inf = prod_{i>=0}(1-aq^i).
            # So (zq;q)_inf = prod_{i>=0}(1 - zq^{i+1}).
            # Hmm, that's what I had. So [z^n](...) * (q^ell;q^ell)_n should be polynomial.
            
            # For ell=1: Q_n = D_n^n (confirmed by Round 1).
            # For ell=3: Q_n = (q^3;q^3)_n / (q;q)_n * D_n^n
            # But this requires divisibility. Let me just compute directly.
            
            if ell == 1:
                Q_val = D[(n, n)]
            else:
                # Q_n = (q^ell;q^ell)_n * [z^n](...)
                # [z^n](...) = D_n^n / (q;q)_n ... but D_n^n already has (q;q)_n baked in.
                # Actually no: D_n^n = sum (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q h_j
                # And h_j = (q;q)_j g_j. So the (q;q)_n is NOT directly factored out.
                # D_n^n = (q;q)_n * [z^n]((zq;q)_inf * sum g_m z^m)
                # So [z^n](...) = D_n^n / (q;q)_n
                # Q_n = (q^ell;q^ell)_n * D_n^n / (q;q)_n
                qn_val = qn[n]
                qelln = prod(1 - q^(ell*i) for i in range(1, n+1)) if n > 0 else R(1)
                Q_val = qelln * D[(n, n)] / qn_val
            
            # Check if Q_val is a polynomial (finite terms, all nonneg)
            coeffs = Q_val.list()
            is_nonneg = all(c >= 0 for c in coeffs)
            eval_1 = sum(coeffs)
            
            results[(c, n)] = (Q_val, is_nonneg, eval_1)
            
    return results

# Test for d=2
print("=" * 60)
print("d=2, ell=1")
print("=" * 60)
res2 = compute_Qn(2, 3, prec=200)
for (c, n), (Q, nn, ev) in sorted(res2.items()):
    coeffs = Q.list()[:20]
    print(f"  c={c}, n={n}: nonneg={nn}, Q(1)={ev}, coeffs={coeffs}")

# Test for d=4
print("\n" + "=" * 60)
print("d=4, ell=1")
print("=" * 60)
res4 = compute_Qn(4, 3, prec=200)
for (c, n), (Q, nn, ev) in sorted(res4.items()):
    coeffs = Q.list()[:20]
    print(f"  c={c}, n={n}: nonneg={nn}, Q(1)={ev}, coeffs={coeffs}")

# Test for d=5
print("\n" + "=" * 60)  
print("d=5, ell=1")
print("=" * 60)
res5 = compute_Qn(5, 2, prec=200)
for (c, n), (Q, nn, ev) in sorted(res5.items()):
    coeffs = Q.list()[:15]
    print(f"  c={c}, n={n}: nonneg={nn}, Q(1)={ev}, coeffs={coeffs}")

# Test for d=3 (ell=3)
print("\n" + "=" * 60)
print("d=3, ell=3")  
print("=" * 60)
res3 = compute_Qn(3, 2, prec=200)
for (c, n), (Q, nn, ev) in sorted(res3.items()):
    coeffs = Q.list()[:15]
    print(f"  c={c}, n={n}: nonneg={nn}, Q(1)={ev}, coeffs={coeffs}")
