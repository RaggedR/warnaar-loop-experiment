"""
Independent verifier, part 2: ground truth + uniqueness witness.

(a) Brute-force bivariate F_c(y,q) from the RAW conjecture.tex interlacing definition
    (my own implementation, structured differently from seed3's): all cylindric
    partitions with |Lambda| <= T; g_c(n) = sum_m eps_{n-m} [y^m]F exact to q^T.
(b) My own q-adic solve of the POSITIVE tex system ALONE, starting from a junk
    (all-ones) point at every level -> uniqueness/convergence witness.
(c) My own q-adic solve of the RAW CW system (orbit level).
Checks: (b) == (c) to q^PREC for n <= NMAX; (b) == (a) to q^T; per-orbit label checks
on reversal-asymmetric pairs (Z2,Z3),(Z4,Z5),(Z6,Z7),(C2,C3).
"""
import sys, time
from verify3L4_system import (TEX, REPS, NAMES, raw_row, rot, orep,
                              Z1,Z2,Z3,Z4,Z5,Z6,Z7,C1,C2,C3,C4,C5)

PREC=200; NMAX=8; T=20

# ---------------- (a) brute force ----------------
def partitions_upto(T):
    out=[()]
    def rec(pref,last,rem):
        for p in range(1,min(last,rem)+1):
            np=pref+(p,); out.append(np); rec(np,p,rem-p)
    rec((),T,T)
    return out

def over(lam,mu,s):
    # lam_t >= mu_{t+s} for all t>=1  <=>  for u>s: lam_{u-s} >= mu_u
    for u in range(s+1,len(mu)+1):
        t=u-s
        lv=lam[t-1] if t<=len(lam) else 0
        if lv<mu[u-1]: return False
    return True

def brute_g(reps, T, nmax):
    parts=partitions_upto(T)
    N=len(parts); print(f"  {N} partitions of size <= {T}")
    size=[sum(p) for p in parts]; first=[p[0] if p else 0 for p in parts]
    shifts=set()
    for c in reps: shifts.update(c)
    down={s:[set() for _ in range(N)] for s in shifts}
    t0=time.time()
    for s in shifts:
        ds=down[s]
        for i in range(N):
            li=parts[i]; szb=T-size[i]
            for j in range(N):
                if size[j]<=szb and over(li,parts[j],s): ds[i].add(j)
    print(f"  pair tables built ({time.time()-t0:.0f}s)", flush=True)
    G={}
    for c in reps:
        c1,c2,c3=c
        Fym=[[0]*(T+1) for _ in range(T+1)]  # [maxpart][size]
        d2,d3,d1=down[c2],down[c3],down[c1]
        up1=[set() for _ in range(N)]
        for k in range(N):
            for i in d1[k]: up1[i].add(k)
        for i in range(N):
            si=size[i]
            for j in d2[i]:
                sj=si+size[j]
                if sj>T: continue
                for k in d3[j]&up1[i]:
                    sk=sj+size[k]
                    if sk<=T:
                        Fym[max(first[i],first[j],first[k])][sk]+=1
        # g(n) = sum_{m<=n} eps_{n-m} * Fym[m],  (yq;q)_inf = sum_j eps_j y^j
        # eps_j = (-1)^j q^{j(j+1)/2} / (q;q)_j
        eps=[]
        for j in range(nmax+1):
            e=[0]*(T+1)
            v=j*(j+1)//2
            if v<=T: e[v]=(-1)**j
            for k in range(1,j+1):
                for idx in range(k,T+1): e[idx]+=e[idx-k]
            eps.append(e)
        g=[]
        for n in range(nmax+1):
            gn=[0]*(T+1)
            for m in range(n+1):
                e=eps[n-m]
                for a in range(T+1):
                    ea=e[a]
                    if ea:
                        for b in range(T+1-a): gn[a+b]+=ea*Fym[m][b]
            g.append(gn)
        G[c]=g
        print(f"  brute c={NAMES[c]} done ({time.time()-t0:.0f}s)", flush=True)
    return G

# ---------------- (b)/(c) q-adic solves ----------------
def solve(rows, nmax, prec, junk_start=False):
    g=[{c:[1]+[0]*(prec-1) for c in REPS}]
    for n in range(1,nmax+1):
        if junk_start: cur={c:[1]*prec for c in REPS}      # different starting point
        else: cur={c:[0]*prec for c in REPS}
        while True:
            changed=False
            for t in REPS:
                acc=[0]*prec
                for (r,s),m in rows[t].items():
                    for (j,a),v in m.items():
                        if n-j<0: continue
                        src=cur[r] if j==0 else g[n-j][r]
                        sh=a+s*(n-j)
                        if sh<prec:
                            for i in range(prec-sh):
                                if src[i]: acc[i+sh]+=v*src[i]
                if acc!=cur[t]: cur[t]=acc; changed=True
            if not changed: break
        g.append(cur)
        print(f"  level n={n} fixed point reached", flush=True)
    return g

if __name__=="__main__":
    print("=== (b) solving POSITIVE tex system alone, junk start (uniqueness witness) ===")
    gpos=solve(TEX,NMAX,PREC,junk_start=True)
    print("=== (c) solving RAW CW system (my own orbit-level implementation) ===")
    RAW={t:raw_row(t) for t in REPS}
    graw=solve(RAW,NMAX,PREC)
    ok=all(gpos[n][c]==graw[n][c] for n in range(NMAX+1) for c in REPS)
    print(f"positive-system solution == raw-system solution (all 12 orbits, n<={NMAX}, q^{PREC}): {'PASS' if ok else 'FAIL'}")
    if not ok:
        for n in range(NMAX+1):
            for c in REPS:
                if gpos[n][c]!=graw[n][c]: print("  mismatch",n,NAMES[c])
    print(f"=== (a) brute force from conjecture.tex definition, T={T} ===")
    gb=brute_g(REPS,T,NMAX)
    ok2=True
    for c in REPS:
        for n in range(NMAX+1):
            if gpos[n][c][:T+1]!=gb[c][n]:
                ok2=False; print(f"  BRUTE MISMATCH {NAMES[c]} n={n}\n   sys  {gpos[n][c][:T+1]}\n   brute{gb[c][n]}")
    print(f"brute (raw definition) == positive-system solution (12 orbits, n<={NMAX}, q^{T}): {'PASS' if ok2 else 'FAIL'}")
    # label sensitivity: asymmetric pairs must DIFFER (check has power to catch reversal)
    print("=== label sensitivity (reversal-asymmetric pairs differ in brute data) ===")
    for a,b in [(Z2,Z3),(Z4,Z5),(Z6,Z7),(C2,C3)]:
        diff=any(gb[a][n]!=gb[b][n] for n in range(NMAX+1))
        print(f"  brute g[{NAMES[a]}] != g[{NAMES[b]}]: {diff}")
    # save gpos for the sage cross-check
    import pickle
    with open("verify3L4_gpos.pkl","wb") as f: pickle.dump({(c,n):gpos[n][c] for c in REPS for n in range(NMAX+1)},f)
    print("saved verify3L4_gpos.pkl")
