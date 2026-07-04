"""
Seed 2, Layer 1: Explore the bead/abacus decomposition angle.

From Tingley and Kursungoz-Seyrek:
- Cylindric partitions biject to pairs (ordinary partition, colored distinct parts)
- The abacus model maps partitions to bead positions on runners

For profile c = (c_0,c_1,c_2) with k=3, t = 3+d:
- Borodin's decomposition: CP of profile c <-> (ordinary partition mu, labeled cylindric diagram)
- Tingley's decomposition: CP <-> (ordinary partition mu, labeled partition into distinct parts)
- Kursungoz-Seyrek: CP <-> (ordinary partition mu, colored partition into distinct parts)

The generating function factorizes as:
F_c(q) = 1/(q;q)_inf * product_of_terms

The 1/(q;q)_inf corresponds to the ordinary partition mu.
The product_of_terms corresponds to the distinct parts piece.

For bounded cylindric partitions (max <= n), the decomposition becomes:
F_{c,n}(q) = sum over (mu, colored_distinct) with max(CP) <= n of q^{size}

The key question: can we decompose Q_{n,c}(q) via this bijection?

Q_{n,c}(q) = (q;q)_n * [z^n] (z;q)_inf * sum_N F_{c,N} z^N

Let's think about this using the Kursungoz-Seyrek decomposition more carefully.

From K-S: F_c(q) = 1/(q;q)_inf * prod_{j in S} 1/(1-q^j) where S is a specific set.
Wait, not quite. Let me look at their result more carefully.

Their Theorem 7: There is a bijection between cylindric partitions of profile c
and pairs (mu, nu) where mu is an ordinary partition and nu is a partition into
distinct parts colored by colors from a specific set determined by c.

The generating function becomes:
F_c(q) = 1/(q;q)_inf * prod_{j in S_c} (1 + q^j)

where S_c is a multiset of positive integers determined by the profile c.

Hmm, but that's for unrestricted CPs. For bounded CPs, the decomposition
must account for the bound on max entry.

Let me compute the "distinct parts" piece separately and see if it helps
with understanding Q_{n,c}(q).

For c = (2,1,1), d=4, t=7:
Borodin's formula: F_c(q) = 1/(q^7;q^7)_inf * [other factors]

Let me compute F_c(q) / (1/(q;q)_inf) = (q;q)_inf * F_c(q) and see what it is.
This should be the "cylindric diagram" piece.
"""

from collections import defaultdict


class QPoly:
    def __init__(self, coeffs=None, max_deg=100):
        self.max_deg = max_deg
        self.coeffs = defaultdict(int)
        if coeffs:
            for k, v in (coeffs.items() if isinstance(coeffs, dict) else enumerate(coeffs)):
                if k <= max_deg and v != 0:
                    self.coeffs[k] = v

    @staticmethod
    def one(md=100): return QPoly({0: 1}, md)
    @staticmethod
    def zero(md=100): return QPoly({}, md)

    def __add__(self, other):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items(): r.coeffs[k] += v
        for k, v in other.coeffs.items():
            if k <= self.max_deg: r.coeffs[k] += v
        return r

    def __mul__(self, other):
        r = QPoly(max_deg=self.max_deg)
        for i, ai in self.coeffs.items():
            if ai == 0: continue
            for j, bj in other.coeffs.items():
                if bj == 0 or i+j > self.max_deg: continue
                r.coeffs[i+j] += ai * bj
        return r

    def to_list(self):
        if not self.coeffs: return [0]
        md = max(self.coeffs.keys())
        result = [self.coeffs.get(i, 0) for i in range(md + 1)]
        while len(result) > 1 and result[-1] == 0: result.pop()
        return result


def qpoch_inf_trunc(a, b, md):
    """(q^a; q^b)_inf truncated to degree md."""
    result = QPoly.one(md)
    i = 0
    while a + b*i <= md:
        factor = QPoly({0: 1, a+b*i: -1}, md)
        result = result * factor
        i += 1
    return result


