load("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")
NMAX = 28
def qbin(a, b):
    if b < 0 or b > a or a < 0: return Rq(0)
    return q_binomial(a, b, q)
def T(n, j): return q**(n*n + j*j - n*j)
H, viol = build_H(4, NMAX, verbose=False)
profs = [(0,1,3),(0,3,1),(1,3,0),(3,0,1),(1,0,3),(3,1,0)]
D = {c: dtower(H, c, NMAX) for c in profs}
ok_310_as_031 = True; ok_301_as_013 = True; rot13 = True; rot31 = True
for n in range(NMAX+1):
    Xn  = sum(T(n,j) * q**n * qbin(2*n, j) for j in range(2*n+1))
    Xp  = sum(T(n,j) * q**(2*j) * qbin(2*n-2, j) for j in range(max(1,2*n-1)))
    F310 = sum(T(n,j) * q**j * qbin(2*n, j) for j in range(2*n+1))
    F301 = Xn + (1 - q**n) * Xp
    ok_310_as_031 &= (F310 == D[(0,3,1)][(n,n)])
    ok_301_as_013 &= (F301 == D[(0,1,3)][(n,n)])
    rot13 &= (D[(0,1,3)][(n,n)] == D[(1,3,0)][(n,n)] == D[(3,0,1)][(n,n)])
    rot31 &= (D[(0,3,1)][(n,n)] == D[(1,0,3)][(n,n)] == D[(3,1,0)][(n,n)])
print("CW(3,1,0) formula == engine orbit of (0,3,1), n<=%d: %s" % (NMAX, ok_310_as_031))
print("CW(3,0,1) formula == engine orbit of (0,1,3), n<=%d: %s" % (NMAX, ok_301_as_013))
print("C3-rotation invariance within orbits: %s %s" % (rot13, rot31))
