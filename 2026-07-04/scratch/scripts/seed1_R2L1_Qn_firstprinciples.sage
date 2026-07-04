# Compute Q_n from FIRST PRINCIPLES using the definition
# Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
# where F_c(z,q) = sum_{Lambda in C_c} q^{|Lambda|} z^{max(Lambda)}

# For r=3 (k=3 rows), profile c, F_c(z,q) = sum_m g_m z^m 
# where g_m = F_{c,m} - F_{c,m-1} with F_{c,-1} = 0

# We compute F_{c,m} exactly as a power series.
# For d=2, c=(1,1,0): F_{c,1} = 1/(1-q)

# Q_{n,c} = (q^ell;q^ell)_n * [z^n](sum_{i>=1} (1-zq^i) * sum_m g_m z^m)
# = (q^ell;q^ell)_n * sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * g_j(q)

# Actually, let me think about this more carefully.
# (zq;q)_inf = prod_{i>=1}(1-zq^i)
# [z^n] of (zq;q)_inf * F_c(z,q) where F_c(z,q) = sum_m F_{c,m} z^m (not g_m!)
# = sum_{j=0}^n c_{n-j} * F_{c,j} where c_k = [z^k](zq;q)_inf

# The coefficients of (zq;q)_inf:
# (zq;q)_inf = sum_{k>=0} (-1)^k q^{k(k+1)/2} z^k / (q;q)_k

# So c_k = (-1)^k q^{k(k+1)/2} / (q;q)_k

# [z^n](...) = sum_{j=0}^n (-1)^{n-j} q^{(n-j)(n-j+1)/2} / (q;q)_{n-j} * F_{c,j}

# Now I need F_{c,m} as power series. For d=2, c=(1,1,0), I proved F_{c,1} = 1/(1-q).
# Let me compute F_{c,0} = 1 (only the empty CP has max 0).
# Wait: max = 0 means all parts are 0, so only (empty, empty, empty). Size=0. So F_{c,0} = 1.

# For F_{c,m}: CPs with parts in {0,1,...,m}. Each partition lambda^i has parts in {0,...,m}.
# For c=(1,1,0), interlacing:
# lam^0_j >= lam^1_{j+1} (c_1=1)
# lam^1_j >= lam^2_j (c_2=0)
# lam^2_j >= lam^0_{j+1} (c_0=1)

# For general m, represent each partition by the number of parts >= k for k=1,...,m.
# Let a^i_k = #{parts of lam^i >= k}. Then lam^i is determined by the sequence a^i_1 >= a^i_2 >= ... >= a^i_m >= 0.

# The interlacing conditions become:
# lam^0_j >= lam^1_{j+1} iff a^0_k >= a^1_k + 1 for all k where lam^1_{a^1_k} >= k
# Hmm, this is getting complicated. Let me just use the transfer matrix.

# TRANSFER MATRIX APPROACH:
# Let T_m(q) be the matrix indexed by "states" at level m.
# A CP with max <= m is built column by column.
# At each column j (from left), the state is (lam^0_j, lam^1_j, lam^2_j) in {0,...,m}^3
# but constrained by the interlacing with the NEXT column.

# Actually, for cylindric partitions, we should think of it differently.
# Let me use the "layer" representation: a CP with max <= m corresponds to
# a sequence of m "layers", where layer k (for k=1,...,m) records which
# positions have value >= k. Each layer is a cylindric partition of 0-1 type.

# A layer is a triple (S_0, S_1, S_2) where S_i is a "cut" partition with parts 0 or 1,
# determined by a_i = #{parts of lam^i >= k}.
# The interlacing for the SAME k gives: a^0_k >= a^1_k + c_1, etc.? No, that's wrong.

# Actually: lam^i_j >= k iff j <= a^i_k. The interlacing lam^0_j >= lam^1_{j+1} 
# at level k means: if lam^1_{j+1} >= k then lam^0_j >= k, i.e. j+1 <= a^1_k implies j <= a^0_k.
# So a^0_k >= a^1_k. Similarly a^1_k >= a^2_k and a^2_k >= a^0_k - 1 (from lam^2_j >= lam^0_{j+1}).

# So for EACH k, we need a^0_k >= a^1_k >= a^2_k and a^0_k <= a^2_k + 1.
# These are INDEPENDENT across different k (since k-levels are decoupled in the layer representation).

# Wait, but we also need the a^i_k to be weakly decreasing in k: a^i_1 >= a^i_2 >= ... >= a^i_m.
# So they're NOT fully independent.

