"""
Seed 8: Use Corteel-Welsh functional equation to compute F_c(y,q) exactly.

The key identity:
  F_c(y,q) = sum_{J != empty, J subseteq I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})

with F_c(0,q) = 1 and the base case when c has all entries 0 giving F_0(y,q) = 1/(1-y).

For c = (c_0, c_1, c_2), I_c = {i : c_i > 0}.

We can use this to compute [y^n] F_c(y,q) as a power series in q.

The key observation: the operation c -> c(J) either decreases some c_i by 1 or increases it.
But the total d = sum(c_i) is preserved. What changes is the shape.

For c = (0,0,...,0), we have a trivial cylindric partition: all lambda^i are the same.
Then F_{(0,...,0)}(y,q) = 1/(1-y) * 1/(1-yq) * 1/(1-yq^2) * ...
Wait, no. For c = (0,0,0) with k=3, the conditions become
lam^i_j >= lam^{i+1}_j for all i,j (cyclic), so all three partitions are equal.
F_{(0,0,0)}(y,q) = sum_{lam partition} q^{3|lam|} y^{lam_1}
= sum_{n>=0} y^n * sum_{lam : lam_1 = n} q^{3|lam|}
= sum_{n>=0} y^n * q^{3n} * (sum_{partitions with max part n} q^{3(|lam|-n)})
Hmm, that's not simple.

Actually F_{(0,0,0)}(y,q) = prod_{j>=1} 1/(1 - yq^{3j}) ... no.

Let me reconsider. For the zero profile c = (0,0,0), the cylindric partition is
three identical partitions. So F = sum_lam q^{3|lam|} y^{max(lam)}.
For a single partition lam, |lam| = sum of parts and max(lam) = lam_1.
So F = sum_{n>=0} y^n * sum_{lam with lam_1 <= n} ... no, max = n means lam_1 = n.
But actually max(Lambda) for the cylindric partition is max of all lambda^i_1.
Since they're all equal, max = lam_1.

So F_{(0,0,0)}(y,q) = sum_{lam} q^{3|lam|} y^{lam_1}.

Now sum_{lam} q^{3|lam|} y^{lam_1} = sum_{n>=0} y^n * (F_{n}(q^3) - F_{n-1}(q^3))
where F_n(q) = sum_{lam: parts <= n} q^|lam| = prod_{i=1}^{inf} 1/(1-q^i) restricted...

Actually for partitions with parts <= n:
sum_{lam: lam_1 <= n} q^|lam| = prod_{i=1}^n 1/(1-q^i) ... no, that's partitions
with at most n parts. For parts <= n, it's 1/(q;q)_inf * ... hmm, no.

Partitions with largest part <= n are in bijection with partitions with at most n parts
(by conjugation). And sum_{lam: at most n parts} q^|lam| = prod_{i=1}^n 1/(1-q^i) = 1/(q;q)_n.

Wait, that's wrong too. sum over partitions with at most n parts of q^|lam| = 1/(q;q)_n?
No: 1/(q;q)_n = 1/((1-q)(1-q^2)...(1-q^n)) = sum over partitions with at most n parts.

Actually that's correct by the generating function for partitions into at most n parts.

So: sum_{lam: largest part <= n} q^|lam| = 1/(q;q)_n  (by conjugation bijection).

Then F_{(0,0,0)}(y,q) = sum_{n>=0} y^n * [1/(q^3;q^3)_n - 1/(q^3;q^3)_{n-1}]
with the convention 1/(q^3;q^3)_{-1} = 0.

OK this is getting complicated. Let me just use the Corteel-Welsh recurrence computationally.

The key issue with direct enumeration was not enough parts. The recurrence avoids this.

Let me implement F_c(y,q) as a formal power series in both y and q.
I'll represent it as a dict: n -> polynomial_in_q, where n is the power of y.
"""

from collections import defaultdict
from math import gcd
from functools import lru_cache
import json

MAX_Q_DEG = 40
MAX_Y_DEG = 6


def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}


def poly_sub(a, b):
    return poly_add(a, {k: -v for k, v in b.items()})


