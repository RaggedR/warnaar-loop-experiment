# Compare transfer matrix F_{c,n} with brute force for d=2
from itertools import combinations

def profiles(d):
    result = []
    for c0 in range(d+1):
        for c1 in range(d-c0+1):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def EMD_formula(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

d = 2
profs = profiles(d)
prec = 50
R = PowerSeriesRing(QQ, 'q', default_prec=prec)
q = R.gen()

# Transfer matrix method
F_tm = {(c, 0): R(1) for c in profs}
for n in range(1, 3):
    denom = R(1) / (1 - q**(3*n))
    for c in profs:
        val = R(0)
        for cp in profs:
            emd = EMD_formula(c, cp)
            val += q**(n * emd) * F_tm[(cp, n-1)]
        F_tm[(c, n)] = val * denom

# Known brute-force values (from previous script)
# (1,1,0), n=1:
bf_110_1 = R(sum(c * q**i for i, c in enumerate([1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1])))
bf_200_1 = R(sum(c * q**i for i, c in enumerate([1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1])))

print("Transfer matrix vs brute force for d=2, n=1:")
print(f"  (1,1,0): TM = {F_tm[((1,1,0), 1)].polynomial()}")
print(f"  (1,1,0): BF = {bf_110_1.polynomial()}")
print(f"  Match: {F_tm[((1,1,0), 1)].polynomial() == bf_110_1.polynomial()}")

print(f"\n  (2,0,0): TM = {F_tm[((2,0,0), 1)].polynomial()}")
print(f"  (2,0,0): BF = {bf_200_1.polynomial()}")
print(f"  Match: {F_tm[((2,0,0), 1)].polynomial() == bf_200_1.polynomial()}")

# Check EMD values from (1,1,0) and (2,0,0)
print(f"\nEMD values from (1,1,0):")
for cp in profs:
    emd = EMD_formula((1,1,0), cp)
    print(f"  EMD((1,1,0), {cp}) = {emd}")

print(f"\nEMD values from (2,0,0):")
for cp in profs:
    emd = EMD_formula((2,0,0), cp)
    print(f"  EMD((2,0,0), {cp}) = {emd}")
