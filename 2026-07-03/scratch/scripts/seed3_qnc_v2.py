"""
Seed 3 v2: Compute Q_{n,c}(q) using the product formula approach.

Instead of enumerating cylindric partitions directly (which requires
handling infinite families), use the relation:

F_{c,n}(q) = [y^0 ... y^n sum] from the generating function.

Actually, let's use a transfer matrix / recurrence approach.
For profile c = (c0, c1, c2) with k=3 components, the bounded
generating function F_{c,n}(q) counts cylindric partitions with
max entry <= n.

A cylindric partition with max entry <= n can be built layer by layer.
Think of it as n layers where each layer is a cylindric "slice."

Alternative: use the Corteel-Welsh recurrence on F_c(y,q).
F_c(y,q) = sum_{J subset I_c, J nonempty} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1 - yq^|J|)

with F_c(0,q) = 1.

Then F_{c,n}(q) = sum_{m=0}^{n} [coeff of y^m in F_c(y,q)]
(since F_{c,n}(q) = sum_{Lambda: max<=n} q^|Lambda|
and F_c(y,q) = sum_{Lambda} y^max q^|Lambda|, so 
F_{c,n}(q) = sum_{m=0}^n [y^m] F_c(y,q)).

Actually wait: Q_{n,c}(q) = (q^ell; q^ell)_n * [z^n]((zq)_inf * GK_c(z,q))
where GK_c(z,q) = F_c(z,q).

The variable z here plays the role of y — it marks the maximum.

So we need:
[z^n] ((zq)_inf * F_c(z,q))
= [z^n] (sum_m (-1)^m q^{m(m+1)/2} / (q;q)_m * z^m) * (sum_j [y^j]F_c(y,q) * z^j)
= sum_{m+j=n} (-1)^m q^{m(m+1)/2} / (q;q)_m * f_j(q)

where f_j(q) = [y^j] F_c(y,q) = sum_{Lambda: max=j} q^|Lambda|.

So we need f_j(q) for j = 0, 1, ..., n.

Let me try to compute f_j(q) for small j using direct enumeration
but with enough parts.

For max = j, a cylindric partition with max entry exactly j must have
all parts <= j and at least one part equal to j.
f_j(q) = F_{c,j}(q) - F_{c,j-1}(q)
where F_{c,m}(q) = sum_{Lambda: max <= m} q^|Lambda|.

So I need F_{c,m}(q) for m = 0, ..., n.

For the enumeration to be correct, I need partitions with arbitrarily
many parts. But partitions with max entry <= m and satisfying the 
interlacing conditions — do they have bounded length?

The interlacing condition lambda^(i)_j >= lambda^(i+1)_{j+c_{i+1}} means
the parts of lambda^(i+1) at position j+c_{i+1} are bounded by lambda^(i)_j.
If lambda^(i) has finite length L, then lambda^(i+1) has length at most
L + c_{i+1} (since parts beyond L+c_{i+1} would need to be bounded by
lambda^(i)_j for j > L, which is 0).

Going around the cycle: the total length is bounded, and we get
L <= L + c_1 + c_2 + ... + c_k going full cycle... 

Hmm, wait. Going around the full cycle:
lam^(1)_j >= lam^(2)_{j+c_2} >= lam^(3)_{j+c_2+c_3} >= lam^(1)_{j+c_2+c_3+c_1} = lam^(1)_{j+d}
where d = c_1 + c_2 + c_3 = sum of all c_i.

So lam^(1)_j >= lam^(1)_{j+d}. This means lam^(1) is "periodic-ish" — 
each part is >= the part d positions later. For a partition (weakly decreasing),
this is automatically satisfied! So there's no bound on the length from the
cyclic condition alone for partitions.

BUT: we need max entry <= m. With max entry <= m, we have lam^(i)_1 <= m.
The interlacing lam^(i)_j >= lam^(i+1)_{j+c_{i+1}} means if we go around
the full cycle, lam^(1)_j >= lam^(1)_{j+d}. Since lam^(1) is weakly decreasing
with parts <= m, this is automatic. So a partition with parts <= m can have
arbitrary length (well, infinite parts equal to m, but those contribute
infinitely to the size).

Actually for a PARTITION (nonneg integers, weakly decreasing, finitely many
nonzero parts), the parts eventually become 0. The interlacing conditions
just constrain how the different partitions relate, but each partition still
has finite length. The generating function F_{c,m}(q) is still an infinite
series in q for m >= 1 (since you can have arbitrarily long partitions
all with parts <= m satisfying the interlacing).

Wait, but Q_{n,c}(q) is supposed to be a POLYNOMIAL. So the extraction
[z^n]((zq)_inf * F_c(z,q)) must give a power series that, when multiplied
by (q^ell;q^ell)_n, yields a polynomial. That's the miracle.

For computation, I can't enumerate all cylindric partitions. I need to
truncate the q-degree and make sure I go high enough.

Let me try a different approach: compute F_{c,m}(q) mod q^N for some
truncation N, by using the Borodin product formula truncated.

For F_c(q) (unrestricted), Borodin gives an explicit infinite product.
For F_{c,n}(q) (bounded max <= n), we need a different formula.

Actually, the simplest approach for small cases is to directly enumerate
but realize that for max <= m and total degree <= N, the number of parts
is bounded by N (since each nonzero part contributes at least 1).

Let me try with enough parts.
"""

