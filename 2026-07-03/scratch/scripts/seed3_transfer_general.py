"""
Seed 3: General transfer matrix for cylindric partitions with arbitrary profile.

For profiles where some c_i > 1, the interlacing conditions connect columns
that are c_i apart. We handle this by using a wider state window.

For c = (c0, c1, c2), the constraints are:
  lam^0_j >= lam^1_{j+c1}
  lam^1_j >= lam^2_{j+c2}
  lam^2_j >= lam^0_{j+c0}

The maximum shift is max(c0, c1, c2). If max shift = s, then the state
at column j depends on columns j-s through j. So we use a window of 
size s (tracking values of the last s columns).

Actually, it's cleaner to think of it as: the state needs to encode
enough columns to check all constraints.

For c = (c0, c1, c2) with all c_i <= 1 (handled before), the state is
a single column (a, b, cv).

For c = (2, 1, 1), d=4, the shifts are:
  lam^0_j >= lam^1_{j+1}  (c1=1)
  lam^1_j >= lam^2_{j+1}  (c2=1)
  lam^2_j >= lam^0_{j+2}  (c0=2)

The c0=2 constraint connects column j to column j+2. So we need a 
window of size 2: the state at "position j" encodes columns j and j-1.

State = ((a_{j-1}, b_{j-1}, cv_{j-1}), (a_j, b_j, cv_j))

Transition adds a new column j+1:
State' = ((a_j, b_j, cv_j), (a_{j+1}, b_{j+1}, cv_{j+1}))

Constraints for the new column j+1:
- a_j >= b_{j+1}  (from c1=1: lam^0_j >= lam^1_{j+1})
- b_j >= cv_{j+1}  (from c2=1: lam^1_j >= lam^2_{j+1})
- cv_{j-1} >= a_{j+1} (from c0=2: lam^2_{j-1} >= lam^0_{j+1})
- Partition decreasing: a_{j+1} <= a_j, b_{j+1} <= b_j, cv_{j+1} <= cv_j
- Within-column constraints from c_i=0 (none for this profile since all c_i > 0)

This works! The window size is max(c_i).
"""

from collections import defaultdict
from math import gcd
import sys


