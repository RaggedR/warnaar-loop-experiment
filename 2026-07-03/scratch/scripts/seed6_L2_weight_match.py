#!/usr/bin/env python3
"""
Seed 6, Layer 2: Try to match Q_1 coefficients to orbit weights.

Key observation: for c=(3,1,0) d=4:
  Orbits (excluding orbit 0 = {(4,0,0),(0,4,0),(0,0,4)}):
    Orbit 1: min c.x = 1
    Orbit 2: min c.x = 2  
    Orbit 3: min c.x = 3
    Orbit 4: min c.x = 4
  Q_1 = q + q^2 + q^3 + q^5
  
  min c.x values = [1, 2, 3, 4], but Q_1 has weights [1, 2, 3, 5].
  
  Close but not quite! The last one is off by 1.
  
  What if we subtract the minimum c.x across ALL triples? 
  For c=(3,1,0): min over all (a,b,c) of 3a+b+0c with a+b+c=4 is 0 (at (0,0,4)).
  Orbit 0 min c.x = 0. So we subtract 0. Still doesn't match.
  
  What if we use max(c.x) - d? For orbit 0: max = 12, 12-4=8.
  
  Try another function of the orbit.
"""

from fractions import Fraction
from itertools import combinations

def all_compositions(d, k=3):
    if k == 1:
        yield (d,)
        return
    for i in range(d+1):
        for rest in all_compositions(d - i, k - 1):
            yield (i,) + rest

def shifted_profile(c, J):
    k = len(c)
    result = list(c)
    for i in range(k):
        prev = (i - 1) % k
        if i in J and prev not in J:
            result[i] = c[i] - 1
        elif i not in J and prev in J:
            result[i] = c[i] + 1
    return tuple(result)

def get_I_c(c):
    return frozenset(i for i, ci in enumerate(c) if ci > 0)

def nonempty_subsets(S):
    S = list(S)
    for r in range(1, len(S) + 1):
        for combo in combinations(S, r):
            yield frozenset(combo)

