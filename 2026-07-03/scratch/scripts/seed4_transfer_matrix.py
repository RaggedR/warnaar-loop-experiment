"""
Seed 4: Transfer matrix computation for cylindric partitions.
Computes F_{c,N}(q) and Q_{n,c}(q) via the transfer matrix method.
Handles profiles with max shift <= 2.
"""
from math import gcd

def multiply_series(a, b, prec):
    result = [0] * prec
    for i in range(min(len(a), prec)):
        if a[i] == 0: continue
        for j in range(min(len(b), prec - i)):
            result[i + j] += a[i] * b[j]
    return result

def inverse_series(s, prec):
    result = [0] * prec; result[0] = 1
    for n in range(1, prec):
        val = 0
        for k in range(1, n + 1):
            if k < len(s): val += s[k] * result[n - k]
        result[n] = -val
    return result

def qpoch_series(a_exp, q_exp, n, prec):
    result = [0] * prec; result[0] = 1
    for i in range(n):
        power = a_exp + i * q_exp
        if power >= prec: continue
        new_result = list(result)
        for j in range(prec):
            if j + power < prec: new_result[j + power] -= result[j]
        result = new_result
    return result

def compute_F(c_profile, N, prec):
    c1, c2, c3 = c_profile
    max_shift = max(c1, c2, c3)
    
    def valid_col(a, b, cc):
        if c2 == 0 and a < b: return False
        if c3 == 0 and b < cc: return False
        if c1 == 0 and cc < a: return False
        return True
    
    cols = [(a, b, cc) for a in range(N+1) for b in range(N+1) 
            for cc in range(N+1) if valid_col(a, b, cc)]
    zero_col = (0, 0, 0)
    
    def pair_valid(prev, curr):
        for i in range(3):
            if curr[i] > prev[i]: return False
        if c2 == 1 and prev[0] < curr[1]: return False
        if c3 == 1 and prev[1] < curr[2]: return False
        if c1 == 1 and prev[2] < curr[0]: return False
        return True
    
    if max_shift <= 1:
        h = {s: [0]*prec for s in cols}
        for s in cols: h[s][0] = 1
        trans = {}
        for s in cols:
            trans[s] = [(sp, sum(sp)) for sp in cols if sp != zero_col and pair_valid(s, sp)]
        for d in range(1, prec):
            for s in cols:
                val = 0
                for (ns, w) in trans[s]:
                    if w <= d: val += h[ns][d - w]
                h[s][d] = val
        F = [0] * prec
        for s in cols:
            w = sum(s)
            for d in range(prec):
                if d + w < prec: F[d + w] += h[s][d]
        return F
    elif max_shift == 2:
        states_pairs = [(p, c) for p in cols for c in cols if pair_valid(p, c)]
        def transition_valid(state, next_col):
            prev, curr = state
            if not pair_valid(curr, next_col): return False
            if c1 == 2 and prev[2] < next_col[0]: return False
            if c2 == 2 and prev[0] < next_col[1]: return False
            if c3 == 2 and prev[1] < next_col[2]: return False
            return True
        h = {sp: [0]*prec for sp in states_pairs}
        for sp in states_pairs: h[sp][0] = 1
        trans = {}
        for sp in states_pairs:
            trans[sp] = []
            for nc in cols:
                if nc == zero_col: continue
                if transition_valid(sp, nc):
                    ns = (sp[1], nc)
                    if ns in h: trans[sp].append((ns, sum(nc)))
        for d in range(1, prec):
            for sp in states_pairs:
                val = 0
                for (ns, w) in trans[sp]:
                    if w <= d: val += h[ns][d - w]
                h[sp][d] = val
        F = [0] * prec; F[0] = 1
        for c1c in cols:
            if c1c == zero_col: continue
            w1 = sum(c1c)
            if w1 < prec: F[w1] += 1
            for c2c in cols:
                if c2c == zero_col: continue
                if not pair_valid(c1c, c2c): continue
                w2 = sum(c2c)
                state = (c1c, c2c)
                if state not in h: continue
                for d in range(prec):
                    total = w1 + w2 + d
                    if total < prec: F[total] += h[state][d]
        return F
    return None

def compute_Q_all(c_profile, n_max, prec):
    d = sum(c_profile); k = 3; l = gcd(d, k)
    F_bounded = {N: compute_F(c_profile, N, prec) for N in range(n_max + 1)}
    a = {0: list(F_bounded[0])}
    for N in range(1, n_max+1):
        a[N] = [F_bounded[N][i] - F_bounded[N-1][i] for i in range(prec)]
    euler = {}
    for m in range(n_max + 1):
        qp = qpoch_series(1, 1, m, prec)
        inv = inverse_series(qp, prec)
        shift = m * (m + 1) // 2; sign = (-1) ** m
        ec = [0] * prec
        for i in range(prec):
            if i + shift < prec: ec[i + shift] = sign * inv[i]
        euler[m] = ec
    results = {}
    for n in range(1, n_max + 1):
        zn = [0] * prec
        for j in range(n + 1):
            conv = multiply_series(euler[j], a[n-j], prec)
            for i in range(prec): zn[i] += conv[i]
        qpoch_ln = qpoch_series(l, l, n, prec)
        results[n] = multiply_series(qpoch_ln, zn, prec)
    return results

if __name__ == "__main__":
    prec = 40
    for c in [(1,1,0), (2,0,0), (2,1,1), (1,2,1), (2,2,0)]:
        d = sum(c)
        if d % 3 == 0: continue
        l = gcd(d, 3)
        print(f"\nc = {c}, d={d}, l={l}")
        Q = compute_Q_all(c, 3, prec)
        for n in range(1, 4):
            nz = [(i, Q[n][i]) for i in range(prec) if Q[n][i] != 0]
            neg = [x for x in nz if x[1] < 0]
            expected = ((d+1)*(d+2)//6 - 1)**n
            status = "NEGATIVE!" if neg else "nonneg"
            print(f"  Q_{n}: {nz[:12]}{'...' if len(nz)>12 else ''} [{status}, sum={sum(Q[n])}, exp={expected}]")
