# Compare energy-graded configuration sums with Q_n and P_n
# For A_2^(1), d=2, profiles (2,0,0), (1,1,0), (0,1,1) etc.

import sys

R.<q> = PowerSeriesRing(ZZ, default_prec=100)

# === Step 1: Compute P_n and Q_n from the transfer matrix ===

def get_profiles(d):
    """All compositions (c0,c1,c2) with c0+c1+c2 = d"""
    profiles = []
    for a in range(d+1):
        for b in range(d+1-a):
            profiles.append((a, b, d-a-b))
    return profiles

def compute_Ic(c):
    """I_c = {i : c_i > 0}"""
    return [i for i in range(len(c)) if c[i] > 0]

def shifted_profile(c, J):
    """Compute c(J) given profile c and subset J of I_c.
    c_i(J) = c_i - 1 if i in J and (i-1) not in J
    c_i(J) = c_i + 1 if i not in J and (i-1) in J
    c_i(J) = c_i otherwise
    Indices cyclic mod k (k = len(c))
    """
    k = len(c)
    result = list(c)
    for i in range(k):
        i_in_J = i in J
        im1_in_J = ((i-1) % k) in J
        if i_in_J and not im1_in_J:
            result[i] -= 1
        elif not i_in_J and im1_in_J:
            result[i] += 1
    return tuple(result)

def all_nonempty_subsets(S):
    """All nonempty subsets of S"""
    if not S:
        return []
    result = []
    n = len(S)
    for mask in range(1, 2**n):
        subset = [S[i] for i in range(n) if mask & (1 << i)]
        result.append(subset)
    return result

def compute_F_bivariate(profile, prec=100, z_prec=10):
    """Compute F_c(z,q) = sum_n F_{c,n}(q) * z^n using Borodin's formula + CW recurrence.
    Actually, we'll compute g_m = [y^m] F_c(y,q) via the CW functional equation iteratively.
    Then F_{c,n} = sum_{m=0}^n g_m.
    
    Wait - F_c(y,q) = sum_{Lambda} q^|Lambda| * y^max(Lambda)
    So [y^m] F_c(y,q) = sum_{Lambda: max=m} q^|Lambda| = g_m
    And F_{c,n}(q) = sum_{m=0}^n g_m
    """
    c = profile
    d = sum(c)
    k = len(c)  # k=3
    t = d + k
    
    Rq.<q_var> = PowerSeriesRing(ZZ, default_prec=prec)
    
    # Use Borodin's product formula for F_c(q) (the unrestricted GF)
    # Then use CW to extract g_m
    
    # Actually, let's compute g_m iteratively using the CW functional equation
    # g_0 = 1 (just the empty partition)
    # For m >= 1: the CW equation gives a recurrence
    
    # CW: F_c(y,q) = sum_{J} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1 - yq^|J|)
    # This means g_m(c) = [y^m] F_c(y,q) satisfies:
    # sum_m g_m(c) y^m = sum_J (-1)^{|J|-1} * (1/(1-yq^|J|)) * sum_m g_m(c(J)) (yq^|J|)^m
    # = sum_J (-1)^{|J|-1} * sum_{m>=0} g_m(c(J)) * q^{m|J|} * y^m * sum_{k>=0} (yq^|J|)^k
    # = sum_J (-1)^{|J|-1} * sum_{n>=0} y^n * sum_{m=0}^n g_m(c(J)) * q^{(n-m+m)|J|}
    # Hmm this is getting complicated. Let me just use the matrix approach.
    
    # From synthesis: F_{c,n} = (I - A(q))^{-1} ... but that's also complex
    # Let me enumerate CPs directly for d=2
    
    pass

