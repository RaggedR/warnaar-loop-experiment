"""
Seed 3, Layer 2: Investigating whether Imamura's Upsilon bijection
can be adapted to bounded cylindric partitions.

Key idea: A cylindric partition of profile c=(c0,c1,c2) with k=3 and
circumference t=3+d can be viewed as a periodic configuration on
Z/tZ x N. The Sagan-Stanley correspondence maps such a configuration
to a pair of skew tableaux (P, Q).

The Upsilon bijection then maps (P, Q) -> (V, W; kappa, nu) where
V, W are vertically strict tableaux.

We want to understand:
1. How does "max entry <= N" translate under Sagan-Stanley?
2. What does the z^n extraction look like on the (V, W) side?
3. Can we make Q_{n,c} manifestly positive by working on the (V,W) side?
"""

from collections import defaultdict
from math import gcd
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed3_transfer_v4 import compute_F_transfer, compute_Q, poly_to_list


def cp_to_skew_shape(lam0, lam1, lam2, c):
    """
    Convert a cylindric partition (lam0, lam1, lam2) of profile c
    to a skew shape on the cylinder of circumference t = 3 + d.
    
    The cylindric partition lives on k=3 "tracks" arranged around a cylinder.
    Between track i and track i+1, we shift by c_{i+1}.
    
    Convention: track 0 uses rows 0..0 (row 0)
                track 1 uses rows 1..1 (row c1 after shift)
                track 2 uses rows 2..2 (row c1+c2 after shift)
                wrap: track 0 again at row c1+c2+c0 = d (= row t-3)
    
    Actually, the standard construction for cylindric partitions of profile c
    places k partitions at specific "levels" on the cylinder, where level
    separations are given by the c_i values.
    
    For our profile c = (c0, c1, c2), the cylinder has t = k + sum(c) = 3 + d
    "rows" (in the period).
    """
    c0, c1, c2 = c
    d = c0 + c1 + c2
    t = 3 + d
    
    # The skew shape: 
    # At level 0: partition lam0
    # At level 1 (shift c1 from level 0): partition lam1
    # At level 2 (shift c1+c2 from level 0): partition lam2
    # At level 3 (= next period, shift d+3 = t): partition lam0 again
    
    # The interlacing conditions ensure these fit together as a valid
    # skew plane partition on the cylinder.
    
    # For a skew tableaux representation:
    # The "outer" partition lambda has parts lambda_i for i in {0, 1, ..., t-1}
    # The "inner" partition rho has parts rho_i for i in {0, 1, ..., t-1}
    # Both are periodic with period t.
    
    return {
        'profile': c,
        't': t,
        'lam0': lam0,
        'lam1': lam1,
        'lam2': lam2,
    }


def analyze_q1_structure():
    """
    For Q_1: the polynomial Q_{1,c}(q) counts "something" with nonneg coefficients.
    
    Q_1 = [z^1] ((zq;q)_inf * F_c(z,q)) * (q;q)_1
        = (1-q) * [z^1] ((zq;q)_inf * F_c(z,q))
    
    [z^1] F_c(z,q) = g_1(q) = F_{c,1}(q) - F_{c,0}(q) = F_{c,1}(q) - 1
    
    (zq;q)_inf = 1 - zq - z^2 q^3 + z^2 q^3 + ... 
    Actually (zq;q)_inf = sum_m (-1)^m q^{m(m+1)/2} / (q;q)_m * z^m
    
    [z^1] = just the z^1 term = -q/(1-q) * F_{c,0} + 1 * F_{c,1}... no.
    
    Let me be more careful.
    (zq;q)_inf = prod_{i>=1} (1 - zq^i)
    = 1 - z(q + q^2 + q^3 + ...) + z^2(...) - ...
    
    No: (zq;q)_inf = (1-zq)(1-zq^2)(1-zq^3)...
    
    [z^0] = 1
    [z^1] = -(q + q^2 + q^3 + ...) = -q/(1-q)
    [z^2] = sum_{1<=i<j} q^{i+j} = q^3/(1-q)(1-q^2) * ...
    
    Hmm. Let me just compute directly.
    """
    pass


