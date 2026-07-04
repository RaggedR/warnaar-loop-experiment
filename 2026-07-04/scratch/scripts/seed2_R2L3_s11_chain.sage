# Seed 2 R2 L3: verify the (3,3,2) chain
#   D1 := S11(e3|e3) - q S11(e2|e2)   [derived from Warnaar Prop_finiteform a=-1, k=3, limit]
#   D2 := S11(e3|e2) - q S11(e2|e1)   [Uncu's PROVED formula for H_{(3,3,2)}]
# Checks:
#   [T]  T-form (denominator (q)_{r3+s3}) == D1  (Pochhammer split, sanity of derivation)
#   [A]  D1 == D2 coefficientwise at z-orders n=0..4  (the bridging S-identity)
#   [B]  (q)_n (q)_inf [z^n] D1 == Q_n^{(3,3,2)} ground truth (=> FERM=(q)_inf*combo chain)
import json, time

PREC = 300
CHK  = 150   # compare series only up to q^CHK (safe vs truncation)
R.<q> = PowerSeriesRing(ZZ, default_prec=PREC)

def poch(n):  # (q;q)_n
    p = R(1)
    for i in range(1, n+1):
        p *= (1 - q**i)
    return p

pc = {}
def P(n):
    if n not in pc: pc[n] = poch(n)
    return pc[n]

def Pinv(n):
    key = ('i', n)
    if key not in pc: pc[key] = P(n)**(-1)
    return pc[key]

qinf = poch(60)  # (q;q)_inf mod q^PREC needs 1-q^i for i<PREC; 60 not enough!
qinf = R(1)
for i in range(1, PREC):
    qinf *= (1 - q**i)

SMAX = 26

def S11_zorder(n, rho, sigma, split=True):
    """[z^n] S_11(z; rho|sigma) as q-series (r1 = n fixed).
       split=True: standard denominator (q)_{r3}(q)_{s3}(q)_{r3+s3+1}
       split=False: T-form denominator (q)_{r3}(q)_{s3}(q)_{r3+s3} (no +1) --
                    actually the T-form from Prop_finiteform has denominator
                    (q)_{r3+s3} in place of (q)_{r3}(q)_{s3}(q)_{r3+s3+1}?  NO:
                    T-form denom = (q)_{r1-r2}(q)_{r2-r3}(q)_{s1-s2}(q)_{s2-s3}
                                   (q)_{r3}(q)_{s3}  * 1/(q)_{r3+s3}?? see note."""
    r1 = n
    total = R(0)
    for r2 in range(r1+1):
        for r3 in range(r2+1):
            for s1 in range(SMAX):
                for s2 in range(min(s1, SMAX)+1):
                    for s3 in range(s2+1):
                        e = (r1^2 - r1*s1 + s1^2 + rho[0]*r1 + sigma[0]*s1
                           + r2^2 - r2*s2 + s2^2 + rho[1]*r2 + sigma[1]*s2
                           + r3^2 - r3*s3 + s3^2 + rho[2]*r3 + sigma[2]*s3
                           + 2*r3*s3)
                        if e >= PREC: continue
                        den = (Pinv(r1-r2)*Pinv(r2-r3)*Pinv(s1-s2)*Pinv(s2-s3)
                               *Pinv(r3)*Pinv(s3)*Pinv(r3+s3+1))
                        total += q**e * den
    return total

e3 = (0,0,0); e2 = (0,0,1); e1 = (0,1,1)

def trunc(f, N):
    return f.truncate(N)

# ground truth
with open("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L2_qn_d8.json") as fh:
    gt = json.load(fh)
key332 = None
for k in gt:
    if k.startswith("(3, 3, 2)"): key332 = True
print("sample keys:", list(gt.keys())[:3])

t0 = time.time()
okA = okB = True
for n in range(5):
    S_e3e3 = S11_zorder(n, e3, e3)
    S_e2e2 = S11_zorder(n, e2, e2)
    S_e3e2 = S11_zorder(n, e3, e2)
    S_e2e1 = S11_zorder(n, e2, e1)
    D1 = S_e3e3 - q*S_e2e2
    D2 = S_e3e2 - q*S_e2e1
    diffA = trunc(D1 - D2, CHK)
    a_ok = (diffA == 0)
    okA = okA and a_ok
    # [B]
    Qn_series = trunc(P(n) * qinf * D1, CHK)
    kk = "(3, 3, 2)|%d" % n
    if kk in gt:
        coeffs = gt[kk]
        want = R(sum(c*q**i for i,c in enumerate(coeffs[:CHK])))
        got = Qn_series
        m = min(CHK, len(coeffs))
        b_ok = all(got.padded_list(m)[i] == coeffs[i] for i in range(m))
    else:
        b_ok = None
    okB = okB and bool(b_ok)
    print("n=%d  [A] D1==D2: %s   [B] (q)_n(q)_inf[z^n]D1 == Q_n: %s   (%.0fs)"
          % (n, a_ok, b_ok, time.time()-t0))

print("OVERALL: A(bridging identity) =", okA, "  B(chain vs ground truth) =", okB)
