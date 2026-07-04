"""
Seed 5 — Compute Q_{n,c}(q) via transfer matrix method.

For profile c = (c_0, c_1, c_2) with k=3, t = 3 + d where d = c_0+c_1+c_2.

A cylindric partition of profile c with max entry <= n can be viewed as
a path of length n on a transfer matrix. The states are cross-sections
of the cylinder — tuples of partition parts at each level.

Actually, let me use a different approach: use the known product formula
for F_c(q) (Borodin) and the Corteel-Welsh recurrence for F_c(y,q).

The Corteel-Welsh recurrence:
  F_c(y,q) = sum_{empty != J subseteq I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})

with F_c(0,q) = 1.

From this we can extract F_{c,n}(q) = [y^0 + y^1 + ... + y^n terms summed]
or rather the coefficients [y^j] F_c(y,q) for each j.

Actually, let me think about what F_c(y,q) looks like.
F_c(y,q) = sum_{Lambda} q^{|Lambda|} y^{max(Lambda)}
         = sum_{n>=0} y^n * (sum_{Lambda: max=n} q^{|Lambda|})

Note F_c(0,q) = [y^0 term] = 1 (empty partition has max 0 and size 0).

The recurrence relates F_c(y,q) to F_{c(J)}(yq^{|J|}, q).

Let me instead use a direct transfer matrix approach.

For a cylindric partition Lambda = (lam^0, lam^1, lam^2) of profile c with
max entry <= n, we can build it column by column. The j-th column consists
of the values (lam^0_j, lam^1_j, lam^2_j) where lam^i_j is the j-th part
of the i-th partition.

Wait, this is getting complicated with the interlacing conditions.
Let me try a much simpler approach: use sympy or sage-like computation.

Actually, let me try the simplest case first: c = (1,0,1), d=2, k=3, t=5.
For this profile, a cylindric partition is three partitions (lam^0, lam^1, lam^2) with:
- lam^0_j >= lam^1_{j+0} = lam^1_j  (since c_1 = 0)
- lam^1_j >= lam^2_{j+1}  (since c_2 = 1)
- lam^2_j >= lam^0_{j+1}  (since c_0 = 1)

So: lam^0_j >= lam^1_j >= lam^2_{j+1} and lam^2_j >= lam^0_{j+1}.

This means: lam^0_j >= lam^1_j >= lam^2_{j+1} >= lam^0_{j+2}.
And also: lam^2_j >= lam^0_{j+1} >= lam^1_{j+1} >= lam^2_{j+2}.

So we get interlacing chains. The state at position j is (lam^0_j, lam^1_j, lam^2_j)
and we need:
- lam^0_j >= lam^1_j (from c_1=0)
- lam^1_j >= lam^2_{j+1} (from c_2=1)
- lam^2_j >= lam^0_{j+1} (from c_0=1)

Also each sequence lam^i is weakly decreasing (it's a partition).

So the state at column j is s_j = (a_j, b_j, c_j) = (lam^0_j, lam^1_j, lam^2_j)
with a_j >= b_j (interlacing condition from c_1=0).

The transition from column j to column j+1 requires:
- b_j >= c_{j+1} (from the c_2=1 condition)
- c_j >= a_{j+1} (from the c_0=1 condition)
- a_{j+1} >= b_{j+1} (interlacing within column j+1)
- a_{j+1} <= a_j, b_{j+1} <= b_j, c_{j+1} <= c_j (each partition is weakly decreasing)

With all parts in {0, 1, ..., n}.

This is a finite state transfer matrix! States are triples (a,b,c) with
0 <= c <= b <= a <= n (wait, no — a >= b from the c_1=0 condition, but
c vs a and c vs b have no direct within-column constraint).

Actually, the within-column constraint is only a >= b (from c_1 = 0).
The constraint c <= ... doesn't come from within-column.

So states are (a, b, c) with n >= a >= b >= 0 and n >= c >= 0.

Transition (a,b,c) -> (a',b',c') requires:
- b >= c' (from c_2=1: lam^1_j >= lam^2_{j+1})
- c >= a' (from c_0=1: lam^2_j >= lam^0_{j+1})
- a' >= b' (within column)
- a' <= a, b' <= b, c' <= c (weakly decreasing partitions)

And the q-weight of column j is q^{a_j + b_j + c_j}.

Let me implement this.
"""

