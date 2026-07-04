# Check which profiles have Q_n < 0 -- are they exactly the degenerate ones?
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

def compute_Qn(d, n_max, prec):
    profs = profiles(d)
    ell = gcd(d, 3)
    
    from sage.rings.power_series_ring import PowerSeriesRing
    R = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = R.gen()
    
    # Compute F_{c,n}
    F = {(c, 0): R(1) for c in profs}
    for n in range(1, n_max + 1):
        denom = R(1) / (1 - q**(3*n))
        for c in profs:
            val = R(0)
            for cp in profs:
                emd = EMD_formula(c, cp)
                val += q**(n * emd) * F[(cp, n-1)]
            F[(c, n)] = val * denom
    
    # Compute Q_{n,c}
    Q = {}
    for n in range(1, n_max + 1):
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
    
    return Q, profs

# Check d=4 and d=7
for d in [4, 7]:
    print(f"\n=== d={d} ===")
    prec = 100 if d <= 5 else 200
    Q, profs = compute_Qn(d, 2, prec)
    
    for n in range(1, 3):
        neg_profiles = []
        pos_profiles = []
        for c in profs:
            poly = Q[(c, n)]
            coeffs = poly.padded_list()
            has_neg = any(coeff < 0 for coeff in coeffs)
            if has_neg:
                neg_profiles.append(c)
            else:
                pos_profiles.append(c)
        
        # Classify
        deg_neg = [c for c in neg_profiles if 0 in c]
        nondeg_neg = [c for c in neg_profiles if 0 not in c]
        deg_pos = [c for c in pos_profiles if 0 in c]
        nondeg_pos = [c for c in pos_profiles if 0 not in c]
        
        print(f"\n  n={n}:")
        print(f"    Degenerate (some c_i=0) with neg coeffs: {len(deg_neg)} profiles: {deg_neg[:5]}...")
        print(f"    Non-degenerate (all c_i>0) with neg coeffs: {len(nondeg_neg)} profiles: {nondeg_neg[:5]}")
        print(f"    Degenerate with pos coeffs: {len(deg_pos)} profiles")
        print(f"    Non-degenerate with pos coeffs: {len(nondeg_pos)} profiles")
        
        # Check: are the degenerate profiles with c_i = 0 exactly the ones from rank-2?
        # Profiles like (d, 0, 0) have only 1 nonzero entry -- these are "rank-1"
        # Profiles like (a, b, 0) have 2 nonzero entries -- these are "rank-2"
        rank1_neg = [c for c in neg_profiles if sum(1 for ci in c if ci > 0) == 1]
        rank2_neg = [c for c in neg_profiles if sum(1 for ci in c if ci > 0) == 2]
        rank3_neg = [c for c in neg_profiles if sum(1 for ci in c if ci > 0) == 3]
        print(f"    Negative by rank: rank1={len(rank1_neg)}, rank2={len(rank2_neg)}, rank3={len(rank3_neg)}")
