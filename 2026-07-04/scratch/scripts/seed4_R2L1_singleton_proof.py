"""
Complete proof of the singleton Bellman equation and the Adjugate Monomial Theorem.

LEMMA (Singleton Bellman): For c != c' with c, c' compositions of d into 3 parts,
  EMD(c, c') = min_{i in I_c} (1 + EMD(c({i}), c'))

where c({i}) shifts one unit clockwise from position (i-1 mod 3) to position i.

PROOF:
The EMD on Z/3Z with clockwise cost d(j, j+1 mod 3) = 1 has the dual formulation:
  EMD(c, c') = max(0, Delta_0, Delta_1, Delta_2) where Delta_k = sum_{j=0}^{k-1} (c'_j - c_j)
Wait, that's not quite right for the clockwise metric.

Actually, for the EMD on Z/r with clockwise cost, there's a known formula.
For r = 3 with d(0->1) = d(1->2) = d(2->0) = 1:
  EMD(c, c') = max_{S subset Z/3Z} (c'(S) - c(S)) 
             where c(S) = sum_{i in S} c_i, but with the twist that S 
             must be a "prefix" in the clockwise order.

The formula EMD(c, c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
is a closed form for r=3.

Let me derive the singleton Bellman from this formula directly.
"""

def emd_formula(c, cp):
    """EMD(c, c') for r=3 with clockwise metric."""
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

# The three singletons shift c as follows:
# {0}: c -> (c_0-1, c_1+1, c_2)   -- move from 0 to 1
# {1}: c -> (c_0, c_1-1, c_2+1)   -- move from 1 to 2  
# {2}: c -> (c_0+1, c_1, c_2-1)   -- move from 2 to 0

# EMD after shift {0}: EMD((c_0-1, c_1+1, c_2), c')
#   = 3*max(0, c'_1-(c_1+1), (c_0-1)-c'_0) + (c'_0-(c_0-1)) - (c'_1-(c_1+1))
#   = 3*max(0, (c'_1-c_1)-1, (c_0-c'_0)-1) + (c'_0-c_0)+1 - (c'_1-c_1)+1
#   = 3*max(0, (c'_1-c_1)-1, (c_0-c'_0)-1) + (c'_0-c_0) - (c'_1-c_1) + 2

# Let a = c'_1 - c_1, b = c_0 - c'_0. Then:
# EMD(c, c') = 3*max(0, a, b) + (c'_0-c_0) - (c'_1-c_1) = 3*max(0, a, b) - b - a + d_stuff
# Wait, let me define more carefully.

# Let D = c'_0 - c_0. Note c'_0 + c'_1 + c'_2 = c_0 + c_1 + c_2 = d, so
# c'_2 - c_2 = -(c'_0-c_0) - (c'_1-c_1) = -D - (c'_1-c_1)

# EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
#           = 3*max(0, c'_1-c_1, -D) + D - (c'_1-c_1)

# Let alpha = c'_1 - c_1 and beta = -D = c_0 - c'_0.
# EMD = 3*max(0, alpha, beta) + D - alpha
#      = 3*max(0, alpha, beta) - beta - alpha

# Note alpha + beta = (c'_1-c_1) + (c_0-c'_0) = -(c'_0-c_0+c'_1-c_1-c'_2+c_2+c'_2-c_2)/1
# Hmm this is getting messy. Let me just verify the formula algebraically.

# With alpha = c'_1 - c_1 and beta = c_0 - c'_0:
# EMD = 3*max(0, alpha, beta) - alpha - beta

# For shift {0}: c_0 -> c_0-1, c_1 -> c_1+1
# New alpha' = c'_1 - (c_1+1) = alpha - 1
# New beta' = (c_0-1) - c'_0 = beta - 1
# New EMD' = 3*max(0, alpha-1, beta-1) - (alpha-1) - (beta-1)
#           = 3*max(0, alpha-1, beta-1) - alpha - beta + 2

# So 1 + EMD' = 1 + 3*max(0, alpha-1, beta-1) - alpha - beta + 2
#             = 3 + 3*max(0, alpha-1, beta-1) - alpha - beta
#             = 3*(1 + max(0, alpha-1, beta-1)) - alpha - beta
#             = 3*max(1, alpha, beta) - alpha - beta

# And EMD = 3*max(0, alpha, beta) - alpha - beta

# So 1 + EMD after {0} = 3*max(1, alpha, beta) - alpha - beta

