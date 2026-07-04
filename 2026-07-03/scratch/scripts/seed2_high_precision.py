"""
Seed 2, Layer 1: High-precision Q_{n,c}(q) computation.

The issue: F_{c,N}(q) is an INFINITE power series in q (for N >= 1).
When we truncate at q_max, the alternating sum doesn't cancel properly.

Key realization: Q_{n,c}(q) is a POLYNOMIAL. For it to be computed correctly
from the infinite series F_{c,N}, we need the cancellation to happen exactly.
With truncation, terms near the boundary don't cancel.

Solution: We need q_max to be much larger than the degree of Q_{n,c}(q).

What is deg(Q_{n,c}(q))? 

From Warnaar's paper, for small cases:
- c=(1,1,0), d=2: Q_{1,c}(q) = q (just q, degree 1). Q_1(1)=1. Check.
- c=(2,1,1), d=4: Q_{1,c}(q) = 2q + q^2 + q^3 (degree 3). Q_1(1)=4.

So the degrees are small! The problem is that our q_max=40 should be enough
for n <= 3 with d=2, but the F_{c,N} series are truncated and the
cancellation fails at the boundary.

The fix: we need q_max >> degree of Q_n, but more importantly, we need to
compute F_{c,N}(q) mod q^{q_max+1} CORRECTLY — meaning we need ALL
cylindric partitions with size <= q_max.

The issue in the previous script: the number of parts was limited to
N + max(c) + 1, which may not be enough. A cylindric partition with max
entry N can have many parts (especially the partition lam^(i) can have
many parts equal to N).

Wait, let me reconsider. For profile c=(1,1,0) and max entry N=1:
lam^(0), lam^(1), lam^(2) are partitions with parts <= 1.
So each is of the form (1,1,...,1,0,0,...) with some number of 1s.
Constraints:
  lam^0_j >= lam^1_{j+c_1} = lam^1_{j+1}
  lam^1_j >= lam^2_{j+c_2} = lam^2_{j+0} = lam^2_j
  lam^2_j >= lam^0_{j+c_0} = lam^0_{j+1}

So: lam^0_j >= lam^1_{j+1}, lam^1_j >= lam^2_j, lam^2_j >= lam^0_{j+1}

From lam^1_j >= lam^2_j >= lam^0_{j+1} >= lam^1_{j+2}
So lam^1 is "almost" non-increasing by steps of 2.

With parts in {0,1}: if lam^0 = (1^a, 0^...), lam^1 = (1^b, 0^...), lam^2 = (1^c, 0^...)
then: a >= b-1 (from lam^0_j >= lam^1_{j+1}), b >= c, c >= a-1.

So: c >= a-1, a >= b-1, b >= c.
Thus: c >= a-1 >= b-2, and b >= c. So b >= c >= b-2.

Case c = b: a >= b-1, b >= a-1. So |a-b| <= 1.
Case c = b-1: a >= b-1 = c, c >= a-1. So a-1 <= c = b-1, so a <= b.
  Also a >= b-1. So a in {b-1, b}.
Case c = b-2: a >= b-1, c = b-2 >= a-1, so a <= b-1.
  But a >= b-1, so a = b-1. And c = b-2 >= a-1 = b-2. OK.

So the valid triples (a,b,c) with a,b,c >= 0 are:
For each b >= 0:
  (b, b, b), (b+1, b, b), (b-1, b, b), (b, b, b-1), (b-1, b, b-1),
  (b, b, b-2), (b-1, b, b-2)
Wait this is getting complicated. Let me just count them computationally
with UNLIMITED number of parts (but bounded total size).

The key insight: for parts in {0,1}, a partition is just (1^a) for some a >= 0.
The size is a. So the total size = a + b + c where a = #1s in lam^0, etc.

For max entry 1 and total size S, we need a + b + c = S with the
interlacing constraints. This gives finitely many triples for each S.
"""

from collections import defaultdict
import sys


