# The key connection: can we extract Q_n from KR crystal data?
# 
# What we know:
# 1. B^{1,d} has dim = C(d+2,2) = number of profiles
# 2. H(c,c') is constant on profile pairs (just proved)
# 3. Q_{n,c}(q) is a polynomial, Q_n(1) = ((d+1)(d+2)/6 - 1)^n for d not div by 3
# 4. The EMD path formula: P_n(c) = (q^3;q^3)_n * F_{c,n} = sum over paths q^{sum n_k * EMD}
# 5. Q_n = q-binomial transform of F_{c,n} with alternating signs
#
# The transfer matrix for CPs has entries A_{c,c'}(x)
# with adj(I-A(x))[c,c'] = x^{EMD(c,c')}
#
# The KR energy H(c,c') is a DIFFERENT function from EMD(c,c')
#
# BUT: the ODCS for B^{1,d}^{tensor n} graded by energy gives
# sum_b q^{energy(b)} e^{wt(b)}
# Since energy is constant on profiles, this becomes
# sum_{path c^(1),...,c^(n)} q^{sum H(c^(i),c^(i+1))} * product(classical_wt)
# 
# The path sum with ENERGY grading uses H, while the P_n path sum uses EMD.
# These give different polynomials!
#
# QUESTION: Is there a TRANSFORM relating H-graded paths to Q_n?

from sage.all import *
from collections import defaultdict

R = QQ['q']
q = R.gen()

def compute_H_matrix_dict(d):
    K = crystals.KirillovReshetikhin(['A',2,1], 1, d)
    T = crystals.TensorProduct(K, K)
    def prof(b):
        tab = list(b.to_tableau())[0]
        return (tab.count(1), tab.count(2), tab.count(3))
    H = {}
    for b in T:
        H[(prof(b[0]), prof(b[1]))] = b.energy_function()
    profiles = sorted(set(prof(b) for b in K))
    return H, profiles

d = 4
H, profs = compute_H_matrix_dict(d)
N = len(profs)

# Build the H-graded path sum for n=2:
# sum_{c^(1), c^(2)} q^{H(c^(1),c^(2))} 
# grouped by c^(2) (the "final profile")

print("H-graded path sum for n=2, grouped by final profile c^(2):")
H_paths_n2 = defaultdict(lambda: R(0))
for c1 in profs:
    for c2 in profs:
        h = H[(c1, c2)]
        H_paths_n2[c2] += q**h

for c in sorted(H_paths_n2.keys()):
    poly = H_paths_n2[c]
    print(f"  c={c}: {poly}  [q=1: {poly(q=1)}]")

# These should match the "energy by right profile" from earlier
# Which gave e.g. c=(2,1,1): 7q^3 + 5q^2 + 2q + 1

# Now: for comparison, compute the EMD-graded path sum
# EMD from Round 1: EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
# But this formula might not be right. Let me use the definition from Round 1.