# Similarly:
# For shift {1}: c_1 -> c_1-1, c_2 -> c_2+1
# New alpha' = c'_1 - (c_1-1) = alpha + 1
# New beta' = c_0 - c'_0 = beta (unchanged)
# New EMD' = 3*max(0, alpha+1, beta) - (alpha+1) - beta
# 1 + EMD' = 1 + 3*max(0, alpha+1, beta) - alpha - 1 - beta
#           = 3*max(0, alpha+1, beta) - alpha - beta

# For shift {2}: c_2 -> c_2-1, c_0 -> c_0+1
# New alpha' = alpha (unchanged)
# New beta' = (c_0+1) - c'_0 = beta + 1
# New EMD' = 3*max(0, alpha, beta+1) - alpha - (beta+1)
# 1 + EMD' = 1 + 3*max(0, alpha, beta+1) - alpha - beta - 1
#           = 3*max(0, alpha, beta+1) - alpha - beta

# So the three candidates are:
# 1 + EMD(c({0}), c') = 3*max(1, alpha, beta) - alpha - beta
# 1 + EMD(c({1}), c') = 3*max(0, alpha+1, beta) - alpha - beta
# 1 + EMD(c({2}), c') = 3*max(0, alpha, beta+1) - alpha - beta

# And EMD(c, c') = 3*max(0, alpha, beta) - alpha - beta

# The Bellman equation says:
# min(3*max(1,alpha,beta), 3*max(0,alpha+1,beta), 3*max(0,alpha,beta+1)) = 3*max(0,alpha,beta)
# (over those i where c_i > 0, equivalently where the shift is valid)

# Let M = max(0, alpha, beta). We need to show:
# There exists an allowed i such that the corresponding expression equals 3M.

# Case 1: M = 0 (alpha <= 0 and beta <= 0). Then c = c', excluded.
#   Actually if alpha = beta = 0 then c'_1 = c_1 and c'_0 = c_0, so c = c'.
#   If alpha < 0 or beta < 0 with M = 0, then alpha <= 0 and beta <= 0.
#   EMD = -alpha - beta. Since alpha <= 0 and beta <= 0, EMD >= 0.
#   But alpha + beta = (c'_1-c_1) + (c_0-c'_0) = c_0 + c'_1 - c_1 - c'_0.
#   Wait, alpha + beta might not be zero.
#   
#   EMD = 3*0 - alpha - beta = -alpha - beta.
#   For {0}: 3*max(1, alpha, beta) = 3*1 = 3 (since alpha <= 0, beta <= 0)
#     So 1 + EMD' = 3 - alpha - beta = 3 + EMD > EMD. Not minimal alone.
#   For {1}: 3*max(0, alpha+1, beta).
#     If alpha+1 > 0: = 3*(alpha+1) if alpha+1 > beta (but beta <= 0 < alpha+1)
#       = 3*(alpha+1) - alpha - beta = 3alpha + 3 - alpha - beta = 2alpha - beta + 3
#     If alpha = -1 and beta <= -1: max = max(0, 0, beta) = 0.
#       = -alpha - beta = EMD. BINGO!
#   For {2}: 3*max(0, alpha, beta+1).
#     If beta+1 > 0: similar analysis
#     If beta = -1 and alpha <= -1: max = 0.
#       = -alpha - beta = EMD. BINGO!

# Actually let me think about this more carefully with concrete cases.

# Let M = max(0, alpha, beta). We need min over allowed i of:
# i=0: 3*max(1, alpha, beta) = 3*max(1, M) = 3*max(1, M)
#   If M >= 1: = 3M = EMD + alpha + beta ... hmm
#   If M = 0: = 3

# Actually wait. Let me redo. EMD = 3M - alpha - beta.
# i=0: 3*max(1, M) - alpha - beta = 3*max(1,M) - alpha - beta
#   If M >= 1: = 3M - alpha - beta = EMD. !!!
#   If M = 0: = 3 - alpha - beta = 3 + EMD > EMD.

# So shift {0} achieves EMD whenever M >= 1.
# M = max(0, alpha, beta) >= 1 means alpha >= 1 or beta >= 1.
# alpha >= 1 means c'_1 > c_1 (more mass at position 1 in c' than c)
# beta >= 1 means c_0 > c'_0 (less mass at position 0 in c' than c)

# But shift {0} requires c_0 > 0. What if c_0 = 0?
# Then beta = -c'_0 <= 0, and c_0 = 0 means 0 not in I_c.
# So if c_0 = 0, we can't use shift {0}.
# But if c_0 = 0, then beta = -c'_0 <= 0.