def compute_g_m(c, m, q_max):
    """g_m = [z^m] F_c(z,q) = F_{c,m} - F_{c,m-1}."""
    Fm = compute_F_transfer(c, m, q_max)
    Fm_prev = compute_F_transfer(c, m-1, q_max) if m > 0 else {0: 1}
    
    g = {}
    for k in set(list(Fm.keys()) + list(Fm_prev.keys())):
        val = Fm.get(k, 0) - Fm_prev.get(k, 0)
        if val != 0:
            g[k] = val
    return g


def analyze_crystal_structure():
    """
    The key idea from Seeds 5, 7, 8: Q_{n,c} should be the character of
    some module related to affine Lie algebras at level 3.
    
    For sl_3 at level d, the dominant weights form a simplex with
    (d+1)(d+2)/2 points. Under the C_3 center of SL_3, these break
    into orbits. The number of orbits is (d+1)(d+2)/6 for d not div by 3.
    
    Subtracting 1 for the "trivial" orbit... but wait, for d not div by 3,
    there are no fixed points under C_3, so all orbits have size 3.
    Number of orbits = (d+1)(d+2)/6. But Q_n(1) = ((d+1)(d+2)/6 - 1)^n.
    
    So the "base" is (d+1)(d+2)/6 - 1 = number of C_3 orbits minus 1.
    
    What is subtracted? One orbit. Which one?
    
    The orbit of (0, 0, d) = {(0,0,d), (0,d,0), (d,0,0)}.
    For d not div by 3, this is indeed a full 3-element orbit.
    
    So base = number of NONTRIVIALLY-COMPOSED C_3 orbits?
    Not exactly — the orbit {(0,0,d),(0,d,0),(d,0,0)} is a valid orbit;
    what's special about it?
    
    Hmm. Let's check: for d=2, base = 1. Total C_3 orbits = 2.
    The orbits are: {(0,0,2),(0,2,0),(2,0,0)} and {(1,1,0),(1,0,1),(0,1,1)}.
    Subtracting the first gives 1 orbit. And Q_n = q^{n^2} (one monomial).
    The remaining orbit is {(1,1,0),(1,0,1),(0,1,1)} — these are the profiles!
    
    For d=4, base = 4. Total C_3 orbits = 5.
    Orbits: {(0,0,4),(0,4,0),(4,0,0)}, 
            {(0,1,3),(1,3,0),(3,0,1)},
            {(0,2,2),(2,2,0),(2,0,2)},
            {(0,3,1),(3,1,0),(1,0,3)},
            {(1,1,2),(1,2,1),(2,1,1)}.
    
    So 5 orbits - 1 = 4 = base. The subtracted orbit contains
    (0,0,4) — the "extremal" weights.
    
    For d=5, base = 6. Total orbits = 7.
    The orbit containing (0,0,5) is subtracted: 7 - 1 = 6. Yes.
    
    So: base = (number of C_3 orbits of dominant sl_3 weights at level d) - 1,
    where we subtract the orbit of the "corner" weights {(d,0,0),(0,d,0),(0,0,d)}.
    
    This is clean. What does it mean for Q_{n,c}?
    
    If Q_{n,c}(q) = sum over "interior" C_3 orbits of something^n,
    then Q_n(1) = (base)^n. But Q_n is not just base^n as a polynomial.
    
    Better interpretation: there are BASE many "generators", and Q_n counts
    n-fold products/compositions of these generators with q-weight.
    """
    
    for d in [2, 4, 5, 7, 8]:
        if d % 3 == 0:
            continue
        triples = [(a, b, d-a-b) for a in range(d+1) for b in range(d+1-a)]
        
        # C_3 orbits
        orbits = []
        seen = set()
        for t in triples:
            a, b, c = t
            canon = min((a,b,c), (b,c,a), (c,a,b))
            if canon not in seen:
                seen.add(canon)
                orbit = sorted(set([(a,b,c),(b,c,a),(c,a,b)]))
                orbits.append((canon, orbit))
        
        # Identify the "corner" orbit
        corner = min((0,0,d), (0,d,0), (d,0,0))
        corner_orbit = [o for o in orbits if o[0] == corner]
        interior = [o for o in orbits if o[0] != corner]
        
        # Interior orbits: those where all three entries are > 0
        all_positive = [(canon, orb) for canon, orb in orbits 
                       if all(x > 0 for x in canon)]
        
        base = (d+1)*(d+2)//6 - 1
        print(f"d={d}: {len(orbits)} C3-orbits, {len(interior)} non-corner, "
              f"{len(all_positive)} all-positive, base={base}")
        
        # Is "non-corner" the same as "all-positive"?
        # For d=4: corner = (0,0,4). Interior includes (0,1,3), (0,2,2), etc.
        # (0,1,3) has a zero. So non-corner != all-positive.
        # But base = 4 = number of non-corner orbits.
        
        for canon, orb in orbits:
            marker = " <-- corner" if canon == corner else ""
            positive = all(x > 0 for x in canon)
            print(f"  {canon}: orbit {orb}{marker} {'(all>0)' if positive else ''}")


