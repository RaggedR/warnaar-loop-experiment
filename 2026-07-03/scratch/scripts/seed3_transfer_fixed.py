"""
Seed 3: Fixed general transfer matrix for cylindric partitions.

Bug fix: the transition builder now enforces partition-decreasing constraints
and short-range interlacing between the last column of the old state and
the new column of the target state.
"""

from collections import defaultdict
from math import gcd


def compute_F_transfer(c, N, q_max):
    """
    Compute F_{c,N}(q) using transfer matrix with window of size max(c_i).
    Handles arbitrary profiles c = (c0, c1, c2).
    """
    c0, c1, c2 = c
    window = max(c0, c1, c2)
    
    if window == 0:
        # All c_i = 0 => all three partitions must be equal
        result = [0] * (q_max + 1)
        result[0] = 1
        for j in range(1, N + 1):
            for d in range(3 * j, q_max + 1):
                result[d] += result[d - 3 * j]
        return {i: result[i] for i in range(q_max + 1) if result[i] != 0}
    
    # Within-column constraints from c_i = 0
    def valid_column(a, b, cv):
        if c0 == 0 and cv < a:
            return False
        if c1 == 0 and a < b:
            return False
        if c2 == 0 and b < cv:
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
    
    def check_adjacent(prev_col, next_col):
        """Check all constraints between adjacent columns (distance 1).
        This includes partition-decreasing AND c_i=1 interlacing."""
        pa, pb, pcv = prev_col
        na, nb, ncv = next_col
        # Partition decreasing
        if na > pa or nb > pb or ncv > pcv:
            return False
        # Interlacing with shift 1
        if c1 == 1 and pa < nb:
            return False
        if c2 == 1 and pb < ncv:
            return False
        if c0 == 1 and pcv < na:
            return False
        return True
    
    def check_distance(old_col, new_col, dist):
        """Check interlacing constraints at given distance."""
        oa, ob, ocv = old_col
        na, nb, ncv = new_col
        if c1 == dist and oa < nb:
            return False
        if c2 == dist and ob < ncv:
            return False
        if c0 == dist and ocv < na:
            return False
        return True
    
    # Generate all valid states: windows of `window` columns
    def gen_states():
        """Generate all valid nonzero states of width `window`."""
        if window == 1:
            for col in all_columns:
                if col != zero_col:
                    yield (col,)
            return
        
        if window == 2:
            for col1 in all_columns:
                for col2 in all_columns:
                    if col1 == zero_col and col2 == zero_col:
                        continue
                    # col2 must be valid given col1 (adjacent: col1 is at j-1, col2 at j)
                    if not check_adjacent(col1, col2):
                        continue
                    # Also check c_i=2 constraint from col1 to... well, there's no col after col2 yet
                    # The c_i=2 constraint will be checked when we add the next column
                    yield (col1, col2)
            return
        
        raise NotImplementedError(f"Window size {window} > 2 not implemented")
    
    nonzero_states = list(gen_states())
    n_states = len(nonzero_states)
    state_idx = {s: i for i, s in enumerate(nonzero_states)}
    
    if n_states == 0:
        return {0: 1}
    
    # Build transitions
    transitions = []  # (from_idx, to_idx, q_weight_of_new_col)
    
    for i, s in enumerate(nonzero_states):
        for j, sp in enumerate(nonzero_states):
            # Check window overlap: sp[:-1] must equal s[1:]
            if sp[:-1] != s[1:]:
                continue
            
            new_col = sp[-1]
            last_col = s[-1]
            
            # Check adjacent constraints (distance 1): last_col -> new_col
            if not check_adjacent(last_col, new_col):
                continue
            
            # Check long-range constraints (distance = window) from s[0] to new_col
            if window >= 2:
                if not check_distance(s[0], new_col, window):
                    continue
            
            transitions.append((i, j, sum(new_col)))
    
    # Compute G = (I - A)^{-1} * 1 iteratively
    G = [{0: 1} for _ in range(n_states)]
    current = [{0: 1} for _ in range(n_states)]
    
    for iteration in range(q_max + 1):
        new_current = [defaultdict(int) for _ in range(n_states)]
        any_nonzero = False
        for fi, ti, w in transitions:
            for deg, coeff in current[ti].items():
                nd = deg + w
                if nd <= q_max and coeff != 0:
                    new_current[fi][nd] += coeff
                    any_nonzero = True
        
        if not any_nonzero:
            break
        
        current = [dict(d) for d in new_current]
        for idx in range(n_states):
            for deg, coeff in current[idx].items():
                G[idx][deg] = G[idx].get(deg, 0) + coeff
    
    # F_{c,N}(q) = 1 + sum over starting states s, q^{w(s)} * G[s]
    F = {0: 1}
    for idx, s in enumerate(nonzero_states):
        init_weight = sum(sum(col) for col in s)
        for deg, coeff in G[idx].items():
            nd = deg + init_weight
            if nd <= q_max:
                F[nd] = F.get(nd, 0) + coeff
    
    return {k: v for k, v in F.items() if v != 0}


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
    q_max = 120
    
    test_cases = [
        ((1, 1, 0), 4),   # d=2
        ((1, 0, 1), 3),   # d=2
        ((2, 1, 1), 3),   # d=4
        ((1, 2, 1), 3),   # d=4
        ((2, 2, 1), 2),   # d=5
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
            match = eval_at_1 == expected_base ** n
            status = "OK" if all_pos and match else "ISSUE"
            
            if len(coeffs) <= 30:
                print(f"  n={n}: Q = {coeffs}")
            else:
                print(f"  n={n}: Q has {len(coeffs)} terms")
                print(f"    first 20: {coeffs[:20]}")
            print(f"    Q(1) = {eval_at_1} (expected {expected_base**n}), "
                  f"nonneg: {all_pos} [{status}]")
            
            if not all_pos:
                neg = [(i, coeffs[i]) for i in range(len(coeffs)) if coeffs[i] < 0]
                print(f"    Negative: {neg[:10]}")


if __name__ == "__main__":
    main()