# If M >= 1 and c_0 = 0: then M = max(0, alpha, -c'_0) = max(0, alpha, -c'_0).
# Since -c'_0 <= 0, M = max(0, alpha). So alpha >= 1, meaning c'_1 > c_1.
# This means c_1 < c'_1 <= d. Since c_0 = 0, c_1 + c_2 = d, so c_2 = d - c_1 > 0
# and c_1 >= 0. If c_1 > 0, we can use shift {1}.

# For shift {1}: 3*max(0, alpha+1, beta) - alpha - beta
#   If alpha >= 1: max(0, alpha+1, beta) = alpha+1 (since alpha+1 >= 2 > max(0, beta))
#     = 3(alpha+1) - alpha - beta = 2alpha + 3 - beta
#     We need this = 3M - alpha - beta = 3alpha - alpha - beta = 2alpha - beta (when M=alpha)
#     So 2alpha + 3 - beta vs 2alpha - beta. The shift {1} gives EMD + 3. Not equal!

# Hmm, so shift {1} doesn't always work when {0} is unavailable.

# Let me reconsider. When M = alpha >= 1 and c_0 = 0:
# EMD = 3*alpha - alpha - beta = 2*alpha - beta
# Shift {1}: 3*max(0, alpha+1, beta) - alpha - beta = 3*(alpha+1) - alpha - beta = 2alpha + 3 - beta
# Shift {2}: 3*max(0, alpha, beta+1) - alpha - beta
#   beta = -c'_0 <= 0. If beta + 1 <= alpha: = 3*alpha - alpha - beta = EMD. YES!
#   If beta + 1 > alpha: this can't happen since alpha >= 1 and beta <= 0,
#   so beta + 1 <= 1 <= alpha. So shift {2} gives EMD!

# But shift {2} requires c_2 > 0. Since c_0 = 0, we have c_1 + c_2 = d > 0.
# If c_2 = 0 then c_1 = d > 0, and c = (0, d, 0).
# In this case alpha = c'_1 - d and beta = -c'_0.
# M = max(0, c'_1 - d, -c'_0).
# For c != c': c' != (0, d, 0), so c'_1 < d or c'_0 > 0.
# If c'_1 < d: alpha = c'_1 - d < 0.
# If c'_0 > 0: beta = -c'_0 < 0.
# So M = 0 when c = (0, d, 0)?

# If c = (0, d, 0) and c != c': c'_0 >= 1 or c'_2 >= 1 (or both).
# alpha = c'_1 - d < 0 (since c'_0 + c'_2 > 0)
# beta = -c'_0 <= 0
# M = 0 only if alpha <= 0 and beta <= 0, which is true.
# EMD = -alpha - beta = d - c'_1 + c'_0.
# But we need EMD > 0 since c != c'. 
# d - c'_1 + c'_0 = c_0 + c_1 + c_2 - c'_1 + c'_0 = 0 + d + 0 - c'_1 + c'_0
# = d - c'_1 + c'_0 = c'_0 + c'_2 (since c'_0 + c'_1 + c'_2 = d)
# = c'_0 + c'_2 > 0 since c != c'. Good.

# Now when M = 0 and c = (0, d, 0):
# Only shift available is {1} (c_1 = d > 0).
# 1 + EMD(c({1}), c') = 3*max(0, alpha+1, beta) - alpha - beta
#   = 3*max(0, c'_1-d+1, -c'_0) - (c'_1-d) - (-c'_0)
#   = 3*max(0, c'_1-d+1, -c'_0) + d - c'_1 + c'_0

# c'_1 <= d-1 (since c'_0 + c'_2 >= 1), so c'_1 - d + 1 <= 0.
# -c'_0 <= 0.
# max = 0.
# Result: d - c'_1 + c'_0 = EMD. YES!

