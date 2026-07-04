"""
Seed 7 — Vertex operator perspective on Q_{n,c}(q).

Key idea from the seed context:
- Tsuchioka studies the D4(3) twisted affine Lie algebra
- Uses vertex operators Z_i(beta) to construct spanning sets for modules
- The commutation relations produce character formulas for level-3 modules
- The basic representation V^(rho) of D4(3) has level 3

Connection to cylindric partitions:
- The modulus t = k + ell for profile c = (c_0, c_1, c_2) is t = 3 + d
- Borodin's product for F_c(q) involves factors with period t
- For d = 2, t = 5 (modulus 5 = connected to A4(2))
- For d = 4, t = 7 (modulus 7)
- For d = 5, t = 8 (modulus 8)
- For d = 7, t = 10 (modulus 10)

The Tsuchioka paper works with modulus 9 (= 3+6, so d=6, but d=6 is divisible by 3!).
This is interesting: the D4(3) algebra naturally lives at modulus 9, which is precisely
the case EXCLUDED from the conjecture (d divisible by 3).

However, the vertex operator / Z-algebra technology is general and applies to 
other affine algebras. The question is: can we find an analogous representation-theoretic
interpretation of Q_{n,c}(q) as a graded character?

Approach:
1. Compute the character of the basic D4(3) module and compare with known 
   Andrews-Schilling-Warnaar identities
2. Look at the structure: Z-algebra commutation relations -> difference conditions ->
   cylindric partition interlacing
3. Explore whether the (q;q)_inf cancellation in Q_{n,c}(q) has a vertex operator
   interpretation via boson-fermion correspondence

The key identity from the seed: Z-operators satisfy (anti-)commutation relations
that reduce the spanning set to monomials in a single root type Z_i(beta_1).
This is analogous to how cylindric partitions of a given profile can be built
from a single "layer" operation.
"""

from math import gcd
from collections import defaultdict

def qpoch(a, q_step, n, max_deg):
    """Compute (q^a; q^q_step)_n as polynomial."""
    result = {0: 1}
    for i in range(n):
        pw = a + i * q_step
        if pw > max_deg:
            break
        new = dict(result)
        for k, v in result.items():
            if k + pw <= max_deg:
                new[k + pw] = new.get(k + pw, 0) - v
                if new[k + pw] == 0:
                    del new[k + pw]
        result = new
    return result


