"""
Seed 5: Schubert polynomial analysis of Q_{n,c}(q).

Key idea from seed context: Schubert polynomials Y_v(x,y) are a basis for
polynomials, characterized by vanishing properties (Theorem 3.1.1).
They expand positively in certain bases, and divided differences act
on them in controlled ways.

Question: Can Q_{n,c}(q) be expressed as a specialization of a Schubert
polynomial, or more precisely, as a sum of specializations of Schubert
polynomials with positive coefficients?

Key observations from the seed context:
1. K_u * x^{k...1} = Y_{u+[k,...,1,0^{n-k}]}(x, 0) — products of key
   polynomials with staircase monomials give Schubert polynomials
2. The Pieri formula for Schubert polynomials gives a positive expansion
3. Grothendieck polynomials factorize over Young subgroups
4. Vexillary Schubert polynomials = multi-Schur determinants

Potential connection: The cylindric partition generating function F_c(z,q)
might be related to a specialization of a Schubert kernel or Grothendieck
polynomial, where q plays the role of a ratio of x_i/y_j parameters.

Let me explore:
1. Whether Q_{n,c}(q) at q=q matches any Schur function evaluations
2. Whether the degree patterns match what Schubert theory predicts
3. Whether the q-binomial coefficient expansion of Q_{n,c}(q) is positive
   (which would connect to Schubert calculus via intersection numbers)
"""

# First, let me re-use the seed8 computation infrastructure to get exact Q values
# Then analyze them from the Schubert perspective.

from itertools import combinations
from collections import defaultdict
from math import gcd

MAX_Q = 60
MAX_N = 5

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

def poly_str(p):
    if not p: return "0"
    parts = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0: continue
        if e == 0: parts.append(str(c))
        elif c == 1: parts.append(f"q^{e}")
        elif c == -1: parts.append(f"-q^{e}")
        else: parts.append(f"{c}q^{e}")
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
    if not I_c:
        return []
    terms = []
    for size in range(1, len(I_c)+1):
        for J in combinations(I_c, size):
            c_J = compute_cJ(c, J)
            if any(x < 0 for x in c_J):
                continue
            sign = (-1) ** (size - 1)
            terms.append((sign, size, c_J))
    return terms


def solve_CW_system(target_profile, k=3, max_n=MAX_N, max_q=MAX_Q):
    d = sum(target_profile)
    all_profiles = list(enumerate_profiles(d, k))
    zero_profile = tuple([0] * k)

    cw_system = {}
    for p in all_profiles:
        if p == zero_profile:
            continue
        cw_system[p] = build_CW_system(p, k)

    # Base case
    base_coeffs = {}
    prev_cum = {0: 1}
    base_coeffs[0] = {0: 1}
    for n in range(1, max_n + 1):
        curr_cum = {}
        kn = k * n
        for p, c in prev_cum.items():
            j = 0
            while p + kn * j <= max_q:
                curr_cum[p + kn * j] = curr_cum.get(p + kn * j, 0) + c
                j += 1
        curr_cum = {p: c for p, c in curr_cum.items() if c != 0}
        base_coeffs[n] = poly_sub(curr_cum, prev_cum)
        prev_cum = curr_cum

    B = {}
    B[zero_profile] = {}
    cum = {0: 1}
    for n in range(max_n + 1):
        if n == 0:
            B[zero_profile][0] = {0: 1}
        else:
            cum = poly_add(cum, base_coeffs.get(n, {}))
            B[zero_profile][n] = dict(cum)

    for p in all_profiles:
        if p == zero_profile:
            continue
        B[p] = {-1: {}}
    for p in all_profiles:
        B[p][0] = {0: 1}

    for n in range(1, max_n + 1):
        non_zero = [p for p in all_profiles if p != zero_profile]
        rhs = {}
        for p in non_zero:
            known = dict(B[p][n-1])
            for sign, s, target in cw_system[p]:
                if target == zero_profile:
                    contrib = poly_scale(B[zero_profile][n], sign)
                    contrib = poly_shift(contrib, n * s, max_q)
                    known = poly_add(known, contrib)
            rhs[p] = known

        for p in non_zero:
            B[p][n] = dict(rhs[p])

        max_iter = max_q // max(1, n) + 2
        for iteration in range(max_iter):
            changed = False
            for p in non_zero:
                new_val = dict(rhs[p])
                for sign, s, target in cw_system[p]:
                    if target != zero_profile:
                        contrib = poly_shift(B[target][n], n * s, max_q)
                        contrib = poly_scale(contrib, sign)
                        new_val = poly_add(new_val, contrib)
                if new_val != B[p][n]:
                    changed = True
                B[p][n] = new_val
            if not changed:
                break

    result = {}
    for m in range(max_n + 1):
        if m == 0:
            result[m] = B[target_profile][0]
        else:
            result[m] = poly_sub(B[target_profile][m], B[target_profile][m-1])
    return result, B