# Let me think of this as m nested layers. Each layer k has state (a^0_k, a^1_k, a^2_k)
# with a^0_k >= a^1_k >= a^2_k, a^0_k <= a^2_k + 1, and a^i_k <= a^i_{k-1} for all i.

# The weight (size) of a CP is sum_{i,k} a^i_k.

# This gives a transfer matrix formulation: the state at level k is (a^0, a^1, a^2)
# satisfying a^0 >= a^1 >= a^2, a^0 <= a^2+1.
# These states are: (a, a, a) and (a+1, a+1, a) and (a+1, a, a) for a >= 0.
# But a can be any nonneg integer, so the state space is infinite.

# However, the constraint a^i_k <= a^i_{k-1} means we can think of this as a
# chain of weakly decreasing triples. The transfer matrix T from level k-1 to level k
# has T[(a0,a1,a2), (b0,b1,b2)] = 1 if b0<=a0, b1<=a1, b2<=a2 (and the interlacing).

# This is still infinite-dimensional. For a finite computation, note that F_{c,m}
# can be computed as a PRODUCT of contributions from each layer.

# Actually, the key insight for d=2, c=(1,1,0): at each layer, the valid states
# (a0, a1, a2) with a0 >= a1 >= a2, a0 <= a2+1 are:
# Type A: (a, a, a) for a >= 0. Weight = 3a.
# Type B: (a+1, a+1, a) for a >= 0. Weight = 3a+2.
# Type C: (a+1, a, a) for a >= 0. Weight = 3a+1.

# At layer k, the valid states (a0_k, a1_k, a2_k) must have each component
# <= the corresponding component at layer k-1.

# For F_{c,m}, we have m layers. GF = sum over all valid layer sequences of q^{total weight}.
# The weight of layer k with state (a0,a1,a2) is a0+a1+a2.

# For F_{c,1} (one layer): sum over valid states of q^{a0+a1+a2}
# = sum_{a>=0} q^{3a} + sum_{a>=0} q^{3a+2} + sum_{a>=0} q^{3a+1}
# = 1/(1-q^3) + q^2/(1-q^3) + q/(1-q^3) = (1+q+q^2)/(1-q^3) = 1/(1-q)
# Confirmed!

# For F_{c,2} (two layers): layer 1 state (a0,a1,a2), layer 2 state (b0,b1,b2)
# with b0<=a0, b1<=a1, b2<=a2.
# Weight = (a0+a1+a2) + (b0+b1+b2).

# Let's compute this by generating function methods.
# Since the three components interact through the type constraints but the
# dominance constraint b<=a is per-component, we can be clever.

# Actually, the states at each layer can be parameterized by just 2 values:
# the minimum value a2 (=a for all types) and the type (A, B, or C).
# But the per-component constraints mean we can't just track the type.

# Let me just compute numerically with a truncation.

from sage.all import *

R = PowerSeriesRing(QQ, 'q', default_prec=200)
q = R.gen()

