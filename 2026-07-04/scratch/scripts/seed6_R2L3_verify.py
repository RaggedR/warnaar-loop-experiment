#!/usr/bin/env python3
"""Seed 6, Round 2, Layer 3 - complete d=4 verification.

Exact Z[q] arithmetic (polynomials = int coefficient lists).
Checks:
 (V0) H-recursion exact for d=4, m<=MMAX (all 15 profiles).
 (V1) brute-force F_{c,m} spot check m<=3.
 (V2) Q_n via Q-transform; Q_n(1)=4^n; Q_n >= 0.
 (V3) CW<->ours profile mapping: match 5 derived Q_n formulas against 15 profiles.
 (V4) Inversion Lemma: H_{c,m} = sum_{n<=m} [m,n] Q_n, all profiles, m<=MMAX.
 (V5) Monotonicity identity: H_m - H_{m-1} = sum_n q^{m-n}[m-1,n-1] Q_n.
 (V6) Absorption A: X_n - q^n X'_n >= 0, and Pascal-1^2 decomposition exact.
 (V7) Absorption B: X_n - q^n Y'_n >= 0 (n<=NMAX); plus identity (*) check.
"""
import sys
sys.setrecursionlimit(100000)

def ptrim(p):
    while p and p[-1]==0: p.pop()
    return p
def padd(a,b,sa=1,sb=1):
    n=max(len(a),len(b)); r=[0]*n
    for i,x in enumerate(a): r[i]+=sa*x
    for i,x in enumerate(b): r[i]+=sb*x
    return ptrim(r)
def pshift(a,k): return ([0]*k+list(a)) if a else []
def pmul(a,b):
    if not a or not b: return []
    r=[0]*(len(a)+len(b)-1)
    for i,x in enumerate(a):
        if x:
            for j,y in enumerate(b): r[i+j]+=x*y
    return ptrim(r)
def pdiv_exact(num,den):
    num=list(num); r=[]
    if not ptrim(list(num)): return []
    dd=len(den)-1; dl=den[-1]
    for i in range(len(num)-1-dd,-1,-1):
        c=num[i+dd]
        if c%dl!=0: raise ValueError("non-exact division")
        c//=dl
        if c:
            for j,y in enumerate(den): num[i+j]-=c*y
        r.append(c)
    if any(num): raise ValueError("nonzero remainder")
    r.reverse(); return ptrim(r)
def nonneg(p): return all(x>=0 for x in p)
def pev1(p): return sum(p)

# q-binomials via Pascal, memoized
QB={}
def qbin(n,k):
    if k<0 or k>n or n<0: return []
    if k==0 or k==n: return [1]
    key=(n,k)
    if key in QB: return QB[key]
    r=padd(qbin(n-1,k-1), pshift(qbin(n-1,k),k))   # [n,k]=[n-1,k-1]+q^k[n-1,k]
    QB[key]=r; return r

def qpoch(m):
    p=[1]
    for i in range(1,m+1): p=pmul(p,[1]+[0]*(i-1)+[-1])
    return p

def profiles(d): return [(a,b,d-a-b) for a in range(d+1) for b in range(d-a+1)]
def EMD(c,cp): return 3*max(0,cp[1]-c[1],c[0]-cp[0])+(cp[0]-c[0])-(cp[1]-c[1])

def H_tower(d,mmax):
    ps=profiles(d)
    H=[{c:[1] for c in ps}]
    for m in range(1,mmax+1):
        den=[0]*(2*m+1); den[0]=1; den[m]+=1; den[2*m]+=1
        Hm={}
        for c in ps:
            num=[]
            for cp in ps: num=padd(num,pshift(H[m-1][cp],m*EMD(cp,c)))
            Hm[c]=pdiv_exact(num,den)
        H.append(Hm)
    return ps,H