def compute_Q(b_coeffs, profile, max_n=MAX_N, max_q=MAX_Q):
    d = sum(profile)
    r = len(profile)
    ell = gcd(d, r)

    def inv_qpoch(m):
        result = {0: 1}
        for i in range(1, m+1):
            new = {}
            for p, c in result.items():
                j = 0
                while p + i*j <= max_q:
                    new[p + i*j] = new.get(p + i*j, 0) + c
                    j += 1
            result = {k: v for k, v in new.items() if v != 0}
        return result

    def qpoch_fin(n):
        result = {0: 1}
        for i in range(1, n+1):
            exp = ell * i
            new = {}
            for p, c in result.items():
                if p <= max_q:
                    new[p] = new.get(p, 0) + c
                if p + exp <= max_q:
                    new[p + exp] = new.get(p + exp, 0) - c
            result = {k: v for k, v in new.items() if v != 0}
        return result

    Q_polys = {}
    for n in range(max_n + 1):
        inner = {}
        for m in range(n+1):
            sign = (-1)**m
            shift = m*(m+1)//2
            if shift > max_q: break
            inv_m = inv_qpoch(m)
            b = b_coeffs.get(n-m, {})
            term = poly_mul(inv_m, b, max_q)
            term = poly_shift(term, shift, max_q)
            term = poly_scale(term, sign)
            inner = poly_add(inner, term)

        qpn = qpoch_fin(n)
        Q = poly_mul(qpn, inner, max_q)
        Q_polys[n] = {k: v for k, v in Q.items() if v != 0}
    return Q_polys


# === Analysis ===

def q_binomial(n, k, max_q=MAX_Q):
    """Compute [n choose k]_q = (q;q)_n / ((q;q)_k * (q;q)_{n-k})."""
    if k < 0 or k > n:
        return {}
    if k == 0 or k == n:
        return {0: 1}
    # Use the recurrence: [n,k] = [n-1,k-1] + q^k * [n-1,k]
    # Or compute directly: numerator / denominator
    num = {0: 1}
    for i in range(n - k + 1, n + 1):
        factor = {0: 1, i: -1}  # (1 - q^i)
        num = poly_mul(num, factor, max_q)
        num = poly_scale(num, -1)  # no wait
    # Actually: [n choose k]_q = prod_{i=1}^{k} (1-q^{n-k+i}) / (1-q^i)
    # = prod_{i=1}^{k} (q^i - q^{n-k+i}) / (q^i - 1) ... hmm
    # Let me just use polynomial division.
    # [n choose k]_q = (q;q)_n / ((q;q)_k * (q;q)_{n-k})
    
    def qpoch(m):
        r = {0: 1}
        for i in range(1, m+1):
            f = {0: 1, i: -1}
            r = poly_mul(r, f, max_q)
        return r
    
    num = qpoch(n)
    den1 = qpoch(k)
    den2 = qpoch(n - k)
    den = poly_mul(den1, den2, max_q)
    
    # Polynomial division: num / den
    # Since [n choose k]_q is a polynomial, this should divide exactly.
    # Do long division.
    quotient = {}
    remainder = dict(num)
    den_lead_deg = min(den.keys()) if den else 0
    den_lead_coeff = den.get(den_lead_deg, 1)
    
    for deg in range(max_q + 1):
        r_coeff = remainder.get(deg, 0)
        if r_coeff == 0:
            continue
        q_coeff = r_coeff // den_lead_coeff  # should divide exactly
        if q_coeff == 0:
            continue
        shift = deg - den_lead_deg
        if shift < 0:
            continue
        quotient[shift] = quotient.get(shift, 0) + q_coeff
        # Subtract q_coeff * q^shift * den from remainder
        for d_deg, d_coeff in den.items():
            r_deg = d_deg + shift
            if r_deg <= max_q:
                remainder[r_deg] = remainder.get(r_deg, 0) - q_coeff * d_coeff
    
    return {k: v for k, v in quotient.items() if v != 0}


