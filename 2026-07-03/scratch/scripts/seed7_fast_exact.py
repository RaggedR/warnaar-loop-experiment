"""
Seed 7 — Fast exact computation of Q_{n,c}(q) for small n.
Uses transfer matrix approach for c = (1,1,0), d=2, k=3, t=5.
"""

from collections import defaultdict
from math import gcd

def compute_transfer_matrix_d2(n_bound, max_q=80):
    """
    For c = (1,1,0), d=2, k=3, t=5.
    
    Interlacing conditions (1-indexed parts, cyclic):
    lam^0_j >= lam^1_{j + c_1} = lam^1_{j+1}  (c_1 = 1)
    lam^1_j >= lam^2_{j + c_2} = lam^2_j       (c_2 = 0)
    lam^2_j >= lam^0_{j + c_0} = lam^0_{j+1}   (c_0 = 1)
    
    So: lam^0_j >= lam^1_{j+1}, lam^1_j >= lam^2_j, lam^2_j >= lam^0_{j+1}
    
    From lam^1_j >= lam^2_j >= lam^0_{j+1} >= lam^1_{j+2},
    so lam^1 has difference-2-like behavior with lam^0 interlaced.
    
    State at column j: (a_j, b_j, c_j) = (lam^0_j, lam^1_j, lam^2_j)
    Within-column constraint: b_j >= c_j (from lam^1_j >= lam^2_j)
    
    Transition (a,b,c) -> (a',b',c') requires:
    - a >= b' (from lam^0_j >= lam^1_{j+1}, with j -> j, j+1 -> j+1)
      Wait: lam^0_j >= lam^1_{j+1}. At column j, a_j = lam^0_j.
      At column j+1, b_{j+1} = lam^1_{j+1}. So a_j >= b_{j+1}, i.e., a >= b'.
    - c >= a' (from lam^2_j >= lam^0_{j+1})
    - b' >= c' (within-column at j+1)
    - a' <= a, b' <= b, c' <= c (partitions are weakly decreasing)
    
    Weight: q^{a+b+c} per column.
    
    All parts in {0, 1, ..., n_bound}.
    """
    
    # Enumerate valid states
    states = []
    for a in range(n_bound + 1):
        for b in range(n_bound + 1):
            for c in range(b + 1):  # b >= c
                states.append((a, b, c))
    
    state_idx = {s: i for i, s in enumerate(states)}
    N = len(states)
    
    # Build transition matrix T where T[(s,s')] = q^{weight(s')} if s -> s' is valid
    # We represent T as: for each state pair, the q-power contributed
    
    # F_{c,n}(q) = sum over all valid sequences of n+1 columns
    # But actually, partitions can have infinitely many parts (all 0 after some point).
    # The "state" (0,0,0) is absorbing with weight 0.
    # A partition sequence of length L means columns 1, ..., L have some nonzero state,
    # then columns L+1, L+2, ... are all (0,0,0).
    
    # So F_{c,n}(q) = sum over all finite sequences starting from ANY initial state
    # (a,b,c) with 0 <= c <= b and a <= n, ending at (0,0,0).
    
    # Wait, that's not right either. The partitions lam^0, lam^1, lam^2 can start
    # with any values <= n. There's no initial constraint beyond max <= n.
    
    # Actually, the FIRST column gives the first parts of each partition.
    # There's no constraint from a "column 0" since j starts at 1.
    # The initial state is any valid (a,b,c) with b >= c and a, b, c <= n.
    # The final state (as j -> infinity) must be (0,0,0).
    
    # So F_{c,n}(q) = sum over all valid paths from any initial state to (0,0,0).
    
    # But transitions: going from column j to j+1:
    # a >= b', c >= a', b' >= c', a' <= a, b' <= b, c' <= c
    
    # Let me build the transfer matrix T where T[s'][s] = 1 if s -> s' is valid.
    # Then F_{c,n} = sum_{L>=0} sum_{s_1, ..., s_L valid path} q^{sum weights}
    # = sum_s (I + T + T^2 + ...)_{ (0,0,0), s } * q^{wt(s)} ... hmm this is getting complicated.
    
    # Let me just use vectors. Let v[s] = q^{wt(s)} for starting states.
    # Apply T repeatedly, accumulating.
    
    # Actually, the cleanest formulation: think of it as a sum over column-length L.
    # For L columns (L parts in each partition):
    # Choose s_1, ..., s_L where s_j -> s_{j+1} is valid, and s_L -> (0,0,0) is valid.
    
    # This is the "all paths from any start to ground state" formulation.
    
    # Let R[s] = total weight of all paths from s to (0,0,0).
    # Then R[(0,0,0)] = 1 (empty path, weight q^0 = 1).
    # For other s: R[s] = q^{wt(s)} * sum_{s': s->s' valid} R[s']
    
    # And F_{c,n} = sum_s R[s] where the sum is over all valid initial states.
    
    # Wait, R should accumulate the weight of s, then recurse.
    # R[s] = q^{wt(s)} * (1 if s=(0,0,0) else sum_{s': s->s' valid and s'!=(0,0,0) or s'=(0,0,0)} R[s'])
    # Hmm, (0,0,0) -> (0,0,0) is always valid and has weight 0.
    
    # Let me reconsider. A cylindric partition is three partitions. Column j has
    # state s_j = (lam^0_j, lam^1_j, lam^2_j). Eventually s_j = (0,0,0) for large j.
    # The first column can be anything with parts <= n.
    
    # Total weight = sum of all entries = sum_j (a_j + b_j + c_j).
    
    # So F_{c,n}(q) = sum over valid sequences (s_1, s_2, ...) where s_j -> s_{j+1}
    # satisfies transition rules, eventually reaching (0,0,0), of q^{sum wt(s_j)}.
    
    # Build as: R[s] = polynomial in q giving total generating function for paths
    # starting at s and ending at (0,0,0).
    # R[(0,0,0)] = 1
    # R[s] = q^{wt(s)} * sum_{s': s -> s'} R[s']   for s != (0,0,0)
    
    # Actually (0,0,0) to (0,0,0) is valid, so we'd get infinite loop.
    # The issue is that (0,0,0) is the "tail" of the partition.
    # Once we reach (0,0,0), we stay there forever with weight 0.
    # So the generating function for paths from (0,0,0) is 1 (the empty continuation).
    
    # For s != (0,0,0):
    # R[s] = q^{wt(s)} * sum_{s' <= s valid transition} R[s']
    # where s' = (0,0,0) gives R[(0,0,0)] = 1.
    
    # This recursion terminates because wt(s') < wt(s) or s' has smaller entries.
    # Actually s' <= s component-wise (each partition is weakly decreasing),
    # so wt(s') <= wt(s), with equality only if s' = s which can't happen
    # (a' <= a, b' <= b, c' <= c, and a >= b' and c >= a', so if s' = s then
    # a = b and c = a, i.e., a = b = c, and then b >= c gives a = b = c).
    # For s = (v,v,v): a >= b' = v, c = v >= a' = v, ok, and a' <= a = v,
    # so a' = v, b' = v, c' = v. Yes, (v,v,v) -> (v,v,v) is valid!
    # This means the recursion doesn't terminate for (v,v,v) states.
    
    # Right — (v,v,v) -> (v,v,v) -> ... forever is a valid cylindric partition
    # (all parts equal to v). This has infinite weight, so it doesn't appear
    # in the bounded generating function.
    
    # For the BOUNDED case (max <= n), we only consider partitions with max <= n.
    # The total number of nonzero parts can be unbounded, but we're working with
    # power series truncated at max_q.
    
    # Let me use dynamic programming. R[s] as a truncated polynomial in q.
    # Process states in order of decreasing weight.
    
    # Actually, let me just compute iteratively. Start with the identity:
    # v = delta_{(0,0,0)} (unit vector at ground state)
    # Apply T repeatedly: v -> T*v -> T^2*v -> ...
    # F_{c,n} = sum_s sum_{L>=0} [T^L * v](s) * q^{wt(s)}  ... no.
    
    # Let me think differently. Let R be a vector indexed by states, where
    # R[s] = generating function for paths from s to (0,0,0).
    # We need to solve: R = q^{wt} * (delta_{0} + T * R)
    # where delta_0 means "if s=(0,0,0), add 1", and T is the transition.
    
    # For (0,0,0): R[(0,0,0)] = q^0 * (1 + sum_{s' valid from 0} R[s']) = 1 + R[(0,0,0)]
    # This diverges because (0,0,0) -> (0,0,0) is valid.
    
    # THE FIX: We should not include the self-loop at (0,0,0).
    # A cylindric partition has finitely many nonzero columns.
    # Column j contributes weight a_j + b_j + c_j. If s_j = (0,0,0), weight is 0.
    # So ALL columns after the last nonzero one are (0,0,0) with zero contribution.
    # We should sum over finite paths s_1, ..., s_L with s_L != (0,0,0) and 
    # the transition s_L -> (0,0,0) is valid.
    
    # Alternatively, R[(0,0,0)] = 1, and for s != (0,0,0):
    # R[s] = q^{wt(s)} * sum_{s': s->s' valid, s'<s or s'=(0,0,0)} R[s']
    # But self-loops for (v,v,v) -> (v,v,v) ARE allowed and give infinite contributions
    # as a POWER SERIES (not as a polynomial).
    
    # For F_{c,n}(q) to make sense as a power series, we need to be more careful.
    # The set C_{c,n} of cylindric partitions with max <= n IS finite for each 
    # fixed total weight! So F_{c,n}(q) is well-defined as a power series.
    
    # For POLYNOMIAL computation up to degree max_q, I'll iterate the transfer
    # matrix enough times.
    
    # Build transition map
    transitions = defaultdict(list)  # s -> list of s'
    for s in states:
        a, b, c = s
        for s2 in states:
            a2, b2, c2 = s2
            # Check: a >= b2, c >= a2, b2 >= c2 (always), a2 <= a, b2 <= b, c2 <= c
            if a >= b2 and c >= a2 and a2 <= a and b2 <= b and c2 <= c:
                transitions[s].append(s2)
    
    # Compute R[s] for each state using iteration
    # R[s] = sum over all finite paths from s to ground, of q^{total weight}
    # Iterate: R^{(0)}[s] = delta_{s, (0,0,0)}
    # R^{(L)}[s] = q^{wt(s)} * sum_{s'} R^{(L-1)}[s']  for the L-step paths
    # Total R[s] = sum_L R^{(L)}[s] where L counts number of steps
    
    # But we need R^{(0)} to handle the "path of length 0" correctly.
    # Path of length 0: only (0,0,0) contributes with weight 0. So R^{(0)}[(0,0,0)] = 1.
    # Path of length 1 from s: s -> (0,0,0) valid and s != (0,0,0): weight = wt(s).
    #   R^{(1)}[s] = q^{wt(s)} if (0,0,0) in transitions[s] and s != (0,0,0).
    # Path of length L from s: s -> s' -> ... -> (0,0,0), L steps, all intermediate != (0,0,0)
    
    # Let's use polynomial-valued DP. For each step, add contributions.
    
    # Initialize: R[s] = {} (empty polynomial = 0 for all states)
    # R[(0,0,0)] = {0: 1}  (constant 1)
    
    R = {s: {} for s in states}
    R[(0,0,0)] = {0: 1}
    
    # Iterate: keep applying one more transition step
    # new_R[s] = q^{wt(s)} * sum_{s' in transitions[s], s'!= s} R[s']
    # Actually, we need to handle self-loops carefully.
    # Let's just iterate and add contributions at each step.
    
    # Better approach: F_{c,n}(q) at fixed q-degree D = number of cylindric partitions
    # of profile c with max <= n and total weight D.
    # Use column-by-column construction.
    
    # current[s] = polynomial tracking all partial cylindric partitions 
    # whose current column is s (and all future columns are to be determined).
    
    # Actually, let's think about it as counting from the last column backwards.
    # The last column before everything becomes 0 has state s_L != (0,0,0).
    # Transition s_L -> (0,0,0) must be valid.
    
    # previous[s] = generating function for partial partitions that have 
    # been built so far with current state s.
    
    # Start: prev[(0,0,0)] = {0: 1}
    # Add columns: for each state s != (0,0,0) that can transition to some s' in prev:
    #   prev[s] += q^{wt(s)} * prev[s']  (if s -> s' is valid)
    
    # But we want the TOTAL: F_{c,n}(q) = sum_s prev[s] accumulated over all iterations.
    
    # Let me just do it properly with iteration.
    
    acc = dict(R[(0,0,0)])  # accumulate total (starts with the empty partition: weight 0)
    
    prev = {}
    # First column: any state s with (0,0,0) as a valid next state
    # Actually, we're building from right to left.
    # prev = {(0,0,0): {0: 1}}
    prev = {(0,0,0): {0: 1}}
    
    max_iters = max_q + 5  # enough iterations for weight up to max_q
    
    for iteration in range(1, max_iters + 1):
        new_prev = defaultdict(lambda: {})
        found_new = False
        for s in states:
            if s == (0,0,0):
                continue
            a, b, c = s
            wt = a + b + c
            if wt > max_q:
                continue
            # s -> s' must be valid for some s' in prev
            for s2 in transitions[s]:
                if s2 in prev and prev[s2]:
                    # Add q^wt * prev[s2] to new_prev[s]
                    for p, v in prev[s2].items():
                        pp = p + wt
                        if pp <= max_q:
                            if pp not in new_prev[s]:
                                new_prev[s][pp] = 0
                            new_prev[s][pp] += v
                            found_new = True
        
        if not found_new:
            break
        
        # Add to accumulator and update prev
        for s, poly in new_prev.items():
            for p, v in poly.items():
                acc[p] = acc.get(p, 0) + v
        
        # Merge new_prev into prev
        merged = defaultdict(lambda: {})
        for s in states:
            if s in prev:
                merged[s] = dict(prev[s])
            if s in new_prev:
                for p, v in new_prev[s].items():
                    merged[s][p] = merged[s].get(p, 0) + v
        prev = dict(merged)
    
    return {k: v for k, v in acc.items() if v != 0}


if __name__ == "__main__":
    print("Transfer matrix computation of F_{c,n}(q)")
    print("Profile c = (1,1,0), d=2")
    print()
    
    max_q = 30
    
    for n in range(4):
        print(f"Computing F_{{c,{n}}}(q)...")
        F = compute_transfer_matrix_d2(n, max_q)
        terms = sorted(F.items())[:20]
        s = " + ".join(f"{v}q^{e}" if v != 1 else f"q^{e}" for e, v in terms if v > 0)
        print(f"  F_{{c,{n}}} = {s}")
        print(f"  F(1) = {sum(F.values())}")
        print()