def brute_F(c,m,N):
    def chains_ok(x):
        for i in range(3):
            if x[(i+1)%3]>x[i]+c[(i+1)%3]: return False
        return True
    coef=[0]*(N+1)
    def rec(t,prev,wt):
        if wt>N: return
        if t==m: coef[wt]+=1; return
        ub=prev if prev else (N,N,N)
        for a in range(min(ub[0],N-wt)+1):
            for b in range(min(ub[1],N-wt-a)+1):
                for cc in range(min(ub[2],N-wt-a-b)+1):
                    x=(a,b,cc)
                    if chains_ok(x): rec(t+1,x,wt+a+b+cc)
    rec(0,None,0)
    return coef

MMAX=8; NMAX=12
d=4
ps,H=H_tower(d,MMAX)
print(f"(V0) OK: H-recursion exact division, d=4, all {len(ps)} profiles, m<={MMAX}")

# V1 brute force
ok=True; N=16
# NOTE: chain-model convention is the REVERSAL of the H-recursion (EMD) convention:
# brute_F(c) == F_{rev(c)} with rev(c)=(c2,c1,c0). (F is constant on C3-orbits, so
# reversal-symmetric orbits masked this in seed4's sampled check.)
for c in [(0,0,4),(0,1,3),(0,2,2),(0,3,1),(1,1,2),(2,1,1),(3,1,0)]:
    rc=(c[2],c[1],c[0])
    for m in (1,2,3):
        F=brute_F(c,m,N)
        cut=N-6
        Hb=pmul(qpoch(m),F); Hb=(Hb+[0]*cut)[:cut]
        tg=(H[m][rc]+[0]*cut)[:cut]
        if Hb!=tg: print(f"(V1) MISMATCH c={c} m={m}"); ok=False
print(f"(V1) {'OK: brute-force F_c matches H-recursion at rev(c) (7 profiles, m<=3, mod q^10)' if ok else 'FAIL'}")

