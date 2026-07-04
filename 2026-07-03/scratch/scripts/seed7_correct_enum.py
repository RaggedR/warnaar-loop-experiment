"""
Seed 7 — Correct enumeration of cylindric partitions.

For c = (1,1,0), d=2, k=3, t=5:
Interlacing:
  lam^0_j >= lam^1_{j+1}  (c_1 = 1)
  lam^1_j >= lam^2_j       (c_2 = 0)
  lam^2_j >= lam^0_{j+1}   (c_0 = 1)

Chain: lam^0_j >= lam^1_{j+1} >= lam^2_{j+1} >= lam^0_{j+2}
So lam^0_j >= lam^0_{j+2} (but this is just weak decrease by 2 steps).

Also: lam^2_j >= lam^0_{j+1} >= lam^1_{j+2} >= lam^2_{j+2}
So each of lam^0, lam^1, lam^2 satisfies lam^i_j >= lam^i_{j+2}.

For max entry n, the maximum number of nonzero parts is bounded.
With n=1: parts are 0 or 1. Partition with parts in {0,1} has parts (1,1,...,1,0,0,...).
If lam^0 = (1,...,1,0,...) with length L0, similarly for lam^1 (L1) and lam^2 (L2).

Conditions:
- lam^0_j >= lam^1_{j+1}: For j <= L0, lam^0_j = 1. Need lam^1_{j+1} <= 1, which is auto.
  For j > L0, lam^0_j = 0. Need lam^1_{j+1} = 0, so j+1 > L1, i.e., j >= L1.
  So L0 >= L1.
  Wait: if j = L0, then lam^0_j = 1 (since j <= L0), need lam^1_{j+1} <= 1 (auto).
  If j = L0+1, then lam^0_j = 0, need lam^1_{j+2} = 0... no wait.
  lam^0_j >= lam^1_{j+1}: for j > L0, lam^0_j = 0, need lam^1_{j+1} <= 0, so j+1 > L1.
  So for all j > L0, need j+1 > L1, i.e., j >= L1.
  Since j > L0, this means L0+1 >= L1, i.e., L1 <= L0 + 1.
  But also need: for j = L0 (if L0 >= 1): lam^0_{L0} = 1 (if the partition has L0 ones).
  Actually wait, L0 is the number of parts equal to 1. So lam^0_j = 1 for j <= L0, 0 for j > L0.
  
  So: lam^0_j >= lam^1_{j+1} means:
  - j <= L0: 1 >= lam^1_{j+1}, automatic
  - j > L0: 0 >= lam^1_{j+1}, so j+1 > L1, i.e., L1 <= j. Min j with j > L0 is j = L0+1.
    So L1 <= L0 + 1... wait, need L1 <= j for all j > L0.
    Actually need j+1 > L1 for all j > L0. The strongest constraint is j = L0+1:
    need L0+1+1 > L1, i.e., L1 <= L0+1.
    Hmm, but also j = L0: if L0 >= 1, lam^0_{L0} = 1, need lam^1_{L0+1} <= 1, auto.
    And j = L0+1: lam^0_{L0+1} = 0, need lam^1_{L0+2} = 0, so L1 < L0+2, L1 <= L0+1.

Similarly:
  lam^1_j >= lam^2_j: for j <= L1, 1 >= lam^2_j auto.
  For j > L1: 0 >= lam^2_j, so j > L2, L2 < j. Min j: L1+1. So L2 <= L1.

  lam^2_j >= lam^0_{j+1}: for j <= L2, 1 >= lam^0_{j+1} auto.
  For j > L2: 0 >= lam^0_{j+1}, so j+1 > L0, L0 <= j. Min j: L2+1. So L0 <= L2 + 1.
  Wait, need L0 <= j for all j > L2, so L0 <= L2 + 1.

So: L1 <= L0 + 1, L2 <= L1, L0 <= L2 + 1.
Combining: L0 <= L2 + 1 <= L1 + 1 <= L0 + 2.

So L0, L1, L2 satisfy: L2 <= L1 <= L0 + 1 and L0 <= L2 + 1.

For n = 1: weight = L0 + L1 + L2.

Let's enumerate: L0 >= 0.
- L0 = 0: L2 <= L1 <= 1, L0 = 0 <= L2 + 1 (auto).
  (L1, L2) in {(0,0), (1,0), (1,1)}: weights 0, 1, 2.
- L0 = 1: L2 <= L1 <= 2, 1 <= L2 + 1 so L2 >= 0.
  (L1, L2) in {(0,0): 1<=1 yes, (1,0): 1<=1 yes, (1,1): 1<=2 yes, (2,1): 1<=2 yes, (2,2): 1<=3 yes}
  Wait, L1 can be 0,1,2. L2 <= L1 and L2 >= 0.
  L1=0: L2=0: L0=1 <= 0+1=1 yes. weight=1.
  L1=1: L2=0: L0=1<=1 yes. weight=2. L2=1: 1<=2 yes. weight=3.
  L1=2: L2=0: 1<=1 yes. weight=3. L2=1: 1<=2 yes. weight=4. L2=2: 1<=3 yes. weight=5.
- L0 = 2: L1 <= 3, L2 <= L1, L0=2 <= L2+1 so L2 >= 1.
  L1=1: L2=1: 2<=2 yes. weight=4.
  L1=2: L2=1: 2<=2 yes. weight=5. L2=2: 2<=3 yes. weight=6.
  L1=3: L2=1: 2<=2 yes. weight=6. L2=2: 2<=3 yes. weight=7. L2=3: 2<=4 yes. weight=8.
  
And so on...

For F_{c,1}(q), we sum over all valid (L0,L1,L2) combinations:
L0=0: {0:1, 1:1, 2:1}
L0=1: {1:1, 2:1, 3:2, 4:1, 5:1}
L0=2: {4:1, 5:1, 6:2, 7:1, 8:1}
L0=3: would need L2 >= 2...
...

This shows F_{c,1}(q) for n=1 is an infinite series (since L0 can be arbitrarily large).
This is correct: F_{c,1} counts cylindric partitions with max <= 1, and there are 
infinitely many of them (unbounded number of parts).

So F_{c,1}(q) diverges at q=1. The earlier computation with max_parts=5 was wrong
because it truncated, giving a FINITE answer.

THIS IS THE KEY ISSUE with all the earlier scripts: they truncated the number of parts,
but cylindric partitions can have arbitrarily many parts.

For Q_{n,c}(q), we need F_{c,m}(q) only as a POWER SERIES truncated at some q-degree.
The direct enumeration must run long enough to capture all partitions up to a given weight.
"""

