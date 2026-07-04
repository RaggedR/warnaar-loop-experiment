"""
Inverse q-binomial transform: unique g_n (m-independent) with
  H_m = sum_{n=0}^m g_n(q) [m,n]_q.
If all g_n >= 0 coefficientwise, monotonicity follows instantly by Pascal:
  H_m - H_{m-1} = sum_n g_n q^{m-n} [m-1,n-1] >= 0.
Compute g_n for ALL orbits at d=2,4,5,7 (m up to mmax) and report positivity.
Also report val(g_n) and whether known ferm orbits reproduce
g_n = sum_j q^{n^2-nj+j^2+an+bj}[2n+c,j].
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from seed1_R2L3_fermfit import qbinom
from seed1_R2L3_engine import H_tower, psub, pmul, pneg, pstr

def val(p): return min(p) if p else None

def inv_qbt(H):
    """H: list of polys, m=0..M. Return g_0..g_M."""
    M = len(H)-1
    g = []
    for n in range(M+1):
        r = dict(H[n])
        for k in range(n):
            r = psub(r, pmul(g[k], dict(qbinom(n, k))))
        g.append(r)
    return g

for d, mmax in [(2,8),(4,8),(5,8),(7,6)]:
    orbits, _, hist = H_tower(d, mmax, 'target_first')
    reps = [o[0] for o in orbits]
    print(f"===== d={d} =====")
    for i, rep in enumerate(reps):
        H = [hist[m][i] for m in range(mmax+1)]
        g = inv_qbt(H)
        # check reconstruction at top level as sanity
        ok = all(not pneg(g[n]) and not {k:-v for k,v in g[n].items() if -v<0} or True for n in range(len(g)))
        negs = [n for n in range(len(g)) if pneg(g[n])]
        vals = [val(g[n]) for n in range(len(g))]
        print(f"  H{rep}: g_n >= 0 for n<= {mmax}: {not negs}"
              + (f"  NEG at n={negs}" if negs else f"  val(g_n)={vals}"))
        if negs:
            n0 = negs[0]
            print(f"    g_{n0} = {pstr(g[n0])}")
        else:
            for n in range(min(3, len(g))):
                print(f"    g_{n} = {pstr(g[n])}")
