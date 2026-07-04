"""
Seed 1 Layer 2: Test if h_m matches Hall-Littlewood principal specializations.

The KWZ formula (Lemma 2.4 from Griffin-Ono-Warnaar) gives:
  P_lambda(1, q, q^2, ...; q^n) = sum over chains of partitions
  
At the specialization x = (1, q, q^2, ...) with parameter q^n (so t = q^n),
this is a manifestly positive multisum.

For rank 1 (n=1): P_{(a)}(x; q) = h_a(x) (complete symmetric function),
and at x = (1, q, q^2, ...): P_{(a)}(1,q,q^2,...; q) = 1/(q;q)_a.

For rank 2 (n=2): P_{(a,b)}(1,q,...; q^2) has a more complex formula.

The question: for profile c = (c_0, c_1, c_2) with d = sum(c), 
is h_m related to P_lambda for some lambda depending on c and m?

Concrete test for d=4, c=(2,1,1):
  h_1 = 3q + q^2 + q^3, h_1(1) = 5.
  
  What HL polynomial at a geometric specialization gives evaluation 5?
  P_{(1)}(1,q,...;q^n) for n variables gives... 
  Actually for the principal specialization:
  P_{(1^k)}(1,q,...,q^{n-1}; q^n) = q^{k(k-1)/2} [n choose k]_{q^n} / (stuff)

Let me just compute some HL principal specializations and compare.

Actually, let me think about this differently. The key formula from
Larson's "generalized Andrews-Gordon" (chunk 16 of seed context):

P_lambda(1,q,q^2,...; q^n) = sum_{chains} B_{m,n}(s; q^n) * q^{A_{m,n}(s)}

For n=3 (since we have k=3 partitions in the cylindric partition):
P_lambda(1,q,q^2,...; q^3) would involve sums over chains with q^3 binomials.

Modulus t = k + d = 3 + d.

For d=4: t = 7, and the HL polynomials live in the A_2 setting (3 variables).
The principal specialization P_lambda(1, q, q^2; q^3) evaluates a HL polynomial
in 3 variables at x = (1, q, q^2) with parameter t = q^3.

Let me compute these and compare with h_m.
"""

from math import comb

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_mul(a, b, max_deg=200):
    result = {}
    for i, ai in a.items():
        if ai == 0 or i > max_deg: continue
        for j, bj in b.items():
            if bj == 0 or i + j > max_deg: continue
            result[i + j] = result.get(i + j, 0) + ai * bj
    return {k: v for k, v in result.items() if v != 0}

def qbinom(n, k, q_step=1, max_deg=100):
    """
    Compute [n choose k]_{q^step} as polynomial in q.
    [n choose k]_t = (t;t)_n / ((t;t)_k * (t;t)_{n-k}) where t = q^step.
    """
    if k < 0 or k > n: return {}
    if k == 0 or k == n: return {0: 1}
    
    # Build via q-Pascal: [n;k]_t = [n-1;k-1]_t + t^{n-k} [n-1;k]_t
    table = {}
    for nn in range(n+1):
        for kk in range(min(nn, k)+1):
            if kk == 0 or kk == nn:
                table[(nn, kk)] = {0: 1}
            else:
                a = table[(nn-1, kk-1)]
                b = table[(nn-1, kk)]
                shift = (nn - kk) * q_step
                b_shifted = {p + shift: v for p, v in b.items()}
                result = dict(a)
                for p, v in b_shifted.items():
                    result[p] = result.get(p, 0) + v
                table[(nn, kk)] = {p: v for p, v in result.items() if v != 0}
    return table[(n, k)]