from math import gcd

def F_bounded_parts01(c, n_bound, max_q):
    """
    Compute F_{c,n}(q) for the special case where all parts are 0 or 1 (n_bound = 1),
    using the closed-form approach.
    
    For max entry = 1, each partition is just (1,1,...,1,0,...) with some length L.
    The interlacing conditions become constraints on (L0, L1, L2).
    """
    if n_bound == 0:
        return {0: 1}
    
    if n_bound != 1:
        raise NotImplementedError("Only n_bound=1 supported here")
    
    c0, c1, c2 = c
    
    # For general c = (c0, c1, c2), with each partition being (1^{L_i}, 0^...):
    # Conditions: lam^i_j >= lam^{(i+1)%3}_{j + c_{(i+1)%3}}
    # With binary parts: L_i >= L_{(i+1)%3} - c_{(i+1)%3} + 1? No...
    # lam^i_j = 1 if j <= L_i, 0 if j > L_i.
    # Need: for j > L_i, lam^{i+1}_{j + c_{i+1}} = 0, so j + c_{i+1} > L_{i+1}, i.e., j > L_{i+1} - c_{i+1}.
    # Strongest: j = L_i + 1 (smallest j > L_i): need L_i + 1 > L_{i+1} - c_{i+1}, i.e., L_{i+1} <= L_i + c_{i+1}.
    # So: L_1 <= L_0 + c_1, L_2 <= L_1 + c_2, L_0 <= L_2 + c_0.
    
    # Summing: L_0 <= L_2 + c_0 <= L_1 + c_2 + c_0 <= L_0 + c_1 + c_2 + c_0 = L_0 + d.
    # So the constraints are consistent.
    
    # Weight = L_0 + L_1 + L_2.
    # Sum over all valid non-negative (L_0, L_1, L_2).
    
    result = {}
    for L0 in range(max_q + 1):
        # L_1 <= L_0 + c_1 and L_0 <= L_2 + c_0 so L_2 >= L_0 - c_0
        # L_2 <= L_1 + c_2
        for L1 in range(max(0, L0 - c0 - c2), min(max_q - L0, L0 + c1) + 1):
            L2_min = max(0, L0 - c0)
            L2_max = min(max_q - L0 - L1, L1 + c2)
            for L2 in range(L2_min, L2_max + 1):
                # Verify all conditions
                if L1 <= L0 + c1 and L2 <= L1 + c2 and L0 <= L2 + c0:
                    w = L0 + L1 + L2
                    if w <= max_q:
                        result[w] = result.get(w, 0) + 1
    
    return result