def investigate_demazure_connection():
    """
    Seed 5 found Q decomposes into Demazure characters K_{(a,b)}(q, q^2).
    
    A Demazure character for sl_r at dominant weight lambda is the character
    of the Demazure module B_w(lambda) for some Weyl group element w.
    
    For sl_2 (r=2), the Demazure character K_{(a,b)}(x1, x2) with a >= b
    is just the Schur function s_{(a-b)}(x1, x2) * (x1 x2)^b.
    
    For sl_3, the Demazure characters are more interesting:
    K_w(lambda)(x1, x2, x3) depends on the Weyl group element w in S_3.
    
    The connection I want to explore: Q_{n,c}(q) as a specialization of
    a Demazure character for the AFFINE sl_3 (or some twisted affine algebra).
    
    In the affine setting, Demazure modules are indexed by (w, Lambda) where
    w is in the affine Weyl group and Lambda is a level-l dominant weight.
    The characters of affine Demazure modules are positive in the weight basis.
    
    If Q_{n,c}(q) = sum of Demazure characters at level 3 of the relevant
    affine algebra, positivity follows.
    
    The "level 3" comes from k = 3 (three partitions in the cylindric partition).
    The modulus t = 3 + d determines the affine algebra.
    
    Key test: does the Demazure character have the right evaluation at q = 1?
    """
    pass


def compute_q_diff_structure():
    """
    Investigate whether Q_n satisfies a q-difference equation in n.
    
    If Q_{n+1} = A(q) * Q_n + B(q) * Q_{n-1} + ...
    with A, B having nonneg coefficients, then positivity of Q_n
    would follow by induction.
    """
    q_max = 100
    
    for c in [(1,1,0), (2,1,1), (2,2,1)]:
        d = sum(c)
        if d % 3 == 0:
            continue
        
        print(f"\nProfile c = {c}, d = {d}")
        
        Qs = []
        for n in range(6):
            Q = compute_Q(c, n, q_max)
            coeffs = poly_to_list(Q)
            while coeffs and coeffs[-1] == 0:
                coeffs.pop()
            Qs.append(coeffs)
            
        # Check if Q_{n+1} / Q_n makes sense (as formal power series)
        # Q_0 = 1, so Q_1/Q_0 = Q_1
        # Q_2/Q_1 = ?
        
        # Better: check if Q_{n+1}(q) = P(q) * Q_n(q) + R(q) for polynomials P, R
        # This would be a first-order recurrence.
        
        # For d=2: Q_n = q^{n^2}. So Q_{n+1}/Q_n = q^{2n+1}. 
        # Q_{n+1} = q^{2n+1} * Q_n. Beautiful!
        
        if d == 2:
            print(f"  d=2: Q_n = q^{{n^2}}")
            print(f"  Q_{{n+1}} = q^{{2n+1}} * Q_n")
            for n in range(5):
                print(f"  Q_{n} = {Qs[n]}")
            continue
        
        # For d > 2, check if Q_{n+1}(q) = f(q,n) * Q_n(q) + ... 
        # Look at degree patterns
        for n in range(1, min(5, len(Qs))):
            deg_n = len(Qs[n]) - 1
            deg_prev = len(Qs[n-1]) - 1 if n > 1 else 0
            print(f"  Q_{n}: deg = {deg_n}, Q(1) = {sum(Qs[n])}")
        
        # Try: Q_{n+1} = sum_j a_j(q) * Q_j for j <= n
        # For Q_1 and Q_2, check if there's a multiplier
        if len(Qs) >= 3 and len(Qs[1]) > 1:
            print(f"\n  Attempting Q_2 = f(q) * Q_1 + g(q):")
            print(f"  Q_1 = {Qs[1][:20]}")
            print(f"  Q_2 = {Qs[2][:20]}")
            # If Q_2 = f*Q_1 + g, then at q=1: Q_2(1) = f(1)*Q_1(1) + g(1)
            # base^2 = f(1)*base + g(1)
            # So g(1) = base^2 - f(1)*base = base(base - f(1))
            # The simplest: f = q^something * (base-1 term), g = ...
            # This is probably not a clean factorization.