def borodin_Fc(c, q_max):
    """
    Compute F_c(q) using Borodin's product formula for k=3.
    
    F_c(q) = 1/(q^t;q^t)_inf * product_terms
    
    For k=3, c=(c_0,c_1,c_2), t=3+d, d=c_0+c_1+c_2.
    
    d_{i,j} = c_i + c_{i+1} + ... + c_j (partial sums, 0-indexed in our case)
    
    Wait, the formula in the conjecture uses 1-indexed. Let me re-index.
    With k=3, indices i,j in {1,2,3} (original), c = (c_1,c_2,c_3).
    
    d_{i,j} = c_i + c_{i+1} + ... + c_j for i <= j.
    
    First product (i<j): i=1,j=2; i=1,j=3; i=2,j=3
    For i=1,j=2: m=1..c_1, factor 1/(q^{m+d_{2,2}+2-1};q^t) = 1/(q^{m+c_2+1};q^t)
    For i=1,j=3: m=1..c_1, factor 1/(q^{m+d_{2,3}+3-1};q^t) = 1/(q^{m+c_2+c_3+2};q^t)
    For i=2,j=3: m=1..c_2, factor 1/(q^{m+d_{3,3}+3-2};q^t) = 1/(q^{m+c_3+1};q^t)
    
    Second product (i>j, but i>=2, j>=2): i=2,j=2 (excluded since need j<i); i=3,j=2; i=3,j=3 (excluded)
    Wait: second product has i=2..k, j=2..i-1.
    For k=3: i=2, j from 2 to 1 => empty. i=3, j from 2 to 2 => j=2.
    For i=3, j=2: m=1..c_3, factor 1/(q^{t-(m+d_{2,2}+3-2)};q^t) = 1/(q^{t-(m+c_2+1)};q^t)
    """
    k = 3
    # Convert to 1-indexed: c_1=c[0], c_2=c[1], c_3=c[2]
    c1, c2, c3 = c
    d = c1 + c2 + c3
    t = k + d
    
    # Start with 1/(q^t;q^t)_inf
    # We need the inverse: sum q^{t*m} * p(m) where p(m) = #partitions with parts = multiples of t
    # 1/(q^t;q^t)_inf = sum_{n>=0} p_t(n) q^n where p_t(n) = partitions into parts divisible by t
    
    # Build the product 1/(...) by multiplying by geometric series
    # 1/(q^a; q^t)_inf = prod_{j>=0} 1/(1-q^{a+jt}) = sum q^{...}
    
    # Let's build the full product directly as a power series truncated to q_max.
    
    result = QPoly.one(q_max)
    
    # 1/(q^t;q^t)_inf
    j = 0
    while t + t*j <= q_max:
        # multiply by 1/(1-q^{t+tj}) = sum_{m>=0} q^{m(t+tj)}
        new_result = QPoly.zero(q_max)
        exp = t + t*j
        for deg, coeff in result.coeffs.items():
            if coeff == 0: continue
            d2 = deg
            while d2 <= q_max:
                new_result.coeffs[d2] += coeff
                d2 += exp
        result = new_result
        j += 1
    
    # First product: i=1,j=2
    for m in range(1, c1+1):
        a = m + c2 + 1
        j = 0
        while a + t*j <= q_max:
            new_result = QPoly.zero(q_max)
            exp = a + t*j
            for deg, coeff in result.coeffs.items():
                if coeff == 0: continue
                d2 = deg
                while d2 <= q_max:
                    new_result.coeffs[d2] += coeff
                    d2 += exp
            result = new_result
            j += 1
    
    # First product: i=1,j=3
    for m in range(1, c1+1):
        a = m + c2 + c3 + 2
        j = 0
        while a + t*j <= q_max:
            new_result = QPoly.zero(q_max)
            exp = a + t*j
            for deg, coeff in result.coeffs.items():
                if coeff == 0: continue
                d2 = deg
                while d2 <= q_max:
                    new_result.coeffs[d2] += coeff
                    d2 += exp
            result = new_result
            j += 1
    
    # First product: i=2,j=3
    for m in range(1, c2+1):
        a = m + c3 + 1
        j = 0
        while a + t*j <= q_max:
            new_result = QPoly.zero(q_max)
            exp = a + t*j
            for deg, coeff in result.coeffs.items():
                if coeff == 0: continue
                d2 = deg
                while d2 <= q_max:
                    new_result.coeffs[d2] += coeff
                    d2 += exp
            result = new_result
            j += 1
    
    # Second product: i=3,j=2
    for m in range(1, c3+1):
        a = t - (m + c2 + 1)
        if a <= 0: continue
        j = 0
        while a + t*j <= q_max:
            new_result = QPoly.zero(q_max)
            exp = a + t*j
            for deg, coeff in result.coeffs.items():
                if coeff == 0: continue
                d2 = deg
                while d2 <= q_max:
                    new_result.coeffs[d2] += coeff
                    d2 += exp
            result = new_result
            j += 1
    
    return result


