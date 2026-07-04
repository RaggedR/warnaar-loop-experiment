"""
Seed 3 v4: Transfer matrix with all-nonzero window states.

Fix: for window >= 2, only include states where ALL columns are nonzero.
This prevents double-counting from phantom transitions through zero-trailing states.

Also must handle the initial state more carefully: for a partition with
fewer than `window` nonzero columns, we need special handling.
"""

from collections import defaultdict
from math import gcd


def compute_F_transfer(c, N, q_max):
    """Compute F_{c,N}(q) using transfer matrix."""
    c0, c1, c2 = c
    window = max(c0, c1, c2)
    
    if window == 0:
        result = [0] * (q_max + 1)
        result[0] = 1
        for j in range(1, N + 1):
            for d in range(3 * j, q_max + 1):
                result[d] += result[d - 3 * j]
        return {i: result[i] for i in range(q_max + 1) if result[i] != 0}
    
    def valid_column(a, b, cv):
        if c0 == 0 and cv < a: return False
        if c1 == 0 and a < b: return False
        if c2 == 0 and b < cv: return False
        return True
    
    all_columns = [(a,b,cv) for a in range(N+1) for b in range(N+1) for cv in range(N+1) if valid_column(a,b,cv)]
    zero_col = (0, 0, 0)
    nonzero_cols = [col for col in all_columns if col != zero_col]
    
    def check_adjacent(prev_col, next_col):
        pa, pb, pcv = prev_col
        na, nb, ncv = next_col
        if na > pa or nb > pb or ncv > pcv: return False
        if c1 == 1 and pa < nb: return False
        if c2 == 1 and pb < ncv: return False
        if c0 == 1 and pcv < na: return False
        return True
    
    def check_distance(old_col, new_col, dist):
        oa, ob, ocv = old_col
        na, nb, ncv = new_col
        if c1 == dist and oa < nb: return False
        if c2 == dist and ob < ncv: return False
        if c0 == dist and ocv < na: return False
        return True
    
    if window == 1:
        # State = single nonzero column
        states = nonzero_cols
        state_idx = {s: i for i, s in enumerate(states)}
        
        transitions = []
        for i, s in enumerate(states):
            for j, sp in enumerate(states):
                if check_adjacent(s, sp):
                    transitions.append((i, j, sum(sp)))
        
        # G = (I - A)^{-1} * 1
        G = [{0: 1} for _ in range(len(states))]
        current = [{0: 1} for _ in range(len(states))]
        
        for _ in range(q_max + 1):
            new_current = [defaultdict(int) for _ in range(len(states))]
            any_nz = False
            for fi, ti, w in transitions:
                for deg, coeff in current[ti].items():
                    nd = deg + w
                    if nd <= q_max and coeff != 0:
                        new_current[fi][nd] += coeff
                        any_nz = True
            if not any_nz: break
            current = [dict(d) for d in new_current]
            for idx in range(len(states)):
                for deg, coeff in current[idx].items():
                    G[idx][deg] = G[idx].get(deg, 0) + coeff
        
        F = {0: 1}
        for idx, s in enumerate(states):
            w = sum(s)
            for deg, coeff in G[idx].items():
                nd = deg + w
                if nd <= q_max:
                    F[nd] = F.get(nd, 0) + coeff
        
        return {k: v for k, v in F.items() if v != 0}
    
    elif window == 2:
        # States: pairs (col1, col2) where both are nonzero and satisfy
        # adjacency constraints.
        full_states = []  # pairs of nonzero columns
        for col1 in nonzero_cols:
            for col2 in nonzero_cols:
                if check_adjacent(col1, col2):
                    full_states.append((col1, col2))
        
        # Single-column states: just one nonzero column followed by zero
        # These handle partitions where only 1 column is nonzero.
        single_states = list(nonzero_cols)
        
        # For full states: G includes extension by new nonzero columns AND termination
        # For single states: these are terminal (next column must be zero by decreasing + adjacency)
        
        # Actually, let me think about this differently.
        # A cylindric partition with columns col_1, col_2, ..., col_L, 0, 0, ...
        # where L >= 1 and all col_i nonzero.
        # Weight = sum of all col_i.
        # 
        # For L = 1: weight = sum(col_1). Contribution from initial single state.
        # For L = 2: weight = sum(col_1) + sum(col_2). Initial full state, no transition.
        # For L >= 3: weight = initial full state + transitions adding columns.
        
        # BUT: for L >= 2, we need the c0=2 constraint between col_{L-1} and 
        # the zero column (col_{L+1} = 0). This is trivially satisfied since
        # it's col_{L-1}[2] >= 0.
        # We also need the c0=2 constraint between col_1 and col_3 (if L >= 3).
        # This is handled by the transition from state (col_1, col_2) to (col_2, col_3).
        
        # For L = 1: col_1 is nonzero, col_2 = 0.
        # Need: check_adjacent(col_1, zero_col) — is this satisfied?
        # Partition decreasing: 0 <= col_1 componentwise. Yes.
        # c1=1: col_1[0] >= 0. Yes.
        # c2=1: col_1[1] >= 0. Yes.
        # So yes, any nonzero column can transition to zero. OK.
        # But we also need c0=2: constraint from col_1 to col_3 = 0. But L=1, col_3=0.
        # col_1[2] >= 0. Trivially true. But wait — the c0=2 constraint is that 
        # lam^2_j >= lam^0_{j+2}. For j such that the partition still has nonzero entries...
        # Actually, the c0=2 constraint at column j says: the value in row 2 at column j 
        # must be >= the value in row 0 at column j+2. For L=1: at column 1, cv_1 >= a_3 = 0.
        # Always true. So L=1 is fine.
        
        # For L = 2: the full initial state covers columns 1 and 2.
        # c0=2 constraint: col_1[2] >= col_3[0] = 0. True.
        # Also: col_2[2] >= col_4[0] = 0. True.
        # The c0=2 constraint between columns within the state (col_1 to col_2+1=col_3):
        # Wait, the constraint is lam^2_j >= lam^0_{j+2}. For column j=1: cv_1 >= a_3 = 0.
        # For column j=2: cv_2 >= a_4 = 0. All fine for terminal states.
        # But what about WITHIN the initial state: lam^2_1 >= lam^0_3 = 0 (since col_3=0).
        # That's col_1[2] >= 0. Always true. So no additional constraint on the initial state.
        
        # HMPH. Actually, the issue is trickier. For L=2, the partition has:
        # lam^0 = (a_1, a_2, 0, 0, ...)
        # lam^1 = (b_1, b_2, 0, 0, ...)
        # lam^2 = (cv_1, cv_2, 0, 0, ...)
        # The c0=2 constraint: lam^2_j >= lam^0_{j+2} for ALL j >= 1.
        # j=1: cv_1 >= a_3 = 0. OK.
        # j=2: cv_2 >= a_4 = 0. OK.
        # BUT ALSO: lam^0_j >= lam^1_{j+1} for all j >= 1 (c1=1).
        # j=1: a_1 >= b_2. This IS checked in the initial state generation.
        # j=2: a_2 >= b_3 = 0. Always true.
        
        # And lam^1_j >= lam^2_{j+1} for all j >= 1 (c2=1).
        # j=1: b_1 >= cv_2. Checked in initial state.
        # j=2: b_2 >= cv_3 = 0. Always true.
        
        # So the initial state generation with check_adjacent is sufficient for L=2.
        # For L >= 3, the transitions handle the constraints.
        
        # IMPLEMENTATION:
        # F_{c,N}(q) = 1 (empty partition)
        #            + sum_{single nonzero col} q^{w(col)} * 1 (L=1 partitions)
        #            + sum_{full state (c1,c2)} q^{w(c1)+w(c2)} * G[(c1,c2)] (L>=2)
        # where G[(c1,c2)] = 1 + sum of paths from (c1,c2) through transitions.
        
        n_full = len(full_states)
        
        # Build transitions between full states
        transitions = []
        for i, s in enumerate(full_states):
            for j, sp in enumerate(full_states):
                if sp[0] != s[1]:  # window overlap: sp[0] must equal s[1]
                    continue
                new_col = sp[1]
                last_col = s[1]
                
                if not check_adjacent(last_col, new_col):
                    continue
                if not check_distance(s[0], new_col, 2):  # c0=2 constraint
                    continue
                
                transitions.append((i, j, sum(new_col)))
        
        # Compute G
        G = [{0: 1} for _ in range(n_full)]
        current = [{0: 1} for _ in range(n_full)]
        
        for _ in range(q_max + 1):
            new_current = [defaultdict(int) for _ in range(n_full)]
            any_nz = False
            for fi, ti, w in transitions:
                for deg, coeff in current[ti].items():
                    nd = deg + w
                    if nd <= q_max and coeff != 0:
                        new_current[fi][nd] += coeff
                        any_nz = True
            if not any_nz: break
            current = [dict(d) for d in new_current]
            for idx in range(n_full):
                for deg, coeff in current[idx].items():
                    G[idx][deg] = G[idx].get(deg, 0) + coeff
        
        # Build F
        F = {0: 1}  # empty partition
        
        # L=1 contributions
        for col in nonzero_cols:
            w = sum(col)
            if w <= q_max:
                F[w] = F.get(w, 0) + 1
        
        # L>=2 contributions
        for idx, (c1_col, c2_col) in enumerate(full_states):
            init_w = sum(c1_col) + sum(c2_col)
            for deg, coeff in G[idx].items():
                nd = init_w + deg
                if nd <= q_max:
                    F[nd] = F.get(nd, 0) + coeff
        
        return {k: v for k, v in F.items() if v != 0}
    
    else:
        raise NotImplementedError(f"Window size {window} > 2 not implemented")


def compute_Q(c, n_target, q_max):
    """Compute Q_{n,c}(q)."""
    d = sum(c)
    ell = gcd(d, 3)
    
    F_cm = {}
    for m in range(n_target + 1):
        F_cm[m] = compute_F_transfer(c, m, q_max)
    
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
        ((1, 1, 0), 4),
        ((1, 0, 1), 3),
        ((2, 1, 1), 3),
        ((1, 2, 1), 3),
        ((2, 2, 1), 3),
        ((1, 0, 0), 3),
    ]
    
    for c, n_max in test_cases:
        d = sum(c)
        ell = gcd(d, 3)
        if d % 3 == 0:
            print(f"\nSkipping c={c}, d={d}")
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
            match = eval_at_1 == expected_base ** n
            status = "OK" if all_pos and match else "ISSUE"
            
            if len(coeffs) <= 30:
                print(f"  n={n}: Q = {coeffs}")
            else:
                print(f"  n={n}: Q has {len(coeffs)} terms, first 20: {coeffs[:20]}")
            print(f"    Q(1) = {eval_at_1} (expected {expected_base**n}), "
                  f"nonneg: {all_pos} [{status}]")


if __name__ == "__main__":
    main()
