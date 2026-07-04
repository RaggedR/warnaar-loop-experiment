"""
Seed 8: Iterative Corteel-Welsh extraction.

The Corteel-Welsh functional equation:
  F_c(y,q) = sum_{empty != J subseteq I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})

Note: F_c(0,q) = 1 (the empty cylindric partition contributes 1).

To extract [y^n] F_c(y,q), we can work iteratively:
The [y^n] coefficient of F_c(y,q) depends on [y^m] F_{c(J)}(y,q) for m < n
(because of the y -> yq^{|J|} substitution and the 1/(1-yq^{|J|}) factor).

Wait, that's not quite right. The F_{c(J)} on the RHS is a DIFFERENT generating function
(different profile), so we can't directly extract [y^n] iteratively.

Let me think again...

Actually, the Corteel-Welsh recurrence expresses F_c(y,q) in terms of
F_{c(J)}(yq^s, q) for various shifted profiles c(J). These shifted profiles
may equal c or other profiles. The key is: the set of profiles reachable from c
by the c -> c(J) operation is FINITE (since d is fixed and entries are nonneg).

So we have a SYSTEM of functional equations involving a finite number of
generating functions. We can solve this system by extracting [y^n] iteratively.

Let me set up this system for c = (1,1,0), d=2, k=3.

Profile (1,1,0):
  I_c = {0, 1} (positions with c_i > 0)
  Subsets J:
    J = {0}: |J| = 1
      c(J): c_0 -> c_0-1=0 (i=0 in J, i-1=2 not in J)
             c_1 -> c_1+1=2 (i=1 not in J, i-1=0 in J)
             c_2 -> c_2=0 (neither)
      c(J) = (0, 2, 0)

    J = {1}: |J| = 1
      c(J): c_0 -> c_0=1 (neither)
             c_1 -> c_1-1=0 (i=1 in J, i-1=0 not in J)
             c_2 -> c_2+1=1 (i=2 not in J, i-1=1 in J)
      c(J) = (1, 0, 1)

    J = {0,1}: |J| = 2
      c(J): c_0 -> c_0-1=0 (i=0 in J, i-1=2 not in J)
             c_1 -> c_1=1 (i=1 in J, i-1=0 in J: no change)
             c_2 -> c_2+1=1 (i=2 not in J, i-1=1 in J)
      c(J) = (0, 1, 1)

So F_{(1,1,0)}(y,q) = F_{(0,2,0)}(yq,q)/(1-yq) + F_{(1,0,1)}(yq,q)/(1-yq) - F_{(0,1,1)}(yq^2,q)/(1-yq^2)

Now I need to compute what profiles (0,2,0), (1,0,1), (0,1,1) map to as well.
This will form a finite system.

Let me enumerate ALL profiles with d=2, k=3:
(2,0,0), (0,2,0), (0,0,2), (1,1,0), (1,0,1), (0,1,1)

For each, compute the CW recurrence. Then solve the system iteratively for [y^n].
"""

from itertools import combinations
from collections import defaultdict
from math import gcd

MAX_Q = 50
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
    """All compositions of d into k nonneg parts."""
    if k == 1:
        yield (d,)
        return
    for i in range(d+1):
        for rest in enumerate_profiles(d-i, k-1):
            yield (i,) + rest


def compute_cJ(c, J):
    """Compute shifted profile c(J)."""
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
    """
    Build the Corteel-Welsh recurrence system for profile c.
    Returns list of (sign, |J|, target_profile) for each J.
    """
    I_c = [i for i in range(k) if c[i] > 0]
    if not I_c:
        return []  # base case: c = (0,...,0)

    terms = []
    for size in range(1, len(I_c)+1):
        for J in combinations(I_c, size):
            c_J = compute_cJ(c, J)
            if any(x < 0 for x in c_J):
                continue
            sign = (-1) ** (size - 1)
            terms.append((sign, size, c_J))
    return terms


