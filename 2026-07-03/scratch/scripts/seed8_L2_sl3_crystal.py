"""
Seed 8, Layer 2: sl_3 weight analysis and Demazure crystal connection.

For sl_3, level-d dominant weights are (a,b,c) with a+b+c = d, a,b,c >= 0.
The number of such weights is (d+1)(d+2)/2.
Under C_3 (cyclic group of order 3) action: (a,b,c) -> (b,c,a),
the number of orbits is (d+1)(d+2)/6 when 3 does not divide d.

Q_{n,c}(1) = ((d+1)(d+2)/6 - 1)^n.

We want to check: can Q_{n,c}(q) be expressed as a character of
some Demazure-type module?
"""

from itertools import combinations
from math import gcd
import sys

def sl3_dominant_weights(d):
    """Level-d dominant weights for sl_3: (a,b,c) with a+b+c=d, a,b,c >= 0."""
    weights = []
    for a in range(d+1):
        for b in range(d+1-a):
            c = d - a - b
            weights.append((a,b,c))
    return weights

def c3_orbits(d):
    """C_3 orbits of level-d dominant weights."""
    weights = sl3_dominant_weights(d)
    seen = set()
    orbits = []
    for w in weights:
        if w in seen:
            continue
        orbit = set()
        a, b, c = w
        orbit.add((a,b,c))
        orbit.add((b,c,a))
        orbit.add((c,a,b))
        orbits.append(sorted(orbit))
        seen.update(orbit)
    return orbits

