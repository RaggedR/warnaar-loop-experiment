# Key insight: the factor (zq;q)_inf in the Q_n definition looks like a 
# Weyl denominator. In the A_2^(1) context at level d:
#
# The principally specialized character of V(Lambda) is:
# ch_q(V(Lambda)) = sum_{b in B(Lambda)} q^{deg(b)}
#
# And Tingley shows: the partition function for cylindric partitions of profile c is
# F_c(q) = ch_q(V(Lambda)) / (q^n;q^n)_inf  (Theorem 4.14)
# where n = 3 in our case.
#
# Specifically: sum_{pi in CP(c)} q^{|pi|} = ch_q(V(Lambda)) / (q^3;q^3)_inf
# The factor 1/(q^3;q^3)_inf accounts for the partition lambda(pi) in V_Lambda tensor F.
#
# But this is the UNRESTRICTED generating function F_c(q) = lim_{n->inf} F_{c,n}(q).
# What about the BOUNDED version F_{c,n}(q)?
#
# Bounded CPs with max <= n correspond to abacus configs where
# the beads haven't moved more than n steps from the compactification.
# In the Kyoto path model, this means paths of length <= n.
#
# In the V_Lambda tensor F decomposition:
# A CP pi maps to (v(pi), lambda(pi)) where v(pi) in B_Lambda and lambda(pi) is a partition.
# The weight is: deg(v(pi)) + 3*|lambda(pi)|.
#
# If max(pi) = m, then lambda(pi) has at most m parts (each <= m).
# Actually, lambda(pi) is determined by how much the abacus differs from the tight config.
#
# The BOUNDED generating function is:
# F_{c,n}(q) = sum_{(v,lambda): max condition} q^{deg(v) + 3*|lambda|}
#
# And Q_{n,c}(q) = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
# = (q;q)_n * sum_k c_k g_{n-k}
#
# The (zq;q)_inf factor removes the partition component!
# Specifically, if F_c(z,q) = sum_m z^m * sum_{(v,lambda): max=m} q^{deg(v)+3|lambda|}
# and (zq;q)_inf "kills" the partition part, then we'd get the crystal character.
#
# More precisely: the unrestricted result is
# (zq;q)_inf * F_c(z,q) = (zq;q)_inf * ch_q(V_Lambda) * ??(z,q)
# where the ?? accounts for the z-grading and partition part.
#
# Let me think about this differently.
# From Tingley: each CP of max = m corresponds to (v, lambda) in B_Lambda x P
# with deg(v) + 3|lambda| = |pi|.
# The max = m condition on pi translates to some condition on (v, lambda).
# 
# KEY QUESTION: What is max(pi) in terms of (v, lambda)?
# From Tingley's construction: the abacus config psi has tight part gamma(psi) 
# and partition lambda(psi). The CP pi(psi) has entries pi_{ij} = number of beads
# to the right of the (j-p_i+1)-th white bead.
#
# The max entry max(pi) is the maximum number of beads to the right of any white bead.
# This depends on both gamma(psi) (the crystal element) and lambda(psi).
#
# For the COMPACTIFIED (tight) config gamma: max(pi(gamma)) = some function of gamma
# (could be 0 for the highest weight element).
# Adding the partition lambda shifts the beads further right, increasing max.
# Specifically, lambda(psi) = (lambda_1 >= lambda_2 >= ...) and each part corresponds
# to shifting a column of beads by that many steps.
#
# So max(pi) = max(pi(gamma)) + lambda_1 (largest part of lambda).
#
# Wait, that's not quite right. Let me think more carefully.
# If gamma is tight (all beads as far left as possible), then the CP pi(gamma)
# has max = 0 (all entries are 0).
# No wait -- tight doesn't mean max = 0. The tight config has beads in their
# "ground state" positions, and the CP entries reflect the actual bead positions.
#
# Let me reconsider. For the GROUND STATE (highest weight element):
# All beads are in the compactification, which has specific positions.
# The CP for the ground state has max = 0? Not necessarily.
# 
# Actually, from the definition: pi_{ij} = number of black beads to the right
# of the (j-p_i+1)th white bead of psi_i. For the compactification, all black
# beads are to the left of all white beads, so pi_{ij} = 0 for all valid (i,j).
# So yes, max(pi(compactification)) = 0.
#
# For a general tight config gamma: the crystal operators f_i move one bead
# one step to the right. Each application increases the CP max by at most 1.
# Actually, applying f_i moves one bead past one white bead, so max increases by 1
# in that column. But globally, max(pi) = max over all columns.
#
# The key formula from Tingley Thm 4.13:
# |pi| = deg(v(pi)) + 3*|lambda(pi)|
#
# And max(pi) = ??? Let me just compute for d=2.

# For d=2, A_2^(1), B^{1,2}:
# B(Lambda) is the infinite crystal. Elements of B_Lambda correspond to tight configs.
# Each tight config gamma gives a CP pi(gamma) with max = depth of gamma in the crystal.

# Actually, I realize: max(pi) in Tingley's setup equals the "length" of the
# Kyoto path -- how many positions differ from the ground state.
# For a truncated path of length <= n, max(pi) <= n.