def qpoch_inv(a, q_step, max_deg):
    """Compute 1/(q^a; q^q_step)_inf as truncated power series."""
    result = {0: 1}
    for n in range(1, max_deg // q_step + 2):
        pw = a + (n - 1) * q_step
        if pw > max_deg:
            break
        new = dict(result)
        for k in sorted(result.keys()):
            kk = k + pw
            while kk <= max_deg:
                new[kk] = new.get(kk, 0) + new.get(kk - pw, 0)
                kk += pw
        result = new
    return result


def poly_mul(a, b, max_deg):
    result = {}
    for e1, c1 in a.items():
        if e1 > max_deg:
            continue
        for e2, c2 in b.items():
            e = e1 + e2
            if e > max_deg:
                continue
            result[e] = result.get(e, 0) + c1 * c2
    return {k: v for k, v in result.items() if v != 0}


def borodin_product(c, max_deg):
    """
    Compute F_c(q) = Borodin's product formula.
    c = (c_0, ..., c_{k-1}), 0-indexed.
    """
    k = len(c)
    d = sum(c)
    t = k + d

    result = {0: 1}

    # 1/(q^t; q^t)_inf
    result = qpoch_inv(t, t, max_deg)

    # d_{i,j} = c_i + ... + c_j (using 0-indexed, but formula uses 1-indexed)
    # In 1-indexed: d_{i,j} = c_i + c_{i+1} + ... + c_j
    # We'll convert: 1-indexed i -> 0-indexed i-1
    def d_sum(i, j):
        """1-indexed partial sum d_{i,j} = c_i + ... + c_j."""
        if i > j:
            return 0
        return sum(c[ii - 1] for ii in range(i, j + 1))

    # First product: prod_{i=1}^{k} prod_{j=i+1}^{k} prod_{m=1}^{c_{i-1}} 
    #   1/(q^{m + d_{i+1,j} + j - i}; q^t)_inf
    for i in range(1, k + 1):
        for j in range(i + 1, k + 1):
            for m in range(1, c[i - 1] + 1):
                exp = m + d_sum(i + 1, j) + (j - i)
                if 0 < exp < t:
                    factor = qpoch_inv(exp, t, max_deg)
                    result = poly_mul(result, factor, max_deg)

    # Second product: prod_{i=2}^{k} prod_{j=2}^{i-1} prod_{m=1}^{c_{i-1}}
    #   1/(q^{t - (m + d_{j,i-1} + i - j)}; q^t)_inf
    for i in range(2, k + 1):
        for j in range(2, i):
            for m in range(1, c[i - 1] + 1):
                inner = m + d_sum(j, i - 1) + (i - j)
                exp = t - inner
                if 0 < exp < t:
                    factor = qpoch_inv(exp, t, max_deg)
                    result = poly_mul(result, factor, max_deg)

    return result


def character_formula(c, max_deg):
    """
    Compute the character-like quantity:
    F_c(q) * (q;q)_inf  (or similar normalization)
    
    In representation theory, characters of affine Lie algebra modules
    have the form: (product formula) / (q;q)_inf^rank
    
    The key observation is:
    Q_{n,c}(q) involves extracting [z^n]( (zq)_inf * F_c(z,q) )
    The (zq)_inf factor plays the role of "removing" denominators 
    related to the Weyl denominator.
    
    For D4(3), the principally specialized character is:
    ch(V^(rho)) = 1 / prod_{n>=1, n not equiv 0 mod 9} (1-q^n)
    
    This gives a product of the form sum_n a_n q^n with a_n >= 0
    (since it's 1/(positive q-series)).
    
    The question is whether Q_{n,c}(q) can be interpreted as
    a truncated/bounded version of such a character.
    """
    
    # Compute Borodin's product
    F = borodin_product(c, max_deg)
    
    # Compute (q;q)_inf truncated
    qq_inf = {0: 1}
    for i in range(1, max_deg + 1):
        new = dict(qq_inf)
        for k, v in qq_inf.items():
            if k + i <= max_deg:
                new[k + i] = new.get(k + i, 0) - v
        qq_inf = new
    
    # F_c(q) * (q;q)_inf
    product = poly_mul(F, qq_inf, max_deg)
    
    return F, qq_inf, product


def print_poly(p, name="", max_terms=30):
    if not p:
        print(f"  {name} = 0")
        return
    terms = sorted(p.items())[:max_terms]
    parts = []
    for e, c in terms:
        if c == 0:
            continue
        if e == 0:
            parts.append(str(c))
        elif c == 1:
            parts.append(f"q^{e}")
        elif c == -1:
            parts.append(f"-q^{e}")
        else:
            parts.append(f"{c}q^{e}")
    s = " + ".join(parts).replace("+ -", "- ") if parts else "0"
    if len(terms) < len(p):
        s += " + ..."
    print(f"  {name} = {s}")


if __name__ == "__main__":
    max_deg = 40

    profiles = [
        ((1, 1, 0), "d=2, t=5"),
        ((2, 1, 1), "d=4, t=7"),
        ((2, 2, 1), "d=5, t=8"),
        ((3, 2, 2), "d=7, t=10"),
        ((3, 3, 0), "d=6, t=9 (excluded, div by 3)"),
    ]

    for c, desc in profiles:
        d = sum(c)
        t = 3 + d
        ell = gcd(d, 3)
        print(f"\n{'='*60}")
        print(f"Profile c = {c}, {desc}")
        print(f"  t = {t}, ell = {ell}")
        print(f"{'='*60}")

        F, qq, product = character_formula(c, max_deg)
        print_poly(F, "F_c(q)")
        
        # Check: is F_c(q) * (q;q)_inf a nice theta-like series?
        print_poly(product, "F_c(q)*(q;q)_inf")
        
        # Compare with Andrews-Schilling-Warnaar: 
        # The sum side of A-S-W identities involves (q;q)_inf * F_c(q)
        # which should give a modular-form-like expression
        
        # For d=2, t=5: should relate to Rogers-Ramanujan
        # F_{(1,1,0)}(q) * (q;q)_inf = sum related to mod-5 identities
        
        all_pos_product = all(v >= 0 for v in product.values())
        print(f"  F_c(q)*(q;q)_inf all non-neg: {all_pos_product}")
        
        # Now look at what happens for the D4(3) specialization
        # The character of basic D4(3) module is 1/prod_{n>=1, n not=0 mod 9}(1-q^n)
        if t == 9:
            # Compare with D4(3) character
            d4_char = {0: 1}
            for n in range(1, max_deg + 1):
                if n % 9 != 0:
                    new = dict(d4_char)
                    for k in sorted(d4_char.keys()):
                        kk = k + n
                        while kk <= max_deg:
                            new[kk] = new.get(kk, 0) + new.get(kk - n, 0)
                            kk += n
                    d4_char = new
            print_poly(d4_char, "D4(3) character (principally specialized)")
            
            # Check if F_c(q) matches
            match = all(F.get(k, 0) == d4_char.get(k, 0) for k in range(max_deg + 1))
            print(f"  Matches D4(3) character: {match}")

    # Key observation about the vertex operator connection:
    print(f"\n{'='*60}")
    print("KEY OBSERVATIONS FOR VERTEX OPERATOR APPROACH")
    print(f"{'='*60}")
    print("""
1. The D4(3) algebra naturally lives at modulus 9 = 3 + 6,
   corresponding to profile d = 6 which is EXCLUDED from the conjecture.
   
2. The Tsuchioka commutation relations produce identities for modulus 9.
   For the conjecture, we need analogous identities for moduli t = 3 + d
   where d is NOT divisible by 3.

3. For d = 2 (mod 5): this connects to A2(2) (twisted rank-1)
   For d = 4 (mod 7): connections to higher-rank twisted algebras
   For d = 5 (mod 8): connections to affine algebras at level 3

4. The Z-algebra approach works as follows:
   - Start with a highest weight module V for an affine algebra
   - The Z-operators Z_i(beta) generate the "vacuum space" Omega_V
   - The commutation relations among Z_i impose "difference conditions"
   - These difference conditions match the interlacing conditions of
     cylindric partitions!
   
5. The key step in Tsuchioka: commutation relations show that
   Z'-operators are redundant (spanned by Z-operators alone).
   Analogously, for cylindric partitions, the interlacing conditions
   mean not all partition combinations appear — there are constraints.

6. For proving positivity of Q_{n,c}(q):
   - We need: (q^ell;q^ell)_n * [z^n]((zq)_inf * F_c(z,q)) >= 0
   - The (zq)_inf factor creates cancellation
   - In representation theory: (zq)_inf relates to the Weyl denominator
   - A positive character expansion would give manifest positivity
   
7. CRUCIAL: The Z-algebra vacuum space has a basis indexed by 
   "colored partitions" satisfying difference conditions.
   These are EXACTLY the kind of objects that could give a 
   manifestly positive formula for Q_{n,c}(q).
""")