def poly_mul(a, b, max_deg=MAX_Q_DEG):
    result = {}
    for i, ai in a.items():
        if ai == 0 or i > max_deg:
            continue
        for j, bj in b.items():
            if bj == 0 or i + j > max_deg:
                continue
            result[i + j] = result.get(i + j, 0) + ai * bj
    return {k: v for k, v in result.items() if v != 0}


def poly_scale(p, s):
    if s == 0:
        return {}
    return {k: v * s for k, v in p.items()}


def poly_shift(p, s, max_deg=MAX_Q_DEG):
    return {k + s: v for k, v in p.items() if k + s <= max_deg}


def poly_str(p):
    if not p:
        return "0"
    parts = []
    for e in sorted(p.keys()):
        c = p[e]
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
    return " + ".join(parts).replace("+ -", "- ") if parts else "0"


def inv_1_minus_yqa(a, max_y, max_q=MAX_Q_DEG):
    """
    Compute 1/(1 - y*q^a) as a bivariate series in y and q.
    Returns dict: y_power -> polynomial_in_q.
    1/(1-yq^a) = sum_{n>=0} y^n * q^{na}
    """
    result = {}
    for n in range(max_y + 1):
        if n * a <= max_q:
            result[n] = {n * a: 1}
        else:
            break
    return result


def biv_add(f, g, max_y=MAX_Y_DEG):
    """Add two bivariate series."""
    result = {}
    keys = set(list(f.keys()) + list(g.keys()))
    for n in keys:
        if n > max_y:
            continue
        fn = f.get(n, {})
        gn = g.get(n, {})
        s = poly_add(fn, gn)
        if s:
            result[n] = s
    return result


def biv_sub(f, g, max_y=MAX_Y_DEG):
    result = {}
    keys = set(list(f.keys()) + list(g.keys()))
    for n in keys:
        if n > max_y:
            continue
        fn = f.get(n, {})
        gn = g.get(n, {})
        s = poly_sub(fn, gn)
        if s:
            result[n] = s
    return result


def biv_scale(f, s):
    """Multiply by scalar."""
    return {n: poly_scale(p, s) for n, p in f.items() if p}


def biv_yq_shift(f, q_shift, max_y=MAX_Y_DEG, max_q=MAX_Q_DEG):
    """
    Replace y by y*q^{q_shift} in the bivariate series f.
    If f = sum_n y^n * p_n(q), then result = sum_n y^n * q^{n*q_shift} * p_n(q).
    """
    result = {}
    for n, pn in f.items():
        if n > max_y:
            continue
        shifted = poly_shift(pn, n * q_shift, max_q)
        if shifted:
            result[n] = shifted
    return result


def biv_mul_inv_1_minus_yqa(f, a, max_y=MAX_Y_DEG, max_q=MAX_Q_DEG):
    """
    Multiply bivariate series f by 1/(1 - y*q^a).
    1/(1-yq^a) = sum_{m>=0} y^m * q^{ma}.
    If f = sum_n y^n * p_n(q), then
    f / (1-yq^a) = sum_n y^n * sum_{m=0}^n q^{ma} * p_{n-m}(q).
    """
    result = {}
    for n in range(max_y + 1):
        s = {}
        for m in range(n + 1):
            shift = m * a
            if shift > max_q:
                break
            p_nm = f.get(n - m, {})
            if p_nm:
                s = poly_add(s, poly_shift(p_nm, shift, max_q))
        if s:
            result[n] = s
    return result