def compute_base_case_coeffs(k, max_n, max_q):
    """
    For c = (0,...,0) with k parts:
    F_{(0,...,0)}(y,q) = sum_lam q^{k|lam|} y^{lam_1}

    [y^n] = prod_{j=1}^n 1/(1-q^{kj}) - prod_{j=1}^{n-1} 1/(1-q^{kj})
    with [y^0] = 1.
    """
    result = {}
    prev_cum = {0: 1}
    result[0] = {0: 1}

    for n in range(1, max_n + 1):
        # Multiply prev_cum by 1/(1-q^{kn})
        curr_cum = {}
        kn = k * n
        for p, c in prev_cum.items():
            j = 0
            while p + kn * j <= max_q:
                curr_cum[p + kn * j] = curr_cum.get(p + kn * j, 0) + c
                j += 1
        curr_cum = {p: c for p, c in curr_cum.items() if c != 0}

        result[n] = poly_sub(curr_cum, prev_cum)
        prev_cum = curr_cum

    return result


def solve_CW_system(target_profile, k, max_n, max_q):
    """
    Solve the CW system iteratively to get [y^n] F_c(y,q) for n = 0, ..., max_n.

    The system: for each profile c with d = sum(target_profile):
      F_c(y,q) = sum_terms (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1-yq^{|J|})

    [y^n] F_c(y,q) for the (0,...,0) profile is given by the base case.

    For other profiles:
    [y^n] F_c(y,q) = sum_terms sign * [y^n]( F_{c(J)}(yq^s, q) / (1-yq^s) )
    where s = |J|.

    Now [y^n]( G(yq^s, q) / (1-yq^s) ) = sum_{m=0}^n q^{ms} * [y^{n-m}](G(yq^s, q))
                                         = sum_{m=0}^n q^{ms} * q^{(n-m)s} * g_{n-m}(q)
    Wait: if G(y,q) = sum_n y^n g_n(q), then
    G(yq^s, q) = sum_n (yq^s)^n g_n(q) = sum_n y^n q^{ns} g_n(q)
    So [y^m] G(yq^s, q) = q^{ms} g_m(q).

    Then G(yq^s, q)/(1-yq^s) = sum_n y^n * sum_{m=0}^n q^{(n-m)s} * q^{ms} * g_m(q) ...
    Wait: 1/(1-yq^s) = sum_{j>=0} y^j q^{js}.
    So [y^n]( G(yq^s, q) / (1-yq^s) )
    = sum_{j=0}^n q^{js} * [y^{n-j}](G(yq^s, q))
    = sum_{j=0}^n q^{js} * q^{(n-j)s} * g_{n-j}(q)
    = q^{ns} * sum_{j=0}^n g_{n-j}(q)
    = q^{ns} * sum_{m=0}^n g_m(q)

    Wait, that seems too simple. Let me double-check.
    [y^{n-j}](G(yq^s, q)) = q^{(n-j)s} g_{n-j}(q)
    So sum_{j=0}^n q^{js} * q^{(n-j)s} * g_{n-j}(q)
     = sum_{j=0}^n q^{js + (n-j)s} g_{n-j}(q)
     = sum_{j=0}^n q^{ns} g_{n-j}(q)
     = q^{ns} * sum_{m=0}^n g_m(q)

    So [y^n]( F_{c(J)}(yq^s, q) / (1-yq^s) ) = q^{ns} * F_{c(J),n}(q)

    where F_{c(J),n}(q) = sum_{m=0}^n g_m(q) = cumulative sum of [y^m] coefficients up to m=n.

    This is great! The cumulative [y^0] + [y^1] + ... + [y^n] of F_{c(J)}(y,q)
    is exactly F_{c(J), <=n}(q), the GF for cylindric partitions with max <= n.

    So: [y^n] F_c(y,q) = sum_terms sign * q^{n*|J|} * F_{c(J),n}(q)

    And F_{c,n}(q) = sum_{m=0}^n [y^m] F_c(y,q) = cumulative.

    So we have: b_n(c) = [y^n] F_c = sum_terms sign * q^{n*s} * sum_{m=0}^n b_m(c(J))

    Let B_n(c) = F_{c,n}(q) = sum_{m=0}^n b_m(c).

    Then b_n(c) = sum_terms sign * q^{n*s} * B_n(c(J))

    And B_n(c) = B_{n-1}(c) + b_n(c) = B_{n-1}(c) + sum_terms sign * q^{ns} * B_n(c(J))

    This is a system of equations for B_n across all profiles!
    For each n, given B_{n-1}(c) for all c, we solve for B_n(c).

    For the zero profile (0,...,0):
      B_n((0,...,0)) = prod_{j=1}^n 1/(1-q^{kj})

    For non-zero profiles, the equation is:
      B_n(c) = B_{n-1}(c) + sum_{terms for c} sign * q^{ns} * B_n(c(J))

    If c(J) = (0,...,0), then B_n(c(J)) is known.
    If c(J) = c or another non-zero profile, we have a coupled system.

    For d=2, k=3, let me trace the profiles:
    Non-zero profiles: (2,0,0), (0,2,0), (0,0,2), (1,1,0), (1,0,1), (0,1,1)
    Zero profile: (0,0,0)

    By symmetry (cyclic rotation), (2,0,0), (0,2,0), (0,0,2) are all equivalent,
    and (1,1,0), (1,0,1), (0,1,1) are all equivalent.

    Let me compute the CW terms for each.
    """
    d = sum(target_profile)

    # Enumerate all profiles
    all_profiles = list(enumerate_profiles(d, k))
    profile_idx = {p: i for i, p in enumerate(all_profiles)}
    zero_profile = tuple([0] * k)

    # Build CW system for each non-zero profile
    cw_system = {}
    for p in all_profiles:
        if p == zero_profile:
            continue
        cw_system[p] = build_CW_system(p, k)

    print(f"Profiles: {all_profiles}")
    print(f"CW system:")
    for p, terms in cw_system.items():
        for sign, s, target in terms:
            print(f"  F_{p} has term: {'+'if sign>0 else '-'} F_{target}(yq^{s}, q) / (1-yq^{s})")

    # Base case: compute B_n for zero profile
    base_coeffs = compute_base_case_coeffs(k, max_n, max_q)
    B = {}
    B[zero_profile] = {}
    cum = {0: 1}
    for n in range(max_n + 1):
        if n == 0:
            B[zero_profile][0] = {0: 1}
        else:
            cum = poly_add(cum, base_coeffs.get(n, {}))
            B[zero_profile][n] = dict(cum)

    # Initialize B for other profiles
    for p in all_profiles:
        if p == zero_profile:
            continue
        B[p] = {-1: {}}  # B_{-1} = 0

    # For n = 0: b_0(c) = [y^0] F_c(y,q) = F_c(0,q) = 1 for ALL profiles
    # (the empty cylindric partition has max = 0 and size = 0)
    for p in all_profiles:
        B[p][0] = {0: 1}

    # For n >= 1: solve the system iteratively
    for n in range(1, max_n + 1):
        # b_n(c) = sum_terms sign * q^{ns} * B_n(c(J))
        # B_n(c) = B_{n-1}(c) + b_n(c)
        #
        # The system is:
        # B_n(c) = B_{n-1}(c) + sum_terms sign * q^{ns} * B_n(c(J))
        #
        # This couples different profiles. We need to solve simultaneously.
        # However, if all c(J) in the terms for c are either (0,...,0) or
        # reduce to profiles whose B_n we already know, we can solve directly.
        #
        # For d=2, k=3:
        # Let me check which profiles appear as c(J) targets.

        # For the general case, set up linear equations (over polynomial ring).
        # B_n(c) - sum_{c(J) != (0,...,0)} sign * q^{ns} * B_n(c(J)) = B_{n-1}(c) + sum_{c(J)=(0,...,0)} sign * q^{ns} * B_n((0,...,0))
        #
        # This is a system (I - M) * X = rhs where X = [B_n(c)] for non-zero c,
        # M encodes the CW terms between non-zero profiles,
        # and rhs absorbs known quantities.
        #
        # Since our polynomials are truncated, we can solve this degree by degree.

        non_zero = [p for p in all_profiles if p != zero_profile]

        # For each non-zero profile c, the equation is:
        # B_n(c) = B_{n-1}(c) + sum_{(sign, s, target) for c} sign * q^{ns} * B_n(target)
        # = B_{n-1}(c) + sum_{target=(0,...,0)} sign * q^{ns} * B_n((0,...,0))
        #   + sum_{target != (0,...,0)} sign * q^{ns} * B_n(target)

        # The known part (rhs):
        rhs = {}
        for p in non_zero:
            known = dict(B[p][n-1])
            for sign, s, target in cw_system[p]:
                if target == zero_profile:
                    contrib = poly_scale(B[zero_profile][n], sign)
                    contrib = poly_shift(contrib, n * s, max_q)
                    known = poly_add(known, contrib)
            rhs[p] = known

        # The coupling terms:
        # B_n(c) - sum_{target in non_zero} coeff(c,target) * B_n(target) = rhs(c)
        # where coeff(c, target) = sum of sign * q^{ns} over terms with that target.

        # Build coupling matrix
        coupling = {}  # coupling[(c, target)] = polynomial coefficient
        for p in non_zero:
            for sign, s, target in cw_system[p]:
                if target != zero_profile:
                    key = (p, target)
                    contrib = poly_scale({n * s: 1}, sign)
                    if key in coupling:
                        coupling[key] = poly_add(coupling[key], contrib)
                    else:
                        coupling[key] = contrib

        # Solve by iteration: since coupling terms involve q^{ns} with s >= 1,
        # the coupling shifts the q-degree by at least n.
        # So for degrees < n, B_n(c) = rhs(c).
        # For degrees >= n, we need iteration.

        # Initialize B_n to rhs
        for p in non_zero:
            B[p][n] = dict(rhs[p])

        # Iterate to convergence (the coupling shifts by at least n per step)
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

    # Extract [y^m] = b_m = B_m - B_{m-1}
    result = {}
    for m in range(max_n + 1):
        if m == 0:
            result[m] = B[target_profile][0]
        else:
            result[m] = poly_sub(B[target_profile][m], B[target_profile][m-1])

    return result, B


