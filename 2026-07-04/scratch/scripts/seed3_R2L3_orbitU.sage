"""
Seed 3, R2L3, Script 2: orbit-level U(x) matrices and exact difference data.
"""
Rq.<q> = PolynomialRing(ZZ)
Rx.<x> = PolynomialRing(ZZ)

def profiles(d): return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]
def emd(cp, c):
    e = [cp[i]-c[i] for i in range(3)]
    return 2*e[0]+e[1]+3*max(0,-e[0],-e[0]-e[1])
def rho(a): return (a[1], a[2], a[0])
def orbit_rep(c): return min([c, rho(c), rho(rho(c))])

def orbits(d):
    reps = sorted(set(orbit_rep(c) for c in profiles(d)))
    return reps

def Umatrix(d):
    reps = orbits(d)
    U = {}
    for ci, c in enumerate(reps):          # target
        for oj, o in enumerate(reps):      # source orbit
            T = sum(x^emd(s, c) for s in {o, rho(o), rho(rho(o))})
            quo, rem = T.quo_rem(1+x+x^2)
            assert rem == 0
            U[(ci, oj)] = quo
    return reps, U

for d in [2, 4]:
    reps, U = Umatrix(d)
    K = len(reps)
    print(f"\n===== d={d}, K={K} orbits: {reps} =====")
    print("U(x) [row=target orbit, col=source orbit]:")
    for i in range(K):
        print(f"  {reps[i]}: ", [U[(i,j)] for j in range(K)])
    print("U(x) - I:")
    for i in range(K):
        print(f"  {reps[i]}: ", [U[(i,j)] - (1 if i==j else 0) for j in range(K)])

# exact H and D at orbit level for d=4
def compute_HD(d, m_max):
    reps, U = Umatrix(d)
    K = len(reps)
    H = [vector(Rq, [1]*K)]
    for m in range(1, m_max+1):
        Um = matrix(Rq, K, K, lambda i, j: U[(i,j)](q^m))
        H.append(Um * H[m-1])
    D = [None] + [H[m] - H[m-1] for m in range(1, m_max+1)]
    return reps, H, D

reps, H, D = compute_HD(4, 5)
print("\n===== d=4 exact data =====")
for m in range(1, 5):
    print(f"-- m={m}")
    for i, r in enumerate(reps):
        print(f"   H_{m-1}[{r}] = {H[m-1][i]}")
    for i, r in enumerate(reps):
        print(f"   D_{m}[{r}] = {D[m][i]}")