def compute_Fc_bivariate(c_tuple, max_y=MAX_Y_DEG, max_q=MAX_Q_DEG, memo=None):
    """
    Compute F_c(y,q) using Corteel-Welsh recurrence.

    F_c(y,q) = sum_{J != empty, J subseteq I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})

    Base case: when all c_i = 0, F_{(0,...,0)}(y,q) = sum_lam q^{k|lam|} y^{lam_1}
    where k = len(c) and the sum is over all partitions lam.

    For the zero profile case with k=3:
    F_{(0,0,0)}(y,q) = sum_{lam} q^{3|lam|} y^{lam_1}

    We can compute this as:
    [y^0] = 1 (empty partition)
    [y^n] = sum_{lam: lam_1 = n} q^{3|lam|}
          = q^{3n} * sum_{lam: parts <= n, at most "inf" parts, lam_1 = n} q^{3(|lam|-n)}
    This is messy. Let me think...

    Actually, sum_{lam: lam_1 <= n} q^{3|lam|} = prod_{j=1}^n 1/(1-q^{3j})
    (partitions with parts <= n, then multiply sizes by 3 is same as partitions
    with parts in {3, 6, 9, ..., 3n}, which is prod 1/(1-q^{3j})).

    Wait, no. lam_1 <= n means lam is a partition with largest part <= n.
    The GF for partitions with parts <= n is prod_{j=1}^n 1/(1-q^j).
    But we're computing q^{3|lam|} = (q^3)^{|lam|}, so it's
    sum_{lam: parts <= n} (q^3)^|lam| = prod_{j=1}^n 1/(1-q^{3j}).

    So F_{(0,0,0),n}(q) = cumulative GF = prod_{j=1}^n 1/(1-q^{3j}).
    And [y^n] F = F_{n} - F_{n-1}.

    For general c = (0,...,0) with k parts: replace 3 by k.
    """
    if memo is None:
        memo = {}

    c_tuple = tuple(c_tuple)
    if c_tuple in memo:
        return memo[c_tuple]

    k = len(c_tuple)
    d = sum(c_tuple)

    # Base case: all zeros
    if d == 0:
        # F_{(0,...,0)}(y,q) where all k partitions are equal
        # [y^n coeff] = prod_{j=1}^n 1/(1-q^{kj}) - prod_{j=1}^{n-1} 1/(1-q^{kj})
        # We compute cumulative F_n = prod_{j=1}^n 1/(1-q^{kj})
        result = {}
        prev_cum = {0: 1}  # F_0 = 1
        result[0] = {0: 1}  # [y^0] = 1

        for n in range(1, max_y + 1):
            # F_n = F_{n-1} * 1/(1-q^{kn})
            curr_cum = {}
            for p, c in prev_cum.items():
                j = 0
                while p + k * n * j <= max_q:
                    curr_cum[p + k * n * j] = curr_cum.get(p + k * n * j, 0) + c
                    j += 1
            curr_cum = {p: c for p, c in curr_cum.items() if c != 0}

            # [y^n] = curr_cum - prev_cum
            coeff_n = poly_sub(curr_cum, prev_cum)
            if coeff_n:
                result[n] = coeff_n

            prev_cum = curr_cum

        memo[c_tuple] = result
        return result

    # General case: Corteel-Welsh recurrence
    # I_c = {i : c_i > 0}
    I_c = [i for i in range(k) if c_tuple[i] > 0]

    if not I_c:
        # Should not happen since d > 0
        raise ValueError(f"I_c empty but d={d}")

    # Enumerate all nonempty subsets J of I_c
    from itertools import combinations

    result = None

    for size in range(1, len(I_c) + 1):
        for J in combinations(I_c, size):
            J_set = set(J)
            sign = (-1) ** (size - 1)

            # Compute shifted profile c(J)
            c_J = list(c_tuple)
            for i in range(k):
                i_prev = (i - 1) % k
                if i in J_set and i_prev not in J_set:
                    c_J[i] -= 1
                elif i not in J_set and i_prev in J_set:
                    c_J[i] += 1
            c_J = tuple(c_J)

            # Check validity (all c_J[i] >= 0)
            if any(x < 0 for x in c_J):
                continue

            # Recursively compute F_{c(J)}(y, q)
            F_cJ = compute_Fc_bivariate(c_J, max_y, max_q, memo)

            # Substitute y -> yq^{|J|}
            F_shifted = biv_yq_shift(F_cJ, size, max_y, max_q)

            # Multiply by 1/(1 - yq^{|J|})
            F_div = biv_mul_inv_1_minus_yqa(F_shifted, size, max_y, max_q)

            # Apply sign
            F_term = biv_scale(F_div, sign)

            if result is None:
                result = F_term
            else:
                result = biv_add(result, F_term, max_y)

    if result is None:
        result = {}

    memo[c_tuple] = result
    return result


