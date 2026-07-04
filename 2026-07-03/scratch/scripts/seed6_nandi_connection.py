#!/usr/bin/env python3
"""
Seed 6: Explore connections between Nandi's conjecture (mod 14 partition identities)
and the Warnaar positivity conjecture.

Key idea from seed context: Takigiku-Tsuchioka proved Nandi's conjecture using
double sums of the form:
  N_a = sum_{i,j>=0} (-1)^j q^{binom(i,2) + 2*binom(j,2) + 2ij + A_a(i,j)} / ((q;q)_i (q^2;q^2)_j)

These are MANIFESTLY NON-POSITIVE due to the (-1)^j factor, yet they equal
positive infinite products (partitions into specific residues mod 14).

This is structurally analogous to the Warnaar conjecture: Q_{n,c}(q) involves
massive cancellation between positive and negative terms, yet is always nonneg.

Questions to explore:
1. Can the Takigiku-Tsuchioka double-sum technique be adapted to give
   multisum representations of Q_{n,c}(q)?
2. Is there a mod-(2d+k) = mod-(2d+3) structure in Q_{n,c}(q) that
   mirrors the mod-14 structure of Nandi's identities?
3. For d=4 (t=7), mod 2*7=14: is there a direct connection?
"""

from fractions import Fraction