def F_bounded_general(c, n_bound, max_q, max_parts=50):
    """
    Compute F_{c,n}(q) by iterating over column states.
    
    State = (a, b, c_val) = values at a column, 0 <= a,b,c_val <= n_bound.
    Within-column: must satisfy interlacing conditions with PREVIOUS column.
    
    Use DP: dp[state] = polynomial giving sum over all valid continuations
    (all subsequent columns) starting from this state.
    
    dp[(0,0,0)] = 1
    dp[s] = q^{wt(s)} * sum_{s': s -> s' valid} dp[s']
    
    Process in order of decreasing total weight to avoid self-loops.
    Actually, self-loops ARE possible (same state repeated), so we need
    to handle them via geometric series.
    """
    c0, c1, c2 = c
    n = n_bound
    
    # Enumerate states
    states = []
    for a in range(n + 1):
        for b in range(n + 1):
            for cv in range(n + 1):
                states.append((a, b, cv))
    
    # Build transition map: s -> s' valid if:
    # From column j (state s=(a,b,cv)) to column j+1 (state s'=(a',b',cv')):
    # lam^0_j >= lam^1_{j+c_1}: but this relates different column offsets.
    # 
    # Actually, the interlacing conditions are NOT column-to-column in general.
    # lam^i_j >= lam^{(i+1)%3}_{j + c_{(i+1)%3}} relates the j-th part of lam^i
    # to the (j + c_{...})-th part of lam^{(i+1)%3}.
    #
    # For the transfer matrix to work, we need to track a WINDOW of columns.
    # The window size is max(c_i) + 1.
    #
    # For c = (1,1,0): max(c_i) = 1, so window size 2.
    # State = (column_j, column_{j+1}) ... gets complicated.
    
    # For simplicity, let me just do exact enumeration with sufficient parts.
    
    def get(lam, j):  # 1-indexed
        return lam[j-1] if 0 < j <= len(lam) else 0
    
    def gen_parts(mx, mp):
        if mp == 0 or mx == 0:
            yield ()
            return
        yield ()
        for f in range(1, mx+1):
            for rest in gen_parts(f, mp-1):
                yield (f,) + rest
    
    # Need enough parts. For weight W, max part n, number of parts <= W/1 = W.
    # But also constrained by interlacing.
    mp = min(max_q + 1, max_parts)
    parts = list(gen_parts(n, mp))
    
    print(f"  {len(parts)} partitions with max<={n}, max_parts<={mp}")
    
    result = {}
    count = 0
    
    for l0 in parts:
        s0 = sum(l0)
        if s0 > max_q: continue
        for l1 in parts:
            s1 = sum(l1)
            if s0 + s1 > max_q: continue
            # Check lam^0_j >= lam^1_{j+c1}
            ok = True
            for j in range(1, mp + c1 + 1):
                if get(l0, j) < get(l1, j + c1):
                    ok = False
                    break
                if get(l0, j) == 0 and get(l1, j + c1) == 0:
                    break
            if not ok: continue
            
            for l2 in parts:
                s2 = sum(l2)
                total = s0 + s1 + s2
                if total > max_q: continue
                
                # Check lam^1_j >= lam^2_{j+c2}
                ok2 = True
                for j in range(1, mp + c2 + 1):
                    if get(l1, j) < get(l2, j + c2):
                        ok2 = False
                        break
                    if get(l1, j) == 0 and get(l2, j + c2) == 0:
                        break
                if not ok2: continue
                
                # Check lam^2_j >= lam^0_{j+c0}
                ok3 = True
                for j in range(1, mp + c0 + 1):
                    if get(l2, j) < get(l0, j + c0):
                        ok3 = False
                        break
                    if get(l2, j) == 0 and get(l0, j + c0) == 0:
                        break
                if not ok3: continue
                
                result[total] = result.get(total, 0) + 1
                count += 1
    
    print(f"  Found {count} cylindric partitions")
    return result


