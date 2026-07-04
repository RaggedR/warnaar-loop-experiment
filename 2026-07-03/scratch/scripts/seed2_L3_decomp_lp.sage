"""
Seed 2, Layer 3: LP-based decomposition of D_k^m into GL_3 key polynomials.
"""
from sage.all import *

R = PolynomialRing(ZZ, 'q')
q = R.gen()

W = WeylCharacterRing("A2", style="cocharacters")

def schur_spec(lam, max_deg=200):
    """Schur polynomial s_lam at (q, q^2, q^3)."""
    if any(x < 0 for x in lam): return None
    lam_sorted = tuple(sorted(lam, reverse=True))
    try:
        chi = W(lam_sorted)
        result = R(0)
        for wt, mult in chi.weight_multiplicities().items():
            wt_tuple = tuple(wt.to_vector())
            deg = int(wt_tuple[0] + 2*wt_tuple[1] + 3*wt_tuple[2])
            if deg <= max_deg:
                result += mult * q**deg
        return result
    except:
        return None

def demazure_spec(lam, word, max_deg=200):
    """Demazure character at specialization (q, q^2, q^3).
    lam: dominant weight, word: reduced word for w."""
    S = PolynomialRing(ZZ, ['x1', 'x2', 'x3'])
    x1, x2, x3 = S.gens()
    xs = [x1, x2, x3]
    
    f = x1**lam[0] * x2**lam[1] * x3**lam[2]
    
    for si in word:
        i = si - 1
        swap = {xs[i]: xs[i+1], xs[i+1]: xs[i]}
        sf = f.subs(swap)
        num = xs[i] * f - xs[i+1] * sf
        denom = xs[i] - xs[i+1]
        f = S(num // denom)
    
    result = R(0)
    for coeff, mon in zip(f.coefficients(), f.monomials()):
        degs = mon.degrees()
        deg = degs[0] + 2*degs[1] + 3*degs[2]
        if deg <= max_deg:
            result += ZZ(coeff) * q**deg
    return result

# Build catalogue of ALL key polynomials up to degree 30
print("Building key polynomial catalogue...")
key_catalog = {}

# All 6 Weyl group elements for A2
weyl_elements = [
    ('e', []),
    ('s1', [1]),
    ('s2', [2]),
    ('s1s2', [1, 2]),
    ('s2s1', [2, 1]),
    ('w0', [1, 2, 1])
]

for a in range(12):
    for b in range(a + 1):
        for c in range(b + 1):
            lam = (a, b, c)
            for wname, word in weyl_elements:
                try:
                    if not word:
                        # Identity element: monomial
                        kp = q**(a + 2*b + 3*c)
                    elif wname == 'w0':
                        kp = schur_spec(lam)
                    else:
                        kp = demazure_spec(lam, word)
                    
                    if kp is not None and kp != 0:
                        key_name = (wname, lam)
                        key_catalog[key_name] = kp
                except:
                    pass

print(f"Catalogue size: {len(key_catalog)}")

# D_k^m polynomials for d=4, c=(2,1,1)
D_4 = {}
D_4[(0,0)] = R(1)
D_4[(0,1)] = 3*q + q**2 + q**3
D_4[(0,2)] = 3*q**2 + 4*q**3 + 5*q**4 + 3*q**5 + 3*q**6 + 2*q**7 + 2*q**8 + q**9 + q**10 + q**12
D_4[(1,1)] = 2*q + q**2 + q**3
D_4[(1,2)] = 3*q**3 + 4*q**4 + 3*q**5 + 3*q**6 + 2*q**7 + 2*q**8 + q**9 + q**10 + q**12
D_4[(2,2)] = q**3 + 3*q**4 + 2*q**5 + 3*q**6 + 2*q**7 + 2*q**8 + q**9 + q**10 + q**12

# D_k^m for d=7, c=(3,2,2)
D_7 = {}
D_7[(0,0)] = R(1)
D_7[(0,1)] = 3*q + 3*q**2 + 2*q**3 + 2*q**4 + q**5 + q**6
D_7[(1,1)] = 2*q + 3*q**2 + 2*q**3 + 2*q**4 + q**5 + q**6
D_7[(0,2)] = 3*q**2 + 6*q**3 + 10*q**4 + 11*q**5 + 13*q**6 + 12*q**7 + 13*q**8 + 10*q**9 + 11*q**10 + 9*q**11 + 9*q**12 + 7*q**13 + 7*q**14 + 5*q**15 + 5*q**16 + 3*q**17 + 3*q**18 + 2*q**19 + 2*q**20 + q**21 + q**22 + q**24
D_7[(1,2)] = 3*q**3 + 8*q**4 + 9*q**5 + 12*q**6 + 11*q**7 + 13*q**8 + 10*q**9 + 11*q**10 + 9*q**11 + 9*q**12 + 7*q**13 + 7*q**14 + 5*q**15 + 5*q**16 + 3*q**17 + 3*q**18 + 2*q**19 + 2*q**20 + q**21 + q**22 + q**24
D_7[(2,2)] = q**3 + 5*q**4 + 7*q**5 + 10*q**6 + 10*q**7 + 12*q**8 + 10*q**9 + 11*q**10 + 9*q**11 + 9*q**12 + 7*q**13 + 7*q**14 + 5*q**15 + 5*q**16 + 3*q**17 + 3*q**18 + 2*q**19 + 2*q**20 + q**21 + q**22 + q**24

# Greedy decomposition
def greedy_decompose(target, catalog, max_deg=30):
    """Try to greedily decompose target into nonneg sum of catalog entries."""
    remaining = target
    decomp = []
    
    while remaining != 0:
        # Find the catalog entry that, when subtracted, leaves largest leading coeff
        best = None
        best_score = -1
        
        for key, kp in catalog.items():
            if kp == 0: continue
            # Check if kp can be subtracted from remaining
            diff = remaining - kp
            # Check if all coefficients of diff are >= 0 up to max_deg
            ok = True
            for i in range(max_deg + 1):
                if diff[i] < 0:
                    ok = False
                    break
            if ok:
                # Score: prefer entries that reduce the highest degree
                score = sum(kp[i] for i in range(max_deg + 1))
                if score > best_score:
                    best = key
                    best_score = score
        
        if best is None:
            break
        
        remaining = remaining - catalog[best]
        decomp.append(best)
    
    return decomp, remaining


# Try decompositions
for label, Dkm_dict in [("d=4", D_4), ("d=7", D_7)]:
    print(f"\n{'='*60}")
    print(f"Key polynomial decomposition for {label}")
    print(f"{'='*60}")
    
    for (k, m), poly in sorted(Dkm_dict.items()):
        print(f"\n  D_{k}^{m}: {poly}")
        print(f"  eval1 = {poly(1)}")
        
        decomp, rem = greedy_decompose(poly, key_catalog)
        
        if rem == 0:
            print(f"  DECOMPOSITION ({len(decomp)} terms):")
            from collections import Counter
            counts = Counter(decomp)
            for key, count in sorted(counts.items()):
                wname, lam = key
                print(f"    {count} x K_{wname}{lam} = {key_catalog[key]}")
        else:
            print(f"  PARTIAL decomposition ({len(decomp)} terms), remainder: {rem}")
            from collections import Counter
            counts = Counter(decomp)
            for key, count in sorted(counts.items()):
                wname, lam = key
                print(f"    {count} x K_{wname}{lam}")
            print(f"  Remainder eval1 = {rem(1)}")

# Also try an exact decomposition using integer linear programming
print("\n\n" + "="*60)
print("ILP decomposition of D_k^m into key polynomials")
print("="*60)

def ilp_decompose(target, catalog, max_deg=30):
    """Use ILP to decompose target into nonneg integer sum of catalog entries."""
    # Filter catalog to entries with max degree <= max_deg of target
    target_max_deg = max(i for i in range(max_deg + 1) if target[i] != 0) if target != 0 else 0
    
    relevant = {}
    for key, kp in catalog.items():
        kp_max = max(i for i in range(max_deg + 1) if kp[i] != 0) if kp != 0 else 0
        if kp_max <= target_max_deg and kp(1) <= target(1):
            relevant[key] = kp
    
    keys_list = list(relevant.keys())
    n_vars = len(keys_list)
    
    if n_vars == 0:
        return None
    
    # Set up ILP: minimize sum of coefficients subject to constraints
    p = MixedIntegerLinearProgram(maximization=False)
    x = p.new_variable(integer=True, nonneg=True)
    
    # Objective: minimize total multiplicity
    p.set_objective(sum(x[i] for i in range(n_vars)))
    
    # Constraint: for each degree d, sum of coefficients = target[d]
    for d in range(target_max_deg + 1):
        target_coeff = target[d]
        p.add_constraint(
            sum(x[i] * relevant[keys_list[i]][d] for i in range(n_vars)) == target_coeff
        )
    
    # Upper bound on each variable
    max_mult = target(1)
    for i in range(n_vars):
        p.add_constraint(x[i] <= max_mult)
    
    try:
        p.solve()
        sol = p.get_values(x)
        decomp = {}
        for i in range(n_vars):
            if sol[i] > 0.5:
                decomp[keys_list[i]] = int(round(sol[i]))
        return decomp
    except:
        return None

for label, Dkm_dict in [("d=4", D_4), ("d=7", D_7)]:
    print(f"\n--- {label} ---")
    for (k, m), poly in sorted(Dkm_dict.items()):
        if poly == 0 or poly == 1: continue
        max_d = max(i for i in range(200) if poly[i] != 0)
        if max_d > 30: 
            print(f"  D_{k}^{m}: skipped (deg={max_d} > 30)")
            continue
        
        print(f"\n  D_{k}^{m}: {poly}  (eval1={poly(1)}, deg={max_d})")
        result = ilp_decompose(poly, key_catalog, max_d)
        if result is not None:
            print(f"  ILP decomposition ({sum(result.values())} terms):")
            for key, count in sorted(result.items()):
                wname, lam = key
                print(f"    {count} x K_{wname}{lam} = {key_catalog[key]}")
            # Verify
            total = R(0)
            for key, count in result.items():
                total += count * key_catalog[key]
            if total == poly:
                print(f"  VERIFIED: decomposition is correct")
            else:
                print(f"  ERROR: decomposition does not match!")
                print(f"  Diff: {poly - total}")
        else:
            print(f"  No ILP decomposition found")
