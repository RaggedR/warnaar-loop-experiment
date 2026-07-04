#!/usr/bin/env python3
"""d=2: the R-relations close into a 2-cycle and solve the system exactly.
R_(1,1,0): G(z) = G_(1,0,1)(zq) + zq G_(1,1,0)(zq^2)   [(0,1,1) ~ (1,1,0)]
R_(1,0,1): G(z) = G_(1,1,0)(zq) + zq G_(1,1,0)(zq^2)   [family A: head (0,1,1)~(1,1,0), tail [(1,1,0)]]
Wait -- family A (1,0,1): head (0,1,1), tail [(1,1,0)]. Both heads/tails are the SAME orbit (1,1,0).
=> g_(1,1,0)(n) = q^n g_(1,0,1)(n) + q^{2n-1} g_(1,1,0)(n-1)
   g_(1,0,1)(n) = q^n g_(1,1,0)(n) + q^{2n-1} g_(1,1,0)(n-1)
=> g_(1,1,0)(n) (1-q^{2n}) = q^{2n-1}(1+q^n) g_(1,1,0)(n-1)
=> g_(1,1,0)(n) = q^{2n-1}/(1-q^n) g_(1,1,0)(n-1)  =>  g(n) = q^{n^2}/(q;q)_n
=> Q_n^(1,1,0) = q^{n^2};  and (2,0,0): g(n) = q^n g_(1,1,0)(n) => Q_n = q^{n^2+n}.
Verify numerically against raw CW."""
from itertools import combinations
PREC = 300; NMAX = 6

def padd(a, b, scale=1, shift=0):
    for i, x in enumerate(b):
        j = i + shift
        if j >= PREC: break
        if x: a[j] += scale*x
    return a
def pmul(a, b):
    res = [0]*PREC
    for i, x in enumerate(a):
        if x == 0: continue
        for j, y in enumerate(b):
            if i+j >= PREC: break
            if y: res[i+j] += x*y
    return res
def poch(n):
    res = [0]*PREC; res[0] = 1
    for i in range(1, n+1):
        f = [0]*PREC; f[0] = 1; f[i] = -1
        res = pmul(res, f)
    return res
def canon(c): return max(tuple(c[i:]+c[:i]) for i in range(3))
def Ic(c): return [i for i in range(3) if c[i] > 0]
def cJ(c, J):
    Js = set(J); out = []
    for i in range(3):
        prev = (i-1) % 3
        if i in Js and prev not in Js: out.append(c[i]-1)
        elif i not in Js and prev in Js: out.append(c[i]+1)
        else: out.append(c[i])
    return tuple(out)
CWCOEF = {1: {(0,0):1}, 2: {(0,0):1,(1,1):-1}, 3: {(0,0):1,(1,1):-1,(1,2):-1,(2,3):1}}
reps = [(2,0,0),(1,1,0)]
g = {r: {0: [0]*PREC} for r in reps}
for r in reps: g[r][0][0] = 1
for n in range(1, NMAX+1):
    cur = {r: [0]*PREC for r in reps}
    for _ in range(PREC//n + 2):
        new = {}
        for r in reps:
            acc = [0]*PREC
            I = Ic(r)
            for sz in range(1, len(I)+1):
                for J in combinations(I, sz):
                    tgt = canon(cJ(r, J)); sgn = (-1)**(sz-1)
                    for (az, bq), s in CWCOEF[sz].items():
                        m = n - az
                        if m < 0: continue
                        src = cur[tgt] if m == n else g[tgt][m]
                        padd(acc, src, scale=sgn*s, shift=bq+sz*m)
            new[r] = acc
        if new == cur: break
        cur = new
    for r in reps: g[r][n] = cur[r]
ok = True
for n in range(NMAX+1):
    # predicted g_(1,1,0)(n) = q^{n^2}/(q)_n
    pred = [0]*PREC
    inv = [0]*PREC; inv[0] = 1   # 1/(q)_n via series inversion
    pn = poch(n)
    for i in range(1, PREC):
        s = sum(-pn[j]*inv[i-j] for j in range(1, min(i, len(pn)-1)+1) if pn[j])
        inv[i] = s
    padd(pred, inv, shift=n*n)
    if pred != g[(1,1,0)][n]: ok = False; print(f"n={n} MISMATCH (1,1,0)")
    pred2 = [0]*PREC; padd(pred2, inv, shift=n*n+n)
    if pred2 != g[(2,0,0)][n]: ok = False; print(f"n={n} MISMATCH (2,0,0)")
    Q = pmul(poch(n), g[(1,1,0)][n])
    Q2 = pmul(poch(n), g[(2,0,0)][n])
    print(f"n={n}: Q^(1,1,0) = q^{n*n} check {[i for i,x in enumerate(Q) if x] == ([n*n] if n>=0 else [])}, "
          f"Q^(2,0,0) = q^{n*n+n} check {[i for i,x in enumerate(Q2) if x] == [n*n+n]}")
print("ALL OK" if ok else "FAILURES")