from collections import defaultdict
from math import gcd, comb
from functools import lru_cache
import sys


def compute_fcm_q(c, m, max_q_deg):
    """
    Compute F_{c,m}(q) = sum_{Lambda in C_{c,m}} q^|Lambda|
    truncated to q^max_q_deg.
    
    Uses dynamic programming / transfer matrix on a cylinder.
    
    For k=3, profile c=(c0,c1,c2), a cylindric partition with max <= m
    consists of 3 partitions lambda^(0), lambda^(1), lambda^(2) with:
    - all parts in [0, m]
    - cyclic interlacing conditions
    
    We think of it column-by-column (or rather, layer by layer in terms
    of the parts). 
    
    Actually, let's think of it differently. A cylindric partition of 
    profile c with k partitions each having parts in {0,...,m} is 
    equivalent to arranging numbers on a cylinder. Let's just enumerate
    using the "column" representation.
    
    The cylinder has circumference t = k + d where d = sum(c).
    A cylindric partition with max <= m is a function f on the cylinder
    lattice... this gets complicated.
    
    Simpler: direct enumeration with enough parts.
    Since max <= m and total <= max_q_deg, each partition has at most
    max_q_deg nonzero parts. But that's still a lot.
    
    Let me use recursion with memoization. Build each partition part by part,
    tracking the running total and the current interlacing constraints.
    """
    if m == 0:
        return {0: 1}
    
    k = len(c)
    # For k=3, c = (c0, c1, c2)
    # Conditions:
    # lam^(0)_j >= lam^(1)_{j+c1} for all j >= 1
    # lam^(1)_j >= lam^(2)_{j+c2} for all j >= 1  
    # lam^(2)_j >= lam^(0)_{j+c0} for all j >= 1
    
    # Maximum number of parts any partition can have: max_q_deg (since each contributes >= 1)
    # But even max_q_deg parts with value m gives total m * max_q_deg, so we need
    # at most max_q_deg / 1 parts. That's too many to enumerate directly.
    
    # Better approach: note that the interlacing conditions constrain how
    # many parts each partition can have, relative to the others.
    # If lam^(0) has L_0 nonzero parts, then lam^(1) has at most L_0 + c_1 nonzero parts
    # (by the interlacing lam^(0)_j >= lam^(1)_{j+c1}, so if j > L_0, then lam^(1)_{j+c1} = 0).
    # Wait, that's wrong — lam^(0)_j = 0 for j > L_0 means lam^(1)_{j+c1} <= 0 = 0,
    # so lam^(1)_j = 0 for j > L_0 + c1. But also lam^(1) is weakly decreasing, so
    # if lam^(1)_{L_0 + c1 + 1} = 0 then lam^(1)_j = 0 for all j > L_0 + c1.
    # So: len(lam^(1)) <= len(lam^(0)) + c1
    # Similarly: len(lam^(2)) <= len(lam^(1)) + c2 <= len(lam^(0)) + c1 + c2
    # And: len(lam^(0)) <= len(lam^(2)) + c0 <= len(lam^(0)) + c1 + c2 + c0 = len(lam^(0)) + d
    # So the cyclic constraint is automatically satisfied (it just gives len(lam^(0)) <= len(lam^(0)) + d).
    
    # But from lam^(2)_j >= lam^(0)_{j+c0}: len(lam^(0)) <= len(lam^(2)) + c0
    # Combined with len(lam^(2)) <= len(lam^(0)) + c1 + c2:
    # len(lam^(0)) <= len(lam^(0)) + c1 + c2 + c0 = len(lam^(0)) + d
    # This is trivially true. So there's no upper bound on partition lengths
    # from the cyclic structure alone.
    
    # For bounded computation, set max_parts = max_q_deg (each nonzero part >= 1)
    max_parts = min(max_q_deg, 15)  # cap to keep computation feasible
    
    # Use polynomial arithmetic in q, truncated
    # Generate using transfer matrix: state = (last values of each partition
    # at the interlacing boundary)
    
    # Actually, this is getting complicated. Let me just use direct enumeration
    # with small max_parts and acknowledge the truncation.
    
    # For a more accurate computation, use the identity:
    # F_{c,n}(q) relates to bounded partitions inside a rectangle...
    # Or use the fact that for profile (c0,c1,c2) the cylinder has 
    # circumference t = 3 + d, and F_{c,n}(q) is related to 
    # counting paths on the cylinder.
    
    # PLAN B: Use the known formula for F_{c,n}(q) in terms of q-binomial
    # coefficients for small profiles.
    
    # For now, let me just verify with a known case.
    # Profile (1,0,0), d=1 (but d=1 is d%3=1, not 0, so conjecture applies).
    # Wait, k=3 and d=1, so t = 3+1 = 4.
    # Actually d mod 3 = 1 != 0, so conjecture applies.
    
    pass  # This approach is too slow


