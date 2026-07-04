"""
Seed 7, Layer 2: Identify twisted affine algebras with dual Coxeter number.

For cylindric partitions with k=3 parts, modulus t = 3+d.
The Borodin product determines which residues mod t appear.
"""

print("Borodin product residue analysis for c = (3,2,2), d=7, t=10")
print("=" * 60)

# Borodin's formula:
# F_c(q) = 1/(q^t;q^t)_inf * prod_{i<j} prod_{m=1}^{c_i} 1/(q^{m+d_{i+1,j}+j-i}; q^t)_inf
#        * prod_{i>j} prod_{m=1}^{c_i} 1/(q^{t-(m+d_{j,i-1}+i-j)}; q^t)_inf
#
# where d_{i,j} = c_i + c_{i+1} + ... + c_j (for i <= j)
# k = 3, indices 1,2,3; profile c = (c_1, c_2, c_3) = (3, 2, 2)

c = [3, 2, 2]
k = 3
d_total = sum(c)  # 7
t = k + d_total  # 10

# Partial sums d_{i,j}
def d_ij(i, j, c):
    """Sum c_i + c_{i+1} + ... + c_j (1-indexed)"""
    return sum(c[a-1] for a in range(i, j+1))

print(f"c = {c}, k = {k}, d = {d_total}, t = {t}")
print()

# First product: i=1,...,k; j=i+1,...,k; m=1,...,c_i
# Exponent: m + d_{i+1,j} + j - i
print("First product (i < j):")
residues_first = []
for i in range(1, k+1):
    for j in range(i+1, k+1):
        d_val = d_ij(i+1, j, c) if i+1 <= j else 0
        for m in range(1, c[i-1]+1):
            exp = m + d_val + j - i
            res = exp % t
            residues_first.append(res)
            print(f"  i={i}, j={j}, m={m}: exp = {m} + {d_val} + {j-i} = {exp}, mod {t} = {res}")

print()

# Second product: i=2,...,k; j=2,...,i-1; m=1,...,c_i (only when i > 1 and j < i)
# Wait, the formula says i=2,...,k and j=2,...,i-1. For k=3:
# i=2: j from 2 to 1 -> empty
# i=3: j from 2 to 2 -> j=2
# Exponent: t - (m + d_{j,i-1} + i - j)
print("Second product (i > j, i >= 2):")
residues_second = []
for i in range(2, k+1):
    for j in range(2, i):  # j from 2 to i-1
        d_val = d_ij(j, i-1, c)
        for m in range(1, c[i-1]+1):
            exp = t - (m + d_val + i - j)
            res = exp % t
            residues_second.append(res)
            print(f"  i={i}, j={j}, m={m}: exp = {t} - ({m} + {d_val} + {i-j}) = {exp}, mod {t} = {res}")

print()

# Collect all residues
all_residues = residues_first + residues_second
print(f"All denominator residues mod {t}: {sorted(all_residues)}")
print(f"Multiplicity of each residue:")
from collections import Counter
counts = Counter(all_residues)
for r in range(1, t):
    if counts[r] > 0:
        print(f"  residue {r}: multiplicity {counts[r]}")

# Total number of (q^a; q^t) factors in denominator:
# From first product: sum_{i<j} c_i
# From second product: sum for valid (i,j) pairs c_i
total_first = sum(c[i-1] for i in range(1, k+1) for j in range(i+1, k+1))
total_second = sum(c[i-1] for i in range(2, k+1) for j in range(2, i))
print(f"\nTotal factors: first={total_first}, second={total_second}, plus (q^t;q^t) = {total_first + total_second + 1}")

print()
print("The denominator of F_c(q) is a product of factors (q^a; q^t)_inf^{-1}")
print("This should match the principally specialized character of an affine Lie algebra module.")
print()

