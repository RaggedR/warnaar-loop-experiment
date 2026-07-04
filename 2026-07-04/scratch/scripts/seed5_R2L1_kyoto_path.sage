# Seed 5, Round 2, Layer 1
# Test: Do bounded CPs correspond to truncated Kyoto paths?
# And does the generating function match Q_n or P_n?

# First, let's understand what the Kyoto path model looks like for A_2^(1) at level d
# The perfect crystal is B^{1,d} = KR crystal of type (1,d)

# For d=2, r=3: A_2^(1) level 2
# B^{1,2} has dim = binom(4,2) = 6 elements

print("=== Testing Kyoto path model for A_2^(1) ===")
print()

# The KR crystal B^{1,d} for A_2^(1) is the set of semistandard tableaux of shape (d) with entries {1,2,3}
# Number of such tableaux = binom(d+2, 2)

for d in [2, 4, 5]:
    print(f"d = {d}: B^{{1,{d}}} has {binomial(d+2,2)} elements = number of profiles")

print()

# Now let's compute Q_n and P_n for small cases to compare

# Profile c = (c_0, c_1, c_2) with d = c_0 + c_1 + c_2
# Cylindric partitions: 3 partitions lambda^(1), lambda^(2), lambda^(3) with cyclic interlacing

# Let me compute F_{c,n}(q) = sum over CPs with max <= n of q^|Lambda|
# using direct enumeration for d=2

from itertools import product as iprod

def enum_cylindric_partitions_bounded(profile, max_val, max_parts=30):
    """Enumerate CPs of given profile with max entry <= max_val.
    Profile c = (c0, c1, c2). 
    A CP is (lambda^0, lambda^1, lambda^2) where lambda^i are partitions
    with lambda^i_j >= lambda^{i+1}_{j + c_{i+1}} (cyclic).
    """
    c0, c1, c2 = profile
    # For bounded CPs, each partition has parts <= max_val
    # The number of parts needed depends on the interlacing
    # Let's work with finite sequences of length L
    
    R = PowerSeriesRing(ZZ, 'q')
    q = R.gen()
    
    # For small max_val and d, we can enumerate directly
    # lambda^i is a partition with parts in [0, max_val]
    # Need enough parts so interlacing is satisfied
    
    L = max_val + max(c0, c1, c2) + 5  # enough parts
    
    result = R(1)  # empty partition (all zeros) always works with size 0
    
    # This is going to be very slow for large cases
    # Let's use the transfer matrix approach instead
    return None

# Better approach: use the transfer matrix / Borodin product formula
# F_c(q) = product formula, then extract bounded part via functional equation

# Let's use the Corteel-Welsh recurrence approach
# F_c(y,q) satisfies a functional equation

def compute_Q_n(profile, n_max, prec=100):
    """Compute Q_{n,c}(q) for n = 0, 1, ..., n_max using the definition.
    Q_{n,c}(q) = (q^ell; q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
    """
    c = profile
    d = sum(c)
    ell = gcd(d, 3)
    r = 3
    t = d + r
    
    R.<q> = PowerSeriesRing(ZZ, default_prec=prec)
    
    # First compute F_{c,m}(q) for m = 0, ..., n_max using transfer matrix
    # F_{c,m} = sum over CPs with max <= m of q^size
    
    # The profiles for r=3 are compositions (c0,c1,c2) with c0+c1+c2 = d
    profiles = []
    for a in range(d+1):
        for b in range(d+1-a):
            profiles.append((a, b, d-a-b))
    
    num_profiles = len(profiles)
    prof_idx = {p: i for i, p in enumerate(profiles)}
    
    # Transfer matrix A(x): A[c,c'] = coefficient relating F_{c,m} to F_{c',m-1}
    # From the Corteel-Welsh functional equation
    # Actually, let's use the known result:
    # F_{c,n}(q) can be computed via the matrix product formula
    # (I - A(q^k))^{-1} applied iteratively
    
    # The matrix A(x) has entries A[c,c'] = x^{|J|} where c' = c(J) for some J
    # More precisely, from the CW functional equation
    
    # Let me compute directly using the inclusion-exclusion
    # G_n(c) = F_{c,n} - F_{c,n-1} = [y^n] sum_{J} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1-yq^|J|)
    # This is complex. Let me just enumerate small CPs directly.
    
    # For r=3, d=2, a CP is (lam^0, lam^1, lam^2) with:
    # lam^i_j >= lam^{i+1}_{j + c_{i+1}} for i=0,1 and lam^2_j >= lam^0_{j+c_0}
    
    # Direct enumeration for small cases
    pass

# Let me try with SageMath's crystal functionality instead
print("=== KR Crystal B^{1,d} for A_2^(1) ===")
print()

# Test d=2
try:
    K = crystals.KirillovReshetikhin(['A', 2, 1], 1, 2)
    print(f"B^{{1,2}} for A_2^(1): {K.cardinality()} elements")
    for b in K:
        print(f"  {b}: wt = {b.weight()}")
except Exception as e:
    print(f"Error: {e}")

print()

# Tensor product B^{1,d}^{tensor n}
print("=== Tensor products ===")
for d in [2]:
    for n in [1, 2]:
        try:
            K = crystals.KirillovReshetikhin(['A', 2, 1], 1, d)
            if n == 1:
                T = K
            else:
                T = crystals.TensorProduct(*[K]*n)
            print(f"B^{{1,{d}}}^{{tensor {n}}}: {T.cardinality()} elements")
            
            # Compute the 1d configuration sum (energy-graded character)
            R.<q> = PowerSeriesRing(ZZ, default_prec=50)
            # The energy function on tensor products
            energy_sum = R(0)
            for b in T:
                try:
                    e = b.energy_function() if hasattr(b, 'energy_function') else 0
                    energy_sum += q^e
                except:
                    pass
            
            print(f"  Energy sum: {energy_sum}")
        except Exception as e:
            print(f"  Error for d={d}, n={n}: {e}")

print()
print("=== Demazure crystals ===")
# Try to construct Demazure subcrystals
for d in [2]:
    try:
        # The highest weight crystal
        C = crystals.LSPaths(['A', 2, 1], [d, 0, 0])  # Lambda = d*Lambda_0
        print(f"LS paths crystal for A_2^(1), weight d*Lambda_0, d={d}")
        # This is infinite, so we can't enumerate directly
        # But we can look at Demazure subcrystals
        
        # A Demazure crystal B_w(Lambda) for a Weyl group element w
        # is the set of elements reachable from the highest weight by
        # applying f_i operators in the order given by a reduced word for w
        
        # For truncated paths of length n, the relevant Weyl group element
        # involves n applications of the translation element
    except Exception as e:
        print(f"  Error: {e}")