def hl_principal_spec_rank2(a, b, n_step=3, max_deg=100):
    """
    Compute P_{(a,b)}(1, q, q^2, ...; q^n) for rank 2 (2-part partition).
    
    Using the KWZ formula (Lemma from Larson):
    P_{(a,b)}(1,q,q^2,...; q^n) = sum over chains.
    
    For a 2-part partition (a >= b >= 0):
    The chain has m = a (number of columns in lambda' with first column).
    lambda' = (2^b, 1^{a-b}).
    
    Wait, for the KWZ formula, we need lambda and then chains of partitions
    mu^(n) = 0 subset mu^(n-1) subset ... subset mu^(0) = lambda'.
    
    For n = 1 (i.e., t = q):
    P_{(a)}(1,q,...; q) = 1/(q;q)_a (just the inverse q-Pochhammer).
    
    For n = 2 (i.e., t = q^2):
    lambda = (a,b), lambda' has parts determined by conjugation.
    
    Actually, let me use a simpler formula. For the principal specialization
    of Hall-Littlewood polynomials:
    
    P_lambda(1,q,...,q^{n-1}; q^n) = q^{n(lambda)} * prod_i 1/(q^n; q^n)_{m_i(lambda)}
    * prod_{s in lambda} 1/(1 - q^{n*a'(s) + l'(s) + 1}) * ...
    
    This is getting complicated. Let me just compute via the direct formula for small cases.
    """
    # For simplicity, compute via the Cauchy identity approach.
    # P_lambda(x; t) at x = (1, q, q^2, ..., q^{n-1}) and t = q^n.
    # 
    # Use the formula: P_lambda(1, q, ..., q^{N-1}; t) where we compute
    # as a polynomial in q.
    #
    # For lambda = (a) (one row): 
    #   P_{(a)}(1,...,q^{N-1}; t) = [a+N-1 choose a]_q / ... 
    #   Actually P_{(a)} at principal spec = 1/c_lambda * product formula
    #
    # Let me use a different approach: the monomial sum.
    
    # For rank-2 partition (a, b) with a >= b:
    # P_{(a,b)}(x_1, x_2; t) = sum over SSYT T of shape (a,b) with entries in {1,2}
    #                           * t^{charge(T)} * x^{content(T)}
    # At x = (1, q) and t = q^2:
    # This becomes sum over fillings T * q^{2*charge(T)} * q^{(number of 2s in T)}
    
    # Actually, the correct formula for P_lambda in 2 variables:
    # P_{(a,b)}(x_1, x_2; t) = x_1^a x_2^b + terms
    
    # Let me use the recursive/determinantal formula instead.
    pass

def compute_hl_1var(a, n=1, max_deg=50):
    """
    P_{(a)}(1, q, q^2, ...; q^n) -- one-part partition.
    
    This equals 1/(q^n; q^n)_a by the principal specialization formula,
    which is NOT a polynomial. So this is the generating function for
    partitions with at most a parts, each part a multiple of n.
    
    Wait, that's the inverse Pochhammer. We need a TRUNCATION for polynomials.
    
    Actually: P_{(a)}(1, q, ..., q^{N-1}; q^n) for N variables is a polynomial.
    As N -> infinity, it becomes the series 1/(q^n;q^n)_a.
    
    For FINITE N variables:
    P_{(a)}(1, q, ..., q^{N-1}; q^n) = q^{n*binom(a,2)} * [N+a-1 choose a]_{q^n} / ...
    
    Hmm, I need to be more careful. Let me just compute directly.
    """
    pass