def enumerate_CPs_d2(profile, max_val, prec=100):
    """Enumerate all CPs of profile c with max <= max_val, for d=2, r=3.
    Profile c = (c0, c1, c2) with c0+c1+c2 = 2.
    A CP is (lam^0, lam^1, lam^2) where each lam^i is a partition.
    Interlacing: lam^i_j >= lam^{(i+1) mod 3}_{j + c_{(i+1) mod 3}} for all j >= 1.
    """
    Rq.<q_var> = PowerSeriesRing(ZZ, default_prec=prec)
    
    c0, c1, c2 = profile
    
    # Parts <= max_val, and we need enough parts
    # For the interlacing lam^i_j >= lam^{i+1}_{j+c_{i+1}}, if max_val is small,
    # the partitions are also small
    
    # Maximum number of nonzero parts in any partition: bounded by max_val + max shift
    max_parts = max_val + max(c0, c1, c2) + 2
    
    result = Rq(0)
    count = 0
    
    # Generate all triples of partitions with parts <= max_val and <= max_parts parts
    def gen_partitions(max_val, max_len):
        """Generate all partitions with parts in [0, max_val] and at most max_len parts."""
        if max_len == 0:
            yield ()
            return
        for p in range(max_val + 1):
            for rest in gen_partitions(min(p, max_val), max_len - 1):
                yield (p,) + rest
    
    # This is too slow for max_val > 2 or so. Let me use a smarter approach.
    # For d=2, profile (1,1,0):
    # CP = (lam^0, lam^1, lam^2)
    # lam^0_j >= lam^1_{j+c1} = lam^1_{j+1}
    # lam^1_j >= lam^2_{j+c2} = lam^2_{j+0} = lam^2_j  
    # lam^2_j >= lam^0_{j+c0} = lam^0_{j+1}
    
    # So: lam^0_j >= lam^1_{j+1}, lam^1_j >= lam^2_j, lam^2_j >= lam^0_{j+1}
    # This means: lam^1_j >= lam^2_j >= lam^0_{j+1} >= lam^1_{j+2}
    # And also: lam^0_j >= lam^1_{j+1} >= lam^2_{j+1} >= lam^0_{j+2}
    
    # For max_val = 1: parts are 0 or 1
    # lam^i is a partition with parts 0 or 1, so just (1,1,...,1,0,0,...) of some length
    # Determined by the number of 1's
    
    # Let's enumerate for max_val = 0, 1, 2 with profile (1,1,0)
    
    # For efficiency, represent each partition as a tuple padded with zeros
    def pad(lam, length):
        return tuple(list(lam) + [0] * (length - len(lam)))
    
    def check_interlacing(l0, l1, l2, c0, c1, c2, L):
        """Check cyclic interlacing conditions for L-padded partitions."""
        for j in range(L):
            # lam^0_j >= lam^1_{j+c1}
            if j + c1 < L:
                if l0[j] < l1[j + c1]:
                    return False
            # lam^1_j >= lam^2_{j+c2}
            if j + c2 < L:
                if l1[j] < l2[j + c2]:
                    return False
            # lam^2_j >= lam^0_{j+c0}
            if j + c0 < L:
                if l2[j] < l0[j + c0]:
                    return False
        return True
    
    L = max_val + max(c0, c1, c2) + 3
    
    # For small max_val, generate all partitions
    all_parts = list(gen_partitions(max_val, L))
    
    print(f"  Profile {profile}, max={max_val}: {len(all_parts)} partitions of length {L} to check")
    
    for l0 in all_parts:
        l0p = pad(l0, L)
        for l1 in all_parts:
            l1p = pad(l1, L)
            for l2 in all_parts:
                l2p = pad(l2, L)
                if check_interlacing(l0p, l1p, l2p, c0, c1, c2, L):
                    sz = sum(l0p) + sum(l1p) + sum(l2p)
                    result += q_var^sz
                    count += 1
    
    print(f"  Found {count} CPs")
    return result

# Test for d=2, profile (1,1,0)
print("=== Direct CP enumeration for d=2 ===")
for profile in [(1,1,0), (2,0,0), (0,1,1)]:
    for max_val in [0, 1, 2]:
        F = enumerate_CPs_d2(profile, max_val, prec=50)
        print(f"  F_{{c,{max_val}}}(q) for c={profile}: {F}")
    print()

