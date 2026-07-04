#!/usr/bin/env python3
"""R1 region: c = (L, L', a) with L, L' large (>= j-1), a = c_2 small.
Ingredient formulas (hand-derived, verify here):
  mu_e(v)  = [v==e mod 2] + [v>=0] + [v<=0] - [|v|=e] - [v=0]   (|v|<=e, e>=1)
             (# points on sphere e with s+t = v)
  T(delta) = floor((3*delta-1)/2) for delta>=1 else 0
             (# points on sphere e with s+t > beta, delta = e-beta)
  x(m)     = sum_{r=0}^{floor((m-1)/3)} floor((3(m-3r)-1)/2)   (m>=1; 0 else)
             (X_k(beta) = x(k-beta): excess ball count, residue class of k)
  y(m)     = x(m) - x(m-1)
  w_k(beta)= (k+1) - y(k-beta)  for k>=1  (=0 for k<=0)
             ([q^k]Q_1 of profile (inf, inf, beta))
  phi_j(a) = har^inf_j - C1 - C2 + C3   where
     C1 = sum_{e=a+1}^{E} (j-2e+1) * T(e-a)
     C2 = sum_{e=1}^{E} sum_{v=-e}^{min(e,a)} mu_e(v) * y(j-2e-a+v)
     C3 = sum_{i=1}^{5} y(j-i-a),     E = floor((j-1)/2)
Verify each against brute force / the engine."""
import sys
from functools import lru_cache
from seed6_R2L4_sweep import har_j, sphere, g

def mu(e, v):
    if abs(v) > e: return 0
    return (1 if (v-e) % 2 == 0 else 0) + (1 if v >= 0 else 0) + (1 if v <= 0 else 0) \
           - (1 if abs(v) == e else 0) - (1 if v == 0 else 0)

def T(delta):
    return (3*delta - 1)//2 if delta >= 1 else 0

@lru_cache(maxsize=None)
def x(m):
    if m < 1: return 0
    return sum((3*(m-3*r) - 1)//2 for r in range((m-1)//3 + 1))

def y(m): return x(m) - x(m-1)

def u(k): return k+1 if k >= 1 else 0

def w(k, beta):
    if k <= 0: return 0
    return (k+1) - y(k - beta)

def har_inf(j):
    if j <= 5: return [0, 0, -2, 1, 0, 10][j]
    if j % 2 == 0:
        p = j//2; return (p-1)*(2*p*p+5*p-20)//2
    p = (j-1)//2; return p*(p+1)*(p+2) - 10*p + 5

def phi(j, a):
    E = (j-1)//2
    C1 = sum((j-2*e+1)*T(e-a) for e in range(a+1, E+1))
    C2 = sum(mu(e, v)*y(j-2*e-a+v) for e in range(1, E+1)
             for v in range(-e, min(e, a)+1))
    C3 = sum(y(j-i-a) for i in range(1, 6))
    return har_inf(j) - C1 - C2 + C3

# ---- verification ----
def vmu():
    for e in range(1, 25):
        cnt = {}
        for (s, t) in sphere(e): cnt[s+t] = cnt.get(s+t, 0) + 1
        for v in range(-e-2, e+3):
            assert cnt.get(v, 0) == mu(e, v), (e, v)
    print("mu OK (e<=24)")

def vT():
    for e in range(1, 25):
        for beta in range(0, e+3):
            bf = sum(1 for (s, t) in sphere(e) if s+t > beta)
            assert bf == T(e-beta), (e, beta, bf, T(e-beta))
    print("T OK")

def vw():
    # brute force w_k(beta): count points g<=k, g==k mod3, s+t<=beta, minus same at k-1
    def A(k, beta):
        if k < 0: return 0
        return sum(1 for s in range(-k, k+1) for t in range(-k, k+1)
                   if g(s,t) <= k and (k-g(s,t)) % 3 == 0 and s+t <= beta)
    for k in range(1, 30):
        for beta in range(0, k+3):
            assert A(k, beta) - A(k-1, beta) == w(k, beta), (k, beta)
    print("w OK (k<=29)")

def vphi():
    # against real profiles with two large coordinates
    for j in range(0, 34):
        L = j + 40
        for a in range(0, j+3):
            c = (L, L+1, a)   # d = 2L+1+a, any residue fine? engine har defined anyway;
            got = har_j(c, j)
            want = phi(j, a)
            assert got == want, (j, a, got, want)
    print("phi == har_j((L,L+1,a)) OK (j<=33, all a<=j+2)")

if __name__ == "__main__":
    vmu(); vT(); vw(); vphi()
    print("ALL R1 INGREDIENT CHECKS PASS")
