# Now compare Q_n with KR crystal energy sums
# The hypothesis: Q_n(c) is related to the graded character of some Demazure 
# subcrystal of B(Lambda) for A_2^(1) at level d.

# KR crystal B^{1,d} for A_2^(1) has elements = semistandard tableaux of shape (d)
# with entries in {1,2,3}. These correspond bijectively to profiles (c_0,c_1,c_2)
# where c_i = #{entries equal to i+1}.

# The Kyoto path model: paths of length n in B^{1,d} with matching conditions.
# Path: ... tensor b_3 tensor b_2 tensor b_1
# Ground state: ... tensor b_gs tensor b_gs tensor b_gs
# where b_gs depends on the highest weight Lambda.

# The energy function D(path) = sum of local energies H(b_{k+1} tensor b_k)

# For the TRUNCATED path (length n): p = b_n tensor ... tensor b_1
# This is an element of B^{1,d}^{tensor n}

# The 1d configuration sum:
# X_n(Lambda, mu, q) = sum over truncated paths p ending at weight mu of q^{D(p)}

# I need to identify:
# (a) What Lambda corresponds to profile c
# (b) What mu corresponds to the "final state"
# (c) Whether D matches the degree grading of Q_n

# Key observation from Tingley:
# The profile c determines Lambda via Definition 4.11 (Lambdab):
# Lambda = sum m_i Lambda_i where m_i counts boundary conditions

# For our r=3, d=2 case: n_Tingley = 3, ell_Tingley = 3 (wait, no)
# Actually: in Tingley's notation, cylindric partitions of type (n, ell)
# where n = rank of sl_n = 3 and ell = number of rows of abacus = d
# No wait: Tingley has the cylinder determined by (n, ell) where
# the periodicity is pi_{ij} = pi_{i+ell, j-n}
# 
# In our problem: c = (c_0, c_1, c_2), d = sum(c), t = d+3 = circumference
# The cylinder has: 3 partitions with cyclic interlacing
# In Tingley's framework: this is type (n, ell) = (3, d)? Or (d, 3)?
# 
# Looking at Tingley's Definition 4.3: type (n, ell) means
# pi_{ij} = pi_{i+ell, j-n}
# The boundary of the cylinder is determined by the abacus compactification
# which encodes the profile.

# For our problem with r=3 partitions and profile c = (c_0, c_1, c_2):
# We have ell = 3 rows on the abacus, colored with colors 0,1,...,n-1
# where n = number of entries per row = d (??? need to check)

# Actually in Tingley: 
# "An abacus consists of ell rows with n colors (labeled 0,...,n-1)"
# "A cylindric plane partition of type (n, ell)"
# In the context of sl_n-hat at level ell

# So for A_2^(1) = sl_3-hat: n = 3
# Level = ell = number of rows of abacus
# For our problem: we have 3 partitions (= 3 rows on abacus? = ell = 3?)
# And d = sum of profile determines... what?

# Let me re-read more carefully. In Tingley, the abacus has ell rows,
# each row is colored with period n (colors 0,...,n-1 repeating).
# The compactification has charges (c_0,...,c_{ell-1}).
# 
# The cylindric partition has type (n, ell), meaning periodicity 
# pi_{ij} = pi_{i+ell, j-n}.
#
# In our problem: profile c = (c_0, c_1, c_2) with 3 components
# The CP has 3 partitions with cyclic interlacing of shifts c_i
# The cylinder circumference is t = d + 3 where d = sum(c_i)
#
# Mapping to Tingley: ell = 3 (rows), n = t/gcd(t,...) ... hmm
# Actually: circumference t = d+3 = n_Tingley + ell_Tingley
# But t = d + 3, ell = 3, so n_Tingley = d? Or n_Tingley = 3?
#
# The key: our CP has profile c = (c_0, c_1, c_2)
# In Tingley's abacus model with ell rows:
# The ell-th row is a shift of the first, etc.
# The charges of the compactification are the c_i
# 
# For sl_n-hat crystals at level ell:
# n = rank parameter of sl_n, ell = level
# The perfect crystal B^{1,ell} has elements = SSYT of shape (ell) with n entries
# = binom(ell+n-1, n-1) elements
#
# For our problem: 
# The number of profiles = binom(d+2, 2)
# If we set n = 3 (for A_2^(1)) and ell = d (level d):
# B^{1,d} has binom(d+2, 2) elements ✓ (matches!)
# This is the correct identification: sl_3-hat at level d