# V2: Q_n via Q-transform
def Qn(c,n):
    r=[]
    for m in range(n+1):
        k=n-m
        term=pmul(qbin(n,m),pshift(H[m][c],k*(k-1)//2))
        r=padd(r,term,1,(-1)**k)
    return r
Q={c:[Qn(c,n) for n in range(MMAX+1)] for c in ps}
ok=True
for c in ps:
    for n in range(MMAX+1):
        if pev1(Q[c][n])!=4**n: print(f"(V2) Q_n(1)!=4^n at c={c} n={n}"); ok=False
        if not nonneg(Q[c][n]): print(f"(V2) Q_n has NEGATIVE coeff at c={c} n={n}"); ok=False
print(f"(V2) {'OK: Q_n>=0 and Q_n(1)=4^n for all 15 profiles, n<='+str(MMAX) if ok else 'FAIL'}")

# V3: derived Q formulas per CW label
def Qgood(n,lin):  # lin(n,n2) -> linear exponent add-on
    r=[]
    for n2 in range(2*n+1):
        r=padd(r,pshift(qbin(2*n,n2),n*n+n2*n2-n*n2+lin(n,n2)))
    return r
def Xn(n):  return Qgood(n,lambda n,n2:n)
def Xpn(n):
    if n==0: return []
    r=[]
    for n2 in range(2*n-1):
        r=padd(r,pshift(qbin(2*n-2,n2),n*n+n2*n2-n*n2+2*n2))
    return r
def Ypn(n):
    if n==0: return []
    r=[]
    for n2 in range(2*n-1):
        e=n*n+n2*n2-n*n2+n2
        t=padd(pshift(qbin(2*n-2,n2),e),pshift(qbin(2*n-2,n2),e+n+n2))
        r=padd(r,t)
    return r
def Qwall(n,prime):
    X=Xn(n); P=prime(n)
    return padd(padd(X,P),pshift(P,n),1,-1)

formulas={
 'CW(2,1,1)': lambda n: Qgood(n,lambda n,n2:0),
 'CW(4,0,0)': lambda n: Qgood(n,lambda n,n2:n+n2),
 'CW(3,1,0)': lambda n: Qgood(n,lambda n,n2:n2),
 'CW(3,0,1)': lambda n: Qwall(n,Xpn),
 'CW(2,2,0)': lambda n: Qwall(n,Ypn),
}
NCHK=min(MMAX,7)
print("(V3) CW label -> matching profiles (Q_n equal for n<=%d):"%NCHK)
mapping={}
for name,f in formulas.items():
    vals=[f(n) for n in range(NCHK+1)]
    hits=[c for c in ps if all(Q[c][n]==vals[n] for n in range(NCHK+1))]
    mapping[name]=hits
    print(f"   {name}: {hits}")

# V4: Inversion lemma
ok=True
for c in ps:
    for m in range(MMAX+1):
        s=[]
        for n in range(m+1): s=padd(s,pmul(qbin(m,n),Q[c][n]))
        if s!=H[m][c]: print(f"(V4) FAIL c={c} m={m}"); ok=False
print(f"(V4) {'OK: H_m = sum [m,n] Q_n, all profiles, m<='+str(MMAX) if ok else 'FAIL'}")

# V5: monotonicity identity
ok=True
for c in ps:
    for m in range(1,MMAX+1):
        s=[]
        for n in range(1,m+1):
            s=padd(s,pshift(pmul(qbin(m-1,n-1),Q[c][n]),m-n))
        if s!=padd(H[m][c],H[m-1][c],1,-1): print(f"(V5) FAIL c={c} m={m}"); ok=False
print(f"(V5) {'OK: H_m - H_(m-1) = sum q^(m-n)[m-1,n-1]Q_n' if ok else 'FAIL'}")

# V6: Absorption A + Pascal decomposition
okA=True; okAdec=True
for n in range(1,NMAX+1):
    diff=padd(Xn(n),pshift(Xpn(n),n),1,-1)
    if not nonneg(diff): print(f"(V6) A FAIL n={n}"); okA=False
    # decomposition: sum_{n2} q^{n^2+n2^2-n n2+n}((q^{n2-1}+q^{n2})[2n-2,n2-1]+[2n-2,n2-2])
    dec=[]
    for n2 in range(2*n+1):
        e=n*n+n2*n2-n*n2+n
        if n2>=1:
            dec=padd(dec,pshift(qbin(2*n-2,n2-1),e+n2-1))
            dec=padd(dec,pshift(qbin(2*n-2,n2-1),e+n2))
        if n2>=2:
            dec=padd(dec,pshift(qbin(2*n-2,n2-2),e))
    if dec!=diff: print(f"(V6) A-decomp FAIL n={n}"); okAdec=False
print(f"(V6) Absorption A: {'OK' if okA else 'FAIL'}; Pascal decomposition exact: {'OK' if okAdec else 'FAIL'} (n<={NMAX})")

# V7: Absorption B numeric + identity (*)
okB=True; okstar=True
for n in range(1,NMAX+1):
    diff=padd(Xn(n),pshift(Ypn(n),n),1,-1)
    if not nonneg(diff): print(f"(V7) B FAIL n={n}: first coeffs {diff[:12]}"); okB=False
    for n2 in range(2*n-1):
        lhs=padd(qbin(2*n,n2),pshift(qbin(2*n-2,n2),n2),1,-1)
        rhs=padd(qbin(2*n-1,n2-1),pshift(qbin(2*n-2,n2-1),2*n-1))
        if lhs!=rhs: print(f"(V7) (*) FAIL n={n} n2={n2}"); okstar=False
print(f"(V7) Absorption B (X_n - q^n Y'_n >= 0): {'OK n<='+str(NMAX) if okB else 'FAIL'}; identity (*): {'OK' if okstar else 'FAIL'}")

# V7b: Lemma B EXACT identity: X_n - q^n Y'_n == sum_{j=0}^{2n-1} q^{n^2+j^2-nj+2j+1}[2n-1,j]
okBx=True
for n in range(1,NMAX+2):
    lhs=padd(Xn(n),pshift(Ypn(n),n),1,-1)
    rhs=[]
    for j in range(2*n):
        rhs=padd(rhs,pshift(qbin(2*n-1,j),n*n+j*j-n*j+2*j+1))
    if lhs!=rhs: print(f"(V7b) EXACT FAIL n={n}"); okBx=False
print(f"(V7b) Lemma B exact identity: {'OK n<='+str(NMAX+1) if okBx else 'FAIL'}")