def compute_Q_via_qbinom(c, n, max_deg):
    """
    For small profiles, try to compute Q_{n,c}(q) using known formulas.
    
    For c = (1,0,0) (d=1, ell=gcd(1,3)=1):
    The cylindric partitions reduce to ordinary partitions.
    F_{(1,0,0),n}(q) = 1/(q;q)_n  (partitions with max <= n = partitions into parts <= n... wait, that's not quite right.)
    
    Actually for profile (1,0,0), k=3, and the cylindric partition consists of
    3 partitions with c=(1,0,0). The interlacing is:
    lam^(0)_j >= lam^(1)_{j+0} = lam^(1)_j  (since c_1=0)
    lam^(1)_j >= lam^(2)_{j+0} = lam^(2)_j  (since c_2=0)
    lam^(2)_j >= lam^(0)_{j+1}                (since c_0=1)
    
    So: lam^(0)_j >= lam^(1)_j >= lam^(2)_j >= lam^(0)_{j+1}
    
    This means lam^(0) >= lam^(1) >= lam^(2) >= shift(lam^(0)).
    These are plane partitions! Specifically, a plane partition of height 3
    (3 rows in the "depth" direction).
    
    For max <= n, we get plane partitions of height 3 with largest part <= n.
    This is well-known: counted by prod_{1<=i<=3, 1<=j<=n} (1-q^{i+j-1})/(1-q^{i+j-2}) ... 
    Actually the generating function for plane partitions in a 3 x n x infinity box
    is... let me just compute directly.
    """
    pass


