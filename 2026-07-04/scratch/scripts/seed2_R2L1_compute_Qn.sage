# Seed 2, R2L1: Compute Q_{1,c}(q) for all profiles c with d=4
# and compare with KR crystal energy polynomials

from sage.all import *
from collections import defaultdict

PS = PowerSeriesRing(QQ, 'q', default_prec=100)
q = PS.gen()

def Fc1_profile(c, prec=80):
    """Compute F_{c,1}(q) for profile c = (c0,c1,c2) with max=1.
    CPs with max=1: each lam^(i) = (1^{a_i}).
    Conditions: a_0 >= max(0, a_1-c_1), a_1 >= max(0, a_2-c_2), a_2 >= max(0, a_0-c_0).
    """
    c0, c1, c2 = c
    result = PS(0)
    for a0 in range(prec):
        for a1 in range(prec):
            if a0 < max(0, a1 - c1):
                continue
            for a2 in range(prec):
                if a1 < max(0, a2 - c2):
                    continue
                if a2 < max(0, a0 - c0):
                    continue
                s = a0 + a1 + a2
                if s >= prec:
                    continue
                result += q**s
    return result

def Q1_profile(c, prec=80):
    """Compute Q_{1,c}(q) for profile c."""
    Fc1 = Fc1_profile(c, prec)
    G1 = Fc1 - 1
    Q1 = (1 - q) * G1 - q  # = (q;q)_1 * [z^1]((zq;q)_inf * F_c(z,q))
    # Wait, let me re-derive:
    # [z^1]((zq;q)_inf * F_c(z,q))
    # = [z^1](sum_m (-1)^m q^{C(m+1,2)}/(q;q)_m z^m * sum_N G_N z^N)
    # = sum_{m+j=1} (-1)^m q^{C(m+1,2)}/(q;q)_m * G_j
    # = (m=0,j=1): G_1 + (m=1,j=0): (-q)/(1-q) * 1
    # = G_1 - q/(1-q)
    # Q_1 = (1-q) * [G_1 - q/(1-q)] = (1-q)*G_1 - q
    return Q1

print("Q_{1,c}(q) for all profiles c with d=4:")
print("=" * 60)
profiles_d4 = [(c0, c1, c2) for c0 in range(5) for c1 in range(5-c0) 
               for c2 in [4-c0-c1]]
for c in sorted(profiles_d4):
    Q1 = Q1_profile(c, prec=40)
    # Truncate to show polynomial part
    poly_part = sum(Q1[i]*q**i for i in range(40) if Q1[i] != 0)
    ev = sum(Q1[i] for i in range(40))
    print(f"  c={c}: Q_1 = {poly_part.add_bigoh(20)}  [Q_1(1) = {ev}]")

# Now let me also look at the one_dimensional_configuration_sum decomposition
# by classical weight for a single B^{1,4}
print("\n" + "=" * 60)
print("1d config sum for B^{1,4} tensor B^{1,4} by weight component")
print("=" * 60)

R2 = QQ['q']
qq = R2.gen()

K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)
T2 = crystals.TensorProduct(K, K)

# The one_dimensional_configuration_sum already gave us the decomposition
# But let me extract it more carefully by profile

# The classical weight of a tensor product element b1 tensor b2
# should relate to the content of b1 and b2

# For a single element [[a1,...,ad]] with content (c0,c1,c2),
# classical weight = c0*omega_1 + c1*omega_2 + c2*omega_3
# In A_2 notation: wt = (c0-c1)*Lambda_1 + (c1-c2)*Lambda_2 (mod delta)

# For tensor b1 tensor b2 with contents (a0,a1,a2) and (b0,b1_,b2_):
# classical weight = ((a0+b0)-(a1+b1_))*Lambda_1 + ((a1+b1_)-(a2+b2_))*Lambda_2

# So grouping by "total content" (a0+b0, a1+b1_, a2+b2_) gives
# the weight decomposition of the tensor product

# Let me group by total content and compute energy polynomial
energy_by_total_content = defaultdict(lambda: R2(0))

for b in T2:
    e = b.energy_function()
    tab1 = list(b[0].to_tableau())[0]
    tab2 = list(b[1].to_tableau())[0]
    total = (tab1.count(1)+tab2.count(1), tab1.count(2)+tab2.count(2), tab1.count(3)+tab2.count(3))
    energy_by_total_content[total] += qq**e

print("\nEnergy polynomials grouped by total content (n_1, n_2, n_3):")
for tc in sorted(energy_by_total_content.keys()):
    poly = energy_by_total_content[tc]
    print(f"  ({tc[0]},{tc[1]},{tc[2]}): {poly}  [q=1: {poly(q=1)}]")

# The total content sums to 2d = 8. So these are compositions of 8 into 3 parts.
# There are C(10,2) = 45 such compositions.
# This is too many to match to the 15 profiles directly.

# What about grouping by the DIFFERENCE of contents?
# "Net profile" = content(b2) - content(b1) modulo something?
# Or just content(b2)?

