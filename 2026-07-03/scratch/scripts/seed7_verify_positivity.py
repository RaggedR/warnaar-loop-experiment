"""
Seed 7 — Verify positivity of Q_{n,c}(q) with correct enumeration.
"""
from math import gcd

def get(lam, j):
    return lam[j-1] if 0 < j <= len(lam) else 0

def gen_parts(mx, mp):
    if mp == 0 or mx == 0:
        yield ()
        return
    yield ()
    for f in range(1, mx+1):
        for rest in gen_parts(f, mp-1):
            yield (f,) + rest

def F_bounded(c, n_bound, max_q):
    c0, c1, c2 = c
    mp = min(max_q + 2, 30)
    parts = list(gen_parts(n_bound, mp))
    result = {}
    for l0 in parts:
        s0 = sum(l0)
        if s0 > max_q: continue
        for l1 in parts:
            s1 = sum(l1)
            if s0 + s1 > max_q: continue
            ok = True
            for j in range(1, mp + max(c) + 1):
                if get(l0, j) < get(l1, j + c1):
                    ok = False; break
                if get(l0, j) == 0 and get(l1, j + c1) == 0: break
            if not ok: continue
            for l2 in parts:
                s2 = sum(l2)
                total = s0 + s1 + s2
                if total > max_q: continue
                ok2 = True
                for j in range(1, mp + max(c) + 1):
                    if get(l1, j) < get(l2, j + c2):
                        ok2 = False; break
                    if get(l1, j) == 0 and get(l2, j + c2) == 0: break
                if not ok2: continue
                ok3 = True
                for j in range(1, mp + max(c) + 1):
                    if get(l2, j) < get(l0, j + c0):
                        ok3 = False; break
                    if get(l2, j) == 0 and get(l0, j + c0) == 0: break
                if not ok3: continue
                result[total] = result.get(total, 0) + 1
    return result

def compute_Q_all(c, n_max, max_q):
    d = sum(c); ell = gcd(d, 3)
    F = {}
    for m in range(n_max + 1):
        print(f"  Enumerating F_{{c,{m}}}...", end="", flush=True)
        F[m] = F_bounded(c, m, max_q)
        print(f" done ({sum(F[m].values())} partitions)")

    g = {0: dict(F[0])}
    for m in range(1, n_max + 1):
        gm = dict(F[m])
        for p, v in F[m-1].items():
            gm[p] = gm.get(p, 0) - v
            if gm[p] == 0: del gm[p]
        g[m] = gm

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

    results = {}
    for n in range(n_max + 1):
        coeff = {}
        for j in range(n + 1):
            ej = euler(j)
            gm = g.get(n - j, {})
            for p1, v1 in ej.items():
                for p2, v2 in gm.items():
                    p = p1 + p2
                    if p <= max_q:
                        coeff[p] = coeff.get(p, 0) + v1 * v2

        qpoch = {0: 1}
        for i in range(1, n + 1):
            s = ell * i
            new = dict(qpoch)
            for p, v in qpoch.items():
                if p + s <= max_q:
                    new[p + s] = new.get(p + s, 0) - v
                    if new[p + s] == 0: del new[p + s]
            qpoch = new

        Q = {}
        for p1, v1 in qpoch.items():
            for p2, v2 in coeff.items():
                p = p1 + p2
                if p <= max_q:
                    Q[p] = Q.get(p, 0) + v1 * v2
        results[n] = {k: v for k, v in Q.items() if v != 0}

    return results

def poly_str(p, lim=20):
    if not p: return "0"
    items = sorted(p.items())[:lim]
    parts = []
    for e, c in items:
        if c == 0: continue
        if e == 0: parts.append(str(c))
        elif c == 1: parts.append(f"q^{e}")
        elif c == -1: parts.append(f"-q^{e}")
        else: parts.append(f"{c}q^{e}")
    s = " + ".join(parts).replace("+ -", "- ")
    if len(items) < len(p): s += " + ..."
    return s or "0"

if __name__ == "__main__":
    profiles = [
        ((1,1,0), 3, 25),
        ((2,1,1), 2, 20),
        ((2,2,1), 2, 15),
    ]
    
    for c, n_max, mq in profiles:
        d = sum(c)
        ell = gcd(d, 3)
        expected = (d+1)*(d+2)//6 - 1
        print(f"\n{'='*60}")
        print(f"c={c}, d={d}, ell={ell}, Q(1) should be {expected}^n")
        print(f"{'='*60}")
        
        Qs = compute_Q_all(c, n_max, mq)
        for n in range(n_max + 1):
            Q = Qs[n]
            all_pos = all(v >= 0 for v in Q.values())
            q1 = sum(Q.values())
            neg = [(e,v) for e,v in sorted(Q.items()) if v < 0]
            print(f"\n  Q_{n} = {poly_str(Q)}")
            print(f"    all non-negative: {all_pos}")
            if neg:
                print(f"    NEGATIVE at: {neg}")
            print(f"    Q(1) = {q1} (expected {expected**n}, truncated at q^{mq})")