from collections import defaultdict

def compute_Q_transfer(c_profile, n_max, q_trunc):
    """
    Compute Q_{n,c}(q) for n = 0, ..., n_max using transfer matrix.
    
    q_trunc: truncate polynomials at degree q_trunc for efficiency.
    
    Returns dict n -> polynomial (as dict exponent -> coeff).
    """
    c0, c1, c2 = c_profile
    k = 3
    
    # For general profile, the interlacing conditions are:
    # lam^i_j >= lam^{(i+1) mod 3}_{j + c_{(i+1) mod 3}}
    #
    # So:
    # lam^0_j >= lam^1_{j + c_1}
    # lam^1_j >= lam^2_{j + c_2}
    # lam^2_j >= lam^0_{j + c_0}
    
    # For the transfer matrix, we need to track enough consecutive columns
    # to express all the interlacing conditions. The shift is at most max(c_0,c_1,c_2).
    # We need a window of size max(c_i) + 1 columns.
    
    # This gets complicated for general c. Let me handle specific cases.
    # For now, let me use a different approach: recursive enumeration with memoization.
    
    # Actually, let me just enumerate more carefully with larger part counts.
    pass


def enumerate_carefully(c_profile, n_bound):
    """
    Enumerate cylindric partitions of profile c with max <= n_bound.
    
    Returns dict: j -> polynomial b_j where b_j = sum_{Lambda: max=j} q^{|Lambda|}.
    """
    c0, c1, c2 = c_profile
    
    # The conditions are:
    # lam^0_j >= lam^1_{j+c1} for all j >= 1
    # lam^1_j >= lam^2_{j+c2} for all j >= 1
    # lam^2_j >= lam^0_{j+c0} for all j >= 1
    
    # Each lam^i is a partition (weakly decreasing, eventually 0) with parts <= n_bound
    
    # Key insight: the conditions create a decay chain.
    # lam^0_j >= lam^1_{j+c1} >= lam^2_{j+c1+c2} >= lam^0_{j+c1+c2+c0} = lam^0_{j+d}
    # where d = c0+c1+c2.
    # So lam^0_j >= lam^0_{j+d}, which is already guaranteed by lam^0 being a partition.
    # But also lam^0_1 >= ... >= lam^0_{j+d} means at most n_bound * d / something nonzero parts.
    
    # More precisely: lam^0_1 <= n_bound, and lam^0_{1+d} <= lam^0_1, and
    # lam^0_{1+2d} <= lam^0_{1+d} <= lam^0_1 - (something)?
    # No, not necessarily — they're just weakly decreasing.
    
    # But the interlacing forces more rapid decay.
    # lam^0_j >= lam^1_{j+c1} >= lam^2_{j+c1+c2} >= lam^0_{j+d}
    # This chain has length 3 and goes from lam^0_j to lam^0_{j+d}.
    # Each step is >=, so lam^0_j >= lam^0_{j+d}.
    # The maximum number of nonzero parts in lam^0 can be large.
    
    # For n_bound small (say <= 3), the number of nonzero parts is bounded by n_bound * d or so.
    
    max_parts = n_bound * (c0 + c1 + c2 + 3) + 3  # generous
    max_parts = min(max_parts, 20)  # cap for speed
    
    def get(lam, j):
        """1-indexed: get j-th part"""
        if j <= 0 or j > len(lam):
            return 0
        return lam[j-1]
    
    def gen_parts(max_val, max_len):
        """Generate partitions with parts in [0, max_val], length <= max_len."""
        if max_len == 0 or max_val == 0:
            yield ()
            return
        yield ()
        for first in range(1, max_val + 1):
            for rest in gen_parts(first, max_len - 1):
                yield (first,) + rest
    
    all_parts = list(gen_parts(n_bound, max_parts))
    print(f"  Number of partitions with max<={n_bound}, length<={max_parts}: {len(all_parts)}")
    
    # Check interlacing
    b = defaultdict(lambda: defaultdict(int))  # b[mx][size] = count
    
    count = 0
    for lam0 in all_parts:
        for lam1 in all_parts:
            # Quick check: lam^0_j >= lam^1_{j+c1} for all j
            ok01 = True
            for j in range(1, max_parts + 1):
                if get(lam0, j) < get(lam1, j + c1):
                    ok01 = False
                    break
            if not ok01:
                continue
            
            for lam2 in all_parts:
                # Check lam^1_j >= lam^2_{j+c2}
                ok12 = True
                for j in range(1, max_parts + 1):
                    if get(lam1, j) < get(lam2, j + c2):
                        ok12 = False
                        break
                if not ok12:
                    continue
                
                # Check lam^2_j >= lam^0_{j+c0}
                ok20 = True
                for j in range(1, max_parts + 1):
                    if get(lam2, j) < get(lam0, j + c0):
                        ok20 = False
                        break
                if not ok20:
                    continue
                
                size = sum(lam0) + sum(lam1) + sum(lam2)
                mx = max(get(lam0, 1), get(lam1, 1), get(lam2, 1))
                b[mx][size] += 1
                count += 1
    
    print(f"  Found {count} cylindric partitions")
    return dict(b)