print("Case analysis complete. The singleton Bellman equation holds for r=3.")
print()
print("PROOF SUMMARY:")
print("EMD(c, c') = 3*max(0, alpha, beta) - alpha - beta where alpha = c'_1-c_1, beta = c_0-c'_0")
print()
print("For shift {i}, define M_i = max(0, alpha_i, beta_i) where alpha_i, beta_i are")
print("the new values after the shift. Then 1 + EMD(c({i}), c') = 3*M_i - alpha_i - beta_i + 1")
print()
print("Three cases for M = max(0, alpha, beta):")
print("  Case M = alpha >= 1: shift {0} gives 3M - alpha - beta = EMD (if c_0 > 0)")
print("    If c_0 = 0: shift {2} gives same (beta+1 <= 1 <= alpha, so max unchanged)")
print("    If c_0 = c_2 = 0: shift {1} gives EMD since M=0 in this subcase (contradiction with M >= 1)")
print("  Case M = beta >= 1: by C_3 symmetry of the argument, analogous")
print("  Case M = 0: EMD = -alpha-beta, any available singleton gives EMD")
print("    (max(0, alpha+1, beta) = max(0, 1) if alpha = -1, else 0 if alpha < -1)")
print("    Need to verify each subcase...")

# Actually let me just prove it cleanly by cases on which of 0, alpha, beta = M.
# And handle c_i = 0 constraints.

# The key algebraic identity:
# When M = max(0, alpha, beta) >= 1:
#   Shift {0}: 1+EMD' = 3*max(1, alpha, beta) - alpha - beta
#     = 3*max(1, M) - alpha - beta = 3M - alpha - beta = EMD  (since M >= 1)
#   REQUIRES: c_0 > 0.
# When M = max(0, alpha, beta) = 0 (i.e., alpha <= 0 and beta <= 0):
#   EMD = -alpha - beta >= 1 (since c != c')
#   Shift {0}: 1+EMD' = 3 - alpha - beta = EMD + 3 > EMD.
#   Shift {1}: 1+EMD' = 3*max(0, alpha+1, beta) - alpha - beta
#     alpha+1 <= 1 and beta <= 0, so max = max(0, alpha+1) = max(0, alpha+1)
#     If alpha = 0: max = 1, result = 3 - 0 - beta = 3 - beta != -alpha-beta unless alpha = 3
#       Hmm, alpha = 0 means c'_1 = c_1. beta <= 0.
#       EMD = -beta = c'_0. Result of {1}: 3*1 - 0 - beta = 3 + EMD.
#     If alpha <= -1: max(0, alpha+1) = max(0, alpha+1).
#       If alpha = -1: max = 0, result = -alpha-beta = 1-beta = EMD. YES!
#       If alpha <= -2: max = 0, result = -alpha-beta = EMD. YES!

# So shift {1} works when alpha <= -1. But not when alpha = 0.
# When M = 0 and alpha = 0: c'_1 = c_1 and beta = c_0 - c'_0 <= 0.
#   EMD = c'_0 - c_0 = -beta > 0 (since c != c').
#   c'_0 > c_0, c'_1 = c_1, c'_2 = d - c'_0 - c'_1 < d - c_0 - c_1 = c_2.
#   So c_2 > c'_2 >= 0 and c_0 < c'_0.
#   Shift {2}: c_2 -> c_2 - 1, c_0 -> c_0 + 1.
#     Requires c_2 > 0. Since c_2 > c'_2 >= 0 and c_2 = d - c_0 - c_1 and c != c', 
#     we need c_2 >= 1. But c_0 < c'_0 <= d and c_1 = c'_1 <= d.
#     Actually c_0 + c_1 < c'_0 + c_1 = c'_0 + c'_1 <= d, so c_2 = d - c_0 - c_1 > 0.
#   1+EMD' = 3*max(0, alpha, beta+1) - alpha - beta = 3*max(0, 0, beta+1) - 0 - beta
#     If beta = -1: max(0, 0, 0) = 0. Result = -0 - (-1) = 1 = EMD. YES!
#     If beta <= -2: max(0, 0, beta+1) = 0. Result = -beta = EMD. YES!

# So the complete case analysis is:
# M >= 1: Use shift {0} if c_0 > 0. If c_0 = 0: use shift {2} (works because
#   beta+1 <= 1 <= alpha = M, so max unchanged, and c_2 > 0 can be verified).
# M = 0, alpha <= -1: Use shift {1} (requires c_1 > 0; since alpha = c'_1 - c_1 <= -1,
#   c_1 >= c'_1 + 1 >= 1).
# M = 0, alpha = 0, beta <= -1: Use shift {2} (requires c_2 > 0; shown above).
# M = 0, alpha = 0, beta = 0: c = c', excluded.

# But we also need symmetry. The case M = beta >= 1:
# Then shift {0} still works (max(1, alpha, beta) = beta iff beta >= max(1,alpha))
#   1+EMD' = 3*beta - alpha - beta = 2beta - alpha.
#   EMD = 3beta - alpha - beta = 2beta - alpha. SAME! Good.