def compute_F_transfer_general(c, N, q_max):
    """
    Compute F_{c,N}(q) using transfer matrix with window of size max(c_i).
    
    c = (c0, c1, c2), profile.
    N = max entry bound.
    q_max = truncation degree in q.
    
    Returns dict {degree: coefficient}.
    """
    c0, c1, c2 = c
    window = max(c0, c1, c2)
    
    if window == 0:
        # All c_i = 0: trivial case, no interlacing constraints
        # F_{(0,0,0),N}(q) = (number of triples of partitions with parts <= N)^?
        # Actually with all c_i=0: lam^0_j >= lam^1_j >= lam^2_j >= lam^0_j
        # => lam^0_j = lam^1_j = lam^2_j for all j. 
        # So F_{(0,0,0),N}(q) = product of 1/(1-q^i) for i=1..N
        # Actually it's the generating function for partitions with parts <= N,
        # but each part appears with weight q^{3*value} since all three partitions are equal.
        # F = sum_lambda q^{3|lambda|} where lambda has parts <= N
        # = prod_{j=1}^N 1/(1-q^{3j})
        result = [0] * (q_max + 1)
        result[0] = 1
        for j in range(1, N + 1):
            for d in range(3 * j, q_max + 1):
                result[d] += result[d - 3 * j]
        return {i: result[i] for i in range(q_max + 1) if result[i] != 0}
    
    # Within-column constraints from c_i = 0
    within_col = []
    if c0 == 0:
        within_col.append(('cv', 'a'))  # lam^2 >= lam^0 same column
    if c1 == 0:
        within_col.append(('a', 'b'))   # lam^0 >= lam^1 same column
    if c2 == 0:
        within_col.append(('b', 'cv'))  # lam^1 >= lam^2 same column
    
    def valid_column(a, b, cv):
        """Check within-column constraints."""
        for bigger, smaller in within_col:
            big = {'a': a, 'b': b, 'cv': cv}[bigger]
            small = {'a': a, 'b': b, 'cv': cv}[smaller]
            if big < small:
                return False
        return True
    
    # Generate all valid single columns
    all_columns = []
    for a in range(N + 1):
        for b in range(N + 1):
            for cv in range(N + 1):
                if valid_column(a, b, cv):
                    all_columns.append((a, b, cv))
    
    zero_col = (0, 0, 0)
    nonzero_columns = [col for col in all_columns if col != zero_col]
    
    # A state in the transfer matrix is a window of `window` columns.
    # State = (col_{j-window+1}, ..., col_j)
    # For window=1: state = (col_j,)
    # For window=2: state = (col_{j-1}, col_j)
    
    # Generate all valid states (windows of columns)
    # Each column must satisfy within-column constraints and be <= preceding column
    # (weakly decreasing partitions).
    # In a state (col1, col2, ..., colW), each col_i = (a_i, b_i, cv_i).
    # Decreasing: a_{i+1} <= a_i, b_{i+1} <= b_i, cv_{i+1} <= cv_i.
    # Also, between-column interlacing constraints within the window.
    
    # For window=1, state is (col,). The between-column constraints are
    # applied during transitions.
    
    # For window=2, state is (col_{j-1}, col_j). Within the window,
    # col_j is constrained by col_{j-1} (decreasing + between-column constraints
    # with shift=1).
    
    # Generate valid states recursively.
    def gen_states(w, prev_columns=[]):
        """Generate all valid states of width w."""
        if w == 0:
            yield tuple(prev_columns)
            return
        
        if not prev_columns:
            # First column: unconstrained except within-column
            for col in all_columns:
                yield from gen_states(w - 1, [col])
        else:
            last = prev_columns[-1]
            la, lb, lcv = last
            for col in all_columns:
                a, b, cv = col
                # Decreasing partition constraint
                if a > la or b > lb or cv > lcv:
                    continue
                # Between-column interlacing constraints from shift=1
                # These are constraints of the form lam^X_{j-1} >= lam^Y_j
                # where the shift is 1 (the distance between consecutive columns)
                # Which constraints have shift exactly equal to the position difference?
                # The position difference between prev_columns[-1] and col is 1.
                # Constraint with shift s: involves column j-s and column j.
                # For position difference 1: s=1.
                # c1=s means lam^0_{j-s} >= lam^1_j when s = c1.
                # So if c1 == 1: la >= b (lam^0 at last >= lam^1 at col)
                # If c2 == 1: lb >= cv
                # If c0 == 1: lcv >= a
                
                ok = True
                if c1 == 1 and la < b:
                    ok = False
                if c2 == 1 and lb < cv:
                    ok = False
                if c0 == 1 and lcv < a:
                    ok = False
                
                # For larger shifts within the window:
                # If len(prev_columns) >= 2, check shift=2 constraints
                if len(prev_columns) >= 2:
                    pp = prev_columns[-2]
                    pa, pb, pcv = pp
                    if c1 == 2 and pa < b:
                        ok = False
                    if c2 == 2 and pb < cv:
                        ok = False
                    if c0 == 2 and pcv < a:
                        ok = False
                
                if ok:
                    yield from gen_states(w - 1, prev_columns + [col])
    
    all_states = list(gen_states(window))
    
    # Separate zero state and nonzero states
    zero_state = tuple([zero_col] * window)
    nonzero_states = [s for s in all_states if s != zero_state]
    
    # Also allow "partially zero" states where earlier columns are nonzero
    # but later ones are zero. Wait, actually all valid states already include
    # those because gen_states generates all combinations that satisfy constraints.
    # A state like ((1,0,0), (0,0,0)) is valid if the transition from (1,0,0) to (0,0,0) is ok.
    
    # Actually, I realize the state representation needs more thought.
    # The state encodes the LAST `window` columns. The issue is that when
    # the partition has very long rows, we may need many iterations.
    
    # The transfer matrix approach: 
    # Start: can begin with any valid state (representing the first `window` columns).
    # At each step, slide the window by 1: drop the oldest column, add a new column.
    # Weight per step = weight of the new column being added.
    
    # Wait, the initial state represents the first `window` columns, so their
    # total weight needs to be accounted for at initialization.
    
    # Let me redefine:
    # For window=1: state = (col_j,). Weight of column j = w(col_j).
    #   Initial weight = w(state[0]).
    #   Transition: add new column, weight = w(new_col).
    #
    # For window=2: state = (col_{j-1}, col_j). 
    #   The initial state represents columns 1 and 2.
    #   Initial weight = w(col_1) + w(col_2).
    #   Transition to (col_j, col_{j+1}): weight of new column = w(col_{j+1}).
    
    # Hmm, actually the tricky part for window > 1 is that the initial state
    # already has the weight of `window` columns.
    
    # Let me use a cleaner formulation:
    # Phase 1: Initialize with all valid states of width `window` (first window columns).
    #   Weight = sum of weights of all columns in the window.
    # Phase 2: Extend by adding one column at a time.
    #   New state = state[1:] + (new_col,). Weight = w(new_col).
    # Phase 3: Terminal: last state must be able to transition to zero.
    #   For window=1: any state can go to zero.
    #   For window=2: last state (col_{L-1}, col_L). When we try to add 
    #     a zero column, we need: constraints from col_L to zero (shift=1),
    #     and constraints from col_{L-1} to zero (shift=2 if c_i=2).
    #     shift=1 to zero: trivially satisfied.
    #     shift=2 from col_{L-1}: c0=2 => lcv_{L-1} >= 0 (trivially true).
    #     So any state can transition to the zero state.
    
    # OK let me implement this.
    
    state_idx = {s: i for i, s in enumerate(nonzero_states)}
    n_states = len(nonzero_states)
    
    if n_states == 0:
        return {0: 1}
    
    print(f"    N={N}: {n_states} nonzero states, window={window}")
    
    # Build transitions: for each state s, what states s' can follow?
    # s = (col_1, ..., col_W), s' = (col_2, ..., col_W, col_new)
    # So s' must have s'[:-1] == s[1:]  (shifted window)
    # And the new column col_new must satisfy all constraints.
    
    # Precompute transitions
    transitions = []  # (from_idx, to_idx, q_weight_of_new_col)
    
    for i, s in enumerate(nonzero_states):
        prefix = s[1:]  # This must match the first W-1 columns of target state
        for j, sp in enumerate(nonzero_states):
            if sp[:-1] != prefix:
                continue
            new_col = sp[-1]
            # Check constraints from the oldest column in s to the new column
            # The distance from s[0] to new_col is `window` columns.
            # Check if any c_i equals `window`:
            ok = True
            if c1 == window:
                if s[0][0] < new_col[1]:  # lam^0 at s[0] >= lam^1 at new_col
                    ok = False
            if c2 == window:
                if s[0][1] < new_col[2]:  # lam^1 at s[0] >= lam^2 at new_col
                    ok = False
            if c0 == window:
                if s[0][2] < new_col[0]:  # lam^2 at s[0] >= lam^0 at new_col
                    ok = False
            
            if ok:
                transitions.append((i, j, sum(new_col)))
    
    print(f"    {len(transitions)} transitions")
    
    # Now compute F_{c,N}(q):
    # F = 1 (empty partition)
    #   + sum over valid starting states s_init, weight q^{sum w(cols in s_init)}
    #     * (1 + sum over paths from s_init ...)
    
    # The "1 + sum over paths" is the transfer matrix geometric series.
    # Let G[i] = generating function for paths starting from state i (including the empty continuation).
    # G[i] = 1 + sum_{j: transition i->j} q^{w(new_col_j)} G[j]
    # G = 1 + A * G => G = (I - A)^{-1} * 1
    
    # Compute G iteratively
    G = [{0: 1} for _ in range(n_states)]
    current = [{0: 1} for _ in range(n_states)]
    
    for iteration in range(q_max + 1):
        new_current = [defaultdict(int) for _ in range(n_states)]
        any_nonzero = False
        for fi, ti, w in transitions:
            for deg, coeff in current[ti].items():
                new_deg = deg + w
                if new_deg <= q_max and coeff != 0:
                    new_current[fi][new_deg] += coeff
                    any_nonzero = True
        
        if not any_nonzero:
            break
        
        current = [dict(d) for d in new_current]
        for i in range(n_states):
            for deg, coeff in current[i].items():
                G[i][deg] = G[i].get(deg, 0) + coeff
    
    # F_{c,N}(q) = 1 + sum over starting states s, q^{w(s)} * G[s]
    # where w(s) = sum of weights of all columns in the state window
    F = {0: 1}
    for i, s in enumerate(nonzero_states):
        init_weight = sum(sum(col) for col in s)
        for deg, coeff in G[i].items():
            new_deg = deg + init_weight
            if new_deg <= q_max:
                F[new_deg] = F.get(new_deg, 0) + coeff
    
    return {k: v for k, v in F.items() if v != 0}