def solve_system_iterative(d, max_n, q_bound):
    compositions = list(all_compositions(d))
    comp_to_idx = {c: i for i, c in enumerate(compositions)}
    N = len(compositions)
    system = {}
    for c in compositions:
        I_c = get_I_c(c)
        for J in nonempty_subsets(I_c):
            c_J = shifted_profile(c, J)
            j_size = len(J)
            sign = (-1)**(j_size - 1)
            key = (comp_to_idx[c], comp_to_idx[c_J])
            if key not in system:
                system[key] = {}
            system[key][j_size] = system[key].get(j_size, 0) + sign
    all_F = {}
    F_prev = [{0: Fraction(1)} for _ in range(N)]
    for i, c in enumerate(compositions):
        all_F[(c, 0)] = {0: Fraction(1)}
    for n in range(1, max_n + 1):
        A = [[{} for _ in range(N)] for _ in range(N)]
        for (row, col), coeffs in system.items():
            for j_size, coeff in coeffs.items():
                power = n * j_size
                if power <= q_bound:
                    A[row][col][power] = A[row][col].get(power, 0) + coeff
        x = [dict(b) for b in F_prev]
        correction = [dict(b) for b in F_prev]
        for iteration in range(q_bound // n + 2):
            new_correction = [{} for _ in range(N)]
            any_nonzero = False
            for i in range(N):
                for j in range(N):
                    if not A[i][j]: continue
                    for da, ca in A[i][j].items():
                        if ca == 0: continue
                        for db, cb in correction[j].items():
                            dd = da + db
                            if dd <= q_bound:
                                new_correction[i][dd] = new_correction[i].get(dd, Fraction(0)) + Fraction(ca) * cb
                                any_nonzero = True
            if not any_nonzero: break
            for i in range(N):
                new_correction[i] = {k: v for k, v in new_correction[i].items() if v != 0}
            for i in range(N):
                for k, v in new_correction[i].items():
                    x[i][k] = x[i].get(k, Fraction(0)) + v
            correction = new_correction
        for i in range(N):
            x[i] = {k: v for k, v in x[i].items() if v != 0}
        F_prev = x
        for i, c in enumerate(compositions):
            all_F[(c, n)] = dict(x[i])
    return compositions, all_F

def compute_Q(c, n, all_F, q_bound):
    f = {}
    for m in range(n + 1):
        fm = dict(all_F.get((c, m), {}))
        if m > 0:
            for k, v in all_F.get((c, m-1), {}).items():
                fm[k] = fm.get(k, Fraction(0)) - v
        fm = {k: v for k, v in fm.items() if v != 0}
        f[m] = fm
    def q_poch_inv(j, qb):
        result = {0: Fraction(1)}
        for s in range(1, j+1):
            new_result = {}
            for deg in range(qb+1):
                val = Fraction(0)
                k = 0
                while deg - k*s >= 0:
                    val += result.get(deg - k*s, Fraction(0))
                    k += 1
                if val != 0:
                    new_result[deg] = val
            result = new_result
        return result
    z_n = {}
    for j in range(n + 1):
        sign = (-1)**j
        shift = j*(j+1)//2
        inv_j = q_poch_inv(j, q_bound - shift) if shift <= q_bound else {}
        for da, ca in inv_j.items():
            if da + shift > q_bound: continue
            for db, cb in f[n-j].items():
                dd = da + shift + db
                if dd <= q_bound:
                    z_n[dd] = z_n.get(dd, Fraction(0)) + sign * ca * cb
    z_n = {k: v for k, v in z_n.items() if v != 0}
    qq_n = {0: Fraction(1)}
    for i in range(1, n+1):
        new = {}
        for k, v in qq_n.items():
            new[k] = new.get(k, Fraction(0)) + v
            if k + i <= q_bound:
                new[k+i] = new.get(k+i, Fraction(0)) - v
        qq_n = {k: v for k, v in new.items() if v != 0}
    Q_n = {}
    for da, ca in qq_n.items():
        for db, cb in z_n.items():
            dd = da + db
            if dd <= q_bound:
                Q_n[dd] = Q_n.get(dd, Fraction(0)) + ca * cb
    Q_n = {k: v for k, v in Q_n.items() if v != 0}
    return Q_n

def get_orbits(d):
    triples = [(a, b, d-a-b) for a in range(d+1) for b in range(d-a+1)]
    orbits = []
    seen = set()
    for t in triples:
        if t in seen: continue
        orbit = set()
        current = t
        for _ in range(3):
            orbit.add(current)
            current = (current[1], current[2], current[0])
        orbits.append(frozenset(orbit))
        seen.update(orbit)
    return orbits

def try_weight_functions(d, profiles, q_bound=30):
    """Try many weight functions to match Q_1."""
    orbits = get_orbits(d)
    
    # Remove the "trivial" orbit containing (d,0,0)
    trivial_idx = None
    for i, orbit in enumerate(orbits):
        if (d, 0, 0) in orbit:
            trivial_idx = i
            break
    
    nontrivial = [o for i, o in enumerate(orbits) if i != trivial_idx]
    
    for c_profile in profiles:
        compositions, all_F = solve_system_iterative(d, 1, q_bound)
        Q1 = compute_Q(c_profile, 1, all_F, q_bound)
        Q1_coeffs = {int(k): int(v) for k, v in Q1.items() if v != 0}
        
        print(f"\nc={c_profile}, Q_1 = {dict(sorted(Q1_coeffs.items()))}")
        
        c0, c1, c2 = c_profile
        
        # Try many candidate weight functions
        candidates = {}
        
        for orbit in nontrivial:
            reps = sorted(orbit)
            
            # Various weight functions (all C_3-invariant by construction since we min/max/sum):
            weights = {}
            
            # 1. min c.x
            weights['min_cx'] = min(c0*a + c1*b + c2*e for (a,b,e) in orbit)
            
            # 2. max c.x - d
            weights['max_cx_minus_d'] = max(c0*a + c1*b + c2*e for (a,b,e) in orbit) - d
            
            # 3. median c.x (or sorted middle value)
            cx_vals = sorted(c0*a + c1*b + c2*e for (a,b,e) in orbit)
            if len(cx_vals) == 3:
                weights['mid_cx'] = cx_vals[1]
            else:
                weights['mid_cx'] = cx_vals[len(cx_vals)//2]
            
            # 4. min of (c_0*(b+e) + c_1*(a+e) + c_2*(a+b)) / something
            # Note a+b+c = d, so b+e = d-a, etc.
            
            # 5. sum of abs(a-b) + abs(b-e) + abs(e-a) over orbit / 6
            # (C3-invariant since we sum over orbit)
            
            # 6. min of |a-b| + |b-e| + |e-a| (this IS C3-invariant for each triple)
            weights['min_l1'] = min(abs(a-b) + abs(b-e) + abs(e-a) for (a,b,e) in orbit) // 2
            
            # 7. min of max(a,b,e) - min(a,b,e) 
            weights['min_spread'] = min(max(t) - min(t) for t in orbit)
            
            # 8. interaction: a*b + b*c + c*a (C3-invariant)
            t = list(orbit)[0]
            weights['interaction'] = t[0]*t[1] + t[1]*t[2] + t[2]*t[0]
            
            # 9. d^2 - 3*(a*b + b*c + c*a) = a^2+b^2+c^2 - a*b - b*c - c*a 
            weights['disc'] = (d**2 - 3*weights['interaction'])
            
            # 10. Profile-weighted interaction: c0*b*e + c1*a*e + c2*a*b, take min over orbit
            weights['prof_int_min'] = min(c0*b*e + c1*a*e + c2*a*b for (a,b,e) in orbit)
            
            for name, w in weights.items():
                if name not in candidates:
                    candidates[name] = {}
                candidates[name][w] = candidates[name].get(w, 0) + 1
        
        # Check which candidate matches Q1
        for name, weight_dist in sorted(candidates.items()):
            weight_dist_clean = dict(sorted(weight_dist.items()))
            if weight_dist_clean == Q1_coeffs:
                print(f"  MATCH: weight function '{name}' matches Q_1!")
            # Also check shifted versions
            for shift in range(-5, 6):
                shifted = {k + shift: v for k, v in weight_dist.items()}
                if shifted == Q1_coeffs:
                    print(f"  MATCH: weight function '{name}' + {shift} matches Q_1!")
            # And scaled
            for scale in [2, 3, Fraction(1,2), Fraction(1,3)]:
                scaled = {}
                all_int = True
                for k, v in weight_dist.items():
                    sk = k * scale
                    if isinstance(sk, Fraction) and sk.denominator != 1:
                        all_int = False
                        break
                    scaled[int(sk)] = v
                if all_int and scaled == Q1_coeffs:
                    print(f"  MATCH: weight function '{name}' * {scale} matches Q_1!")
        
        # Print all candidates for manual inspection
        print(f"  Weight distributions:")
        for name, weight_dist in sorted(candidates.items()):
            print(f"    {name}: {dict(sorted(weight_dist.items()))}")

def main():
    print("=" * 70)
    print("WEIGHT FUNCTION MATCHING")
    print("=" * 70)
    
    try_weight_functions(4, [(2,1,1), (3,1,0), (1,1,2)])
    try_weight_functions(5, [(2,2,1)])
    try_weight_functions(7, [(3,2,2), (4,2,1)])

if __name__ == "__main__":
    main()