# So: A_2^(1) at level d, perfect crystal B^{1,d}
# Abacus: d rows, 3 colors (0,1,2)
# Wait, but our profile has 3 components. If ell = d, the abacus has d rows.
# The profile c = (c_0, c_1, c_2) is NOT the charge of the abacus rows.
# 
# Hmm. Let me re-examine. Actually I think the identification goes:
# For r-row cylindric partitions with profile c = (c_0,...,c_{r-1}):
# sl_r-hat at level d (where d = sum c_i)
# Abacus has d rows, r colors
# B^{1,d} for sl_r has binom(d+r-1, r-1) elements = number of profiles ✓

# Under this identification:
# n_Tingley = r = 3 (for our r=3 case)
# ell_Tingley = d (level)
# The cylinder type is (3, d), circumference = 3 + d = t ✓

# Now, the highest weight Lambda for profile c:
# From Tingley Def 4.11: Lambda = sum m_i Lambda_i
# where m_i counts certain boundary conditions.
# 
# The charges of the d-row abacus are determined by c.
# But the relationship between the 3-component profile c and 
# the d-component abacus charges needs to be worked out.

# Actually, I think I've been confusing two things.
# Let me approach computationally: just compute with SageMath's KR crystals.

print("=== KR crystal B^{1,d} for A_2^(1) ===")

# For sl_3-hat = A_2^(1), KR crystal B^{1,s} has elements that are 
# semistandard tableaux of shape (s) with entries in {1,2,3}

for d in [2, 4]:
    K = crystals.KirillovReshetikhin(['A', 2, 1], 1, d)
    print(f"\nB^{{1,{d}}} has {K.cardinality()} elements:")
    
    # Map each element to a profile (count of 1's, 2's, 3's)
    elem_to_profile = {}
    for b in K:
        tab = list(b.to_tableau())[0]  # first (only) row
        profile = (tab.count(1), tab.count(2), tab.count(3))
        elem_to_profile[b] = profile
        print(f"  {b} -> profile {profile}")

print()

# The ground state path depends on Lambda.
# For Lambda = d*Lambda_0: ground state = b such that phi(b) = Lambda
# phi_i(b) = max number of times f_i can be applied

# Let's compute epsilon and phi for all elements
print("=== epsilon and phi for B^{1,2} ===")
K2 = crystals.KirillovReshetikhin(['A', 2, 1], 1, 2)
for b in K2:
    eps = tuple(b.epsilon(i) for i in [0,1,2])
    phi = tuple(b.phi(i) for i in [0,1,2])
    tab = list(b.to_tableau())[0]
    profile = (tab.count(1), tab.count(2), tab.count(3))
    print(f"  {b}: profile={profile}, eps={eps}, phi={phi}")

# Ground state for Lambda = 2*Lambda_0:
# Need phi(b) = (2,0,0), i.e. phi_0=2, phi_1=0, phi_2=0
# That's [[3,3]] since f_0 changes 3 to 1

# Ground state for Lambda = Lambda_0 + Lambda_1:
# Need phi(b) = (1,1,0)

# Ground state for Lambda = 2*Lambda_1:
# Need phi(b) = (0,2,0)

# Now compute 1d configuration sums
print("\n=== 1d Configuration Sums for B^{1,2} ===")