# For an untwisted A_{t-1}^(1) = sl_t at level 1:
# The module V(Lambda_i) has character with denominator involving
# all residues 1, ..., t-1 mod t, each with multiplicity 1,
# EXCEPT for specific exclusions determined by the weight Lambda_i.

# Actually the principal specialization of the level-1 character of sl_t
# is 1/prod_{n>=1, n not equiv 0 mod t} (1-q^n).
# That's all residues 1,...,t-1 with multiplicity 1.
# And F_c(q) from Borodin has specific residues with specific multiplicities.

# The total number of distinct residues with multiplicity in Borodin's product
# should match the rank of the affine algebra.

# For A_{t-1}^(1) at level 1: rank = t-1, and we get t-1 distinct residues.
# Our Borodin product has: let's count distinct residues.

distinct_residues = set(all_residues)
print(f"Distinct residues: {sorted(distinct_residues)} ({len(distinct_residues)} total)")
print(f"Missing residues mod {t}: {sorted(set(range(1,t)) - distinct_residues)}")

# At level 1, we'd need t-1 = 9 factors (one for each nonzero residue mod 10).
# We have {total_first + total_second} factors plus 1 for (q^t;q^t).
# This is 7 + 1 = 8, but we need 10 for the full product 1/(q;q)_inf = 1/prod all residues.
# So F_c(q) * (q;q)_inf = (numerator product)

# Actually F_c(q) = 1/(q^t;q^t)_inf * prod 1/(q^a; q^t)_inf
# And (q;q)_inf = prod_{r=1}^{t} (q^r; q^t)_inf  (splitting by residue class mod t)
# Wait: (q;q)_inf = prod_{n>=1} (1-q^n) = prod_{r=0}^{t-1} (q^{r+1}; q^t)_inf ... no.
# Actually (q;q)_inf = prod_{n>=1}(1-q^n) = prod_{r=1}^t prod_{m>=0}(1-q^{r+mt})
# Hmm, for r=1,...,t-1 and r=t: (q^r;q^t)_inf for r=1,...,t.
# But (q^t;q^t)_inf is one of these (r=t).
# So (q;q)_inf = prod_{r=1}^t (q^r;q^t)_inf = (q^t;q^t)_inf * prod_{r=1}^{t-1} (q^r;q^t)_inf

# Therefore:
# F_c(q) * (q;q)_inf = [1/(q^t;q^t)] * prod_{a in S} 1/(q^a;q^t) * (q^t;q^t) * prod_{r=1}^{t-1} (q^r;q^t)
# = prod_{r=1}^{t-1} (q^r;q^t) / prod_{a in S} (q^a;q^t)
# = prod_{r not in S} (q^r;q^t) / prod_{a in S with mult > 1} (q^a;q^t)^{mult_a - 1}

# Hmm, this depends on multiplicities. Let me just compute.

print()
print("F_c(q) * (q;q)_inf analysis:")
print()

# The denominator of F_c(q) is: (q^t;q^t)_inf * prod_{a in residues} (q^a;q^t)_inf
# with multiplicities as counted above.

# F_c * (q;q)_inf = F_c * (q^t;q^t)_inf * prod_{r=1}^{t-1} (q^r;q^t)_inf

# The (q^t;q^t) cancels with the one in F_c's denominator.
# What remains in F_c's denominator: prod_{a in residues} (q^a;q^t)_inf (with mult)
# In the numerator from (q;q)_inf: prod_{r=1}^{t-1} (q^r;q^t)_inf

# Net: F_c * (q;q)_inf = prod_{r=1}^{t-1} (q^r;q^t)_inf / prod_{a with mult} (q^a;q^t)_inf^mult

# So residues NOT in the Borodin set appear in the NUMERATOR (theta-function part)
# Residues IN the Borodin set with mult m appear with net exponent 1-m

missing = sorted(set(range(1,t)) - distinct_residues)
print(f"Numerator residues (missing from Borodin): {missing}")
print(f"These form the 'theta function' part of the ASW identity")
print()