def main():
    q_max = 30
    
    # Test Borodin's formula
    c = (2, 1, 1)
    d = sum(c)
    t = 3 + d
    print(f"Profile c={c}, d={d}, t={t}")
    
    Fc = borodin_Fc(c, q_max)
    print(f"F_c(q) first 30 coeffs: {Fc.to_list()[:30]}")
    
    # Now compute (q;q)_inf * F_c(q) to isolate the "distinct parts" piece
    q_inf = qpoch_inf_trunc(1, 1, q_max)
    distinct_piece = q_inf * Fc
    print(f"\n(q;q)_inf * F_c(q) = {distinct_piece.to_list()}")
    print("This should be a product of (1+q^j) terms (Kursungoz-Seyrek)")
    
    # Check: for c=(2,1,1), d=4, t=7
    # The distinct parts should have "colors" determined by the profile.
    # From Borodin: F_c(q) = 1/(q;q)_inf * G_c(q) where G_c(q) = distinct part gen fn.
    # So G_c(q) = (q;q)_inf * F_c(q).
    
    # From the Borodin formula:
    # F_c(q) = 1/(q^t;q^t) * prod 1/(q^a;q^t)
    # (q;q)_inf * F_c(q) = (q;q)_inf / [(q^t;q^t) * prod (q^a;q^t)]
    # = prod_{j>=1} (1-q^j) / [prod factors]
    # The q-Pochhammer (q;q)_inf = prod_{j>=1}(1-q^j) divided by the denominator
    # should leave a product of (1-q^j) for specific j values.
    
    # Actually, 1/(q;q)_inf = prod_{j>=1} 1/(1-q^j).
    # And F_c(q) = prod 1/(1-q^a) for various a (from Borodin, with specific a).
    # So (q;q)_inf * F_c(q) = prod 1/(1-q^a) / prod 1/(1-q^j) for all j
    #                        = prod_{j not in exponents} (1-q^j)
    # Wait, the exponents from Borodin are a subset of positive integers, each appearing once.
    # The "missing" exponents contribute (1-q^j) factors.
    
    # For c=(2,1,1), t=7:
    # Borodin exponents: {7,14,21,...} from 1/(q^t;q^t)
    #   i=1,j=2: m=1,2 -> a=m+1+1 = 3,4 -> {3,4} mod 7: {3,10,17,...}, {4,11,18,...}
    #   i=1,j=3: m=1,2 -> a=m+1+1+2 = m+4 = 5,6 -> {5,12,19,...}, {6,13,20,...}
    #   i=2,j=3: m=1 -> a=1+1+1 = 3 -> {3,10,...}. Wait, already have 3 mod 7!
    # Hmm, there might be repeated factors. Let me just list all exponents.
    
    c1, c2, c3 = c
    exponents = set()
    
    # 1/(q^t;q^t): exponents t, 2t, 3t, ... -> residues {0 mod t}
    
    # i=1,j=2: m=1..c1, a = m+c2+1 -> m+2 for c2=1
    for m in range(1, c1+1):
        a = m + c2 + 1
        exponents.add(a % t if a % t != 0 else t)
        
    # i=1,j=3: m=1..c1, a = m+c2+c3+2 -> m+4
    for m in range(1, c1+1):
        a = m + c2 + c3 + 2
        exponents.add(a % t if a % t != 0 else t)
    
    # i=2,j=3: m=1..c2, a = m+c3+1 -> m+2
    for m in range(1, c2+1):
        a = m + c3 + 1
        exponents.add(a % t if a % t != 0 else t)
    
    # i=3,j=2: m=1..c3, a = t-(m+c2+1) -> 7-(m+2) = 5-m
    for m in range(1, c3+1):
        a = t - (m + c2 + 1)
        if a > 0:
            exponents.add(a % t if a % t != 0 else t)
    
    print(f"\nBorodin exponent residues mod {t}: {sorted(exponents)}")
    print(f"Missing residues mod {t}: {sorted(set(range(1,t)) - exponents)}")
    # The distinct piece = prod over missing residues r: (q^r; q^t)_inf
    
    # Verify: the distinct piece should equal prod_{r in missing} (q^r;q^t)_inf
    # ... which are factors of (1-q^j) for j = r, r+t, r+2t, ...
    
    missing = sorted(set(range(1, t)) - exponents)
    verify = QPoly.one(q_max)
    for r in missing:
        verify = verify * qpoch_inf_trunc(r, t, q_max)
    
    print(f"\nProduct of (q^r;q^t)_inf for missing r: {verify.to_list()}")
    print(f"(q;q)_inf * F_c(q):                      {distinct_piece.to_list()}")
    print(f"Match: {verify.to_list() == distinct_piece.to_list()}")
    
    # If they don't match, the exponents might have multiplicities.
    # Let me list ALL exponents with multiplicities.
    print("\nAll Borodin exponents (with multiplicities):")
    all_exp = []
    for m in range(1, c1+1):
        a = m + c2 + 1
        all_exp.append(a)
    for m in range(1, c1+1):
        a = m + c2 + c3 + 2
        all_exp.append(a)
    for m in range(1, c2+1):
        a = m + c3 + 1
        all_exp.append(a)
    for m in range(1, c3+1):
        a = t - (m + c2 + 1)
        if a > 0:
            all_exp.append(a)
    
    all_exp.sort()
    print(f"  Exponents (residues mod {t}): {all_exp}")
    print(f"  These plus 0 (from q^t): {[0]+all_exp}")
    
    # Count multiplicities
    from collections import Counter
    counts = Counter(a % t for a in all_exp)
    counts[0] = 1  # from (q^t;q^t)
    print(f"  Residue counts: {dict(sorted(counts.items()))}")
    
    # Total number of "runners" contributing:
    # d(d-1)/2 + ... actually for k=3:
    # Number of factors in first product: sum over i<j of c_i terms
    # = c_1*(k-1 choose 1) = c_1*2 + c_2*1 for k=3
    # First product terms: c_1*(j=2 and j=3) + c_2*(j=3) = 2*c_1 + c_2
    # Second product terms: c_3 * (j=2) = c_3
    # Total: 2*c_1 + c_2 + c_3
    total_factors = 2*c1 + c2 + c3 + 1  # +1 for (q^t;q^t)
    print(f"  Total factors: {total_factors}")
    # For c=(2,1,1): 4+1+1+1 = 7 = t. So EVERY residue class mod t appears once!
    # 2*2+1+1+1 = 8... hmm, that's 7 with multiplicity on residue 3.


if __name__ == "__main__":
    main()