def compute_Q_from_Fc(Fc_biv, profile, n_max, max_q=MAX_Q_DEG):
    """
    Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))

    where [z^n]((zq;q)_inf * F_c(z,q)) = sum_{m=0}^n (-1)^m q^{m(m+1)/2} / (q;q)_m * [z^{n-m}] F_c(z,q)

    ell = gcd(d, r) where d = sum(c), r = len(c).
    """
    d = sum(profile)
    r = len(profile)
    ell = gcd(d, r)

    # [z^j] F_c(z,q) = Fc_biv[j]
    # 1/(q;q)_m as power series
    def inv_qpoch(m):
        result = {0: 1}
        for i in range(1, m + 1):
            new = {}
            for p, c in result.items():
                j = 0
                while p + i * j <= max_q:
                    new[p + i * j] = new.get(p + i * j, 0) + c
                    j += 1
            result = {k: v for k, v in new.items() if v != 0}
        return result

    # (q^ell; q^ell)_n = prod_{i=1}^n (1 - q^{ell*i})
    def qpoch_fin(n):
        result = {0: 1}
        for i in range(1, n + 1):
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
    for n in range(n_max + 1):
        # inner = sum_{m=0}^n (-1)^m q^{m(m+1)/2} / (q;q)_m * b_{n-m}
        inner = {}
        for m in range(n + 1):
            sign = (-1) ** m
            shift = m * (m + 1) // 2
            if shift > max_q:
                break

            inv_m = inv_qpoch(m)
            b_nm = Fc_biv.get(n - m, {})

            term = poly_mul(inv_m, b_nm, max_q)
            term = poly_shift(term, shift, max_q)
            term = poly_scale(term, sign)
            inner = poly_add(inner, term)

        # Multiply by (q^ell; q^ell)_n
        qpn = qpoch_fin(n)
        Q_n = poly_mul(qpn, inner, max_q)
        Q_polys[n] = {k: v for k, v in Q_n.items() if v != 0}

    return Q_polys


def main():
    profiles = [
        (1, 1, 0),   # d=2
        (0, 1, 1),   # d=2
        (2, 0, 0),   # d=2
        (1, 0, 1),   # d=2
        (2, 1, 1),   # d=4
        (1, 2, 1),   # d=4
        (2, 2, 1),   # d=5
    ]

    for profile in profiles:
        d = sum(profile)
        if d % 3 == 0:
            continue

        r = len(profile)
        ell = gcd(d, r)
        expected_base = (d + 1) * (d + 2) // 6 - 1
        print(f"\n{'='*60}")
        print(f"Profile c = {profile}, d = {d}, ell = {ell}")
        print(f"Expected Q_{{n,c}}(1) = {expected_base}^n")
        print(f"{'='*60}")

        max_y = 4
        max_q = 35

        memo = {}
        Fc = compute_Fc_bivariate(profile, max_y, max_q, memo)

        print(f"\n[y^j] F_c(y,q):")
        for j in range(max_y + 1):
            p = Fc.get(j, {})
            s = sum(p.values()) if p else 0
            print(f"  [y^{j}]: sum_coeffs = {s}, poly = {poly_str(p)[:80]}")

        Q_polys = compute_Q_from_Fc(Fc, profile, max_y, max_q)

        print(f"\nQ_{{n,c}}(q):")
        for n in range(max_y + 1):
            Q = Q_polys.get(n, {})
            q1 = sum(Q.values())
            neg = [(k, v) for k, v in sorted(Q.items()) if v < 0]
            all_pos = len(neg) == 0
            print(f"\n  Q_{{{n}}}(q) = {poly_str(Q)}")
            print(f"    Q(1) = {q1}, expected = {expected_base**n}")
            if all_pos:
                print(f"    ALL NONNEGATIVE")
            else:
                print(f"    NEGATIVE coefficients: {neg[:5]}")


if __name__ == "__main__":
    main()
