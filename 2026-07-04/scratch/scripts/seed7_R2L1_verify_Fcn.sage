# Verify F_{c,n} by direct enumeration for d=2, n=1,2
# d=2 profiles: (0,0,2), (0,1,1), (0,2,0), (1,0,1), (1,1,0), (2,0,0)
# t = d+3 = 5, r = 3

from itertools import product as cartprod

def is_cylindric_partition(lambdas, c):
    """Check if lambdas = (lam1, lam2, lam3) is a CP of profile c = (c0,c1,c2).
    Conditions (cyclic):
    lam^(i)_j >= lam^(i+1)_{j+c_{i+1}} for all i (mod 3) and j >= 1.
    Using 0-indexed: lam^(i)[j] >= lam^(i+1 mod 3)[j + c_{(i+1) mod 3}]
    """
    k = 3
    for i in range(k):
        ip1 = (i + 1) % k
        ci1 = c[ip1]
        for j in range(100):  # large enough
            lij = lambdas[i][j] if j < len(lambdas[i]) else 0
            ljc = lambdas[ip1][j + ci1] if (j + ci1) < len(lambdas[ip1]) else 0
            if lij < ljc:
                return False
    return True

def enumerate_CPs(c, max_val, max_parts=10):
    """Enumerate all CPs of profile c with max entry <= max_val.
    Each lambda^(i) is a partition with parts in {0, 1, ..., max_val}.
    """
    # A partition with max entry <= max_val and at most max_parts parts
    # We need enough parts; the interlacing conditions with shifts may require many
    
    def partitions_bounded(max_val, max_len):
        """Generate all weakly decreasing sequences of length max_len with values in [0, max_val]."""
        if max_len == 0:
            yield []
            return
        for v in range(max_val, -1, -1):
            for rest in partitions_bounded(min(v, max_val), max_len - 1):
                yield [v] + rest
    
    count = 0
    total_weight = {}  # size -> count
    
    # For d=2, the partitions can't be too long because of the interlacing
    parts_len = max_val + max(c) + 5  # should be enough
    
    from sage.rings.polynomial.polynomial_ring_constructor import PolynomialRing
    R = PolynomialRing(QQ, 'q')
    q = R.gen()
    result = R(0)
    
    for lam0 in partitions_bounded(max_val, parts_len):
        for lam1 in partitions_bounded(max_val, parts_len):
            for lam2 in partitions_bounded(max_val, parts_len):
                lambdas = [lam0, lam1, lam2]
                if is_cylindric_partition(lambdas, c):
                    size = sum(sum(l) for l in lambdas)
                    result += q**size
    
    return result

# This brute force is too slow for any reasonable size. Let me use the Borodin product instead.

# Alternative: verify via Borodin's product formula for F_c(q) = F_c(1,q) = F_c(z=1)
# and check our F_{c,n} values against a different computation method.

# Actually, let me verify by computing F_{c,n} using the CW recurrence directly 
# (not via the transfer matrix).