def main():
    print("=" * 70)
    print("Crystal structure analysis")
    print("=" * 70)
    analyze_crystal_structure()
    
    print("\n\n" + "=" * 70)
    print("Q_n difference structure")
    print("=" * 70)
    compute_q_diff_structure()
    
    print("\n\n" + "=" * 70)
    print("h_m as character: checking multiplicativity pattern")
    print("=" * 70)
    
    # Seed 1 found h_m(1) = base_h^m where base_h = (d+1)(d+2)/6.
    # If h_m(q) = character of m-fold tensor product, then
    # h_m should factor or have a convolution structure.
    
    q_max = 60
    for c in [(2,1,1), (2,2,1)]:
        d = sum(c)
        print(f"\nProfile c = {c}, d = {d}")
        
        hs = []
        for m in range(1, 5):
            Fm = compute_F_transfer(c, m, q_max)
            Fm_prev = compute_F_transfer(c, m-1, q_max)
            
            g_m = {}
            for k in set(list(Fm.keys()) + list(Fm_prev.keys())):
                val = Fm.get(k, 0) - Fm_prev.get(k, 0)
                if val != 0:
                    g_m[k] = val
            
            # h_m = (q;q)_m * g_m
            qq_m = {0: 1}
            for i in range(1, m + 1):
                new = {}
                for deg, coeff in qq_m.items():
                    new[deg] = new.get(deg, 0) + coeff
                    if deg + i <= q_max:
                        new[deg + i] = new.get(deg + i, 0) - coeff
                qq_m = {k: v for k, v in new.items() if v != 0}
            
            h_m = {}
            for d1, c1 in qq_m.items():
                for d2, c2 in g_m.items():
                    dt = d1 + d2
                    if dt <= q_max:
                        h_m[dt] = h_m.get(dt, 0) + c1 * c2
            h_m = {k: v for k, v in h_m.items() if v != 0}
            
            h_list = poly_to_list(h_m) if h_m else [0]
            while h_list and h_list[-1] == 0:
                h_list.pop()
            hs.append(h_list)
        
        # Check: is h_2 = convolution(h_1, h_1)?
        # Convolution: (h_1 * h_1)[n] = sum_{j} h_1[j] * h_1[n-j]
        h1 = hs[0]
        h2 = hs[1]
        
        conv = [0] * (len(h1) * 2)
        for i in range(len(h1)):
            for j in range(len(h1)):
                if i + j < len(conv):
                    conv[i+j] += h1[i] * h1[j]
        while conv and conv[-1] == 0:
            conv.pop()
        
        print(f"  h_1 = {h1}")
        print(f"  h_2 = {h2}")
        print(f"  h_1 * h_1 (conv) = {conv[:len(h2)]}")
        
        match = h2 == conv[:len(h2)]
        print(f"  h_2 == h_1*h_1? {match}")
        
        if not match:
            diff = [h2[i] - conv[i] if i < len(conv) else h2[i] 
                    for i in range(len(h2))]
            print(f"  h_2 - h_1*h_1 = {diff}")


if __name__ == "__main__":
    main()