def compute_Q(b_coeffs, profile, max_n, max_q):
    """Compute Q_{n,c}(q)."""
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


def main():
    profiles = [
        (1, 1, 0),
        (2, 1, 1),
        (2, 2, 1),
    ]

    for profile in profiles:
        d = sum(profile)
        if d % 3 == 0:
            continue
        k = 3
        ell = gcd(d, k)
        expected_base = (d+1)*(d+2)//6 - 1

        print(f"\n{'='*60}")
        print(f"Profile c = {profile}, d = {d}, ell = {ell}")
        print(f"Expected Q(1) = {expected_base}^n")
        print(f"{'='*60}")

        max_n = min(4, 6 if d <= 2 else 3)
        max_q = 40

        b_coeffs, B = solve_CW_system(profile, k, max_n, max_q)

        print(f"\n[y^m] F_c(y,q):")
        for m in range(max_n + 1):
            b = b_coeffs.get(m, {})
            s = sum(b.values()) if b else 0
            print(f"  [y^{m}]: sum = {s}")

        # Verify F_{c,n}(q) at q=1
        print(f"\nF_{{c,n}}(1):")
        for n in range(max_n + 1):
            Bn = B[profile][n]
            s = sum(Bn.values()) if Bn else 0
            print(f"  F_{{c,{n}}}(1) = {s}")

        Q_polys = compute_Q(b_coeffs, profile, max_n, max_q)

        print(f"\nQ_{{n,c}}(q):")
        for n in range(max_n + 1):
            Q = Q_polys.get(n, {})
            q1 = sum(Q.values())
            neg = [(k, v) for k, v in sorted(Q.items()) if v < 0]
            all_pos = len(neg) == 0
            print(f"  Q_{{{n}}}(q) = {poly_str(Q)[:100]}")
            print(f"    Q(1) = {q1}, expected = {expected_base**n}, match = {q1 == expected_base**n}")
            if all_pos:
                print(f"    ALL NONNEG")
            else:
                print(f"    NEGATIVE: {neg[:5]}")


if __name__ == "__main__":
    main()
