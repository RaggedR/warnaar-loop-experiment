# Compute Q_{n,c}(q) for small d and check GL_3 key polynomial decomposition
# Key polynomials (Demazure characters) for GL_3 at (x1,x2,x3) = (q, q^2, q^3)

from sage.all import *

def compute_Qnc(c, n_max, prec=200):
    """Compute Q_{n,c}(q) using the Corteel-Welsh functional equation approach."""
    r = len(c)
    d = sum(c)
    ell = gcd(d, r)
    t = d + r
    
    R = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = R.gen()
    
    # Borodin's product formula for F_c(q) - we need F_c(z,q)
    # Use the CW recurrence instead
    # F_c(y,q) satisfies the inclusion-exclusion
    
    # Actually, let's compute F_{c,n}(q) directly by enumerating cylindric partitions
    # For small cases this is tractable
    
    results = {}
    
    # Enumerate cylindric partitions of profile c with max <= n
    # Profile c = (c_0, c_1, c_2) for r=3
    # CP = (lam^0, lam^1, lam^2) with cyclic interlacing:
    # lam^i_j >= lam^{i+1}_{j + c_{i+1}} for all i (mod r), all j >= 1
    
    # For max <= n, all parts are in {0, 1, ..., n}
    # Each partition has parts that are weakly decreasing
    
    # This is expensive; let's use the transfer matrix approach instead
    # The transfer matrix A has rows/columns indexed by profiles c'
    # and entries are q-series
    
    # Actually, let me use the iterated q-difference identity
    # Q_n = D_n^n where D_0^m = h_m, D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}
    # and h_m = g_m * (q;q)_m where g_m = F_{c,m} - F_{c,m-1}
    
    # We need F_{c,m} first
    # Use the matrix approach: F_{c,n}(q) = sum over CPs with max <= n of q^|Lambda|
    
    pass

def enumerate_CPs(c, n, max_parts=20):
    """Enumerate cylindric partitions of profile c=(c0,c1,c2) with max entry <= n.
    Each partition is truncated to max_parts parts."""
    r = len(c)
    # Generate all partitions with parts <= n and at most max_parts parts
    # Then check the interlacing conditions
    
    from itertools import product as iprod
    
    # For efficiency, represent each partition as a tuple of parts (weakly decreasing, >= 0)
    # Truncate: since parts beyond some point are 0, we only need enough parts
    
    # The interlacing condition lam^i_j >= lam^{i+1}_{j+c_{i+1}} means
    # parts of lam^i dominate shifted parts of lam^{i+1}
    
    # For small n and d, this is tractable
    d = sum(c)
    
    # Generate partitions with parts in {0,...,n} and at most L parts
    # L should be large enough that all relevant interlacing is captured
    L = max_parts
    
    def gen_partitions(max_val, length):
        """Generate weakly decreasing sequences of given length with values in {0,...,max_val}"""
        if length == 0:
            yield ()
            return
        if length == 1:
            for v in range(max_val + 1):
                yield (v,)
            return
        for first in range(max_val + 1):
            for rest in gen_partitions(first, length - 1):
                yield (first,) + rest
    
    def check_interlacing(lams, c, r, L):
        """Check cyclic interlacing for CP = (lam^0, ..., lam^{r-1})"""
        for i in range(r):
            i_next = (i + 1) % r
            c_next = c[i_next]
            for j in range(L):
                # lam^i_j >= lam^{i_next}_{j + c_next}
                lhs = lams[i][j] if j < len(lams[i]) else 0
                rhs_idx = j + c_next
                rhs = lams[i_next][rhs_idx] if rhs_idx < len(lams[i_next]) else 0
                if lhs < rhs:
                    return False
        return True
    
    count_by_size = {}
    
    # For d small and n small, enumerate
    all_parts = list(gen_partitions(n, L))
    print(f"  Generated {len(all_parts)} partitions with parts <= {n}, length {L}")
    
    total = 0
    for combo in iprod(all_parts, repeat=r):
        if check_interlacing(combo, c, r, L):
            size = sum(sum(p) for p in combo)
            count_by_size[size] = count_by_size.get(size, 0) + 1
            total += 1
    
    print(f"  Found {total} cylindric partitions")
    return count_by_size

# Start with d=2, c=(1,1,0), max_parts = 10
print("=== d=2, c=(1,1,0) ===")
c = (1, 1, 0)
d = sum(c)
ell = gcd(d, 3)
print(f"d={d}, ell={ell}")

# Compute F_{c,n} for n = 0, 1, 2, 3
R = PowerSeriesRing(QQ, 'q', default_prec=100)
q = R.gen()

for n in range(4):
    print(f"\n--- n = {n} ---")
    counts = enumerate_CPs(c, n, max_parts=8)
    # Build polynomial
    F_cn = sum(cnt * q**sz for sz, cnt in counts.items()) + R(0)
    F_cn = F_cn.add_bigoh(100)
    print(f"F_{{c,{n}}} = {F_cn.polynomial()}")

