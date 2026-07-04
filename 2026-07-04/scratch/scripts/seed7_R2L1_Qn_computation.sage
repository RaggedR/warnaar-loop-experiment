# Seed 7 R2L1: Compute Q_{n,c}(q) for d=7 using the matrix product formula
# F_{c,n} = [product of (I-A(q^k))^{-1} for k=1..n] * v_0
# Then Q_{n,c}(q) = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
# 
# We use the adjugate: (I-A(x))^{-1} = adj(I-A(x))/det(I-A(x)) 
#                                      = x^{EMD(c,c')} / (1-x^3)
# So (I-A(q^k))^{-1}[c,c'] = q^{k*EMD(c,c')} / (1-q^{3k})

from itertools import combinations
from collections import defaultdict

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

def compute_Fcn_direct(d, n_max, prec):
    """Compute F_{c,n}(q) for all profiles c, for n = 0..n_max, as power series.
    
    Uses: F_{c,n} = sum over paths (c_0=c, c_1, ..., c_n) of 
           prod_{k=1}^n q^{k*EMD(c_k, c_{k-1})} / prod_{k=1}^n (1-q^{3k})
    
    But wait, (I-A(q^k))^{-1} acts on the LEFT, so the path goes:
    vec(F_{.,n}) = (I-A(q^n))^{-1} * (I-A(q^{n-1}))^{-1} * ... * (I-A(q^1))^{-1} * v_0
    
    where v_0 = (1, 1, ..., 1) since F_{c,0} = 1 for all c (one CP: all parts 0).
    
    So F_{c,n} = sum over paths (c = c_n, c_{n-1}, ..., c_0) of
                 prod_{k=1}^n q^{k*EMD(c_k, c_{k-1})} / (1-q^{3k})
               = 1/(q^3;q^3)_n * sum over paths of q^{sum_k k*EMD(c_k, c_{k-1})}
    
    Wait, this is what Agent B proved: P_n(c) = (q^3;q^3)_n * F_{c,n}
    = sum over paths of prod q^{k*EMD(c^(k), c^(k-1))}.
    """
    profs = profiles(d)
    N = len(profs)
    
    R = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = R.gen()
    
    # F_{c,0} = 1 for all c
    F = {(c, 0): R(1) for c in profs}
    
    # Iteratively compute F_{c,n} for n = 1..n_max
    # F_{c,n} = sum_{c'} (I-A(q^n))^{-1}[c, c'] * F_{c', n-1}
    #         = sum_{c'} q^{n*EMD(c,c')} / (1-q^{3n}) * F_{c', n-1}
    
    for n in range(1, n_max + 1):
        denom = R(1) / (1 - q**(3*n))
        for c in profs:
            val = R(0)
            for cp in profs:
                emd = EMD_formula(c, cp)
                val += q**(n * emd) * F[(cp, n-1)]
            F[(c, n)] = val * denom
        print(f"  Computed F_{{c,{n}}} for all profiles")
    
    return F, profs

def compute_Qn(d, n_max, prec):
    """Compute Q_{n,c}(q) for all profiles c, n = 1..n_max.
    
    Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
    
    where F_c(z,q) = sum_{m>=0} F_{c,m}(q) * z^m and ell = gcd(d,3).
    
    (zq;q)_inf = sum_{j>=0} (-1)^j q^{binom(j+1,2)} / (q;q)_j * z^j
    
    [z^n] of the product = sum_{j=0}^n (-1)^j q^{binom(j+1,2)} / (q;q)_j * F_{c,n-j}
    
    So Q_{n,c} = (q^ell;q^ell)_n * sum_{j=0}^n (-1)^j q^{binom(j+1,2)} / (q;q)_j * F_{c,n-j}
    """
    ell = gcd(d, 3)
    
    F, profs = compute_Fcn_direct(d, n_max, prec)
    
    R = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = R.gen()
    
    Q = {}
    for n in range(1, n_max + 1):
        # (q^ell;q^ell)_n
        qpoch = R(1)
        for i in range(n):
            qpoch *= (1 - q**(ell*(i+1)))
        
        for c in profs:
            coeff_sum = R(0)
            for j in range(n+1):
                # (-1)^j * q^{binom(j+1,2)} / (q;q)_j
                sign = (-1)**j
                qpower = j*(j+1)//2
                qfact = R(1)
                for i in range(1, j+1):
                    qfact *= (1 - q**i)
                
                coeff_sum += sign * q**qpower / qfact * F[(c, n-j)]
            
            Q[(c, n)] = qpoch * coeff_sum
    
    return Q, profs

# Test with d=4 first (smaller, known to work)
print("=== Testing d=4 ===")
prec = 80
Q4, profs4 = compute_Qn(4, 3, prec)

# Check positivity
for n in range(1, 4):
    neg_count = 0
    for c in profs4:
        poly = Q4[(c, n)]
        coeffs = poly.padded_list()
        for i, coeff in enumerate(coeffs):
            if coeff < 0:
                neg_count += 1
                print(f"  NEGATIVE: Q_{n},{c} has coeff {coeff} at q^{i}")
    if neg_count == 0:
        print(f"  Q_{n} >= 0 for all profiles (d=4)")

# Now d=7
print("\n=== d=7 ===")
prec = 200  # Need higher precision for d=7
Q7, profs7 = compute_Qn(7, 2, prec)

print("\nChecking positivity for d=7:")
for n in range(1, 3):
    neg_count = 0
    for c in profs7:
        poly = Q7[(c, n)]
        coeffs = poly.padded_list()
        for i, coeff in enumerate(coeffs):
            if coeff < 0:
                neg_count += 1
                if neg_count <= 5:
                    print(f"  NEGATIVE: Q_{n},{c} has coeff {coeff} at q^{i}")
    if neg_count == 0:
        print(f"  Q_{n} >= 0 for all profiles (d=7), checked to O(q^{prec})")
    else:
        print(f"  Total negatives for n={n}: {neg_count}")

# Show a sample Q value
c_sample = (2, 3, 2)  # balanced-ish
print(f"\nSample: Q_1,{c_sample} = {Q7[(c_sample, 1)].polynomial()}")
print(f"Q_1,{c_sample}(1) = {Q7[(c_sample, 1)].polynomial()(1)}")
print(f"Expected Q_1(1) = (7+1)(7+2)/6 - 1 = {(8*9)//6 - 1}")
