#!/usr/bin/env python3
"""R1 all-j positivity: exact chamber quasi-polynomials for phi_j(a).

phi_j(a) = har_j(c) for c=(L,L',a), min(L,L') >= j-1  (PROVED formula, r1.py):
  phi = har_inf(j) - C1 - C2 + C3,  E = (j-1)//2, y(m)=ceil(m/2) (m>=1, else 0)
  C1 = sum_{e=a+1}^{E} (j-2e+1)*floor((3(e-a)-1)/2)
  C2 = sum_{e=1}^{E} sum_{v=max(-e,1-n_e)}^{min(e,a)} mu_e(v)*y(n_e+v), n_e=j-2e-a
  C3 = sum_{i=1}^{5} y(j-a-i)

STRUCTURAL LEMMA (period 12, degree 3): on each chamber (linear inequalities in
(j,a) with boundaries from {a=0, 4a=j+O(1), 2a=j+O(1), a=j+O(1)}) and each
residue class (j,a) mod 12, phi is a polynomial of degree <= 3.
[Proof: each of C1, C2, C3, har_inf is an iterated sum of quasi-linear-period-2
integrands over intervals whose endpoints are floors of linear forms with
denominators dividing 12; on a fixed residue class mod 12 all floors are linear
and all parities constant, so iterated summation of polynomials gives polynomials,
degree <= 3 by counting. Chamber boundaries come from the max/min/positive-part
switches: min(e,a) switch needs a vs E (2a vs j); max(-e,1-n_e) switch at 3e=j-a-1
interacting with e<=a gives 4a vs j; y positive-part in C3 gives a vs j-5.]

This script: exact interpolation of every chamber x class polynomial, wide-band
verification, cubic-part check vs psi, slop constants, J1, finite check.
All arithmetic exact (int / Fraction).
"""
from fractions import Fraction
import sys, time

def har_inf(j):
    if j <= 5: return [0,0,-2,1,0,10][j]
    if j % 2 == 0:
        p = j//2; return (p-1)*(2*p*p+5*p-20)//2
    p = (j-1)//2; return p*(p+1)*(p+2) - 10*p + 5

def y(m): return (m+1)//2 if m >= 1 else 0

def G(M):   # sum_{m=1}^{M} ceil(m/2) = floor((M+1)^2/4)
    return 0 if M <= 0 else ((M+1)*(M+1))//4

def Gp(M, p):  # sum_{1<=m<=M, m%2==p} ceil(m/2)
    if M < 1: return 0
    if p == 0:
        t = M//2; return t*(t+1)//2
    s = (M-1)//2; return (s+1)*(s+2)//2