def poly_str(p, var='q'):
    if not p:
        return "0"
    terms = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0:
            continue
        if e == 0:
            terms.append(str(c))
        elif c == 1:
            terms.append(f"{var}^{e}" if e > 1 else var)
        elif c == -1:
            terms.append(f"-{var}^{e}" if e > 1 else f"-{var}")
        else:
            terms.append(f"{c}*{var}^{e}" if e > 1 else f"{c}*{var}")
    if not terms:
        return "0"
    result = terms[0]
    for t in terms[1:]:
        if t.startswith('-'):
            result += " - " + t[1:]
        else:
            result += " + " + t
    return result


def compute_Q(b_data, n):
    """
    Q_{n,c}(q) = (q;q)_n * sum_{m=0}^{n} (-1)^m q^{m(m+1)/2} / (q;q)_m * b_{n-m}(q)
    
    b_data: dict mx -> {size: count}
    """
    # b_j as polynomial
    def b_poly(j):
        if j not in b_data:
            return {}
        return dict(b_data[j])
    
    def poly_add(p, q):
        r = dict(p)
        for e, c in q.items():
            r[e] = r.get(e, 0) + c
        return {e: c for e, c in r.items() if c != 0}
    
    def poly_mul(p, q):
        r = {}
        for e1, c1 in p.items():
            for e2, c2 in q.items():
                e = e1 + e2
                r[e] = r.get(e, 0) + c1 * c2
        return {e: c for e, c in r.items() if c != 0}
    
    def poly_scale(p, s):
        if s == 0:
            return {}
        return {e: c * s for e, c in p.items()}
    
    def poly_shift(p, k):
        return {e + k: c for e, c in p.items()}
    
    result = {}
    for m in range(n + 1):
        sign = (-1) ** m
        shift = m * (m + 1) // 2
        
        # (q;q)_n / (q;q)_m = prod_{i=m+1}^{n} (1 - q^i)
        ratio = {0: 1}
        for i in range(m + 1, n + 1):
            factor = {0: 1, i: -1}
            ratio = poly_mul(ratio, factor)
        
        bj = b_poly(n - m)
        term = poly_scale(bj, sign)
        term = poly_shift(term, shift)
        term = poly_mul(term, ratio)
        result = poly_add(result, term)
    
    return result


# Test with c = (1,0,1), d=2
print("Profile c = (1,0,1), d=2")
print("Computing cylindric partitions with max <= 3...")
b_data = enumerate_carefully((1,0,1), 3)

print("\nb_j distributions:")
for j in sorted(b_data.keys()):
    total = sum(b_data[j].values())
    print(f"  b_{j}: {total} partitions, sizes: {dict(sorted(b_data[j].items())[:10])}")

print("\nQ polynomials:")
for n in range(4):
    Q = compute_Q(b_data, n)
    all_pos = all(v >= 0 for v in Q.values())
    q1 = sum(Q.values())
    print(f"  Q_{n}(q) = {poly_str(Q)}")
    print(f"    pos={all_pos}, Q(1)={q1}")

