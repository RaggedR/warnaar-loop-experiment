"""
Seed 8, Layer 2: Investigate CW inductive positivity.

The CW system for B_n(c) = F_{c,n}(q):
  B_n(c) = B_{n-1}(c) + sum_J sign(J) * q^{n*|J|} * B_n(c(J))

This is a system of linear equations for {B_n(c)} given {B_{n-1}(c)}.

Key insight: solve the system (I - M_n) * X = rhs where:
- X = vector of B_n(c) for non-zero profiles c
- M_n has entries sign * q^{n*s} (the coupling)
- rhs = B_{n-1}(c) + (contributions from zero profile)

The solution is X = (I - M_n)^{-1} * rhs.

For positivity to propagate: if rhs >= 0 (coefficientwise) and (I-M_n)^{-1}
has nonneg entries (i.e., the Neumann series I + M + M^2 + ... converges
with nonneg terms), then B_n >= 0.

Since M_n has entries with ALTERNATING SIGNS (the sign(J) = (-1)^{|J|-1}),
(I-M_n)^{-1} does NOT have all nonneg entries in general.

BUT: the q^{n*s} shift means that at each "degree level", only a finite
number of coupling terms contribute. Let's investigate the sign structure.

ALSO: Let's look at how Q_n relates to B_n directly. We have:
  Q_n = (q;q)_n * [z^n]((zq;q)_inf * sum_m b_m z^m)
      = sum_j (-1)^j q^{T_j} (q^{j+1};q)_{n-j} * b_{n-j}

Each b_{n-j} is computed from the CW system. Can we express Q_n 
entirely in terms of B values?
"""

from itertools import combinations
from math import gcd
from collections import defaultdict

MAX_Q = 60


def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_sub(a, b):
    return poly_add(a, {k: -v for k, v in b.items()})

def poly_mul(a, b, max_deg=MAX_Q):
    result = {}
    for i, ai in a.items():
        if ai == 0 or i > max_deg: continue
        for j, bj in b.items():
            if bj == 0 or i+j > max_deg: continue
            result[i+j] = result.get(i+j, 0) + ai * bj
    return {k: v for k, v in result.items() if v != 0}

def poly_shift(p, s, max_deg=MAX_Q):
    return {k+s: v for k, v in p.items() if k+s <= max_deg}

def poly_scale(p, s):
    if s == 0: return {}
    return {k: v*s for k, v in p.items()}

def poly_str(p, max_terms=15):
    if not p: return "0"
    parts = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0: continue
        if e == 0: parts.append(str(c))
        elif c == 1: parts.append(f"q^{e}")
        elif c == -1: parts.append(f"-q^{e}")
        else: parts.append(f"{c}q^{e}")
    if len(parts) > max_terms:
        return " + ".join(parts[:max_terms]).replace("+ -", "- ") + f" + ..."
    return " + ".join(parts).replace("+ -", "- ") if parts else "0"

def enumerate_profiles(d, k):
    if k == 1:
        yield (d,)
        return
    for i in range(d+1):
        for rest in enumerate_profiles(d-i, k-1):
            yield (i,) + rest

def compute_cJ(c, J):
    k = len(c)
    J_set = set(J)
    c_J = list(c)
    for i in range(k):
        i_prev = (i - 1) % k
        if i in J_set and i_prev not in J_set:
            c_J[i] -= 1
        elif i not in J_set and i_prev in J_set:
            c_J[i] += 1
    return tuple(c_J)

def build_CW_system(c, k=3):
    I_c = [i for i in range(k) if c[i] > 0]
    if not I_c: return []
    terms = []
    for size in range(1, len(I_c)+1):
        for J in combinations(I_c, size):
            c_J = compute_cJ(c, J)
            if any(x < 0 for x in c_J): continue
            sign = (-1) ** (size - 1)
            terms.append((sign, size, c_J))
    return terms