def try_q_binomial_expansion(Q_poly, n, max_q=MAX_Q):
    """
    Try to expand Q_{n,c}(q) in the q-binomial basis:
    Q_{n,c}(q) = sum_k a_k * [n choose k]_q * q^{something}
    
    The q-binomial coefficients [n choose k]_q are the Schubert structure constants
    for Grassmannians, so a positive q-binomial expansion would connect to
    Schubert calculus.
    """
    # This is hard to do in general. Instead, let me check:
    # Is Q_{n,c}(q) a product of q-binomials or cyclotomic polynomials?
    pass


def analyze_schur_expansion(Q_poly, max_q=MAX_Q):
    """
    Check if Q_{n,c}(q) can be written as a sum of Schur polynomials
    specialized to q-powers.
    
    At one variable, the Schur polynomial s_lambda(q) = q^{|lambda|} if lambda
    has only one part. For multiple variables specialized to geometric series:
    s_lambda(1, q, q^2, ..., q^{m-1}) is the quantum dimension, which equals
    the q-hook length formula.
    """
    pass


# Main computation and analysis
print("Schubert Polynomial Analysis of Q_{n,c}(q)")
print("=" * 70)

profiles = [
    ((1, 1, 0), 2),
    ((2, 1, 1), 4),
    ((3, 1, 0), 4),
    ((2, 2, 1), 5),
    ((1, 3, 1), 5),
]

