"""
Seed 6, Layer 3: Test positivity for d=9 and d=12 (both divisible by 3).
The synthesis asks whether positivity holds even when d equiv 0 mod 3.
"""

from sage.all import *

def count_at_height(c0, c1, c2, w):
    """Count lattice points (L1, L2, L3) with sum = w satisfying constraints."""
    count = 0
    for L1 in range(w+1):
        for L2 in range(w+1-L1):
            L3 = w - L1 - L2
            if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                count += 1
    return count

def compute_Qn(c, n_max, q_prec=50):
    """
    Compute Q_n for n = 1, ..., n_max.
    
    Uses: Q_n = (q^l;q^l)_n * [z^n]((zq;q)_inf * F_c(z,q))
    
    We compute this via the alternating sum:
    Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} * [n choose j]_{q^l} * h_{n-j}
    
    Wait, the exact formula involves F_{c,m} and then extraction.
    Let me use the direct approach.
    """
    c0, c1, c2 = c
    d = c0 + c1 + c2
    l = gcd(d, 3)
    
    R = PowerSeriesRing(QQ, 'q', default_prec=q_prec)
    q = R.gen()
    
    # Compute G_m = [z^m] F_c(z,q) for m = 0, 1, ..., n_max
    # G_m = sum_{Lambda: max(Lambda)=m} q^{|Lambda|}
    # G_0 = 1 (empty partition)
    # For m >= 1: G_m = F_{c,m} - F_{c,m-1}
    # where F_{c,m} = sum_{Lambda: max <= m} q^{|Lambda|}
    
    # F_{c,m} is hard to compute directly for m >= 2. Let me use the CW recurrence.
    # Actually, for Q_n with small n, I can use:
    
    # (zq;q)_inf = sum_{j >= 0} e_j z^j where e_j = (-1)^j q^{j(j+1)/2} / (q;q)_j
    # (using the q-binomial theorem for the product)
    
    # [z^n]((zq;q)_inf * F_c(z,q)) = sum_{j=0}^n e_j * G_{n-j}
    # = sum_{j=0}^n e_j * (F_{c,n-j} - F_{c,n-j-1})
    # = sum_{j=0}^n e_j * F_{c,n-j} - sum_{j=0}^n e_j * F_{c,n-j-1}
    # = sum_{j=0}^n e_j F_{c,n-j} - sum_{j=1}^{n+1} e_{j-1} F_{c,n-j}  (shifting)
    # Hmm, this gets complicated. Let me just use the formula:
    
    # Actually, the standard approach from the synthesis (Seed 4):
    # Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n choose j]_q * h_{n-j}
    # where h_m are defined by F_{c,m}(q) = sum_m h_m q^m / (q;q)_m... 
    # No, that's not quite right either.
    
    # Let me use the DIRECT definition carefully.
    # From the definition: Q_{n,c}(q) = (q^l;q^l)_n * [z^n]((zq;q)_inf * sum_m G_m z^m)
    
    # Compute F_{c,m} for m = 0, ..., n_max using the CW recurrence (Neumann series).
    
    # F_{c,0} = 1 for all c.
    # F_{c,n} = sum over CPs with max <= n, weighted by q.
    
    # Use the COLUMN DECOMPOSITION: each CP with max <= n consists of columns,
    # each column is a tuple (a1, a2, a3) with 0 <= ai <= n satisfying interlacing.
    # The GF factors as: F_{c,n}(q) = sum over valid column types, q^{column_weight},
    # where the column types are independent.
    
    # Actually, F_{c,n}(q) = product over j >= 1 of (sum of valid column-j contributions).
    # No, the columns are not independent because of interlacing.
    
    # OK let me just compute F_{c,m} via the CW recurrence for small m.
    # The CW system: F_{c,n} = sum_J (-1)^{|J|-1} q^{|J|*n} * (cumulative sum of F_{c(J),j} for j <= n)
    # This is implemented as a matrix iteration.
    
    # For simplicity, let me compute F_{c,m} by direct enumeration for small m.
    # A CP with max <= m is a sequence of partitions with all parts <= m,
    # satisfying interlacing. This is equivalent to: for each "level" from 1 to m,
    # count the number of parts equal to that level in each partition.
    
    # Actually, for a CP of profile c = (c0, c1, c2), the structure is:
    # Three partitions lambda^1, lambda^2, lambda^3 with parts in {0, ..., m}
    # and interlacing conditions.
    
    # This is equivalent to a collection of binary CPs at each level.
    # Specifically: define mu^i_l = #{j : lambda^i_j >= l} for l = 1, ..., m.
    # Then the interlacing conditions translate to:
    # mu^1_l >= mu^2_l - c1 (from lambda^1_j >= lambda^2_{j+c1})
    # ... actually the level decomposition needs care.
    
    # Let me just compute by the CW recurrence directly.
    # I'll implement the S_{c,n} = sum_{j=0}^n F_{c,j} version.
    
    compositions = []
    for a in range(d+1):
        for b in range(d+1-a):
            compositions.append((a, b, d-a-b))
    comp_idx = {c: i for i, c in enumerate(compositions)}
    NC = len(compositions)
    
    # Initialize
    F = {}  # F[comp, n] = power series
    S = {}  # S[comp, n] = cumulative sum
    
    for comp in compositions:
        F[comp, 0] = R(1)
        S[comp, 0] = R(1)
    
    def get_Ic(c):
        return frozenset(i for i in range(3) if c[i] > 0)
    
    def all_nonempty_subsets(Sc):
        Sc = list(Sc)
        ns = len(Sc)
        for mask in range(1, 1 << ns):
            yield frozenset(Sc[j] for j in range(ns) if mask & (1 << j))
    
    def shifted_profile(c, J):
        result = list(c)
        for i in range(3):
            prev = (i - 1) % 3
            if i in J and prev not in J:
                result[i] = c[i] - 1
            elif i not in J and prev in J:
                result[i] = c[i] + 1
        return tuple(result)
    
    for n in range(1, n_max + 1):
        # For each composition, compute F_{comp, n} from the CW recurrence
        # (I - A(q^n)) F_n = RHS(S_{n-1})
        
        # Build the linear system
        M = matrix(R, NC, NC)
        b = vector(R, NC)
        
        for i, comp in enumerate(compositions):
            M[i, i] = R(1)
            Ic = get_Ic(comp)
            if not Ic:
                # F_{comp,n} = 0 for n >= 1 if I_c is empty? No.
                # If c = (d, 0, 0), I_c = {0}. We never have I_c empty for d >= 1.
                # If c = (0, 0, d), I_c = {2}. Still nonempty.
                # c = (0, 0, 0) is d=0, not relevant.
                continue
            
            for J in all_nonempty_subsets(Ic):
                cp = shifted_profile(comp, J)
                if cp not in comp_idx:
                    continue
                j = comp_idx[cp]
                s = len(J)
                sign = (-1)**(s - 1)
                
                # A term: -(-1)^{s-1} x^s F_{cp, n} = -sign * q^{sn} F_{cp,n}
                coeff = sign * q**(s * n)
                M[i, j] -= coeff
                
                # RHS: sign * q^{sn} S_{cp, n-1}
                b[i] += coeff * S[cp, n-1]
        
        # Solve M * F_n = b
        # This is a matrix equation over power series ring.
        # Since M has constant term = I (identity), it's invertible over R.
        
        # Use iterative approach: F_n = M^{-1} b = (I - (I-M))^{-1} b = sum (I-M)^k b
        # I - M = A(q^n) has minimum degree n, so the series converges rapidly.
        
        A_mat = matrix.identity(R, NC) - M  # = A(q^n), has min degree n
        F_vec = vector(R, NC)
        term = b
        for k in range(q_prec // n + 2):
            F_vec += term
            term = A_mat * term
            # Truncate
            term = vector(R, [t.add_bigoh(q_prec) for t in term])
        
        for i, comp in enumerate(compositions):
            F[comp, n] = F_vec[i].add_bigoh(q_prec)
            S[comp, n] = S[comp, n-1] + F[comp, n]
    
    # Now compute Q_n from F_{c,m}
    # G_m = F_{c,m} - F_{c,m-1} for m >= 1, G_0 = 1
    
    # e_j = [z^j](zq;q)_inf = (-1)^j q^{j(j+1)/2} / (q;q)_j
    
    results = {}
    for n in range(1, n_max + 1):
        # Compute [z^n]((zq;q)_inf * sum_m G_m z^m)
        # = sum_{j=0}^n e_j G_{n-j}
        
        bracket = R(0)
        for j in range(n + 1):
            # e_j = (-1)^j q^{j(j+1)/2} / (q;q)_j
            ej = (-1)**j * q**(j*(j+1)//2)
            # Divide by (q;q)_j
            denom = R(1)
            for i in range(1, j+1):
                denom *= (1 - q**i)
            ej = ej * denom.inverse_of_unit()
            
            # G_{n-j}
            m = n - j
            if m == 0:
                Gm = R(1)
            else:
                Gm = F[c, m] - F[c, m-1]
            
            bracket += ej * Gm
        
        bracket = bracket.add_bigoh(q_prec)
        
        # Q_n = (q^l;q^l)_n * bracket
        ql_fac = R(1)
        for i in range(1, n+1):
            ql_fac *= (1 - q**(l*i))
        
        Qn = (ql_fac * bracket).add_bigoh(q_prec)
        results[n] = Qn
    
    return results

# =========================================================
# Test d=9 (divisible by 3)
# =========================================================
print("=" * 60)
print("TESTING d=9 (d equiv 0 mod 3)")
print("=" * 60)

d = 9
l = gcd(d, 3)
print(f"d={d}, l=gcd({d},3)={l}")
print(f"Expected Q_n(1) formula: unclear (Welsh formula requires d not equiv 0 mod 3)")

profiles_9 = [(3,3,3), (4,3,2), (5,2,2), (5,3,1), (6,2,1), (7,1,1), (9,0,0)]

for c in profiles_9:
    print(f"\n--- c = {c} ---")
    try:
        Qs = compute_Qn(c, n_max=2, q_prec=40)
        for n in sorted(Qs.keys()):
            Qn = Qs[n]
            neg = [i for i in range(40) if Qn[i] < 0]
            s = sum(Qn[i] for i in range(40))
            print(f"  Q_{n} (first 15 terms): {[Qn[i] for i in range(15)]}")
            print(f"  Q_{n}(1) ~ {s}, negative at: {neg[:10]}")
    except Exception as e:
        print(f"  Error: {e}")

# =========================================================
# Test d=12 (divisible by 3)
# =========================================================
print("\n" + "=" * 60)
print("TESTING d=12 (d equiv 0 mod 3)")
print("=" * 60)

d = 12
l = gcd(d, 3)
print(f"d={d}, l=gcd({d},3)={l}")

profiles_12 = [(4,4,4), (5,4,3), (6,3,3)]

for c in profiles_12:
    print(f"\n--- c = {c} ---")
    try:
        Qs = compute_Qn(c, n_max=2, q_prec=50)
        for n in sorted(Qs.keys()):
            Qn = Qs[n]
            neg = [i for i in range(50) if Qn[i] < 0]
            s = sum(Qn[i] for i in range(50))
            print(f"  Q_{n} (first 15 terms): {[Qn[i] for i in range(15)]}")
            print(f"  Q_{n}(1) ~ {s}, negative at: {neg[:10]}")
    except Exception as e:
        print(f"  Error: {e}")

# =========================================================
# Also test d=7 and d=8 as sanity checks
# =========================================================
print("\n" + "=" * 60)
print("SANITY CHECK: d=7 and d=8")
print("=" * 60)

for c in [(3,2,2), (4,2,1)]:
    d = sum(c)
    print(f"\n--- d={d}, c = {c} ---")
    Qs = compute_Qn(c, n_max=2, q_prec=30)
    for n in sorted(Qs.keys()):
        Qn = Qs[n]
        neg = [i for i in range(30) if Qn[i] < 0]
        s = sum(Qn[i] for i in range(30))
        print(f"  Q_{n} (first 15): {[Qn[i] for i in range(15)]}")
        print(f"  Q_{n}(1) ~ {s}, negative at: {neg[:10]}")