def main():
    # Focus on d=4 first (the simplest unproved case that was later proved)
    d = 4
    k = 3
    profile = (2, 1, 1)
    
    print(f"CW System Structure for d={d}")
    print("="*60)
    
    all_profiles = list(enumerate_profiles(d, k))
    zero_profile = (0, 0, 0)
    non_zero = [p for p in all_profiles if p != zero_profile]
    
    # Build and display the CW system
    print(f"\nNumber of profiles: {len(all_profiles)} ({len(non_zero)} non-zero)")
    
    cw_system = {}
    for p in non_zero:
        cw_system[p] = build_CW_system(p, k)
    
    # Group profiles by their CW structure
    print("\nCW recurrence for each profile:")
    for p in sorted(non_zero):
        terms = cw_system[p]
        pos_terms = [(s, t) for sign, s, t in terms if sign > 0]
        neg_terms = [(s, t) for sign, s, t in terms if sign < 0]
        print(f"\n  {p}:")
        for s, t in pos_terms:
            marker = " [SELF]" if t == p else (" [ZERO]" if t == zero_profile else "")
            print(f"    + q^{{n*{s}}} * B_n({t}){marker}")
        for s, t in neg_terms:
            marker = " [SELF]" if t == p else (" [ZERO]" if t == zero_profile else "")
            print(f"    - q^{{n*{s}}} * B_n({t}){marker}")
    
    # Count self-loops and zero-profile references
    print(f"\nCoupling structure:")
    for p in sorted(non_zero):
        terms = cw_system[p]
        self_refs = [(sign, s) for sign, s, t in terms if t == p]
        zero_refs = [(sign, s) for sign, s, t in terms if t == zero_profile]
        other_refs = [(sign, s, t) for sign, s, t in terms if t != p and t != zero_profile]
        print(f"  {p}: self={len(self_refs)}, zero={len(zero_refs)}, other={len(other_refs)}")
    
    # KEY QUESTION: For the specific profile (2,1,1), what is the "effective" 
    # recursion after substitution?
    # 
    # B_n(c) = B_{n-1}(c) + sum_J sign * q^{ns} * B_n(c(J))
    #
    # After iterating, we get B_n(c) = (I - M_n)^{-1} * rhs.
    # The Neumann series is B_n = rhs + M*rhs + M^2*rhs + ...
    # where each M application shifts by q^n or more.
    # 
    # So the first few "layers" of the Neumann series are:
    # Layer 0: B_{n-1}(c) + zero-profile contributions (manifestly nonneg)
    # Layer 1: M * (layer 0), shifted by q^n
    # Layer 2: M^2 * (layer 0), shifted by q^{2n}
    # etc.
    
    # The sign of each layer depends on the sign structure of M.
    # For d=4, profile (2,1,1):
    # Let's trace through the Neumann series explicitly for small n.
    
    print("\n\nNeumann series analysis for c=(2,1,1), n=1:")
    
    # For n=1, the coupling involves q^1 and q^2 shifts.
    # The matrix M has entries like sign * q^{|J|} (since n=1).
    # Let's build M explicitly as a polynomial matrix.
    
    n = 1
    print(f"\nCoupling matrix M (at n={n}):")
    for p in sorted(non_zero):
        terms = cw_system.get(p, [])
        for sign, s, target in terms:
            if target != zero_profile and target != p:
                shift = n * s
                print(f"  M[{p}][{target}] += {'+' if sign > 0 else '-'}q^{shift}")
    
    # Now for d=7
    print("\n\n" + "="*60)
    print(f"CW System Structure for d=7, c=(3,2,2)")
    print("="*60)
    
    d = 7
    profile7 = (3, 2, 2)
    all_profiles7 = list(enumerate_profiles(d, k))
    non_zero7 = [p for p in all_profiles7 if p != zero_profile]
    
    print(f"\nNumber of profiles: {len(all_profiles7)} ({len(non_zero7)} non-zero)")
    
    terms7 = build_CW_system(profile7, k)
    print(f"\nCW terms for (3,2,2):")
    for sign, s, target in terms7:
        marker = " [ZERO]" if target == zero_profile else ""
        print(f"  {'+'if sign>0 else '-'} q^{{n*{s}}} * B_n({target}){marker}")
    
    # Connection E analysis: the (d+1)(d+2)/6 number
    print("\n\n" + "="*60)
    print("Connection E: Triple meaning of (d+1)(d+2)/6")
    print("="*60)
    
    for d in [2, 4, 5, 7, 8]:
        if d % 3 == 0: continue
        num = (d+1)*(d+2)//6
        
        # Meaning 1: # C_3 orbits of level-d weights for sl_3
        orbits = []
        seen = set()
        for a in range(d+1):
            for b in range(d+1-a):
                c = d - a - b
                w = (a,b,c)
                if w in seen: continue
                orbit = set()
                orbit.add(w)
                orbit.add((b,c,a))
                orbit.add((c,a,b))
                seen.update(orbit)
                orbits.append(orbit)
        
        # Meaning 2: lattice points in the cone (Seed 7's binary cylindric partitions)
        # For max=1 cylindric partitions with profile c, the valid triples (a_0,a_1,a_2)
        # are those satisfying certain interlacing conditions.
        # The count of nonneg integer solutions is related to the 
        # "dilated simplex" count.
        
        # Meaning 3: h_m(1)^{1/m} evaluation
        # h_m(1) = num^m, so h_1(1) = num.
        # h_1(q) = (1-q) * g_1(q), where g_1 = [y^1] F_c(y,q).
        # g_1(q) counts cylindric partitions with max=1 by total weight.
        # (1-q) * g_1(q) = h_1(q) has evaluation num at q=1.
        
        # The connection: the stable coefficient of g_1 is num.
        # g_1(q) ~ num / (1-q) for large degrees.
        # This means: # cylindric partitions with max=1 and total weight = w
        # converges to num as w -> infinity.
        
        # WHY? Because the asymptotic count of cylindric partitions with max=1
        # is determined by the lattice point count of the fundamental domain.
        
        print(f"\nd = {d}:")
        print(f"  (d+1)(d+2)/6 = {num}")
        print(f"  # C_3 orbits = {len(orbits)}")
        print(f"  # orbits with |orbit|=1 (fixed points): {sum(1 for o in orbits if len(o)==1)}")
        print(f"  # orbits with |orbit|=3: {sum(1 for o in orbits if len(o)==3)}")
        
        # The lattice point interpretation:
        # The "fundamental polytope" for binary (max=1) cylindric partitions
        # of profile c = (c_0,c_1,c_2) is the set of (a_0,a_1,a_2) in Z_>=0^3
        # satisfying:
        #   a_{i+1} <= a_i + c_{i+1}  (cyclic interlacing with shift c_{i+1})
        #
        # For profile (c_0,c_1,c_2), the constraints are:
        #   a_1 <= a_0 + c_1
        #   a_2 <= a_1 + c_2 
        #   a_0 <= a_2 + c_0
        #
        # Adding: a_0 + a_1 + a_2 <= a_0 + a_1 + a_2 + d. Always true for d >= 0.
        # So the constraint polytope is a 3D cone (unbounded).
        
        # The count of lattice points at "level" w (a_0+a_1+a_2 = w) is
        # the coefficient of q^w in g_1(q) (for the right profile).
        # The asymptotic count as w -> inf is the "width" of the polytope
        # at that level, which equals... let me compute.
        
        # For the profile (d-2, 1, 1) (or any specific profile with d = c_0+c_1+c_2):
        # constraints: a_1 <= a_0+1, a_2 <= a_1+1, a_0 <= a_2+d-2
        # => a_0 <= a_2+d-2 <= a_1+d-1 <= a_0+d
        # So as w = a_0+a_1+a_2 -> inf, we need to count solutions.
        
        # For SYMMETRIC profile c = (d/3, d/3, d/3) (when d div by 3):
        # constraints become a_{i+1} <= a_i + d/3 for all i (cyclic).
        # This is maximally symmetric and gives (d+1)(d+2)/6 as the natural count.
        
        # For NON-symmetric profiles, the asymptotic count is the SAME 
        # (it's profile-independent!). This is because the polytope volume
        # depends only on d, not on how d is partitioned.
        
        # PROOF SKETCH: The volume of the polytope slice at level w
        # is 1/2 * (area of the triangle defined by the constraints).
        # The constraints form a triangle in the (a_0, a_1) plane
        # (with a_2 = w - a_0 - a_1). The area is proportional to
        # (c_0 + c_1 + c_2)^2 / 2 = d^2 / 2, divided by... 
        # Actually let me just compute it.
        
        # For specific profile, count lattice points at level w
        if d <= 8:
            # Use profile = (d-2, 1, 1) for testing
            c = (d-2, 1, 1) if d >= 2 else (d, 0, 0)
            counts = {}
            for w in range(20):
                count = 0
                for a0 in range(w+1):
                    for a1 in range(w+1-a0):
                        a2 = w - a0 - a1
                        if a1 <= a0 + c[1] and a2 <= a1 + c[2] and a0 <= a2 + c[0]:
                            count += 1
                counts[w] = count
            
            asymptotic = num
            print(f"  Lattice point counts for c={c}: " + 
                  " ".join(f"{counts[w]}" for w in range(15)))
            print(f"  Asymptotic: {asymptotic}")
            print(f"  Differences: " + 
                  " ".join(f"{counts[w]-counts[w-1]}" for w in range(1, 15)))
    
    # The lattice point count stabilizes to (d+1)(d+2)/6 for large enough w.
    # This is the "stable coefficient" of g_1.
    
    # Now the KEY CONNECTION:
    # h_1(q) = (1-q) * g_1(q) has evaluation h_1(1) = (d+1)(d+2)/6.
    # g_1(q) = sum_w (# lattice points at level w) * q^w
    # (1-q) * g_1(q) = g_1(q) - q*g_1(q) = sum_w (count_w - count_{w-1}) * q^w
    #
    # So h_1(q) = sum_w Delta(w) * q^w where Delta(w) = count_w - count_{w-1}.
    # For large w, Delta(w) stabilizes to the asymptotic value.
    # Since count_w is eventually linear in w with slope 0 (constant!),
    # Delta(w) stabilizes to 0 for large w, and h_1(q) is a polynomial.
    
    # WAIT: count_w is NOT constant. Let me recheck.
    # For c=(2,1,1), d=4: counts are 1, 4, 5, 5, 5, 5, ...
    # No! Let me compute again:
    
    print("\n\nDetailed lattice point analysis:")
    for d, c in [(4, (2,1,1)), (7, (3,2,2)), (7, (4,2,1))]:
        counts = []
        for w in range(25):
            count = 0
            for a0 in range(w+1):
                for a1 in range(w+1-a0):
                    a2 = w - a0 - a1
                    if a1 <= a0 + c[1] and a2 <= a1 + c[2] and a0 <= a2 + c[0]:
                        count += 1
            counts.append(count)
        print(f"\n  d={d}, c={c}:")
        print(f"    counts: {counts}")
        diffs = [counts[w] - counts[w-1] for w in range(1, len(counts))]
        print(f"    diffs:  {diffs}")
        diffs2 = [diffs[w] - diffs[w-1] for w in range(1, len(diffs))]
        print(f"    diffs2: {diffs2}")


if __name__ == "__main__":
    main()