class QPoly:
    def __init__(self, coeffs=None, max_deg=200):
        self.max_deg = max_deg
        self.coeffs = defaultdict(int)
        if coeffs:
            for k, v in (coeffs.items() if isinstance(coeffs, dict) else enumerate(coeffs)):
                if k <= max_deg and v != 0:
                    self.coeffs[k] = v

    @staticmethod
    def one(md=200): return QPoly({0: 1}, md)
    @staticmethod
    def zero(md=200): return QPoly({}, md)

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

    def shift(self, s):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            if k+s <= self.max_deg: r.coeffs[k+s] = v
        return r

    def scale(self, c):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items(): r.coeffs[k] = v * c
        return r

    def to_list(self):
        if not self.coeffs: return [0]
        md = max(self.coeffs.keys())
        result = [self.coeffs.get(i, 0) for i in range(md + 1)]
        while len(result) > 1 and result[-1] == 0: result.pop()
        return result

    def eval_at_1(self): return sum(self.coeffs.values())
    def is_nonneg(self): return all(v >= 0 for v in self.coeffs.values())
    def __repr__(self): return str(self.to_list())


def compute_FcN_exact(c, N, q_max):
    """
    Compute F_{c,N}(q) for profile c with k=3 and max entry <= N.
    
    Key: a partition with parts <= N and at most L parts is the same as
    a partition fitting in an L x N rectangle. For unrestricted L (but
    bounded total size q_max), we need L <= q_max (since each part >= 1
    if nonzero, so at most q_max parts with total <= q_max).
    
    For the interlacing conditions, we need enough parts.
    
    Strategy: enumerate using the "parts in {0,...,N}" representation,
    with at most q_max/1 = q_max parts per partition, but the constraints
    will limit things severely.
    """
    k = len(c)
    assert k == 3

    # Maximum number of nonzero parts in any single partition
    # is bounded by q_max (if all parts are 1).
    # But with interlacing, we can compute how many parts are needed.

    # For a cylindric partition with max <= N, each partition has parts in {0,...,N}.
    # The interlacing lam^i_j >= lam^{i+1}_{j+c_{i+1}} means that
    # if lam^{i+1} has m nonzero parts, then lam^i needs at least m - c_{i+1} nonzero parts.

    # Going around the cycle: if lam^0 has a parts, then:
    # lam^1 needs at most a + c_1 nonzero parts (from shift)
    # Actually, lam^0_j >= lam^1_{j+c_1}, so lam^1 with b parts implies
    # we need lam^0_j >= 0 for j <= b - c_1, which is always true.
    # But lam^0_j >= lam^1_{j+c_1} with lam^1_{j+c_1} > 0 requires j+c_1 <= b,
    # i.e., j <= b - c_1. So lam^0 needs nonzero entries at positions 1..max(0, b-c_1).
    # Thus a >= b - c_1 (if b > c_1, otherwise a >= 0 always).

    # Similarly b >= c_parts - c_2, c_parts >= a - c_0.
    # So a >= b - c_1, b >= c_parts - c_2, c_parts >= a - c_0.
    # Substituting: a >= (c_parts - c_2) - c_1 >= (a - c_0 - c_2) - c_1 = a - d.
    # This is always true. So the constraints are:
    # a >= b - c_1, b >= cp - c_2, cp >= a - c_0

    # For total size S = sum of all parts across three partitions,
    # we need a, b, cp such that sum(lam^0) + sum(lam^1) + sum(lam^2) = S.

    # With max entry N, each partition (1^a_1, ...) with parts <= N can have
    # size up to N * (number of parts). Number of parts is at most q_max // 1 = q_max.

    # For efficiency, let's use a different encoding.
    # Represent each partition by its "part multiplicities":
    # m_v = number of parts equal to v, for v = 0, 1, ..., N.
    
    # Actually, let me just enumerate tuples of partition lengths and use
    # generating functions. For parts in {0,...,N}, a partition of length L
    # (with exactly L nonzero parts) with parts <= N has generating function
    # ... this is getting complicated.

    # SIMPLEST APPROACH: For each partition, encode as the tuple of parts
    # (p_1 >= p_2 >= ... >= p_L > 0) with p_i <= N, and pad with zeros.
    # The interlacing conditions are checked position by position.

    # Since we need the sum to be at most q_max, and each part is >= 1 (if nonzero)
    # and <= N, the max number of nonzero parts is q_max.
    # But checking interlacing over positions up to q_max is too expensive.

    # KEY SIMPLIFICATION for k=3: reformulate as a LATTICE PATH problem.
    # Following Kursungoz-Seyrek, cylindric partitions can be decomposed
    # into an ordinary partition + colored distinct parts.

    # But for now let me just compute with reasonable bounds on number of parts.
    # The degree of Q_n should be small relative to q_max.
    
    max_parts = min(q_max, N * 3 + max(c) + 5)  # practical bound

    # Generate all partitions (weakly decreasing, parts <= N, length max_parts, sum <= q_max)
    # This is potentially huge. Let me cache and prune.

    # Better: use dynamic programming.
    # For each of the 3 partitions, build a table of (length, sum) -> count.
    # But the interlacing constraints couple positions across partitions.
    
    # Position-by-position approach:
    # State at position j: (lam^0_j, lam^1_j, lam^2_j)
    # Transitions from position j to j+1:
    #   lam^i_{j+1} <= lam^i_j (weakly decreasing)
    #   AND the interlacing: lam^0_j >= lam^1_{j+c_1}, lam^1_j >= lam^2_{j+c_2}, lam^2_j >= lam^0_{j+c_0}
    
    # The interlacing conditions couple different positions, so this isn't a simple
    # Markov chain. We need a state that remembers the last max(c) positions.
    
    # For c = (c_0, c_1, c_2), the "memory" needed is max(c) positions.
    # State = last max(c)+1 triples of values.
    
    # This is a transfer matrix approach. Let me implement it.
    
    shift_max = max(c)
    
    # State: the last (shift_max + 1) columns of values.
    # At each position j, we have values (v0_j, v1_j, v2_j).
    # We need to remember the last (shift_max) columns to check interlacing.
    
    # State = tuple of (shift_max + 1) triples
    # But the values range from 0 to N, so state space = (N+1)^{3*(shift_max+1)}.
    # For N=2, shift_max=2: (3)^9 = 19683. Manageable.
    # For N=3, shift_max=2: (4)^9 = 262144. Getting big but doable.
    
    mem = shift_max  # how many previous columns we need to remember
    
    # Initial state: we process columns from right to left (position = max_parts-1 down to 0).
    # Actually, from left to right (position 0, 1, 2, ...) where position 0 is the first
    # (largest) part. Column j has values (lam^0_j, lam^1_j, lam^2_j).
    
    # Wait, partitions are indexed lam^i_1, lam^i_2, ..., lam^i_L.
    # In the conjecture, j >= 1. Let me use 0-based indexing: lam^i_j for j = 0, 1, 2, ...
    # with lam^i_{j} >= lam^i_{j+1} (weakly decreasing).
    
    # Interlacing: lam^0_j >= lam^1_{j+c_1}, lam^1_j >= lam^2_{j+c_2}, lam^2_j >= lam^0_{j+c_0}.
    
    # Process positions j = 0, 1, 2, ... in order.
    # At position j, we choose v0 = lam^0_j, v1 = lam^1_j, v2 = lam^2_j.
    # Constraints:
    #   v0 <= prev_v0 (weakly decreasing)
    #   v1 <= prev_v1
    #   v2 <= prev_v2
    #   0 <= v0, v1, v2 <= N
    # AND interlacing constraints that involve FUTURE positions:
    #   At position j, lam^0_j >= lam^1_{j+c_1} — this constrains
    #   the value at position j+c_1 for partition 1.
    
    # So we need to delay checking: when we choose (v0, v1, v2) at position j,
    # we need to check that values at position j respect constraints from
    # positions j - c_1, j - c_2, j - c_0 (i.e., past positions).
    
    # Specifically:
    # At position j, we need:
    #   lam^0_{j - c_1} >= lam^1_j  (from the constraint lam^0_{j'} >= lam^1_{j'+c_1} with j' = j-c_1)
    #     IF j >= c_1
    #   lam^1_{j - c_2} >= lam^2_j  (if j >= c_2)
    #   lam^2_{j - c_0} >= lam^0_j  (if j >= c_0)
    
    # So the state needs to remember values at positions j-1, j-2, ..., j-shift_max.
    # State = last shift_max columns = ((v0_{j-m}, v1_{j-m}, v2_{j-m}) for m = 1..shift_max)
    # Plus we track the current column.
    
    # DP: state = (last_columns, current_q_total)
    # But tracking q_total as part of state makes it too large.
    # Instead, use polynomial DP where each state maps to a QPoly.
    
    # State = tuple of (mem) triples of values
    # At each step, extend by one column, accumulate q-weight.
    
    # Initial condition: before position 0, all values are N (since lam^i_j = N
    # for j < 0 would be wrong... actually lam^i_j is defined for j >= 0 only,
    # and lam^i_{-1} = N would be the "virtual" value for decreasing check.
    # Hmm, actually lam^i_0 <= N is the constraint, and lam^i_0 >= lam^i_1 etc.
    
    # For the interlacing, when j < c_s, the constraint lam^{i-1}_{j-c_s} >= lam^i_j
    # doesn't apply (j - c_s < 0, and we use the convention that lam_{-k} = infinity,
    # or equivalently, the constraint is vacuous).
    
    # Wait, the original definition uses j >= 1 (1-indexed):
    # lam^(i)_j >= lam^(i+1)_{j+c_{i+1}} for all j >= 1
    # In 0-indexed: lam^(i)_j >= lam^(i+1)_{j+c_{i+1}} for all j >= 0
    
    # So lam^0_j >= lam^1_{j+c_1} for all j >= 0
    # This means: lam^0_0 >= lam^1_{c_1}, lam^0_1 >= lam^1_{c_1+1}, etc.
    
    # So at position p (for partition 1), the constraint is:
    # lam^1_p <= lam^0_{p - c_1}   (with p - c_1 >= 0, else no constraint)
    
    # Similarly:
    # lam^2_p <= lam^1_{p - c_2}
    # lam^0_p <= lam^2_{p - c_0}
    
    # For the DP, process positions p = 0, 1, 2, ...
    # State = values at positions p-1, p-2, ..., p-shift_max
    
    # Let me implement this properly.
    
    # State encoding: tuple of tuples ((v0, v1, v2) at p-1, (v0,v1,v2) at p-2, ...)
    # Length = shift_max
    # For p < shift_max, we pad with (N, N, N) for "virtual" positions.
    
    # Actually, for position p, constraints on v0_p, v1_p, v2_p:
    # 1. v0_p <= v0_{p-1} (decrease)
    # 2. v1_p <= v1_{p-1}
    # 3. v2_p <= v2_{p-1}
    # 4. v1_p <= v0_{p-c_1} if p >= c_1 (interlacing 0->1)
    # 5. v2_p <= v1_{p-c_2} if p >= c_2 (interlacing 1->2)
    # 6. v0_p <= v2_{p-c_0} if p >= c_0 (interlacing 2->0)
    
    # We extend until all values are 0 (and stay 0).
    # The partition ends when all values are 0.
    # We accumulate q-weight = v0_p + v1_p + v2_p at each position.
    
    # State: (column_{p-1}, column_{p-2}, ..., column_{p-mem})
    # where each column is (v0, v1, v2)
    # mem = max(c_0, c_1, c_2)
    
    # If mem = 0, no memory needed (all c_i = 0 means d=0, not interesting).
    
    if mem == 0:
        # All c_i = 0, trivial case
        return QPoly({0: 1}, q_max)
    
    # Initial state: position -1, -2, ..., -mem all have values (N, N, N)
    # (virtual columns with max value, since there's no constraint from before)
    # Actually that's wrong. For p=0:
    # v0_0 <= N (max entry constraint)
    # v1_0 <= N
    # v2_0 <= N
    # v0_0 <= v2_{0-c_0} = v2_{-c_0}: no constraint if c_0 > 0
    # etc.
    # So virtual columns should have value N to not constrain.
    
    init_col = (N, N, N)
    init_state = tuple([init_col] * mem)
    
    # DP: map from state -> QPoly
    dp = {init_state: QPoly.one(q_max)}
    
    max_steps = q_max + 1  # can't have more positions than total q-weight
    
    for p in range(max_steps):
        new_dp = defaultdict(lambda: QPoly.zero(q_max))
        
        for state, poly in dp.items():
            if all(v == 0 for v in poly.coeffs.values()):
                continue
            
            # state = (col_{p-1}, col_{p-2}, ..., col_{p-mem})
            # col_{p-s} = state[s-1] for s = 1..mem
            
            prev_col = state[0]  # column at p-1
            
            # Bounds for v0, v1, v2 at position p
            max_v0 = prev_col[0]  # decrease
            max_v1 = prev_col[1]
            max_v2 = prev_col[2]
            
            # Interlacing constraints
            if c[1] > 0 and c[1] <= mem and p >= c[1]:
                # v1_p <= v0_{p-c_1}, which is state[c_1-1][0]
                max_v1 = min(max_v1, state[c[1]-1][0])
            elif c[1] == 0:
                # v1_p <= v0_p — but v0_p is not yet chosen! 
                # Handle below.
                pass
            
            if c[2] > 0 and c[2] <= mem and p >= c[2]:
                max_v2 = min(max_v2, state[c[2]-1][1])
            elif c[2] == 0:
                pass
            
            if c[0] > 0 and c[0] <= mem and p >= c[0]:
                max_v0 = min(max_v0, state[c[0]-1][2])
            elif c[0] == 0:
                pass
            
            for v0 in range(max_v0, -1, -1):
                ub_v1 = max_v1
                if c[1] == 0:
                    ub_v1 = min(ub_v1, v0)  # v1_p <= v0_p
                
                for v1 in range(ub_v1, -1, -1):
                    ub_v2 = max_v2
                    if c[2] == 0:
                        ub_v2 = min(ub_v2, v1)  # v2_p <= v1_p
                    
                    for v2 in range(ub_v2, -1, -1):
                        if c[0] == 0 and v0 > v2:
                            continue  # v0_p <= v2_p when c_0 = 0
                        
                        weight = v0 + v1 + v2
                        
                        if v0 == 0 and v1 == 0 and v2 == 0:
                            # Terminal: all remaining positions are 0 too
                            new_state = tuple([(0,0,0)] * mem)
                            term = poly  # no additional weight
                            new_dp[new_state] = new_dp[new_state] + term
                        else:
                            new_col = (v0, v1, v2)
                            new_state = (new_col,) + state[:-1]
                            term = poly.shift(weight)
                            new_dp[new_state] = new_dp[new_state] + term
        
        dp = dict(new_dp)
        
        # Prune zero states
        dp = {s: p for s, p in dp.items() if any(v != 0 for v in p.coeffs.values())}
        
        if not dp:
            break
    
    # Sum over all terminal states
    result = QPoly.zero(q_max)
    zero_state = tuple([(0,0,0)] * mem)
    if zero_state in dp:
        result = dp[zero_state]
    
    # Also need to add contributions that haven't terminated
    for state, poly in dp.items():
        if state != zero_state:
            # These are truncated — they haven't reached all zeros yet
            # This means q_max is too small to capture all partitions
            leftover = poly.eval_at_1()
            if leftover > 0:
                pass  # we'll check this
    
    return result


