"""
Seed 1 R2 L3: does the surplus operator act on Warnaar-type fermionic forms
by shifting linear parameters?  (A2 analogue of the d=2 ladder L1.)

ferm(m,a,b,c) := sum_{n,j>=0} q^{n^2 - n j + j^2 + a n + b j} [m, n]_q [2n+c, j]_q
Known (Layer 2, seed 4, d=4): H(1,1,2)=ferm(m,0,0,0), H(0,0,4)=ferm(m,1,1,0),
H(0,3,1)=ferm(m,0,1,0).

Compute the surplus tree at d=4 (S = Delta/q^{m+s}) to depth D and match every
member against ferm(m,a,b,c), a,b in [-1,8], c in [-2,6].
"""
import sys, os
from functools import lru_cache
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from seed1_R2L3_engine import padd, psub, pmul, pstr, pneg, H_tower

def val(p): return min(p) if p else None
def pshift(p, k):
    assert all(e >= k for e in p)
    return {e-k: v for e, v in p.items()}

@lru_cache(maxsize=None)
def qbinom(n, k):
    if k < 0 or n < 0 or k > n: return ()
    if k == 0 or k == n: return ((0, 1),)
    a = dict(qbinom(n-1, k-1)); b = dict(qbinom(n-1, k))
    # [n,k] = [n-1,k-1] + q^k [n-1,k]
    r = dict(a)
    for e, c in b.items():
        r[e+k] = r.get(e+k, 0) + c
    return tuple(sorted(r.items()))

def ferm(m, a, b, c):
    out = {}
    for n in range(0, m+1):
        bn = dict(qbinom(m, n))
        if not bn: continue
        top = 2*n + c
        for j in range(0, max(top,0)+1):
            bj = dict(qbinom(top, j))
            if not bj: continue
            e0 = n*n - n*j + j*j + a*n + b*j
            for e1, c1 in bn.items():
                for e2, c2 in bj.items():
                    e = e0+e1+e2
                    out[e] = out.get(e, 0) + c1*c2
    return {k: v for k, v in out.items() if v}

def match_ferm(seq, mrange):
    """seq[m] for m in mrange; return list of (a,b,c) matching all levels."""
    hits = []
    for a in range(-1, 9):
        for b in range(-1, 9):
            for c in range(-2, 7):
                if all(ferm(m, a, b, c) == seq[m] for m in mrange):
                    hits.append((a, b, c))
    return hits

def tree(d, mmax=8, depth=5):
    orbits, U, hist = H_tower(d, mmax, 'target_first')
    reps = [o[0] for o in orbits]
    members = [(f"H{reps[i]}", [hist[m][i] for m in range(mmax+1)], 0) for i in range(len(orbits))]
    out = []
    queue = list(range(len(members)))
    while queue:
        idx = queue.pop(0)
        name, seq, dep = members[idx]
        L = len(seq)-1
        mr = list(range(0, min(L, 5)+1))
        hits = match_ferm(seq, mr)
        print(f"[{name}] (levels 0..{L}) ferm matches (m<= {mr[-1]}): {hits}")
        if dep >= depth or L < 3: continue
        D = [None] + [psub(seq[m], seq[m-1]) for m in range(1, L+1)]
        if any(pneg(D[m]) for m in range(1, L+1)):
            print(f"  [{name}] FAMILY BREAK"); continue
        sh = sorted(set(val(D[m]) - m for m in range(1, L+1) if D[m]))
        if len(sh) != 1:
            print(f"  [{name}] nonconstant shift {sh}"); continue
        s = sh[0]
        gseq = [pshift(D[i+1], i+1+s) if D[i+1] else {} for i in range(L)]
        nm = f"d({name})s{s}"
        members.append((nm, gseq, dep+1))
        queue.append(len(members)-1)
    return members

if __name__ == "__main__":
    tree(4, mmax=8, depth=4)
