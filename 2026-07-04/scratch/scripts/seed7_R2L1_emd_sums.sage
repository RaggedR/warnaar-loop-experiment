# Study the EMD sum structure for d=7
# For Q_1: the numerator is sum_{c'} q^{EMD(c,c')} * B(c')
# For this to be divisible by (1+q+q^2), the sum needs to vanish at omega = e^{2pi i/3}.
# i.e., sum_{c'} omega^{EMD(c,c')} * B(c')|_{q=omega} = 0

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

def rank(c):
    return sum(1 for ci in c if ci > 0)

# For d=7, the EMD mod 3 of rank-2 and rank-3 profiles
d = 7
profs = profiles(d)

c = (2, 3, 2)
print(f"EMD mod 3 distribution from c={c}:")
from collections import Counter
for r in [2, 3]:
    emds = [EMD_formula(c, cp) for cp in profs if rank(cp) == r]
    mod3 = Counter(e % 3 for e in emds)
    print(f"  rank {r}: EMD values = {sorted(emds)}")
    print(f"           EMD mod 3 counts: {dict(sorted(mod3.items()))}")

# Check: for divisibility by (1+q+q^2), we need the numerator to be zero when q = omega (cube root of unity)
# At q = omega: B(c') for rank 3 = omega(2-omega). For rank 2: B(c') = omega.
# q^{EMD} = omega^{EMD mod 3} (since omega^3 = 1)

# So the condition is:
# sum_{rank 3} omega^{EMD(c,c') mod 3} * omega(2-omega) + sum_{rank 2} omega^{EMD(c,c') mod 3} * omega = 0

# At omega: 2-omega = 2 - omega. Note omega^2 + omega + 1 = 0, so omega^2 = -1-omega.
# omega(2-omega) = 2*omega - omega^2 = 2*omega - (-1-omega) = 3*omega + 1

# So the condition becomes:
# (3*omega+1) * sum_{rank 3} omega^{EMD mod 3} + omega * sum_{rank 2} omega^{EMD mod 3} = 0

# Let S_r = sum_{rank r c'} omega^{EMD(c,c') mod 3} for r = 2, 3

# For S_r, if EMD mod 3 has equal counts in each residue class, then S_r = 0.
# But the counts may not be equal.

# Let me compute S_2 and S_3 for each c.
from sage.rings.number_field.number_field import CyclotomicField
K = CyclotomicField(3)
omega = K.gen()

for c in [(2,3,2), (7,0,0), (1,1,5)]:
    S2 = sum(omega**((EMD_formula(c, cp)) % 3) for cp in profs if rank(cp) == 2)
    S3 = sum(omega**((EMD_formula(c, cp)) % 3) for cp in profs if rank(cp) == 3)
    
    # Check: (3*omega+1)*S3 + omega*S2 = 0?
    val = (3*omega + 1) * S3 + omega * S2
    print(f"\nc={c}:")
    print(f"  S2 = {S2}")
    print(f"  S3 = {S3}")
    print(f"  (3*omega+1)*S3 + omega*S2 = {val}")
    print(f"  Zero? {val == 0}")