# So: CPs with max <= n biject to pairs (path of length n in B^{1,d}, partition)
# where... hmm no, the partition lambda(pi) also contributes to max.

# Let me compute directly.

# In the Kyoto path model for B^{1,2}:
# Ground state for Lambda = 2*Lambda_0: b_gs = [[3,3]] (phi = (2,0,0))
# eps(b_gs) = (0,0,2) = phi of next: phi(b_{k+1}) = eps(b_k) = phi(b_gs) for ground state
# So b_{k+1} must satisfy phi(b_{k+1}) = (0,0,2), which means b_{k+1} = [[3,3]] as well.
# Ground state path: ...[[3,3]][[3,3]][[3,3]]

# A path of length n: (b_n,...,b_1) in B^{1,2}^n
# Matching: eps(b_k) = phi(b_{k+1}) for k=1,...,n-1
# AND phi(b_1) = Lambda_{reduced} ... actually no specific condition on phi(b_1)?

# In the Kyoto model, paths that differ from ground state in finitely many places
# form the crystal B(Lambda). For TRUNCATED paths of length n:
# p = (b_n,...,b_1) with b_k = b_gs for k > n (all further positions are ground state)
# Matching: eps(b_k) = phi(b_{k+1})
# For k >= n: eps(b_gs) = (0,0,2) and phi(b_gs) = (2,0,0)... these don't match!
# Wait, for the GROUND STATE to be a valid path, we need eps(b_gs) = phi(b_gs).
# But eps([[3,3]]) = (0,0,2) and phi([[3,3]]) = (2,0,0). These are NOT equal!

# This means the ground state path does NOT have b_k = b_{k+1} for consecutive k.
# It's a periodic sequence, not constant!

# From Tingley: the ground state path is p_Lambda = ... tensor b_3 tensor b_2 tensor b_1
# with phi(b_1) = Lambda and eps(b_k) = phi(b_{k+1}).

# For Lambda = 2*Lambda_0:
# phi(b_1) = (2,0,0) -> b_1 = [[3,3]] (only element with phi_0 = 2)
# eps(b_1) = (0,0,2) -> phi(b_2) = (0,0,2) -> b_2 = [[2,2]] 
# eps(b_2) = (0,2,0) -> phi(b_3) = (0,2,0) -> b_3 = [[1,1]]
# eps(b_3) = (2,0,0) -> phi(b_4) = (2,0,0) -> b_4 = [[3,3]]
# Period 3! Ground state = ...[[3,3]][[2,2]][[1,1]][[3,3]][[2,2]][[1,1]]...

K = crystals.KirillovReshetikhin(['A', 2, 1], 1, 2)
elems = list(K)
R.<q> = PowerSeriesRing(ZZ, default_prec=100)

# Build eps/phi lookup
eps_map = {}
phi_map = {}
for b in elems:
    eps_map[b] = tuple(b.epsilon(i) for i in [0,1,2])
    phi_map[b] = tuple(b.phi(i) for i in [0,1,2])

# Find ground state path for each Lambda
# The level-2 dominant weights for A_2^(1) are:
# 2*Lambda_0, Lambda_0+Lambda_1, Lambda_0+Lambda_2, 2*Lambda_1, Lambda_1+Lambda_2, 2*Lambda_2

# These correspond to the 6 profiles (compositions of 2 into 3 parts)
# Lambda_i = (0,...,0,1,0,...,0) with 1 in position i

# For Lambda = c_0*Lambda_0 + c_1*Lambda_1 + c_2*Lambda_2:
# phi(b_1) = (c_0, c_1, c_2)

print("=== Ground state paths for level 2, A_2^(1) ===")
for Lambda_profile in [(2,0,0), (1,1,0), (0,2,0), (1,0,1), (0,1,1), (0,0,2)]:
    # Find b_1 with phi = Lambda_profile
    b1 = None
    for b in elems:
        if phi_map[b] == Lambda_profile:
            b1 = b
            break
    
    if b1 is None:
        print(f"  Lambda = {Lambda_profile}: no b_1 found!")
        continue
    
    # Build ground state path
    path = [b1]
    cur = b1
    for step in range(5):
        next_phi = eps_map[cur]
        next_b = None
        for b in elems:
            if phi_map[b] == next_phi:
                next_b = b
                break
        if next_b is None:
            break
        path.append(next_b)
        cur = next_b
    
    path_profiles = [elem_to_profile(b) for b in path]
    print(f"  Lambda = {Lambda_profile}: ground state path profiles = {path_profiles}")

def elem_to_profile(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

for Lambda_profile in [(2,0,0), (1,1,0), (0,0,2)]:
    b1 = None
    for b in elems:
        if phi_map[b] == Lambda_profile:
            b1 = b
            break
    path = [b1]
    cur = b1
    for step in range(8):
        next_phi = eps_map[cur]
        next_b = None
        for b in elems:
            if phi_map[b] == next_phi:
                next_b = b
                break
        path.append(next_b)
        cur = next_b
    path_p = [elem_to_profile(b) for b in path]
    print(f"\nGround state for Lambda={Lambda_profile}: {path_p}")