def emd(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

# EMD-graded n=2 path sum (this should relate to P_2)
EMD_paths_n2 = defaultdict(lambda: R(0))
for c1 in profs:
    for c2 in profs:
        e = emd(c1, c2)
        EMD_paths_n2[c2] += q**(2*e)  # multiply by n=2

print("\nEMD-graded path sum for n=2 (q^{2*EMD}), by final profile:")
for c in sorted(EMD_paths_n2.keys()):
    poly = EMD_paths_n2[c]
    print(f"  c={c}: {poly}  [q=1: {poly(q=1)}]")

# Now compute Q_1 and Q_2 for ALL profiles
PS = PowerSeriesRing(QQ, 'q', default_prec=80)
qq = PS.gen()

def Fc1_profile(c, prec=60):
    c0, c1, c2 = c
    result = PS(0)
    for a0 in range(prec):
        for a1 in range(prec):
            if a0 < max(0, a1 - c1): continue
            for a2 in range(prec):
                if a1 < max(0, a2 - c2): continue
                if a2 < max(0, a0 - c0): continue
                s = a0 + a1 + a2
                if s >= prec: continue
                result += qq**s
    return result

# Q_1 for all profiles
print("\n\nQ_{1,c}(q) for all profiles with d=4:")
Q1_dict = {}
for c in profs:
    Fc1 = Fc1_profile(c, 30)
    G1 = Fc1 - 1
    Q1 = (1-qq)*G1 - qq
    # Extract polynomial part
    coeffs = [Q1[i] for i in range(30)]
    Q1_poly = sum(int(coeffs[i])*q**i for i in range(30) if coeffs[i] != 0)
    Q1_dict[c] = Q1_poly
    print(f"  c={c}: Q_1 = {Q1_poly}  [Q_1(1) = {Q1_poly(q=1)}]")

# Now: the H-paths for n=1 are trivially just 1 for each profile (energy=0 for single element)
# So there's no nontrivial comparison at n=1

# For n=2, we need Q_2. This requires F_{c,2} which needs computing CPs with max <= 2.
# This is harder. Let me see if I can use the recurrence Q_n = D_n^n

# From Round 1: D_0^m = h_m = (q;q)_m * g_m where g_m = F_{c,m} - F_{c,m-1}
# D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}
# Q_n = D_n^n

# For n=2: Q_2 = D_2^2 = D_1^2 - q^2 * D_1^1
# D_1^m = D_0^m - q * D_0^{m-1} = h_m - q*h_{m-1}
# D_1^1 = h_1 - q*h_0 = h_1 - q (since h_0 = 1? or h_0 = 0?)

# h_0 = (q;q)_0 * g_0 = 1 * (F_{c,0} - F_{c,-1}) = 1 * 1 = 1
# h_1 = (1-q) * g_1 = (1-q) * (F_{c,1} - 1)
# Actually I already computed Q_1 = (1-q)*G_1 - q which is the same as D_1^1

# D_1^2 = h_2 - q*h_1
# h_2 = (q;q)_2 * g_2 = (1-q)(1-q^2) * (F_{c,2} - F_{c,1})

# I need F_{c,2} for profile c. For max <= 2, each partition has parts in {0,1,2}.
# lam^(i) = (2^{b_i}, 1^{a_i}) with a_i, b_i >= 0
# lam^(i)_j = 2 if j <= b_i, 1 if b_i < j <= b_i+a_i, 0 if j > b_i+a_i

# Interlacing: lam^(0)_j >= lam^(1)_{j+c_1}
# This means: for each j, the value of lam^(0) at position j is >= value of lam^(1) at position j+c_1

# This is complex but still tractable. Let me compute F_{c,2} for c=(2,1,1)

def Fc2_profile(c, prec=30):
    """Compute F_{c,2}(q) for profile c = (c_0,c_1,c_2) with max=2.
    Each partition: (2^b, 1^a), parameterized by (b,a).
    Total size = 2b + a.
    """
    c0, c1, c2 = c
    result = PS(0)
    
    for b0 in range(prec):
        for a0 in range(prec):
            if 2*b0 + a0 >= prec: break
            for b1 in range(prec):
                for a1 in range(prec):
                    if 2*b0+a0+2*b1+a1 >= prec: break
                    # Check lam0_j >= lam1_{j+c_1} for all j
                    # lam0 = (2^{b0}, 1^{a0})
                    # lam1 = (2^{b1}, 1^{a1})
                    # lam0_j: 2 if j<=b0, 1 if b0<j<=b0+a0, 0 if j>b0+a0
                    # lam1_{j+c1}: 2 if j+c1<=b1, 1 if b1<j+c1<=b1+a1, 0 if j+c1>b1+a1
                    # So j+c1 <= b1 means j <= b1-c1
                    # Need: for all j >= 1:
                    # lam0_j >= lam1_{j+c1}
                    
                    # Case analysis:
                    # If j <= min(b0, b1-c1): both are 2, ok
                    # If j <= b0 and b1-c1 < j <= b1+a1-c1: need 2 >= 1, ok
                    # If j <= b0 and j > b1+a1-c1: need 2 >= 0, ok
                    # If b0 < j <= b0+a0 and j <= b1-c1: need 1 >= 2, FAIL
                    # If b0 < j <= b0+a0 and b1-c1 < j <= b1+a1-c1: need 1 >= 1, ok
                    # If b0 < j <= b0+a0 and j > b1+a1-c1: need 1 >= 0, ok
                    # If j > b0+a0 and j <= b1-c1: need 0 >= 2, FAIL
                    # If j > b0+a0 and b1-c1 < j <= b1+a1-c1: need 0 >= 1, FAIL
                    # If j > b0+a0 and j > b1+a1-c1: need 0 >= 0, ok
                    
                    # Conditions:
                    # 1. If b1-c1 > b0: FAIL (there exist j in (b0, b1-c1] where lam0=1, lam1=2)
                    #    unless b1-c1 <= 0 (no such j)
                    #    So need: b1 <= b0 + c1 (or b1 <= c1 if b0=0)
                    ok01 = True
                    if b1 - c1 > b0:
                        ok01 = False
                    # 2. If b1+a1-c1 > b0+a0: FAIL (j in (b0+a0, b1+a1-c1] where lam0=0, lam1>=1)
                    if b1+a1-c1 > b0+a0:
                        ok01 = False
                    
                    if not ok01:
                        continue
                    
                    for b2 in range(prec):
                        for a2 in range(prec):
                            total = 2*(b0+b1+b2) + a0+a1+a2
                            if total >= prec: break
                            
                            # Check lam1_j >= lam2_{j+c2}
                            ok12 = True
                            if b2 - c2 > b1:
                                ok12 = False
                            if b2+a2-c2 > b1+a1:
                                ok12 = False
                            if not ok12:
                                continue
                            
                            # Check lam2_j >= lam0_{j+c0}
                            ok20 = True
                            if b0 - c0 > b2:
                                ok20 = False
                            if b0+a0-c0 > b2+a2:
                                ok20 = False
                            if not ok20:
                                continue
                            
                            result += qq**total
    return result

c = (2, 1, 1)
print(f"\n\nComputing F_{{c,2}} for c={c}:")
Fc2 = Fc2_profile(c, 25)
print(f"F_{{c,2}} = {Fc2.add_bigoh(20)}")

Fc1 = Fc1_profile(c, 25)
print(f"F_{{c,1}} = {Fc1.add_bigoh(20)}")

G1 = Fc1 - 1
G2 = Fc2 - Fc1

h0 = PS(1)
h1 = (1 - qq) * G1
h2 = (1 - qq) * (1 - qq**2) * G2

D1_0 = h0
D1_1 = h1 - qq * h0
D1_2 = h2 - qq * h1

Q1 = D1_1  # = D_1^1

D2_1 = D1_1 - qq**2 * D1_0
D2_2 = D1_2 - qq**2 * D1_1

Q2 = D2_2

print(f"\nh_0 = {h0}")
print(f"h_1 = {h1.add_bigoh(20)}")
print(f"h_2 = {h2.add_bigoh(20)}")
print(f"D_1^1 = Q_1 = {Q1.add_bigoh(20)}")
print(f"D_1^2 = {D1_2.add_bigoh(20)}")
print(f"D_2^2 = Q_2 = {Q2.add_bigoh(20)}")
print(f"Q_2(1) = {sum(Q2[i] for i in range(25))}")

# Q_2(1) should be 4^2 = 16
# Wait, Q_1 = (1-q)*G_1 - q. But from the iterated difference:
# h_0 = 1, h_1 = (1-q)*G_1, D_1^1 = h_1 - q*h_0 = (1-q)*G_1 - q
# Yes, same thing.