def compute_Q(c, n_target, q_max):
    """
    Compute Q_{n,c}(q) using:
    Q_n = sum_{j=0}^n (-1)^j q^{j(j-1)/2} * (q;q)_n/(q;q)_j * F_{c,n-j}(q)
    """
    d = sum(c)
    ell = gcd(d, 3)
    
    F_cm = {}
    for m in range(n_target + 1):
        F_cm[m] = compute_F_transfer_general(c, m, q_max)
        f1 = sum(F_cm[m].values())
        # Don't print for brevity
    
    Q = defaultdict(int)
    for j in range(n_target + 1):
        sign = (-1) ** j
        shift = j * (j - 1) // 2
        
        ratio = {0: 1}
        for i in range(j + 1, n_target + 1):
            new_ratio = {}
            for deg, coeff in ratio.items():
                if deg <= q_max:
                    new_ratio[deg] = new_ratio.get(deg, 0) + coeff
                if deg + i <= q_max:
                    new_ratio[deg + i] = new_ratio.get(deg + i, 0) - coeff
            ratio = {k: v for k, v in new_ratio.items() if v != 0}
        
        Fm = F_cm[n_target - j]
        term = {}
        for d1, c1 in ratio.items():
            for d2, c2 in Fm.items():
                dt = d1 + d2
                if dt <= q_max:
                    term[dt] = term.get(dt, 0) + c1 * c2
        
        for deg, coeff in term.items():
            nd = deg + shift
            if nd <= q_max:
                Q[nd] += sign * coeff
    
    return {k: v for k, v in Q.items() if v != 0}