def hl_ps_1part_Nvar(a, N, t_step, max_deg=50):
    """
    Compute P_{(a)}(1, q, ..., q^{N-1}; q^{t_step}) as a polynomial in q.
    
    For P_{(a)} = h_a (complete symmetric function) in the HL basis:
    P_{(a)}(x; t) = sum over partitions mu of a * t^{...} * m_mu(x)
    
    At the principal specialization x = (1, q, ..., q^{N-1}):
    m_{(1^k)}(1, q, ..., q^{N-1}) = e_k(1, q, ..., q^{N-1}) = q^{binom(k,2)} [N choose k]_q
    
    h_a(1, q, ..., q^{N-1}) = sum over partitions of a of products of m_mu(1,...,q^{N-1})
    
    Actually, h_a(1, q, ..., q^{N-1}) = [N+a-1 choose a]_q (the q-multiset coefficient).
    
    But P_{(a)} != h_a in general for HL polynomials (P is NOT the power sum or 
    complete symmetric function in general).
    
    For t=0: P_lambda = Schur function s_lambda.
    For general t: P_lambda is the Hall-Littlewood polynomial.
    
    The formula: P_{(a)}(x; t) = sum_{mu of a} z_mu^{-1} prod_i (1-t^{m_i}) * p_mu(x)
    ... this is getting complicated. Let me just tabulate small cases.
    """
    # For a=1: P_{(1)}(x; t) = m_{(1)} = sum x_i. So P_{(1)}(1,q,...,q^{N-1}; t) = (1-q^N)/(1-q) = [N]_q.
    if a == 0: return {0: 1}
    if a == 1:
        # [N]_q = 1 + q + q^2 + ... + q^{N-1}
        return {i: 1 for i in range(N)}
    
    # For a=2: P_{(2)}(x; t) = m_{(2)} + m_{(1,1)} = sum x_i^2 + sum_{i<j} x_i x_j
    # At x = (1,q,...,q^{N-1}):
    # m_{(2)} = sum q^{2i} = (1-q^{2N})/(1-q^2) = [N]_{q^2}
    # m_{(1,1)} = sum_{i<j} q^{i+j} = [N choose 2]_q... wait, that's e_2.
    # 
    # P_{(2)}(x; t) has a specific definition. Let me look it up.
    # P_{(a)}(x; t) = (1/v_lambda(t)) * sum_{w in S_n} w(x^lambda * prod_{i<j} (x_i - t*x_j)/(x_i - x_j))
    # For lambda = (a, 0, ..., 0) and S_n acting on N variables.
    # 
    # This is too complex for manual computation. Let me just compare h_m values
    # with known HL evaluations from the literature.
    
    # ALTERNATIVE: use the Weyl character formula approach.
    # P_{(a)}(1,q,...,q^{N-1}; t) for the one-row partition is:
    # P_{(a)}(x; t) = h_a(x) (the complete symmetric function, for any t!)
    # because for a one-row partition, the HL polynomial equals the Schur = complete.
    
    # So P_{(a)}(1,q,...,q^{N-1}; t) = h_a(1,q,...,q^{N-1}) = [N+a-1 choose a]_q
    
    # This is the q-multiset coefficient.
    return qbinom(N + a - 1, a, q_step=1, max_deg=max_deg)