def compute_Fcm_d2(m, c, prec=200):
    """Compute F_{c,m} for d=2 by summing over m-layer configurations."""
    # c = (1,1,0): valid states at each layer are (a,a,a), (a+1,a+1,a), (a+1,a,a) for a>=0
    # For m layers with decreasing constraints, this is a product of geometric series
    # modulated by the state transitions.
    
    # State at layer k: (type_k, base_k) where
    # type A: (a,a,a), weight 3a
    # type B: (a+1,a+1,a), weight 3a+2  
    # type C: (a+1,a,a), weight 3a+1
    # Constraint: components of layer k <= components of layer k-1
    
    # For type transitions:
    # Layer k-1 has state (a0, a1, a2). Layer k has state (b0, b1, b2) with b_i <= a_i.
    # 
    # If k-1 is type A with base a: (a,a,a)
    #   k can be type A with base b<=a: OK
    #   k can be type B with base b, so (b+1,b+1,b): b+1<=a, b+1<=a, b<=a -> b<=a-1
    #   k can be type C with base b, so (b+1,b,b): b+1<=a, b<=a, b<=a -> b<=a-1
    #
    # If k-1 is type B with base a: (a+1,a+1,a)
    #   k type A base b: b<=a+1, b<=a+1, b<=a -> b<=a
    #   k type B base b: b+1<=a+1, b+1<=a+1, b<=a -> b<=a
    #   k type C base b: b+1<=a+1, b<=a+1, b<=a -> b<=a
    #
    # If k-1 is type C with base a: (a+1,a,a)
    #   k type A base b: b<=a+1, b<=a, b<=a -> b<=a
    #   k type B base b: b+1<=a+1, b+1<=a, b<=a -> b<=a-1
    #   k type C base b: b+1<=a+1, b<=a, b<=a -> b<=a
    
    # So the transition matrix (from base a to base b) depends on types.
    # Let me build the transfer matrix over (type, base) states.
    # Since bases go to infinity, I'll truncate at some max_base.
    
    max_base = 30  # truncate
    states = []
    for t in ['A', 'B', 'C']:
        for b in range(max_base + 1):
            states.append((t, b))
    
    n_states = len(states)
    state_idx = {s: i for i, s in enumerate(states)}
    
    # Weight of state (type, base):
    # A: 3*base, B: 3*base+2, C: 3*base+1
    weights = {}
    for s in states:
        t, b = s
        if t == 'A': weights[s] = 3*b
        elif t == 'B': weights[s] = 3*b + 2
        elif t == 'C': weights[s] = 3*b + 1
    
    # Transition: from state s1 at layer k-1 to state s2 at layer k
    def can_transition(s1, s2):
        t1, a = s1
        t2, b = s2
        if t1 == 'A':
            if t2 == 'A': return b <= a
            elif t2 == 'B': return b <= a - 1
            elif t2 == 'C': return b <= a - 1
        elif t1 == 'B':
            if t2 == 'A': return b <= a
            elif t2 == 'B': return b <= a
            elif t2 == 'C': return b <= a
        elif t1 == 'C':
            if t2 == 'A': return b <= a
            elif t2 == 'B': return b <= a - 1
            elif t2 == 'C': return b <= a
    
    # Build transfer matrix as q-valued matrix
    # T[s2][s1] = q^{weight(s2)} if can_transition(s1, s2), else 0
    # F_{c,m} = sum_{s_1,...,s_m} prod_{k=1}^m q^{w(s_k)} * [transitions valid]
    # = 1^T * T^m * 1 (where 1 is the vector of ones, T includes weights)
    
    # Actually: F_{c,m} = sum over (s_1,...,s_m) product q^{w(s_k)} subject to transitions
    # This is (transfer matrix)^m applied to initial vector (all weights) summed.
    
    # Let v be the initial vector: v[s] = q^{w(s)} for all valid states s
    # (at layer 1, any state is valid)
    # At each subsequent layer, multiply by the transition matrix weighted by q^{w(s_next)}
    
    # Use power series ring
    R2 = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q2 = R2.gen()
    
    if m == 0:
        return R2(1)
    
    # Vector after processing all m layers
    # v_m[s] = sum over all sequences (s_1,...,s_m) ending at s, of product q^{sum w}
    # with valid transitions
    
    # Initialize: after layer 1
    v = {}
    for s in states:
        v[s] = q2**weights[s]
    
    for layer in range(2, m+1):
        v_new = {}
        for s2 in states:
            total = R2(0)
            for s1 in states:
                if can_transition(s1, s2) and v[s1] != 0:
                    total += v[s1] * q2**weights[s2]
            v_new[s2] = total
        v = v_new
    
    # Sum over all final states
    F = sum(v[s] for s in states)
    return F

# Test
print("F_{c,0} =", compute_Fcm_d2(0, (1,1,0)))
F1 = compute_Fcm_d2(1, (1,1,0))
print(f"F_{{c,1}} first terms = {F1.polynomial()}")
print(f"Check: F_{{c,1}} = 1/(1-q)? Mult by (1-q): {((1-q)*F1).polynomial()}")

F2 = compute_Fcm_d2(2, (1,1,0))
print(f"\nF_{{c,2}} first terms = {F2.polynomial()}")

# Now compute Q_n correctly
print("\n\n=== Q_n computation ===")
d = 2
ell = gcd(d, 3)  # = 1
r = 3

Fm_list = [compute_Fcm_d2(m, (1,1,0)) for m in range(5)]

for n in range(5):
    s = R(0)
    for j in range(n + 1):
        k = n - j
        sign = (-1)**k
        qpow = q**(k*(k+1)//2)
        # (q;q)_k
        denom = R(1)
        for i in range(1, k+1):
            denom *= (1 - q**i)
        s += sign * qpow / denom * Fm_list[j]
    
    # (q^ell;q^ell)_n
    qell_n = R(1)
    for i in range(1, n+1):
        qell_n *= (1 - q**(ell*i))
    
    Qn = qell_n * s
    Qn_poly = Qn.polynomial()
    
    neg = [c for c in Qn_poly.coefficients() if c < 0]
    print(f"Q_{n} = {Qn_poly}")
    print(f"  Q_{n}(1) = {Qn_poly(1)}, neg = {'YES '+str(neg[:3]) if neg else 'no'}")