def poly_to_list(poly):
    if not poly:
        return [0]
    mx = max(poly.keys())
    return [poly.get(i, 0) for i in range(mx + 1)]


def main():
    q_max = 100
    
    test_cases = [
        # (profile, n_max_to_test)
        ((1, 1, 0), 4),   # d=2
        ((2, 1, 1), 3),   # d=4
        ((1, 2, 1), 3),   # d=4
        ((2, 2, 1), 3),   # d=5
        ((1, 0, 0), 3),   # d=1
    ]
    
    for c, n_max in test_cases:
        d = sum(c)
        ell = gcd(d, 3)
        if d % 3 == 0:
            print(f"\nSkipping c={c}, d={d} (divisible by 3)")
            continue
        
        expected_base = (d + 1) * (d + 2) // 6 - 1
        print(f"\n{'='*60}")
        print(f"Profile c = {c}, d = {d}, ell = {ell}")
        print(f"Expected Q_{{n,c}}(1) = {expected_base}^n")
        
        for n in range(1, n_max + 1):
            Q = compute_Q(c, n, q_max)
            coeffs = poly_to_list(Q)
            while coeffs and coeffs[-1] == 0:
                coeffs.pop()
            if not coeffs:
                coeffs = [0]
            
            all_pos = all(x >= 0 for x in coeffs)
            eval_at_1 = sum(coeffs)
            
            status = "OK" if all_pos and eval_at_1 == expected_base**n else "ISSUE"
            
            if len(coeffs) <= 25:
                print(f"  n={n}: Q = {coeffs}")
            else:
                print(f"  n={n}: Q has {len(coeffs)} terms, first 15: {coeffs[:15]}")
            print(f"    Q(1) = {eval_at_1} (expected {expected_base**n}), "
                  f"nonneg: {all_pos} [{status}]")
            
            if not all_pos:
                neg = {i: coeffs[i] for i in range(len(coeffs)) if coeffs[i] < 0}
                print(f"    Negative coeffs: {neg}")


if __name__ == "__main__":
    main()