def compute_nandi_double_sum(a, q_bound):
    """
    Compute N_a = sum_{i,j>=0} (-1)^j q^{binom(i,2)+2*binom(j,2)+2ij+A_a(i,j)} / ((q;q)_i (q^2;q^2)_j)
    for a = 1, 2, 3.
    """
    # A_1(i,j) = i+j, A_2(i,j) = i+3j, A_3(i,j) = 2i+3j
    A_funcs = {
        1: lambda i, j: i + j,
        2: lambda i, j: i + 3*j,
        3: lambda i, j: 2*i + 3*j,
    }
    A = A_funcs[a]
    
    # Compute 1/(q;q)_i and 1/(q^2;q^2)_j as power series
    def inv_qpoch(base, n, qb):
        """1/(q^base;q^base)_n as power series up to q^qb."""
        result = {0: Fraction(1)}
        for k in range(1, n+1):
            # Multiply by 1/(1-q^{base*k})
            new_result = dict(result)
            for d in range(base*k, qb+1):
                new_result[d] = new_result.get(d, Fraction(0)) + result.get(d - base*k, Fraction(0))
            result = new_result
        return result
    
    # Actually, we need 1/(q;q)_i = sum_{partitions with parts <= i} q^{size}
    # This is also 1/((1-q)(1-q^2)...(1-q^i)).
    def inv_qpoch_std(i, qb):
        result = {0: Fraction(1)}
        for k in range(1, i+1):
            new = {}
            for d, c in result.items():
                for m in range(0, (qb - d) // k + 1):
                    new[d + m*k] = new.get(d + m*k, Fraction(0)) + c
            result = new
        return result
    
    def inv_q2poch(j, qb):
        """1/(q^2;q^2)_j"""
        result = {0: Fraction(1)}
        for k in range(1, j+1):
            new = {}
            for d, c in result.items():
                for m in range(0, (qb - d) // (2*k) + 1):
                    new[d + m*2*k] = new.get(d + m*2*k, Fraction(0)) + c
            result = new
        return result
    
    total = {}
    for i in range(q_bound + 1):
        binom_i = i*(i-1)//2
        if binom_i > q_bound:
            break
        inv_qi = inv_qpoch_std(i, q_bound)
        
        for j in range(q_bound + 1):
            binom_j2 = j*(j-1)  # 2*binom(j,2) = j(j-1)
            exponent = binom_i + binom_j2 + 2*i*j + A(i, j)
            if exponent > q_bound:
                break
            
            sign = (-1)**j
            inv_q2j = inv_q2poch(j, q_bound)
            
            # Contribution: sign * q^exponent * inv_qi * inv_q2j
            for d1, c1 in inv_qi.items():
                if d1 + exponent > q_bound:
                    continue
                for d2, c2 in inv_q2j.items():
                    d = d1 + d2 + exponent
                    if d > q_bound:
                        continue
                    total[d] = total.get(d, Fraction(0)) + sign * c1 * c2
    
    return total


def compute_mod14_product(a, q_bound):
    """Compute the infinite product side of Nandi's identities."""
    residues = {
        1: [2, 3, 4, 10, 11, 12],  # +/-2, +/-3, +/-4 mod 14
        2: [1, 4, 6, 8, 10, 13],   # +/-1, +/-4, +/-6 mod 14
        3: [2, 5, 6, 8, 9, 12],    # +/-2, +/-5, +/-6 mod 14
    }
    
    result = {0: Fraction(1)}
    for r in residues[a]:
        # Multiply by 1/(q^r;q^14)_inf
        power = r
        while power <= q_bound:
            new = {}
            for d, c in result.items():
                for m in range(0, (q_bound - d) // power + 1):
                    new[d + m*power] = new.get(d + m*power, Fraction(0)) + c
            result = new
            power += 14
            # Oops, this is wrong. 1/(q^r;q^14)_inf = prod_{n>=0} 1/(1-q^{r+14n}).
            break  # Only process one factor at a time
        
    # Let me redo this properly
    result = {0: Fraction(1)}
    for r in residues[a]:
        n = 0
        while r + 14*n <= q_bound:
            p = r + 14*n
            # Multiply result by 1/(1 - q^p) = sum_{m>=0} q^{pm}
            new = {}
            for d, c in result.items():
                m = 0
                while d + m*p <= q_bound:
                    new[d + m*p] = new.get(d + m*p, Fraction(0)) + c
                    m += 1
            result = new
            n += 1
    
    return result


def main():
    q_bound = 20
    
    print("Nandi's identities: verifying double sum = product (mod 14)")
    print("=" * 60)
    
    for a in [1, 2, 3]:
        print(f"\nN_{a}:")
        Na = compute_nandi_double_sum(a, q_bound)
        Pa = compute_mod14_product(a, q_bound)
        
        print(f"  Double sum coefficients:")
        for d in range(min(15, q_bound+1)):
            val = Na.get(d, Fraction(0))
            if val != 0:
                print(f"    q^{d}: {int(val)}")
        
        print(f"  Product coefficients:")
        for d in range(min(15, q_bound+1)):
            val = Pa.get(d, Fraction(0))
            if val != 0:
                print(f"    q^{d}: {int(val)}")
        
        # Check agreement
        match = True
        for d in range(q_bound + 1):
            if Na.get(d, Fraction(0)) != Pa.get(d, Fraction(0)):
                match = False
                print(f"  MISMATCH at q^{d}: sum={Na.get(d,0)}, prod={Pa.get(d,0)}")
                break
        if match:
            print(f"  MATCH confirmed up to q^{q_bound}")
    
    # Now explore: for d=4 (t=7), the cylindric partition GF has products
    # with modulus 7. When we look at Q_{n,c}(q), the coefficients live
    # in residues mod what?
    print("\n\n" + "=" * 60)
    print("Analyzing Q_{n,c} coefficient patterns for mod-14 structure")
    print("=" * 60)
    
    # Q_{1,(2,1,1)}(q) = 2q + q^2 + q^3 from previous computation
    Q1_d4 = {1: 2, 2: 1, 3: 1}
    Q1_d5 = {1: 2, 2: 2, 3: 1, 4: 1}
    Q1_d7 = {1: 2, 2: 3, 3: 2, 4: 2, 5: 1, 6: 1}
    
    for label, Q1, d in [("d=4", Q1_d4, 4), ("d=5", Q1_d5, 5), ("d=7", Q1_d7, 7)]:
        t = 3 + d
        print(f"\n{label}: Q_{{1,c}}(q), t = {t}")
        print(f"  Coefficients: {Q1}")
        print(f"  Total at q=1: {sum(Q1.values())} (expected {(d+1)*(d+2)//6-1})")
        
        # Analyze: what's the degree range?
        min_deg = min(Q1.keys())
        max_deg = max(Q1.keys())
        print(f"  Degree range: {min_deg} to {max_deg}")
        print(f"  Max degree / t: {max_deg / t:.2f}")
        print(f"  Number of nonzero terms: {len(Q1)}")
        
        # Check if coefficients are related to partition counts mod t
        # or related moduli
        print(f"  Degrees mod {t}: {[k % t for k in Q1.keys()]}")
        print(f"  Degrees mod {2*t}: {[k % (2*t) for k in Q1.keys()]}")
        if d % 7 == 0 or t % 7 == 0:
            print(f"  Degrees mod 14: {[k % 14 for k in Q1.keys()]}")
    
    # Key structural observation:
    # The Takigiku-Tsuchioka double sum for Nandi has the form:
    #   sum_{i,j} (-1)^j * (positive) / ((q;q)_i * (q^2;q^2)_j)
    # The Warnaar conjecture has:
    #   Q_{n,c}(q) = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
    # where (zq;q)_inf = sum_j (-1)^j z^j q^{j(j+1)/2} / (q;q)_j
    #
    # In both cases, (-1)^j creates alternating signs that miraculously cancel.
    # The TT approach resolves this by showing the double sum equals a product.
    # Can we adapt this?
    #
    # Observation: for k=3, F_c(z,q) involves a product formula (Borodin)
    # with modulus t = 3+d. The (zq;q)_inf factor brings in (q;q)_j in
    # the denominator. The resulting Q_{n,c}(q) has the factor (q;q)_n
    # which could cancel with the denominator.
    
    print("\n\n" + "=" * 60)
    print("Structural parallel: TT double sum vs Warnaar definition")
    print("=" * 60)
    print("""
Takigiku-Tsuchioka:
  N_a = sum_{i,j>=0} (-1)^j q^{...} / ((q;q)_i (q^2;q^2)_j)
  Key: (-1)^j cancellation resolves to positive product.
  Method: q-difference equations + known q-series identities.

Warnaar:
  Q_{n,c}(q) = (q;q)_n * sum_{j=0}^n (-1)^j q^{j(j+1)/2}/(q;q)_j * f_{n-j}(q)
  Key: (-1)^j cancellation resolves to positive polynomial.
  
Analogy: Both involve alternating sums over j with 1/(q;q)_j or 1/(q^2;q^2)_j
factors. The TT approach works by finding q-difference equations for the
generating function and solving them. Could the same technique work for
the z-generating function of Q_{n,c}?

Specifically: define G_c(z,q) = (zq;q)_inf * F_c(z,q).
Then [z^n] G_c(z,q) = Q_{n,c}(q) / (q;q)_n.
Can we find a q-difference equation for G_c(z,q)?

G_c(z,q) = (zq;q)_inf * F_c(z,q)
The CW recurrence gives a functional equation for F_c(z,q).
And (zq;q)_inf satisfies: (zq;q)_inf = (1-zq) * (zq^2;q)_inf.
So G_c(z,q) = (1-zq) * (zq^2;q)_inf * F_c(z,q).

If we can relate G_c(z,q) and G_c(zq,q):
G_c(zq,q) = (zq^2;q)_inf * F_c(zq,q)

So G_c(z,q) = (1-zq) * G_c(zq,q) * F_c(z,q)/F_c(zq,q).

This would give a q-difference equation if F_c(z,q)/F_c(zq,q) simplifies.
""")
    
    # Let's compute F_c(z,q)/F_c(zq,q) for small cases
    # by computing the ratio of z-coefficients.
    print("Exploring F_c(z,q)/F_c(zq,q) ratio:")
    print("For c=(1,1,0), d=2, t=5:")
    print("  f_m(q) for F_c: f_0=1, f_1 pattern = (2,1,2,2,1,2,...)")
    print("  F_c(zq,q) = sum_m f_m(q) (zq)^m = sum_m f_m(q) q^m z^m")
    print("  So [z^m] F_c(zq,q) = q^m * f_m(q)")
    print("  Ratio [z^m]F_c/[z^m]F_c(zq) = f_m / (q^m * f_m) = q^{-m}")
    print("  But that's for each coefficient separately, not the ratio of GFs.")
    print("  The ratio as a power series in z is more subtle.")

if __name__ == "__main__":
    main()