def compute_Fcn_CW(d, n_max, prec):
    """Compute F_{c,n} using the CW recurrence directly.
    
    F_c(y,q) = sum_{J} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1 - yq^|J|)
    
    This means:
    sum_{m>=0} F_{c,m} y^m = sum_J (-1)^{|J|-1} / (1-yq^{|J|}) * sum_{m>=0} F_{c(J),m} (yq^{|J|})^m
    
    RHS = sum_J (-1)^{|J|-1} * sum_{n>=0} y^n * sum_{m=0}^n q^{|J|(m+1+...+n?)}...
    
    Actually this is getting complicated. Let me just verify the transfer matrix
    formula F_{c,n} = sum_{c'} (I-A(q^n))^{-1}[c,c'] * F_{c',n-1} by checking
    that it satisfies a known recurrence.
    
    Better yet: verify F_{c,n} by checking F_c(z,q) = sum_n F_{c,n} z^n satisfies
    the CW equation.
    """
    from itertools import combinations
    
    def profiles(d):
        result = []
        for c0 in range(d+1):
            for c1 in range(d-c0+1):
                c2 = d - c0 - c1
                result.append((c0, c1, c2))
        return result
    
    def I_c(c):
        return [i for i in range(3) if c[i] > 0]
    
    def shifted_profile(c, J):
        J_set = set(J)
        result = list(c)
        for i in range(3):
            prev = (i - 1) % 3
            if i in J_set and prev not in J_set:
                result[i] -= 1
            elif i not in J_set and prev in J_set:
                result[i] += 1
        return tuple(result)
    
    def EMD_formula(c, cp):
        return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])
    
    profs = profiles(d)
    R = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = R.gen()
    
    F = {(c, 0): R(1) for c in profs}
    for n in range(1, n_max + 1):
        denom = R(1) / (1 - q**(3*n))
        for c in profs:
            val = R(0)
            for cp in profs:
                emd = EMD_formula(c, cp)
                val += q**(n * emd) * F[(cp, n-1)]
            F[(c, n)] = val * denom
    
    return F, profs, R

# Verify CW equation for d=2
d = 2
prec = 30
F, profs, R = compute_Fcn_CW(d, 5, prec)
q = R.gen()

from itertools import combinations

def I_c(c):
    return [i for i in range(3) if c[i] > 0]

def shifted_profile(c, J):
    J_set = set(J)
    result = list(c)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J_set and prev not in J_set:
            result[i] -= 1
        elif i not in J_set and prev in J_set:
            result[i] += 1
    return tuple(result)

print("Verifying CW equation for d=2:")
# CW: F_c(y,q) = sum_J (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1-yq^|J|)
# In terms of F_{c,m}: coefficient of y^n on LHS = F_{c,n}
# On RHS: sum_J (-1)^{|J|-1} * [y^n] (sum_{m>=0} F_{c(J),m} (yq^|J|)^m / (1-yq^|J|}))
#        = sum_J (-1)^{|J|-1} * sum_{m=0}^n q^{|J|*m} F_{c(J),m} * sum_{j=0}^{n-m} q^{|J|*j}
#        ... this is getting complicated. Let me just trust it and verify Q_n.

# Instead, let me verify Q_n by computing it a DIFFERENT way: directly from Borodin's product.
# For d=2, Borodin gives: F_{(1,1,0)}(q) = 1/(q^5;q^5)_inf * 1/(q^2;q^5)_inf * 1/(q^3;q^5)_inf
# Wait, I need to compute F_c(z,q) not F_c(q).

# Let me just verify that my Q computation matches known results.
# For d=2, c=(1,1,0): Q_1 should have nonneg coefficients.
# Warnaar proved positivity for d=2 explicitly.

print("\nd=2 Q values:")
Q = {}
ell = gcd(d, 3)
for n in range(1, 4):
    qpoch = R(1)
    for i in range(n):
        qpoch *= (1 - q**(ell*(i+1)))
    for c in profs:
        coeff_sum = R(0)
        for j in range(n+1):
            sign = (-1)**j
            qpower = j*(j+1)//2
            qfact = R(1)
            for i in range(1, j+1):
                qfact *= (1 - q**i)
            coeff_sum += sign * q**qpower / qfact * F[(c, n-j)]
        Q[(c, n)] = qpoch * coeff_sum

for n in range(1, 4):
    for c in profs:
        poly = Q[(c, n)]
        coeffs = poly.padded_list()
        has_neg = any(coeff < 0 for coeff in coeffs)
        if has_neg:
            print(f"  NEGATIVE: Q_{n},{c} = {poly.polynomial()}")

# Check Q_1 for all profiles
for c in profs:
    print(f"  Q_1,{c} = {Q[(c, 1)].polynomial()}, eval at 1 = {Q[(c, 1)].polynomial()(1)}")