def main():
    q_max = 100
    
    print("Transfer matrix computation of F_{c,N}(q)")
    print(f"q_max = {q_max}")
    
    profile = (1, 1, 0)
    d = sum(profile)
    expected_base = (d+1)*(d+2)//6 - 1
    print(f"\nProfile c = {profile}, d = {d}, expected Q(1) = {expected_base}^n")
    
    FcN = []
    for N in range(5):
        print(f"\n  Computing F_{{c,{N}}}(q)...", flush=True)
        F = compute_FcN_exact(profile, N, q_max)
        FcN.append(F)
        print(f"  F_{{c,{N}}}(1) = {F.eval_at_1()}")
        lst = F.to_list()
        print(f"  First 20 coeffs: {lst[:20]}")
    
    # Now compute Q_n
    print("\nComputing Q_{n,c}(q):")
    for n in range(len(FcN)):
        Q_n = QPoly.zero(q_max)
        for j in range(n + 1):
            sign = (-1) ** j
            q_shift = j * (j - 1) // 2
            
            ratio = QPoly.one(q_max)
            for i in range(j + 1, n + 1):
                factor = QPoly({0: 1, i: -1}, q_max)
                ratio = ratio * factor
            
            term = ratio * FcN[n - j]
            term = term.scale(sign).shift(q_shift)
            Q_n = Q_n + term
        
        coeffs = Q_n.to_list()
        print(f"\n  Q_{{{n},c}}(q) = {coeffs}")
        print(f"    Q(1) = {Q_n.eval_at_1()}, expected = {expected_base**n}")
        print(f"    nonneg = {Q_n.is_nonneg()}")


if __name__ == "__main__":
    main()