def main():
    for d in [2, 4, 5, 7, 8, 10, 11]:
        if d % 3 == 0:
            continue
        orbits = c3_orbits(d)
        trivial = [(a,b,c) for a,b,c in sl3_dominant_weights(d) if a == b == c]
        n_orbits = len(orbits)
        n_trivial_orbits = len([o for o in orbits if len(o) == 1])
        n_nontrivial = n_orbits - n_trivial_orbits
        expected = (d+1)*(d+2)//6
        base = expected - 1
        
        print(f"\nd = {d}")
        print(f"  # weights = {len(sl3_dominant_weights(d))} = (d+1)(d+2)/2 = {(d+1)*(d+2)//2}")
        print(f"  # C_3 orbits = {n_orbits}, expected (d+1)(d+2)/6 = {expected}")
        print(f"  # trivial orbits (a=b=c) = {n_trivial_orbits}: {trivial}")
        print(f"  # nontrivial orbits = {n_nontrivial}")
        print(f"  Q(1) base = (d+1)(d+2)/6 - 1 = {base}")
        
        # List orbits by size
        size1 = [o for o in orbits if len(o) == 1]
        size3 = [o for o in orbits if len(o) == 3]
        print(f"  Size-1 orbits: {size1}")
        if len(size3) <= 10:
            print(f"  Size-3 orbits: {size3}")
        else:
            print(f"  Size-3 orbits: {size3[:5]} ... ({len(size3)} total)")
    
    # For d=7: enumerate Demazure characters
    # In sl_3, a Demazure character is associated with a dominant weight lambda
    # and a Weyl group element w. For the identity element, it's just the
    # highest weight monomial. For w_0 (longest element), it's the full character.
    #
    # The character of V(lambda) for sl_3 with lambda = (a,b) (Dynkin labels)
    # in the weight basis is given by the Weyl character formula.
    #
    # For our purposes, we want to see if Q_{n,c}(q) can be decomposed as
    # a sum of Demazure characters at a specific specialization.
    
    print("\n" + "="*80)
    print("Demazure character analysis for d=7")
    print("="*80)
    
    # sl_3 irreps are labeled by (a,b) with a,b >= 0 (Dynkin labels).
    # dim V(a,b) = (a+1)(b+1)(a+b+2)/2
    # Level = a + b (for affine sl_3 at level d, we have a + b <= d)
    
    # For the conjecture, the relevant irreps might be those with a+b <= 7
    # (or exactly 7 depending on interpretation).
    
    # Key polynomial K_{(a,b)}(x_1, x_2) for GL_2:
    # These are Demazure characters for GL_2 = sl_2 + 1.
    # K_{(a,b)}(q, q^2) = sum of q^{stuff} over the Demazure crystal.
    
    # For sl_3, key polynomials K_{(a,b,c)}(x_1, x_2, x_3) are more complex.
    # At specialization (q, q^2, q^3), they give q-polynomials.
    
    # Let's compute gl_2 key polynomials K_{(a,b)}(q, q^2) for comparison
    # with Seed 5's decomposition.
    
    # GL_2 key polynomial K_{(a,b)} for a >= b:
    # K_{(a,b)}(x_1, x_2) = x_1^a * x_2^b * sum_{j=0}^{a-b} (x_2/x_1)^j
    #                      = sum_{j=0}^{a-b} x_1^{a-j} * x_2^{b+j}
    
    # At (q, q^2):
    # K_{(a,b)}(q, q^2) = sum_{j=0}^{a-b} q^{(a-j) + 2(b+j)} = sum_{j=0}^{a-b} q^{a+2b+j}
    
    print("\nGL_2 key polynomials K_{(a,b)}(q, q^2) for small a,b:")
    for a in range(8):
        for b in range(a+1):
            val = {}
            for j in range(a - b + 1):
                e = a + 2*b + j
                val[e] = val.get(e, 0) + 1
            total = sum(val.values())
            if total <= 15:
                terms = " + ".join(f"q^{e}" for e in sorted(val.keys()))
                print(f"  K_{{({a},{b})}}(q,q^2) = {terms}  [sum={total}]")
    
    # Now try GL_3 key polynomials at (q, q^2, q^3)
    # K_{(a,b,c)}(x_1,x_2,x_3) for a >= b >= c (dominant weight)
    # is the full Schur polynomial s_{(a-c,b-c)}(x_1,x_2,x_3) * (x_1*x_2*x_3)^c
    # when we use the identity Weyl group element (i.e., the character itself).
    #
    # The Demazure character for a non-identity w is a subset of the character.
    
    # Actually for GL_3, the character of V(a,b,c) at (q, q^2, q^3) is:
    # chi_{(a,b,c)}(q, q^2, q^3) = q^{a+2b+3c} * s_{(a-c,b-c)}(1, q, q^2) ... no.
    # Actually s_lambda(q, q^2, q^3) = q^{|lambda|} * s_lambda(1, q, q^2) ... also no.
    # The Schur polynomial s_{(p,r)}(x_1,x_2,x_3) has a known formula.
    
    # Let's compute the character of the sl_3 irrep V(a,b) (Dynkin labels)
    # specialized at (q, q^2, q^3).
    # Weights of V(a,b): w = (w_1, w_2, w_3) with w_1+w_2+w_3 = 0 and
    # w_1 - w_2, w_2 - w_3 are the components.
    # Actually easier: use partition notation.
    # V with highest weight (a,b) in Dynkin has partition lambda = (a+b, b, 0).
    # Schur poly: s_{(a+b,b,0)}(x_1,x_2,x_3) / (x_1*x_2*x_3)^0
    # At (q, q^2, q^3): s_{(a+b,b)}(q, q^2, q^3)
    
    # Schur polynomial via SSYT:
    # s_lambda(x_1,...,x_n) = sum over SSYT T of shape lambda, entries in {1,...,n},
    #   product x_{T(cell)}
    
    # For lambda = (p, r) with p >= r >= 0, n = 3:
    # SSYT with entries in {1,2,3}, shape (p,r), weakly increasing along rows,
    # strictly increasing down columns.
    
    def schur_at_q(p, r, max_deg=100):
        """Compute s_{(p,r)}(q, q^2, q^3) via SSYT enumeration."""
        # Row 1: length p, entries from {1,2,3}, weakly increasing
        # Row 2: length r, entries from {1,2,3}, weakly increasing
        # Column condition: entry in row 2, col j < entry in row 1, col j (strict)
        # Wait: SSYT = weakly increasing in rows, STRICTLY increasing in columns.
        
        result = {}
        
        # Generate all weakly increasing sequences of length p from {1,2,3}
        def gen_row(length, min_val=1):
            if length == 0:
                yield ()
                return
            for v in range(min_val, 4):
                for rest in gen_row(length - 1, v):
                    yield (v,) + rest
        
        for row1 in gen_row(p):
            for row2 in gen_row(r):
                # Check column strictness: row2[j] < row1[j] for all j < r
                # Wait, SSYT has row1 on top, row2 on bottom.
                # Column condition: row1[j] < row2[j] (strictly increasing downward)
                valid = True
                for j in range(r):
                    if row1[j] >= row2[j]:
                        valid = False
                        break
                if not valid:
                    continue
                # Weight: sum of row entries, mapped to q-exponent via x_i = q^i
                weight = sum(row1) + sum(row2)
                result[weight] = result.get(weight, 0) + 1
        
        return result
    
    print("\n\nSchur polynomials s_{(p,r)}(q, q^2, q^3) = character of V(p-r, r) for sl_3:")
    interesting = []
    for p in range(8):
        for r in range(p+1):
            s = schur_at_q(p, r)
            total = sum(s.values())
            dim_formula = (p - r + 1) * (r + 1) * (p + 2) // 2
            dynkin = (p - r, r)
            terms = " + ".join(f"{v}q^{e}" if v > 1 else f"q^{e}" for e, v in sorted(s.items()))
            if total <= 30:
                print(f"  s_{{({p},{r})}}(q,q^2,q^3) = {terms}  [dim={total}, Dynkin=V({dynkin[0]},{dynkin[1]})]")
            interesting.append((p, r, total, s))
    
    # Now: check if Q_{1,(3,2,2)}(q) = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6
    # can be decomposed as nonneg combination of these characters.
    
    Q1_322 = {1: 2, 2: 3, 3: 2, 4: 2, 5: 1, 6: 1}
    print(f"\nQ_{{1,(3,2,2)}}(q) = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6")
    print(f"  sum = 11")
    
    # Can we subtract known characters?
    # s_{(1,0)}(q,q^2,q^3) = q + q^2 + q^3 = character of V(1,0), dim=3
    # s_{(0,0)}(q,q^2,q^3) = 1 = trivial
    # s_{(2,0)}(q,q^2,q^3) = q^2 + q^3 + q^4 + q^3 + q^4 + q^5
    #                        hmm let me compute
    
    s_10 = schur_at_q(1, 0)
    s_01 = schur_at_q(0, 0)  # actually (0,0) is trivial
    s_20 = schur_at_q(2, 0)
    s_11 = schur_at_q(1, 1)
    s_21 = schur_at_q(2, 1)
    s_30 = schur_at_q(3, 0)
    
    print(f"\nKey characters:")
    for name, s in [("s_(1,0)", s_10), ("s_(2,0)", s_20), ("s_(1,1)", s_11), 
                    ("s_(2,1)", s_21), ("s_(3,0)", s_30)]:
        terms = " + ".join(f"{v}q^{e}" if v > 1 else f"q^{e}" for e, v in sorted(s.items()))
        print(f"  {name}(q,q^2,q^3) = {terms}  [dim={sum(s.values())}]")
    
    # Try greedy decomposition of Q_1
    print(f"\nAttempting greedy decomposition of Q_1 into sl_3 characters...")
    
    residual = dict(Q1_322)
    decomp = []
    
    # Try characters in order of decreasing minimum degree
    chars = []
    for p in range(8):
        for r in range(p+1):
            s = schur_at_q(p, r)
            if s:
                min_deg = min(s.keys())
                chars.append((min_deg, p, r, s, sum(s.values())))
    chars.sort(key=lambda x: (-x[0], x[4]))
    
    for min_deg, p, r, s, dim in chars:
        while True:
            # Can we subtract s from residual?
            can_sub = True
            for e, v in s.items():
                if residual.get(e, 0) < v:
                    can_sub = False
                    break
            if not can_sub:
                break
            for e, v in s.items():
                residual[e] = residual.get(e, 0) - v
                if residual[e] == 0:
                    del residual[e]
            decomp.append((p, r))
    
    if not residual:
        print(f"  SUCCESS! Q_1 = sum of characters:")
        from collections import Counter
        counts = Counter(decomp)
        for (p, r), mult in sorted(counts.items()):
            s = schur_at_q(p, r)
            terms = " + ".join(f"{v}q^{e}" if v > 1 else f"q^{e}" for e, v in sorted(s.items()))
            print(f"    {mult} x V({p-r},{r}) = {mult} x ({terms})")
        print(f"  Total dim = {sum(sum(schur_at_q(p,r).values()) for p,r in decomp)}")
    else:
        print(f"  PARTIAL: residual = {residual}")
        print(f"  Decomposed: {decomp}")

    # Try to decompose Q_2
    print(f"\n\nAttempting decomposition of Q_2...")
    Q2_322 = {3: 1, 4: 5, 5: 7, 6: 10, 7: 10, 8: 12, 9: 10, 10: 11, 
              11: 9, 12: 9, 13: 7, 14: 7, 15: 5, 16: 5, 17: 3, 18: 3, 
              19: 2, 20: 2, 21: 1, 22: 1, 24: 1}
    print(f"  Q_2 sum = {sum(Q2_322.values())}")
    
    residual = dict(Q2_322)
    decomp2 = []
    
    for min_deg, p, r, s, dim in chars:
        while True:
            can_sub = True
            for e, v in s.items():
                if residual.get(e, 0) < v:
                    can_sub = False
                    break
            if not can_sub:
                break
            for e, v in s.items():
                residual[e] = residual.get(e, 0) - v
                if residual[e] == 0:
                    del residual[e]
            decomp2.append((p, r))
    
    if not residual:
        from collections import Counter
        counts = Counter(decomp2)
        print(f"  SUCCESS! Q_2 decomposes into {len(decomp2)} characters")
        for (p, r), mult in sorted(counts.items()):
            print(f"    {mult} x V({p-r},{r})")
    else:
        print(f"  PARTIAL: residual has {sum(residual.values())} remaining, terms: {sorted(residual.items())[:10]}")
        from collections import Counter
        counts = Counter(decomp2)
        print(f"  Successfully decomposed {sum(sum(schur_at_q(p,r).values()) for p,r in decomp2)} of 121")
        for (p, r), mult in sorted(counts.items()):
            print(f"    {mult} x V({p-r},{r})")


if __name__ == "__main__":
    main()