# For tensor product B^{1,2}^{tensor n}, paths p = (b_1,...,b_n)
# with matching condition eps(b_k) = phi(b_{k+1}) and phi(b_1) = Lambda
# Energy D(p) = sum_{k=1}^{n-1} H(b_{k+1} tensor b_k)

# The energy H on B^{1,2} tensor B^{1,2}:
# H(b1 tensor b2) = number of winding pairs in combinatorial R-matrix

T2 = crystals.TensorProduct(K2, K2)

# Get energy function H values
from collections import defaultdict
print("\nEnergy matrix H(b1 tensor b2):")
energy_H = {}
for b1 in K2:
    for b2 in K2:
        # Find b1 tensor b2 in T2
        t = T2(b1, b2)
        try:
            e = t.energy_function()
            energy_H[(b1, b2)] = e
        except:
            energy_H[(b1, b2)] = '?'

for b1 in K2:
    tab1 = list(b1.to_tableau())[0]
    p1 = (tab1.count(1), tab1.count(2), tab1.count(3))
    row = []
    for b2 in K2:
        row.append(energy_H.get((b1, b2), '?'))
    print(f"  {p1}: {row}")

# Now compute X_n(Lambda, q) = sum over valid paths of q^{energy}
# Path: (b_1, ..., b_n) in B^{1,2}^n
# Matching: eps(b_k) = phi(b_{k+1}) for k=1,...,n-1
# Starting: phi(b_1) = Lambda (or some condition)

# Actually, in the Kyoto path model, the paths are semi-infinite:
# ... b_3 tensor b_2 tensor b_1, truncated to length n.
# The truncated path just takes b_1,...,b_n with no matching condition
# beyond b_n.

# The 1d configuration sum is typically:
# X_n(Lambda, mu, q) = sum over (b_1,...,b_n) with 
#   phi(b_1) = Lambda (right boundary)
#   wt(b_n) = mu (left boundary, or just sum of all weights)
#   q^{sum H(b_{k+1} tensor b_k)}

# But actually, the bounded CP generating function F_{c,n}(q) is:
# F_{c,n}(q) = sum over CPs of profile c with max <= n of q^|Lambda|
#            = some truncated character

# From Tingley Thm 4.13:
# weight(CP) = principal grading of crystal element + n_Tingley * |partition|
# = principal grading of crystal element + 3 * |lambda(pi)|

# For BOUNDED CPs with max <= n, the crystal element is in a finite subcrystal
# and the partition lambda(pi) has parts <= n (? need to check)

# Let me try: does the 1d config sum match F_{c,n} or Q_n?

# 1d config sum X_n for B^{1,2}, tensor of n copies:
R.<q> = PowerSeriesRing(ZZ, default_prec=100)

K = K2
elems = list(K)

for n_val in [1, 2, 3]:
    print(f"\n--- Tensor product B^{{1,2}}^{{{n_val}}} ---")
    
    if n_val == 1:
        # Just q^0 for each element = 6
        print(f"  Total (no energy): {len(elems)}")
        for b in elems:
            tab = list(b.to_tableau())[0]
            p = (tab.count(1), tab.count(2), tab.count(3))
            print(f"  Profile {p}: {R(1)}")
    elif n_val == 2:
        # sum over (b1, b2) of q^{H(b2, b1)}
        # grouped by profile of the "final" element
        from collections import defaultdict
        sums = defaultdict(lambda: R(0))
        
        for b1 in elems:
            for b2 in elems:
                tab = list(b1.to_tableau())[0]
                final_profile = (tab.count(1), tab.count(2), tab.count(3))
                
                h = energy_H.get((b2, b1), 0)
                if isinstance(h, str):
                    continue
                sums[final_profile] += q^h
        
        print(f"  Grouped by profile of b1 (right end):")
        for p in sorted(sums.keys()):
            print(f"    Profile {p}: {sums[p] + O(q^20)}")
            print(f"      Sum at q=1: {sums[p].polynomial()(1)}")