def compute_q_binomial(n, k, max_deg):
    """Compute q-binomial coefficient [n choose k]_q as polynomial."""
    if k < 0 or k > n:
        return {0: 0}
    if k == 0 or k == n:
        return {0: 1}
    
    # [n choose k]_q = (q;q)_n / ((q;q)_k * (q;q)_{n-k})
    # Use the recurrence: [n choose k]_q = [n-1 choose k-1]_q + q^k [n-1 choose k]_q
    
    # Base cases
    if n == 0:
        return {0: 1} if k == 0 else {}
    
    # Recurrence
    p1 = compute_q_binomial(n-1, k-1, max_deg)
    p2 = compute_q_binomial(n-1, k, max_deg)
    
    # q^k * p2
    p2_shifted = {d + k: c for d, c in p2.items() if d + k <= max_deg}
    
    # Add p1 + p2_shifted
    result = dict(p1)
    for d, c in p2_shifted.items():
        result[d] = result.get(d, 0) + c
    
    return {k: v for k, v in result.items() if v != 0}


def poly_mult(p1, p2, max_deg):
    result = {}
    for d1, c1 in p1.items():
        for d2, c2 in p2.items():
            d = d1 + d2
            if d <= max_deg:
                result[d] = result.get(d, 0) + c1 * c2
    return {k: v for k, v in result.items() if v != 0}


def plane_partition_gf_3_n(n, max_deg):
    """
    Generate the generating function for plane partitions with at most 3 rows,
    at most n columns (equivalently: a 3xn array of nonneg integers, weakly
    decreasing along rows and columns, largest entry unbounded).
    
    Wait, that's not quite right. For profile (1,0,0), we showed the cylindric
    partition is equivalent to lam^(0) >= lam^(1) >= lam^(2) >= shift(lam^(0)).
    This is a plane partition inside a 3 x infinity rectangle.
    
    With max <= n means the largest part is <= n, which means the partition
    fits inside a 3 x infinity x n box.
    
    Actually, the generating function for plane partitions that fit inside an 
    a x b x c box is the MacMahon box formula:
    prod_{i=1}^a prod_{j=1}^b (1 - q^{i+j+c-1}) / (1 - q^{i+j-1})
    
    For our case: a=3 rows (depth), arbitrary columns (b -> inf), max part c = n.
    But b -> inf doesn't give a finite product...
    
    Let me reconsider. The profile (1,0,0) gives cylindric partitions that
    are NOT exactly plane partitions in a box. They can have arbitrarily many 
    columns (parts), and the generating function is an infinite product.
    """
    pass