def phi_fast(j, a):
    E = (j-1)//2
    # C1
    C1 = 0
    for e in range(a+1, E+1):
        C1 += (j-2*e+1) * ((3*(e-a)-1)//2)
    # C2 with closed inner sum
    C2 = 0
    for e in range(1, E+1):
        n = j - 2*e - a
        U = min(e, a)
        m2 = n + U
        if m2 < 1: continue
        m1 = max(1, n - e)
        if m1 > m2: continue
        base = G(m2) - G(m1-1)
        p = (n + e) % 2
        par = Gp(m2, p) - Gp(m1-1, p)
        endm = y(n-e) if (n-e >= 1) else 0          # v = -e inside range iff n-e>=1
        endp = y(n+e) if (e <= a and n+e >= 1) else 0  # v = +e inside range
        C2 += base + par - endm - endp
    C3 = sum(y(j-a-i) for i in range(1, 6))
    return har_inf(j) - C1 - C2 + C3

# ---------- slow reference (from r1.py, verified vs engine) ----------
def mu(e, v):
    if abs(v) > e: return 0
    return (1 if (v-e)%2==0 else 0) + (1 if v>=0 else 0) + (1 if v<=0 else 0) \
           - (1 if abs(v)==e else 0) - (1 if v==0 else 0)

def phi_slow(j, a):
    E = (j-1)//2
    C1 = sum((j-2*e+1)*((3*(e-a)-1)//2) for e in range(a+1, E+1))
    C2 = sum(mu(e,v)*y(j-2*e-a+v) for e in range(1, E+1)
             for v in range(-e, min(e,a)+1))
    C3 = sum(y(j-a-i) for i in range(1, 6))
    return har_inf(j) - C1 - C2 + C3

def check_fast(jmax=80):
    for j in range(1, jmax+1):
        for a in range(0, j+3):
            assert phi_fast(j,a) == phi_slow(j,a), (j,a)
    print(f"phi_fast == phi_slow for j <= {jmax}, all a  [exact]")

# ---------- interpolation machinery ----------
MONO = [(0,0),(1,0),(0,1),(2,0),(1,1),(0,2),(3,0),(2,1),(1,2),(0,3)]  # (dj,da)

def mono_eval(j, a):
    return [Fraction(j)**dj * Fraction(a)**da for (dj,da) in MONO]

def solve_exact(pts, vals):
    """Gaussian elimination over Fraction; pts: list of (j,a)."""
    n = len(MONO)
    A = [mono_eval(j,a) + [Fraction(v)] for (j,a),v in zip(pts, vals)]
    # forward elim
    row = 0
    piv_cols = []
    for col in range(n):
        p = None
        for r in range(row, len(A)):
            if A[r][col] != 0: p = r; break
        if p is None: return None
        A[row], A[p] = A[p], A[row]
        pv = A[row][col]
        A[row] = [x/pv for x in A[row]]
        for r in range(len(A)):
            if r != row and A[r][col] != 0:
                f = A[r][col]
                A[r] = [x - f*y_ for x,y_ in zip(A[r], A[row])]
        piv_cols.append(col); row += 1
        if row == n: break
    if row < n: return None
    coeffs = [A[i][n] for i in range(n)]
    # consistency of extra rows
    for r in range(n, len(A)):
        if A[r][n] != 0: return None
    return coeffs

def poly_eval(coeffs, j, a):
    return sum(c * Fraction(j)**dj * Fraction(a)**da for c,(dj,da) in zip(coeffs, MONO))

# chambers: functions (j -> a-range [lo, hi] inclusive) for sampling deep inside,
# and exact membership predicates to be pinned down after boundary detection.
def sample_points(rj, ra, frac_lo, frac_hi, j_range):
    """class (rj,ra) mod 12, a in [frac_lo*j, frac_hi*j]."""
    pts = []
    for j in j_range:
        if j % 12 != rj: continue
        alo = int(frac_lo*j)+2; ahi = int(frac_hi*j)-2
        for a in range(alo, ahi+1):
            if a % 12 == ra and 0 <= a <= j-2:
                pts.append((j,a))
    return pts

if __name__ == "__main__":
    t0 = time.time()
    check_fast(60)
    print(f"[{time.time()-t0:.1f}s]")

# ================= full pipeline (self-contained certificate) =================
def fit2d(pts):
    return solve_exact(pts, [phi_fast(j,a) for (j,a) in pts])

def fit1d(js, vals):
    A=[[Fraction(j)**k for k in range(4)]+[Fraction(v)] for j,v in zip(js,vals)]
    row=0
    for col in range(4):
        p=next((r for r in range(row,len(A)) if A[r][col]!=0), None)
        if p is None: return None
        A[row],A[p]=A[p],A[row]; pv=A[row][col]
        A[row]=[x/pv for x in A[row]]
        for r in range(len(A)):
            if r!=row and A[r][col]!=0:
                f=A[r][col]; A[r]=[x-f*yy for x,yy in zip(A[r],A[row])]
        row+=1
    for r in range(4,len(A)):
        if A[r][4]!=0: return None
    return [A[i][4] for i in range(4)]

def pipeline():
    CUB = {(3,0):Fraction(1,24),(2,1):Fraction(1,4),(1,2):Fraction(-1,4),(0,3):Fraction(1,12)}
    LOW,HIGH = {},{}
    for rj in range(12):
        for ra in range(12):
            pL,pH=[],[]
            for j in range(80,200):
                if j%12!=rj: continue
                for a in range(ra,j-3,12):
                    (pL if 2*a<=j-4 else pH if (2*a>=j+4 and a<=j-6) else []).append((j,a))
            cL,cH=fit2d(pL),fit2d(pH)
            assert cL and cH,(rj,ra)
            for c,tag in ((cL,'L'),(cH,'H')):
                for co,(dj,da) in zip(c,MONO):
                    if dj+da==3: assert co==CUB[(dj,da)],(tag,rj,ra,dj,da,co)
            LOW[(rj,ra)],HIGH[(rj,ra)]=cL,cH
    assert all(LOW[(rj,ra)]==HIGH[(rj,ra)] for rj in range(1,12,2) for ra in range(12))
    print("288 chamber polys fitted; all cubic parts == (j^3+6j^2a-6ja^2+2a^3)/24; LOW==HIGH for odd j")
    STRIP={}
    for nn in (2,3):
        for rj in range(12):
            js=[j for j in range(60,156) if j%12==rj]
            c=fit1d(js,[phi_fast(j,j-nn) for j in js]); assert c
            assert c[3]==Fraction(1,8)
            STRIP[(nn,rj)]=c
    print("24 strip polys fitted; leads == 1/8")
    def pred(j,a):
        if a in (j-2,j-3):
            c=STRIP[(j-a,j%12)]; return sum(cc*Fraction(j)**k for k,cc in enumerate(c))
        return poly_eval(LOW[(j%12,a%12)] if 2*a<j else HIGH[(j%12,a%12)], j, a)
    n=0
    for j in range(6,150):
        for a in range(0,j-1):
            assert pred(j,a)==phi_fast(j,a),(j,a); n+=1
    JS=list(range(150,800,3))
    for t in range(-30,31):
        for j in JS:
            a=(j+t)//2
            if 2*a-j==t and 0<=a<=j-2: assert pred(j,a)==phi_fast(j,a),(j,a); n+=1
    for t in range(2,31):
        for j in JS:
            if j-t>=0: assert pred(j,j-t)==phi_fast(j,j-t),(j,t); n+=1
    for t in range(0,31):
        for j in JS: assert pred(j,t)==phi_fast(j,t),(j,t); n+=1
    print(f"verification: {n} exact matches (dense 6<=j<150 + sliver lines to j=800), 0 mismatches")
    K2=K1=K0=Fraction(0)
    for D in (LOW,HIGH):
        for c in D.values():
            k={0:Fraction(0),1:Fraction(0),2:Fraction(0)}
            for co,(dj,da) in zip(c,MONO):
                if dj+da<=2: k[dj+da]+=abs(co)
            K2,K1,K0=max(K2,k[2]),max(K1,k[1]),max(K0,k[0])
    j=1
    while Fraction(j**3,24)<=K2*j*j+K1*j+K0: j+=1
    print(f"slop K2={K2} K1={K1} K0={K0}; tail j >= {j} (strips: check leads/slops give j>=10)")
    jS=1
    for c in STRIP.values():
        jj=1
        while Fraction(jj**3,8)<=abs(c[2])*jj*jj+abs(c[1])*jj+abs(c[0]): jj+=1
        jS=max(jS,jj)
    J1=max(j,jS)
    for jj in range(0,J1):
        if jj in (2,4): continue
        m=min(phi_fast(jj,a) for a in range(0,max(1,jj-1)))
        assert m>=0,(jj,m)
    print(f"J1={J1}; finite check j<J1 (j∉{{2,4}}): all min_a phi >= 0")
    print("R1 THEOREM CERTIFIED: har_j(c) >= 0 for all j∉{2,4} whenever two coords of c >= j-1")

if __name__ == "__main__" and "pipeline" in sys.argv:
    pipeline()
