#!/usr/bin/env python3
"""
Seed 6, Layer 2: Combinatorial interpretation of Q_{n,c}(q).

Q_{n,c}(1) = B^n where B = (d+1)(d+2)/6 - 1.
This suggests Q_{n,c}(q) counts n-tuples of B objects, weighted by q.

Key insight from synthesis: B counts nontrivial C_3-orbits of sl_3 level-d 
dominant weights. So the objects are orbits of the form {(a,b,c) with a+b+c=d}
under some symmetry, minus the trivial orbit.

Let's identify these objects and their q-weights from the data.
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
    """Same as in cw_system.py"""
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
                    if not A[i][j]:
                        continue
                    for da, ca in A[i][j].items():
                        if ca == 0:
                            continue
                        for db, cb in correction[j].items():
                            dd = da + db
                            if dd <= q_bound:
                                new_correction[i][dd] = new_correction[i].get(dd, Fraction(0)) + Fraction(ca) * cb
                                any_nonzero = True
            if not any_nonzero:
                break
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
            if da + shift > q_bound:
                continue
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

def analyze_Q1_objects(d, c, Q1):
    """
    Q_1(q) = sum of B terms. Each term is a q-weight for one of B objects.
    Identify these objects.
    
    The number B = (d+1)(d+2)/6 - 1.
    B+1 = (d+1)(d+2)/6 counts something. 
    
    Seed 8's insight: B counts nontrivial C_3-orbits of sl_3 level-d dominant weights.
    sl_3 dominant weights at level d: triples (a,b) with a+b <= d, a,b >= 0.
    (equivalently, (a,b,c) with a+b+c = d, a,b,c >= 0)
    C_3 acts by cyclic permutation: (a,b,c) -> (b,c,a) -> (c,a,b).
    Total number of triples: (d+2 choose 2) = (d+1)(d+2)/2.
    Number of orbits: (d+1)(d+2)/6 when d not equiv 0 mod 3.
    (When d equiv 0 mod 3, there are fixed points, changing the orbit count.)
    
    So Q_{1,c}(1) = number of orbits - 1.
    The "-1" removes the orbit {(d,0,0), (0,d,0), (0,0,d)}.
    Wait, that orbit has 3 elements. Is there a special orbit?
    
    Actually, let me check: which orbit is removed?
    """
    # Enumerate C_3-orbits of triples (a,b,c) with a+b+c=d
    triples = [(a, b, d-a-b) for a in range(d+1) for b in range(d-a+1)]
    orbits = []
    seen = set()
    for t in triples:
        if t in seen:
            continue
        orbit = set()
        current = t
        for _ in range(3):
            orbit.add(current)
            current = (current[1], current[2], current[0])
        orbits.append(frozenset(orbit))
        seen.update(orbit)
    
    print(f"\n  Total triples: {len(triples)}, C_3-orbits: {len(orbits)}")
    print(f"  B+1 = {(d+1)*(d+2)//6}, B = {(d+1)*(d+2)//6 - 1}")
    
    # For each orbit, compute a natural q-weight
    # Candidate 1: minimum element in lex order, weighted by some statistic
    # Candidate 2: sum of the "excess" in each coordinate
    
    # Let's look at Q_1 coefficients and try to match
    Q1_coeffs = {}
    for deg in sorted(Q1.keys()):
        v = int(Q1[deg])
        if v > 0:
            Q1_coeffs[deg] = v
    
    print(f"  Q_1 coefficients: {Q1_coeffs}")
    print(f"  Q_1(1) = {sum(Q1_coeffs.values())}")
    
    # Try various weight functions on orbits
    # Weight 1: min element lex, weight = sum of triple
    # But all triples have sum = d, so that gives q^d for everything. Not useful.
    
    # Weight 2: For an orbit {(a,b,c), (b,c,a), (c,a,b)}, 
    # define w = max(a,b,c) - min(a,b,c)  (the "spread")
    # or w = a*b + b*c + c*a (the "interaction")
    # or w = a^2 + b^2 + c^2 (the "energy")

    def orbit_weight_spread(orbit):
        t = list(orbit)[0]
        return max(t) - min(t)
    
    def orbit_weight_energy(orbit):
        t = list(orbit)[0]
        return t[0]**2 + t[1]**2 + t[2]**2
    
    def orbit_weight_interaction(orbit):
        t = list(orbit)[0]
        return t[0]*t[1] + t[1]*t[2] + t[2]*t[0]
    
    # Check orbit-independence: all elements in an orbit should give same weight
    # for C_3-invariant functions
    for wf_name, wf in [("spread", orbit_weight_spread), 
                         ("energy", orbit_weight_energy),
                         ("interaction", orbit_weight_interaction)]:
        weights = {}
        for orbit in orbits:
            # Check invariance
            vals = set()
            for t in orbit:
                if wf_name == "spread":
                    vals.add(max(t) - min(t))
                elif wf_name == "energy":
                    vals.add(t[0]**2 + t[1]**2 + t[2]**2)
                elif wf_name == "interaction":
                    vals.add(t[0]*t[1] + t[1]*t[2] + t[2]*t[0])
            assert len(vals) == 1, f"Weight {wf_name} not orbit-invariant: {orbit} -> {vals}"
            w = vals.pop()
            weights[w] = weights.get(w, 0) + 1
        
        print(f"  Weight function '{wf_name}': {dict(sorted(weights.items()))}")
    
    # Now try profile-DEPENDENT weights.
    # The key: Q_{1,c}(q) DEPENDS on the profile c. So the weight function
    # must depend on c. 
    # 
    # For the orbit {(a,b,c_triple)}, the weight could be:
    # w = c_0 * a + c_1 * b + c_2 * c_triple (linear in the profile)
    # But this is NOT C_3-invariant in (a,b,c_triple) unless c is constant.
    # However, we could take the MINIMUM or SUM over the orbit.
    
    # Try: for orbit O = {(a,b,e), (b,e,a), (e,a,b)},
    # w(O, c) = min over (a',b',e') in O of (c_0*a' + c_1*b' + c_2*e')
    
    def orbit_weight_profile_min(orbit, profile):
        c0, c1, c2 = profile
        return min(c0*a + c1*b + c2*e for (a,b,e) in orbit)
    
    def orbit_weight_profile_max(orbit, profile):
        c0, c1, c2 = profile
        return max(c0*a + c1*b + c2*e for (a,b,e) in orbit)
    
    # Try: f(a,b,c_triple) = a*c_1 + b*c_2 + c_triple*c_0 (shifted to match the 
    # interlacing structure). Or maybe related to the "distance" in the cylindric
    # partition lattice.
    
    # Actually, let me try: w = sum of (c_i - min over orbit of position-i value)
    # or more simply, try to match the data.
    
    # For c = (2,1,1), d=4:
    # Q_1 = 2q + q^2 + q^3. Total = 4.
    # 4 orbits total, minus 1 = 3. Wait, B = 4. So 5 orbits, 4 nontrivial.
    
    # List orbits for d=4:
    if d == 4:
        print(f"\n  Orbits for d={d}:")
        for i, orbit in enumerate(orbits):
            members = sorted(orbit)
            print(f"    Orbit {i}: {members}")
        
        # For c = (2,1,1):
        # Q_1 = 2q + q^2 + q^3
        # We need to assign q-weights 1, 1, 2, 3 to 4 orbits.
        # (Two orbits get weight 1, one gets weight 2, one gets weight 3.)
        
        # The "trivial" orbit to remove is presumably {(4,0,0),(0,4,0),(0,0,4)}
        # which has spread 4 and energy 16.
        
        # Remaining orbits and their profile-dependent linear forms:
        for i, orbit in enumerate(orbits):
            members = sorted(orbit)
            # Profile (2,1,1): compute c_0*a + c_1*b + c_2*c for each member
            lf_vals = [c[0]*m[0] + c[1]*m[1] + c[2]*m[2] for m in members]
            print(f"    Orbit {i}: {members}, linear forms c.x = {lf_vals}, min={min(lf_vals)}")
    
    if d == 7:
        print(f"\n  Orbits for d={d}:")
        for i, orbit in enumerate(orbits):
            members = sorted(orbit)
            lf_vals = [c[0]*m[0] + c[1]*m[1] + c[2]*m[2] for m in members]
            print(f"    Orbit {i}: {members}, c.x = {sorted(set(lf_vals))}, min={min(lf_vals)}")

def main():
    q_bound = 30

    for d, test_c in [(4, (2,1,1)), (4, (3,1,0)), (5, (2,2,1)), (7, (3,2,2)), (7, (4,2,1))]:
        print("=" * 70)
        print(f"d={d}, c={test_c}")
        print("=" * 70)

        compositions, all_F = solve_system_iterative(d, 1, q_bound)
        Q1 = compute_Q(test_c, 1, all_F, q_bound)
        analyze_Q1_objects(d, test_c, Q1)

if __name__ == "__main__":
    main()