def compute_F_unrestricted(c, max_deg):
    """
    Compute F_c(q) using Borodin's product formula, truncated to max_deg.
    
    F_c(q) = 1/(q^t;q^t)_inf * product terms
    where t = k + d, d = sum(c), k = len(c).
    
    For k=3, c=(c0,c1,c2), t = 3+d, d = c0+c1+c2.
    
    The formula involves d_{i,j} = c_i + ... + c_j.
    """
    k = len(c)
    d = sum(c)
    t = k + d
    
    # Start with 1/(q^t; q^t)_inf = sum of partitions with parts divisible by t
    # = prod_{m>=1} 1/(1 - q^{m*t})
    
    # Compute as polynomial truncated to max_deg
    result = {0: 1}
    
    # 1/(q^t; q^t)_inf
    for m in range(1, max_deg // t + 1):
        # multiply by 1/(1-q^{mt})
        new_result = dict(result)
        for deg in range(m * t, max_deg + 1):
            new_result[deg] = new_result.get(deg, 0) + new_result.get(deg - m * t, 0)
        # Actually this isn't right — need to multiply by the full 1/(1-q^{mt})
        pass
    
    # This is getting complicated. Let me compute 1/(1-q^a) * poly as:
    # result[d] = result[d] + result[d-a] for d from a to max_deg
    
    result = {0: 1}
    
    # Collect all the factors 1/(1-q^a) we need to multiply
    factors = []
    
    # From 1/(q^t;q^t)_inf: factors 1/(1-q^{mt}) for m=1,2,...
    for m in range(1, max_deg // t + 1):
        factors.append(m * t)
    
    # d_{i,j} = c_i + c_{i+1} + ... + c_j (using 0-indexed, cyclically)
    # In the formula, indices go from 1 to k, so let me use 1-indexed
    c_1indexed = [0] + list(c)  # c_1indexed[1] = c[0], etc.
    
    def d_sum(i, j):
        """d_{i,j} = c_i + c_{i+1} + ... + c_j, 1-indexed."""
        s = 0
        for idx in range(i, j + 1):
            s += c_1indexed[idx]
        return s
    
    # First product: prod_{i=1}^k prod_{j=i+1}^k prod_{m=1}^{c_i} 1/(q^{m+d_{i+1,j}+j-i}; q^t)_inf
    for i in range(1, k + 1):
        for j in range(i + 1, k + 1):
            for m in range(1, c_1indexed[i] + 1):
                base = m + d_sum(i + 1, j) + j - i
                # 1/(q^base; q^t)_inf = prod_{s>=0} 1/(1-q^{base + s*t})
                for s in range(0, (max_deg - base) // t + 1):
                    if base + s * t > 0 and base + s * t <= max_deg:
                        factors.append(base + s * t)
    
    # Second product: prod_{i=2}^k prod_{j=2}^{i-1} prod_{m=1}^{c_i} 1/(q^{t-(m+d_{j,i-1}+i-j)}; q^t)_inf
    for i in range(2, k + 1):
        for j in range(2, i):
            for m in range(1, c_1indexed[i] + 1):
                base = t - (m + d_sum(j, i - 1) + i - j)
                for s in range(0, (max_deg - base) // t + 1):
                    if base + s * t > 0 and base + s * t <= max_deg:
                        factors.append(base + s * t)
    
    # Now multiply all 1/(1-q^a) factors
    result_list = [0] * (max_deg + 1)
    result_list[0] = 1
    
    for a in sorted(factors):
        if a <= 0 or a > max_deg:
            continue
        for deg in range(a, max_deg + 1):
            result_list[deg] += result_list[deg - a]
    
    return {i: result_list[i] for i in range(max_deg + 1) if result_list[i] != 0}


def compute_F_bivariate_from_CW(c, max_z, max_deg):
    """
    Compute F_c(z,q) using the Corteel-Welsh functional equation:
    
    F_c(y,q) = sum_{J subset I_c, J nonempty} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1-yq^|J|)
    
    This is recursive. The base cases are when all c_i = 0, giving F = 1/(1-y).
    
    Returns dict: z_power -> {q_power: coefficient}
    """
    # I_c = {i : c_i > 0}
    I_c = [i for i in range(len(c)) if c[i] > 0]
    
    if not I_c:
        # All c_i = 0: F_c(z,q) = 1/(1-z) = sum_{j>=0} z^j
        result = {}
        for j in range(max_z + 1):
            result[j] = {0: 1}
        return result
    
    k = len(c)
    
    # Generate all nonempty subsets of I_c
    from itertools import combinations
    subsets = []
    for size in range(1, len(I_c) + 1):
        for combo in combinations(I_c, size):
            subsets.append(set(combo))
    
    result = defaultdict(lambda: defaultdict(int))
    
    for J in subsets:
        sign = (-1) ** (len(J) - 1)
        j_size = len(J)
        
        # Compute shifted profile c(J)
        c_J = list(c)
        for i in range(k):
            i_prev = (i - 1) % k
            if i in J and i_prev not in J:
                c_J[i] = c[i] - 1
            elif i not in J and i_prev in J:
                c_J[i] = c[i] + 1
            # else unchanged
        c_J = tuple(c_J)
        
        # Check that all c_J[i] >= 0
        if any(x < 0 for x in c_J):
            continue
        
        # Recursively compute F_{c(J)}(z*q^|J|, q) / (1-z*q^|J|)
        # F_{c(J)}(z, q) = sum_m f_m(q) z^m
        # Then F_{c(J)}(z*q^|J|, q) = sum_m f_m(q) * q^{m*|J|} * z^m
        # And 1/(1-z*q^|J|) = sum_{s>=0} z^s * q^{s*|J|}
        # Product: coefficient of z^n is sum_{m+s=n} f_m(q) * q^{m*|J|} * q^{s*|J|}
        #        = q^{n*|J|} * sum_{m=0}^n f_m(q)
        # Wait, that's nice! Let me verify:
        # [z^n] F(zq^J, q)/(1-zq^J) = [z^n] sum_m f_m q^{mJ} z^m * sum_s q^{sJ} z^s
        # = sum_{m+s=n} f_m q^{mJ} q^{sJ} = sum_{m=0}^n f_m q^{mJ} q^{(n-m)J}
        # = q^{nJ} sum_{m=0}^n f_m
        # Hmm, that means the q-shift cancels out?! That can't be right because
        # f_m is a polynomial in q and the sum depends on the individual f_m.
        
        # Let me redo: [z^n] F(zq^J, q)/(1-zq^J)
        # = [z^n] (sum_m f_m(q) (zq^J)^m) * (sum_s (zq^J)^s)
        # = [z^n] sum_m sum_s f_m(q) q^{(m+s)J} z^{m+s}
        # = sum_{m=0}^n f_m(q) q^{nJ}
        # = q^{nJ} * sum_{m=0}^n f_m(q)
        
        # So [z^n] F_{c(J)}(zq^J, q)/(1-zq^J) = q^{n*|J|} * sum_{m=0}^n [z^m] F_{c(J)}(z,q)
        # And [z^m] F_c(z,q) = f_m(q) = sum_{Lambda: max(Lambda)=m} q^|Lambda|
        # So sum_{m=0}^n f_m(q) = F_{c(J),n}(q) (bounded generating function with max <= n)
        
        # This is great! So:
        # F_c(z,q) satisfies: [z^n] F_c(z,q) = sum_J (-1)^{|J|-1} q^{n|J|} F_{c(J),n}(q)
        
        # But F_{c(J),n}(q) = sum_{m=0}^n [z^m] F_{c(J)}(z,q), which requires knowing F_{c(J)}
        # recursively. This is the Corteel-Welsh recurrence.
        
        # Let me compute F_{c(J)} recursively
        F_cJ = compute_F_bivariate_from_CW(c_J, max_z, max_deg)
        
        for n_val in range(max_z + 1):
            # Contribution to [z^n_val] F_c:
            # sign * q^{n_val * j_size} * sum_{m=0}^{n_val} [z^m] F_{c(J)}
            
            cumulative = defaultdict(int)
            for m in range(n_val + 1):
                if m in F_cJ:
                    for qp, coeff in F_cJ[m].items():
                        cumulative[qp] += coeff
            
            # Multiply by q^{n_val * j_size}
            shift = n_val * j_size
            for qp, coeff in cumulative.items():
                new_qp = qp + shift
                if new_qp <= max_deg:
                    result[n_val][new_qp] += sign * coeff
    
    return dict(result)


def compute_Q_from_CW(c, n_val, max_deg):
    """Compute Q_{n,c}(q) using Corteel-Welsh recurrence."""
    r = len(c)
    d = sum(c)
    ell = gcd(d, r)
    
    # Get F_c(z,q) via Corteel-Welsh
    F_biv = compute_F_bivariate_from_CW(c, n_val, max_deg)
    
    # Compute (zq)_inf
    # (zq)_inf = prod_{j>=1} (1-zq^j)
    # [z^m](zq)_inf = (-1)^m q^{m(m+1)/2} / (q;q)_m
    # We need this as a polynomial in q. But 1/(q;q)_m is a power series...
    
    # Wait, (zq)_inf = sum_{m>=0} (-1)^m q^{binom(m+1,2)} / (q;q)_m z^m
    # But 1/(q;q)_m = 1/((1-q)(1-q^2)...(1-q^m)) is a power series, not polynomial.
    # So [z^m](zq)_inf is a power series in q.
    
    # Hmm, but Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n]((zq)_inf * F_c(z,q))
    # The product (zq)_inf * F_c(z,q) has the (zq)_inf part introducing denominators
    # via 1/(q;q)_m, and F_c(z,q) also has denominators. But the multiplication
    # by (q^ell;q^ell)_n is supposed to clear all denominators.
    
    # For computation, I need to work with truncated power series.
    # Let me compute [z^m](zq)_inf as a truncated power series.
    
    # Actually, (zq;q)_inf = prod_{j>=1}(1-zq^j). This is well-defined as
    # a formal power series in z with coefficients in Z[[q]].
    # [z^m](zq;q)_inf = sum coefficient.
    # Let's compute it by multiplying factors (1-zq^j):
    
    zq_coeffs = {0: {0: 1}}  # [z^0] = 1
    
    for j in range(1, max_deg + 1):
        new_coeffs = defaultdict(lambda: defaultdict(int))
        for z_pow, q_poly in zq_coeffs.items():
            for q_pow, coeff in q_poly.items():
                # From "1" term
                if q_pow <= max_deg:
                    new_coeffs[z_pow][q_pow] += coeff
                # From "-zq^j" term
                nz = z_pow + 1
                nq = q_pow + j
                if nz <= n_val and nq <= max_deg:
                    new_coeffs[nz][nq] -= coeff
        zq_coeffs = dict(new_coeffs)
    
    # Now compute [z^n]((zq)_inf * F_c(z,q))
    # = sum_{a+b=n} [z^a](zq)_inf * [z^b]F_c(z,q)
    product_coeff = defaultdict(int)
    for a in range(n_val + 1):
        b = n_val - a
        if a not in zq_coeffs:
            continue
        if b not in F_biv:
            continue
        # Multiply q-polynomials
        for qp1, c1 in zq_coeffs[a].items():
            for qp2, c2 in F_biv[b].items():
                s = qp1 + qp2
                if s <= max_deg:
                    product_coeff[s] += c1 * c2
    
    # Multiply by (q^ell; q^ell)_n
    q_ell_n = {0: 1}
    for i in range(n_val):
        power = ell * (i + 1)
        new = {}
        for deg, coeff in q_ell_n.items():
            if deg <= max_deg:
                new[deg] = new.get(deg, 0) + coeff
            if deg + power <= max_deg:
                new[deg + power] = new.get(deg + power, 0) - coeff
        q_ell_n = {k: v for k, v in new.items() if v != 0}
    
    Q = {}
    for d1, c1 in q_ell_n.items():
        for d2, c2 in product_coeff.items():
            deg = d1 + d2
            if deg <= max_deg:
                Q[deg] = Q.get(deg, 0) + c1 * c2
    
    return {k: v for k, v in Q.items() if v != 0}


def poly_to_list(poly):
    if not poly:
        return [0]
    mx = max(poly.keys())
    return [poly.get(i, 0) for i in range(mx + 1)]


def main():
    print("=" * 70)
    print("Computing Q_{n,c}(q) via Corteel-Welsh recurrence")
    print("=" * 70)
    
    sys.setrecursionlimit(5000)
    
    # Start with simplest profiles
    profiles = [
        (1, 1, 0),   # d=2
        (2, 0, 0),   # d=2
        (1, 0, 1),   # d=2
    ]
    
    max_deg = 30
    
    for c in profiles:
        d = sum(c)
        ell = gcd(d, 3)
        if d % 3 == 0:
            continue
        
        print(f"\nProfile c = {c}, d = {d}, ell = {ell}")
        print("-" * 50)
        
        expected_base = (d + 1) * (d + 2) // 6 - 1
        print(f"Expected Q_{{n,c}}(1) = {expected_base}^n")
        
        for n in range(1, 4):
            try:
                Q = compute_Q_from_CW(c, n, max_deg)
                coeffs = poly_to_list(Q)
                while coeffs and coeffs[-1] == 0:
                    coeffs.pop()
                if not coeffs:
                    coeffs = [0]
                
                all_pos = all(x >= 0 for x in coeffs)
                eval_at_1 = sum(coeffs)
                
                print(f"  n={n}: Q = {coeffs}")
                print(f"    Q(1) = {eval_at_1} (expected {expected_base**n}), positive: {all_pos}")
            except Exception as e:
                import traceback
                print(f"  n={n}: ERROR - {e}")
                traceback.print_exc()


if __name__ == "__main__":
    main()