for profile, d in profiles:
    if d % 3 == 0:
        continue
    expected_base = (d+1)*(d+2)//6 - 1
    k = 3
    ell = gcd(d, k)
    t = k + d

    print(f"\n{'='*60}")
    print(f"Profile c = {profile}, d = {d}, t = {t}")
    print(f"Expected Q(1) = {expected_base}^n")
    print(f"{'='*60}")

    b_coeffs, B = solve_CW_system(profile, k, min(4, MAX_N), MAX_Q)
    Q_polys = compute_Q(b_coeffs, profile, min(4, MAX_N), MAX_Q)

    for n in range(min(5, MAX_N + 1)):
        Q = Q_polys.get(n, {})
        q1 = sum(Q.values())
        neg = [(k, v) for k, v in sorted(Q.items()) if v < 0]
        all_pos = len(neg) == 0
        
        coeffs = sorted(Q.items())
        
        print(f"\n  n={n}: Q(1)={q1}, match={q1 == expected_base**n}, pos={all_pos}")
        if n <= 3:
            print(f"    Q = {poly_str(Q)}")
        
        if n >= 1:
            # Check degree
            if Q:
                max_deg = max(Q.keys())
                min_deg = min(Q.keys())
                print(f"    deg=[{min_deg}, {max_deg}]")
            
            # Check if Q is a single q-binomial coefficient
            # [m choose k]_q for some m, k
            for m in range(1, 20):
                for kk in range(0, m+1):
                    qb = q_binomial(m, kk, max_q=MAX_Q)
                    if qb == Q:
                        print(f"    Q_{n} = [{m} choose {kk}]_q !!!")
            
            # Check if Q = q^a * [m choose k]_q
            if Q:
                min_d = min(Q.keys())
                Q_shifted = {e - min_d: c for e, c in Q.items()}
                for m in range(1, 20):
                    for kk in range(0, m+1):
                        qb = q_binomial(m, kk, max_q=MAX_Q)
                        if qb == Q_shifted:
                            print(f"    Q_{n} = q^{min_d} * [{m} choose {kk}]_q !!!")

    # For d=2 case, the Q polynomials are q^{n^2}. Let me check:
    # This is trivially positive. The Schubert connection would be
    # that q^{n^2} = principal specialization of a Schur function.
    
    # For d=4, Q_1 = 2q + q^2 + q^3. Let me check Schur specializations.
    # s_{(1)}(1,q,q^2) = 1 + q + q^2 = [3 choose 1]_q. Not matching.
    # s_{(2)}(1,q) = q^2 + q + 1 ... hmm different.
    
    # Actually let me try: is Q_1 for (2,1,1) equal to q * (2 + q + q^2)?
    # = 2q + q^2 + q^3. That factors as q*(q^2 + q + 2). Not a standard object.
    
    # But q * ([3,1]_q + 1) = q * (1 + q + q^2 + 1) = q*(2 + q + q^2). Yes!
    # So Q_1 = q * (1 + [3,1]_q) where [3,1]_q = 1 + q + q^2.
    # Or: Q_1 = q + q*[3 choose 1]_q.


print("\n\n" + "=" * 70)
print("PATTERN ANALYSIS")
print("=" * 70)

# For d=2: Q_n = q^{n^2}. This is the principal specialization of
# the Schur function s_{(n)}(q^{n-1}) = q^{n(n-1)} ... no.
# Actually q^{n^2} = q^{n^2}. In Schubert terms, this is the class
# of a point in Gr(1, n+1), which is [n+1 choose 1]_q evaluated... no.
# q^{n^2} is just a monomial. Not very interesting Schubert-wise.

# For d=4: The Q polynomials are richer. Let me look at the structure.
# Q_1 = 2q + q^2 + q^3 for (2,1,1)
# Q_1 = q + q^2 + q^3 + q^5 for (3,1,0)

# Key question: do these expand positively in the basis of q-binomials?
print("\nq-binomial basis analysis for Q_{n,(2,1,1)}:")
b_coeffs_211, B_211 = solve_CW_system((2,1,1), 3, 4, MAX_Q)
Q_211 = compute_Q(b_coeffs_211, (2,1,1), 4, MAX_Q)

for n in range(1, 5):
    Q = Q_211.get(n, {})
    if not Q:
        continue
    print(f"\n  Q_{n}(q) = {poly_str(Q)}")
    
    # Factor out q^{min_deg}
    min_d = min(Q.keys())
    Q_red = {e - min_d: c for e, c in Q.items()}
    print(f"  = q^{min_d} * ({poly_str(Q_red)})")
    
    # Check if Q_red is a product of (1+q^i) factors
    # These are exactly the factors appearing in q-binomials
    
    # Try: is Q_red a Gaussian polynomial?
    total = sum(Q_red.values())
    max_d = max(Q_red.keys()) if Q_red else 0
    print(f"  Q_red(1) = {total}, max_deg = {max_d}")
    
    # Check against q-binomials
    found = False
    for m in range(max_d + 5):
        for kk in range(m + 1):
            qb = q_binomial(m, kk, MAX_Q)
            if qb == Q_red:
                print(f"  Q_red = [{m} choose {kk}]_q")
                found = True
                break
        if found:
            break
    if not found:
        # Try products of q-binomials
        # [a choose 1]_q * [b choose 1]_q = (1+q+...+q^{a-1}) * (1+q+...+q^{b-1})
        pass

