#!/usr/bin/env python3
"""
Seed 6, Layer 2: Exploit D3 symmetry to reduce the CW system.

The CW system couples all compositions c with sum=d.
D3 acts on (c0,c1,c2) by:
  - Cyclic: (c0,c1,c2) -> (c1,c2,c0) -> (c2,c0,c1)
  - Reversal: (c0,c1,c2) -> (c2,c1,c0)

Q_{n,c} is invariant under D3 (verified in Layer 1).
Question: Does the CW SYSTEM respect D3? Can we quotient by it?
"""

from itertools import combinations

def all_compositions(d, k=3):
    if k == 1:
        yield (d,)
        return
    for i in range(d+1):
        for rest in all_compositions(d - i, k - 1):
            yield (i,) + rest

def cyclic_perm(c):
    """(c0,c1,c2) -> (c1,c2,c0)"""
    return (c[1], c[2], c[0])

def reversal(c):
    """(c0,c1,c2) -> (c2,c1,c0)"""
    return (c[2], c[1], c[0])

def d3_orbit(c):
    """Full D3 orbit of c."""
    orbit = set()
    current = c
    for _ in range(3):
        orbit.add(current)
        orbit.add(reversal(current))
        current = cyclic_perm(current)
    return frozenset(orbit)

def canonical_rep(c):
    """Choose canonical representative: lexicographically smallest in D3 orbit."""
    return min(d3_orbit(c))

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

def analyze_symmetry(d):
    compositions = list(all_compositions(d))
    
    # Find D3 orbits
    orbits = {}
    for c in compositions:
        rep = canonical_rep(c)
        if rep not in orbits:
            orbits[rep] = []
        orbits[rep].append(c)
    
    print(f"\nd={d}: {len(compositions)} compositions, {len(orbits)} D3 orbits")
    for rep in sorted(orbits.keys()):
        members = sorted(orbits[rep])
        print(f"  [{rep}]: size {len(members)}, members: {members}")
    
    # Check: does the CW system respect D3?
    # For cyclic permutation sigma: (c0,c1,c2) -> (c1,c2,c0)
    # Does c(J) for sigma(c) equal sigma(c(J')) for some J'?
    
    # The CW recurrence indices are mod k. Cyclic perm shifts all indices.
    # If c' = sigma(c) = (c1,c2,c0), then I_{c'} = {sigma(i) : i in I_c}
    # and for J' = {sigma(j) : j in J}, c'(J') should relate to sigma(c(J)).
    
    # Let's verify this computationally.
    print(f"\n  Checking CW equivariance under cyclic permutation:")
    test_c = [c for c in compositions if all(ci > 0 for ci in c)][:3]
    
    for c in test_c:
        c_cyc = cyclic_perm(c)
        I_c = get_I_c(c)
        for J in nonempty_subsets(I_c):
            c_J = shifted_profile(c, J)
            # Apply cyclic perm to J
            J_cyc = frozenset((j + 1) % 3 for j in J)
            c_cyc_J_cyc = shifted_profile(c_cyc, J_cyc)
            c_J_cyc = cyclic_perm(c_J)
            
            match = (c_cyc_J_cyc == c_J_cyc)
            if not match:
                print(f"    MISMATCH: c={c}, J={set(J)}, c(J)={c_J}")
                print(f"      sigma(c)={c_cyc}, sigma(J)={set(J_cyc)}, sigma(c)(sigma(J))={c_cyc_J_cyc}")
                print(f"      sigma(c(J))={c_J_cyc}")
            
    print(f"    (No mismatches means system is D3-equivariant)")
    
    # Check reversal equivariance
    print(f"\n  Checking CW equivariance under reversal:")
    for c in test_c:
        c_rev = reversal(c)
        I_c = get_I_c(c)
        for J in nonempty_subsets(I_c):
            c_J = shifted_profile(c, J)
            # Under reversal (c0,c1,c2) -> (c2,c1,c0), index i -> (2-i)
            # But the CW formula uses (i-1) mod 3, so reversal sends
            # the cyclic order to the opposite direction.
            # Reversal: index map tau(i) = (k-i) mod k for k=3
            # tau(0)=0, tau(1)=2, tau(2)=1
            tau = {0: 0, 1: 2, 2: 1}
            J_rev = frozenset(tau[j] for j in J)
            
            c_rev_J_rev = shifted_profile(c_rev, J_rev)
            c_J_rev = reversal(c_J)
            
            match = (c_rev_J_rev == c_J_rev)
            if not match:
                print(f"    MISMATCH: c={c}, J={set(J)}, c(J)={c_J}")
                print(f"      rev(c)={c_rev}, rev(J)={set(J_rev)}, rev(c)(rev(J))={c_rev_J_rev}")
                print(f"      rev(c(J))={c_J_rev}")
    
    print(f"    (Reversal check complete)")
    
    return orbits

def compute_reduced_system_size(d):
    """How many unknowns after quotienting by D3?"""
    compositions = list(all_compositions(d))
    orbits = {}
    for c in compositions:
        rep = canonical_rep(c)
        if rep not in orbits:
            orbits[rep] = set()
        orbits[rep].add(c)
    
    # After quotienting, we have one unknown per orbit
    n_original = len(compositions)
    n_reduced = len(orbits)
    reduction = n_original / n_reduced
    
    print(f"\nd={d}: {n_original} -> {n_reduced} unknowns (factor {reduction:.1f} reduction)")
    return n_reduced

def main():
    for d in [2, 4, 5, 7, 8, 10, 11]:
        orbits = analyze_symmetry(d)
        compute_reduced_system_size(d)
    
    # Now let's see what the reduced system looks like for d=7
    print("\n" + "=" * 70)
    print("REDUCED SYSTEM STRUCTURE FOR d=7")
    print("=" * 70)
    
    d = 7
    compositions = list(all_compositions(d))
    
    orbits = {}
    for c in compositions:
        rep = canonical_rep(c)
        if rep not in orbits:
            orbits[rep] = set()
        orbits[rep].add(c)
    
    orbit_reps = sorted(orbits.keys())
    rep_to_idx = {r: i for i, r in enumerate(orbit_reps)}
    
    print(f"\nOrbit representatives ({len(orbit_reps)}):")
    for i, rep in enumerate(orbit_reps):
        print(f"  [{i}] {rep} (orbit size {len(orbits[rep])})")
    
    # Build reduced system: for each orbit, the CW contributions
    # from one representative (summed over D3 action)
    print(f"\nReduced CW transitions:")
    for rep in orbit_reps:
        c = rep  # use canonical rep
        I_c = get_I_c(c)
        transitions = {}
        for J in nonempty_subsets(I_c):
            c_J = shifted_profile(c, J)
            target_rep = canonical_rep(c_J)
            j_size = len(J)
            sign = (-1)**(j_size - 1)
            if target_rep not in transitions:
                transitions[target_rep] = {}
            transitions[target_rep][j_size] = transitions[target_rep].get(j_size, 0) + sign
        
        for target, coeffs in sorted(transitions.items()):
            terms = []
            for j, coeff in sorted(coeffs.items()):
                if coeff != 0:
                    terms.append(f"{'+' if coeff > 0 else ''}{coeff}*q^({j}n)")
            if terms:
                print(f"  F_{rep} -> F_{target}: {', '.join(terms)}")

if __name__ == "__main__":
    main()