def main():
    # For d=4, c=(2,1,1): base = 5, h_1 = 3q + q^2 + q^3, h_1(1) = 5.
    # 
    # Can h_1 be written as a HL polynomial P_lambda(principal spec)?
    #
    # P_{(1)}(1,q,q^2; q^3) = [3]_q = 1 + q + q^2 = 3 at q=1. Not 5.
    # P_{(1)}(1,q,...,q^4; q^5) = [5]_q = 1+q+q^2+q^3+q^4 = 5 at q=1. 
    #   But [5]_q = 1+q+q^2+q^3+q^4, while h_1 = 3q+q^2+q^3. Different!
    #
    # P_{(2)}(1,q; q^2) = h_2(1,q) = [3 choose 2]_q = 1+q+q^2 = 3. Not 5.
    # P_{(1,1)}(1,q; q^2) = e_2(1,q) = q. eval = 1. Not 5.
    #
    # How about sums of HL polynomials?
    # h_1 = 3q + q^2 + q^3 = q(3 + q + q^2) = q * [3]_q ... no, [3]_q = 1+q+q^2.
    #   So h_1 = q * (3 + q + q^2). Hmm, 3 + q + q^2 is NOT a standard q-integer.
    #   But 3 + q + q^2 = 2 + (1+q+q^2) = 2 + [3]_q.
    #
    # Or: h_1 = 3q + q^2 + q^3 = q(1+q+q^2) + 2q = q*[3]_q + 2q.
    #
    # For d=5, c=(2,2,1): h_1 = 3q + 2q^2 + q^3 + q^4, h_1(1) = 7.
    #   h_1 = q(3 + 2q + q^2 + q^3).
    #   7 = (6*7)/6 = binomial(7,2)/3? No, 7 = (d+1)(d+2)/6 = 6*7/6 = 7.
    #
    # For d=7, c=(3,2,2): h_1 = 3q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6, h_1(1) = 12.
    #   12 = (8*9)/6 = 12. Yes.
    #   h_1 = q(3 + 3q + 2q^2 + 2q^3 + q^4 + q^5).
    #   The inner poly: 3 + 3q + 2q^2 + 2q^3 + q^4 + q^5.
    #   This evaluates to 12 at q=1.
    
    # KEY PATTERN: h_1/q = 3 + ... evaluates to base at q=1.
    # And h_1 always starts with 3q.
    # 
    # For d=4: h_1/q = 3 + q + q^2 = 2 + [3]_q
    # For d=5: h_1/q = 3 + 2q + q^2 + q^3
    # For d=7 (3,2,2): h_1/q = 3 + 3q + 2q^2 + 2q^3 + q^4 + q^5
    # For d=7 (4,2,1): h_1/q = 3 + 2q + 2q^2 + 2q^3 + q^4 + q^5 + q^7
    
    # NOTE: the h_1/q polynomial is profile-dependent but always starts with 3.
    # The polynomial h_1/q has a palindromic-like structure for symmetric profiles.
    
    # For c=(3,2,2): h_1/q = 3 + 3q + 2q^2 + 2q^3 + q^4 + q^5
    # Reverse: q^5 + q^4 + 2q^3 + 2q^2 + 3q + 3 -- same as q^5 * (h_1/q)(1/q)
    # = 3 + 3q + 2q^2 + 2q^3 + q^4 + q^5. Palindromic!
    
    # For c=(2,1,1): h_1/q = 3 + q + q^2. Reverse: q^2 + q + 3. NOT palindromic.
    # But (2,1,1) is NOT self-conjugate under profile reversal.
    
    # For c=(4,2,1): h_1/q = 3 + 2q + 2q^2 + 2q^3 + q^4 + q^5 + q^7
    # NOT palindromic (gap at q^6, extra q^7).
    
    print("=== h_1 structure analysis ===")
    print()
    
    # Known h_1 values from Layer 1 and Layer 2 computations
    h1_data = {
        (1,1,0): {1: 2},  # d=2, h_1(1) = 2 = base
        (2,1,1): {1: 3, 2: 1, 3: 1},  # d=4, h_1(1) = 5
        (2,2,1): {1: 3, 2: 2, 3: 1, 4: 1},  # d=5, h_1(1) = 7
        (3,1,1): {1: 3, 2: 1, 3: 2, 5: 1},  # d=5, h_1(1) = 7
        (3,2,2): {1: 3, 2: 3, 3: 2, 4: 2, 5: 1, 6: 1},  # d=7, h_1(1) = 12
        (4,2,1): {1: 3, 2: 2, 3: 2, 4: 2, 5: 1, 6: 1, 8: 1},  # d=7, h_1(1) = 12
    }
    
    for profile, h1 in h1_data.items():
        d = sum(profile)
        base = (d+1)*(d+2)//6
        h1_q1 = sum(h1.values())
        
        # h_1/q polynomial
        h1_shifted = {k-1: v for k, v in h1.items()}
        max_d = max(h1_shifted.keys())
        
        print(f"c = {profile}, d = {d}, base = {base}")
        print(f"  h_1(q)/q = ", end="")
        parts = []
        for e in sorted(h1_shifted.keys()):
            c = h1_shifted[e]
            if e == 0: parts.append(str(c))
            elif c == 1: parts.append(f"q^{e}")
            else: parts.append(f"{c}q^{e}")
        print(" + ".join(parts))
        
        # Check palindromicity
        rev = {max_d - k: v for k, v in h1_shifted.items()}
        is_palindrome = all(h1_shifted.get(k, 0) == rev.get(k, 0) for k in set(list(h1_shifted.keys()) + list(rev.keys())))
        print(f"  palindromic: {is_palindrome}")
        print(f"  max degree of h_1: {max_d + 1}")
        print()
    
    # Now let me check: the number base = (d+1)(d+2)/6 counts lattice points
    # (a,b,c) with a+b+c = d and the cyclic interlacing conditions.
    # These are triples (a,b,c) >= 0 with a+b+c = d such that:
    # the "column" CPP with entries a, b, c (in positions 0, 1, 2) satisfies interlacing.
    # 
    # For a single column of max = 1: the partition in slot i is either (1) or ().
    # The interlacing condition: if slot i has (1) and slot i+1 has (),
    # then we need 1 >= 0 (part 0 >= part c_{i+1}) which is always true for c_{i+1} >= 1.
    # But if c_{i+1} = 0, then we need part_j of slot i >= part_j of slot i+1 for all j,
    # which is (1) >= () at j=0: 1 >= 0 OK. And j=1 onwards: 0 >= 0 OK.
    #
    # Actually I think the count of binary column CPPs is more subtle.
    # Let me compute it directly.
    
    print("=== Binary column CPP count ===")
    for profile in [(1,1,0), (2,1,1), (2,2,1), (3,2,2), (4,2,1)]:
        d = sum(profile)
        base = (d+1)*(d+2)//6
        c0, c1, c2 = profile
        
        # A binary CPP has max = 1, so each lambda^i has parts in {0, 1}.
        # lambda^i is determined by its length (number of 1s).
        # Let a = len(lambda^0), b = len(lambda^1), c_len = len(lambda^2).
        
        # Interlacing: lambda^i_j >= lambda^{i+1}_{j + c_{i+1}} for all j.
        # For binary partitions (entries 0 or 1):
        # lambda^i = (1^a_i). Then lambda^i_j = 1 if j < a_i, else 0.
        # Condition: 1_{j < a_i} >= 1_{j + c_{i+1} < a_{i+1}} for all j.
        # This means: for j >= a_i, we need j + c_{i+1} >= a_{i+1}, i.e., a_{i+1} <= j + c_{i+1}.
        # Taking j = a_i: a_{i+1} <= a_i + c_{i+1}.
        
        # Cyclic: a_0 <= a_2 + c_0, a_1 <= a_0 + c_1, a_2 <= a_1 + c_2.
        # Also a_0 + a_1 + a_2 > 0 (for max = 1).
        
        # And max = 1 means at least one a_i >= 1.
        
        count = 0
        for a0 in range(d + 1):
            for a1 in range(d + 1):
                for a2 in range(d + 1):
                    if a0 == 0 and a1 == 0 and a2 == 0: continue  # max must be 1
                    if a1 > a0 + c1: continue
                    if a2 > a1 + c2: continue
                    if a0 > a2 + c0: continue
                    count += 1
        
        # Also count the total (including (0,0,0)):
        count_with_zero = count + 1
        print(f"c = {profile}: binary CPPs with max=1: {count}")
        print(f"  base = {base}, count+1 = {count + 1}")
        
        # Also: count the weight-1 binary CPPs (exactly one a_i = 1, rest = 0)
        weight1 = 0
        for i in range(3):
            a = [0, 0, 0]
            a[i] = 1
            ok = True
            if a[1] > a[0] + c1: ok = False
            if a[2] > a[1] + c2: ok = False
            if a[0] > a[2] + c0: ok = False
            if ok: weight1 += 1
        print(f"  weight-1 CPPs: {weight1} (should be 3)")


if __name__ == "__main__":
    main()