def compute_Q_from_F(F_data, n_val, max_q):
    """
    Given F_{c,m}(q) for m = 0, ..., n_val, compute Q_{n,c}(q).
    
    F_data: dict m -> polynomial (dict power -> coeff)
    """
    # g_m = F_{c,m} - F_{c,m-1}
    g = {}
    g[0] = dict(F_data[0])
    for m in range(1, n_val + 1):
        gm = dict(F_data[m])
        for p, v in F_data[m-1].items():
            gm[p] = gm.get(p, 0) - v
            if gm[p] == 0: del gm[p]
        g[m] = gm
    
    # Euler coefficients: [z^j](zq;q)_inf = (-1)^j q^{j(j+1)/2} / (q;q)_j
    def euler(j):
        s = j*(j+1)//2
        if s > max_q: return {}
        sign = (-1)**j
        inv = {0: 1}
        for i in range(1, j+1):
            new = dict(inv)
            for p in sorted(inv.keys()):
                pp = p + i
                while pp <= max_q - s:
                    new[pp] = new.get(pp, 0) + new.get(pp - i, 0)
                    pp += i
            inv = new
        return {p + s: sign * v for p, v in inv.items() if p + s <= max_q}
    
    # [z^n] = sum_{j=0}^n euler(j) * g_{n-j}
    coeff = {}
    for j in range(n_val + 1):
        ej = euler(j)
        gm = g.get(n_val - j, {})
        for p1, v1 in ej.items():
            for p2, v2 in gm.items():
                p = p1 + p2
                if p <= max_q:
                    coeff[p] = coeff.get(p, 0) + v1 * v2
    
    # Q = (q;q)_n * coeff  (since ell = 1 when d not div by 3)
    qpoch = {0: 1}
    for i in range(1, n_val + 1):
        new = dict(qpoch)
        for p, v in qpoch.items():
            if p + i <= max_q:
                new[p + i] = new.get(p + i, 0) - v
                if new[p + i] == 0: del new[p + i]
        qpoch = new
    
    Q = {}
    for p1, v1 in qpoch.items():
        for p2, v2 in coeff.items():
            p = p1 + p2
            if p <= max_q:
                Q[p] = Q.get(p, 0) + v1 * v2
    
    return {k: v for k, v in Q.items() if v != 0}


if __name__ == "__main__":
    max_q = 15  # small for speed
    
    # Test n=1 binary case for c=(1,1,0)
    print("Binary partitions (n=1) for c=(1,1,0), d=2:")
    F1 = F_bounded_parts01((1,1,0), 1, max_q)
    print(f"  F_{{c,1}} = {dict(sorted(F1.items()))}")
    
    print()
    print("Now using enumeration:")
    print("c = (1,1,0), d=2, max_q=15")
    
    F_data = {}
    F_data[0] = {0: 1}
    
    for m in range(1, 4):
        print(f"\nComputing F_{{c,{m}}}...")
        F_data[m] = F_bounded_general((1,1,0), m, max_q, max_parts=max_q + 2)
        print(f"  F = {dict(sorted(F_data[m].items())[:15])}")
    
    print("\n" + "="*60)
    print("Q polynomials for c=(1,1,0):")
    for n in range(min(4, len(F_data))):
        Q = compute_Q_from_F(F_data, n, max_q)
        terms = sorted(Q.items())
        all_pos = all(v >= 0 for e, v in terms)
        q1 = sum(v for e, v in terms)
        print(f"  Q_{n} = {dict(terms)}")
        print(f"    all_pos={all_pos}, Q(1)={q1}")