# The numerator residues for level-1 A_{t-1}^(1) character V(Lambda_i)
# are exactly {residues excluded from the product}, which correspond
# to the roots NOT in the Weyl orbit of Lambda_i.

# For the Andrews-Schilling-Warnaar identity, the product side is:
# F_c(q) * (q;q)_inf = prod_{r in missing} (q^r; q^t)_inf
# if all Borodin residues have multiplicity exactly 1.

print("Check: do all Borodin residues have multiplicity 1?")
for r in sorted(distinct_residues):
    m = counts[r]
    print(f"  residue {r}: mult {m}")
    if m > 1:
        print(f"    -> This residue appears with HIGHER multiplicity!")

all_mult_one = all(counts[r] == 1 for r in distinct_residues)
if all_mult_one:
    print()
    print("YES! All multiplicities are 1.")
    print(f"F_c(q) * (q;q)_inf = prod_{{r in {missing}}} (q^r; q^{t})_inf")
    print()
    print(f"This is a THETA FUNCTION product with {len(missing)} factors.")
    print(f"The missing residues mod {t} are: {missing}")
    print()

    # Identify the affine algebra from the theta function
    # For A_{N}^(1) at level 1, the character of V(Lambda_s) involves
    # the theta function with residues {s+1, N+1-s} mod (N+1)?
    # Actually it's more standard: for sl_t at level 1,
    # V(Lambda_s) has character = theta_{s,t} / eta(q)^{t-1}
    # where theta_{s,t} = sum_{n equiv s mod t} q^{n^2/2t} or similar.

    # The product form:
    # theta_{Lambda_s} involves factors (q^a; q^t) for a in a specific set
    # depending on s.

    # For sl_t, the principally specialized character of V(Lambda_0) is
    # 1 / prod_{n>=1, n not equiv 0 mod t} (1-q^n)
    # So F_c(q) * (q;q)_inf = prod_{r=1}^{t-1} (q^r; q^t) / prod_{r in Borodin} (q^r; q^t)
    # = prod_{r in missing} (q^r; q^t)

    # These "missing" residues form the Andrews-Gordon-Bressoud type identity.
    # The pattern of missing residues encodes which representation we're in.

    print(f"For t = {t}, the missing residues {missing} should match")
    print(f"the character formula of an affine Lie algebra module.")
    print()
    print(f"In the Rogers-Ramanujan / Andrews-Gordon framework:")
    print(f"  prod (q^a; q^t) for a in {missing} is a generalized theta function")
    print(f"  that appears as the numerator in the character of a level-1 module.")

# Now do the same for other profiles at d=7
print()
print("=" * 60)
print("Comparing profiles at d = 7")
print("=" * 60)

for profile in [(3,2,2), (4,2,1), (3,3,1), (5,1,1), (4,3,0), (6,1,0), (7,0,0)]:
    c = list(profile)
    if sum(c) != 7:
        continue

    residues = []
    for i in range(1, k+1):
        for j in range(i+1, k+1):
            d_val = d_ij(i+1, j, c) if i+1 <= j else 0
            for m in range(1, c[i-1]+1):
                exp = m + d_val + j - i
                res = exp % t
                residues.append(res)

    for i in range(2, k+1):
        for j in range(2, i):
            d_val = d_ij(j, i-1, c)
            for m in range(1, c[i-1]+1):
                exp = t - (m + d_val + i - j)
                res = exp % t
                residues.append(res)

    res_counts = Counter(residues)
    distinct = sorted(set(residues))
    missing = sorted(set(range(1,t)) - set(residues))
    all_one = all(res_counts[r] == 1 for r in distinct)

    print(f"\nc = {profile}: residues = {distinct}, missing = {missing}, all_mult_1 = {all_one}")
    if not all_one:
        for r in distinct:
            if res_counts[r] > 1:
                print(f"  residue {r}: mult {res_counts[r]}")