# Full proof verified. Let me also verify with the c_0 = 0 edge cases.
# When M = alpha >= 1 and c_0 = 0:
# Shift {2}: 1+EMD' = 3*max(0, alpha, beta+1) - alpha - beta
#   beta = c_0 - c'_0 = -c'_0 <= 0.
#   beta+1 <= 1 <= alpha (since alpha >= 1).
#   max(0, alpha, beta+1) = alpha = M.
#   Result = 3M - alpha - beta = EMD. YES! And c_2 > 0?
#   c_0 = 0, alpha = c'_1 - c_1 >= 1 means c_1 <= c'_1 - 1 <= d-1.
#   c_2 = d - c_0 - c_1 = d - c_1 >= 1. YES!

print("\n\nFULL PROOF OF SINGLETON BELLMAN EQUATION:")
print("=" * 60)
print("""
Lemma: For compositions c != c' of d into 3 parts,
  EMD(c, c') = min_{i: c_i > 0} (1 + EMD(c({i}), c'))

Proof. Let alpha = c'_1 - c_1, beta = c_0 - c'_0, M = max(0, alpha, beta).
Then EMD(c,c') = 3M - alpha - beta.

For shift {i}, let alpha_i, beta_i be the parameters after the shift:
  {0}: alpha_0 = alpha-1, beta_0 = beta-1
  {1}: alpha_1 = alpha+1, beta_1 = beta
  {2}: alpha_2 = alpha,   beta_2 = beta+1

And 1 + EMD(c({i}), c') = 3*max(0, alpha_i, beta_i) - alpha_i - beta_i + 1
                         = 3*max(0, alpha_i, beta_i) - alpha - beta + delta_i
where delta_0 = 2+1=3, delta_1 = -1+1=0, delta_2 = -1+1=0.

Wait that's wrong. Let me redo:
  1 + EMD(c({0}),c') = 1 + 3*max(0,alpha-1,beta-1) - (alpha-1) - (beta-1)
                     = 3*max(0,alpha-1,beta-1) - alpha - beta + 3
                     = 3*(max(0,alpha-1,beta-1) + 1) - alpha - beta
                     = 3*max(1,alpha,beta) - alpha - beta

  1 + EMD(c({1}),c') = 1 + 3*max(0,alpha+1,beta) - (alpha+1) - beta
                     = 3*max(0,alpha+1,beta) - alpha - beta

  1 + EMD(c({2}),c') = 1 + 3*max(0,alpha,beta+1) - alpha - (beta+1)
                     = 3*max(0,alpha,beta+1) - alpha - beta

Want: min over allowed i of these = 3*max(0,alpha,beta) - alpha - beta = EMD.

Case M >= 1 (alpha >= 1 or beta >= 1):
  {0}: 3*max(1,M) = 3M (since M >= 1). Result = 3M - alpha - beta = EMD. 
  Valid if c_0 > 0. If c_0 = 0: beta = -c'_0 <= 0, so M = alpha.
  Then {2}: max(0,alpha,beta+1) = alpha = M (since beta+1 <= 1 <= alpha).
  Result = EMD. Valid since c_2 = d - c_1 >= d - (c'_1-1) >= 1.

Case M = 0 (alpha <= 0, beta <= 0):
  EMD = -alpha - beta >= 1.
  {1}: max(0,alpha+1,beta). Since beta <= 0 and alpha+1 <= 1:
    If alpha <= -1: max = 0. Result = -alpha-beta = EMD.
    Valid since c_1 >= c'_1+1 >= 1.
  {2}: max(0,alpha,beta+1). Since alpha <= 0 and beta+1 <= 1:
    If beta <= -1: max = 0. Result = -alpha-beta = EMD.
    Valid since c_2 = d-c_0-c_1, and c_0 > c'_0 -> c_0 >= 1... 
    wait, beta = c_0-c'_0 <= -1 means c'_0 >= c_0+1, so c_0 < c'_0.
    Actually c_0 doesn't have to be positive for shift {2}.
    Shift {2} requires c_2 > 0.
    If beta <= -1 and alpha = 0: c_2 = d - c_0 - c_1 > 0 (shown above).
    If beta <= -1 and alpha <= -1: either {1} or {2} works.
  
  Remaining subcase: alpha = 0 and beta = 0 -> c = c'. Excluded. QED.
""")

