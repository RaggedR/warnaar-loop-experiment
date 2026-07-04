"""
Algebraic proof that g(J) in {EMD, EMD+3} for all (alpha, beta) != (0,0).

g(J) = |J| + E(alpha_J, beta_J)
where E(a,b) = 3*max(0,a,b) - a - b

Key identity: E(a,b) = a + b + 3*max(0, a-max(a,b), b-max(a,b))
Wait, that doesn't simplify. Let me use:
E(a,b) = a*(2*[a>=b,a>0] - 1) + b*(-1 + 2*[b>=a,b>0]) + 3*max(0,a,b)*(1-1)...

No, the simplest approach: define M(a,b) = max(0, a, b).
Then E(a,b) = 3*M(a,b) - a - b.

For each shift, define:
  delta_a = a' - a (change in alpha)
  delta_b = b' - b (change in beta)
  delta_J = |J| (number of elements)

Then g(J) = |J| + E(a', b') = |J| + 3*M(a', b') - a' - b'
         = |J| + 3*M(a+da, b+db) - (a+da) - (b+db)
         = |J| - da - db + 3*M(a+da, b+db)

EMD = 3*M(a, b) - a - b

g(J) - EMD = |J| - da - db + 3*(M(a+da, b+db) - M(a, b))

For each J, compute |J| - da - db:
  {}: 0 - 0 - 0 = 0
  {0}: 1 - (-1) - (-1) = 3
  {1}: 1 - 1 - 0 = 0
  {2}: 1 - 0 - 1 = 0
  {0,1}: 2 - 0 - (-1) = 3
  {0,2}: 2 - (-1) - 0 = 3
  {1,2}: 2 - 1 - 1 = 0
  {0,1,2}: 3 - 0 - 0 = 3

So g(J) - EMD = 3*delta_M + s_J where s_J is:
  {}: s=0, {0}: s=3, {1}: s=0, {2}: s=0
  {0,1}: s=3, {0,2}: s=3, {1,2}: s=0, {0,1,2}: s=3

And delta_M = M(a+da, b+db) - M(a, b).

Note s_J = 3 * [0 in J]. Because:
- If 0 in J: da includes -1 for alpha and -1 for beta (from the {0} shift), giving +3.
- If 0 not in J: da and db don't include the {0} contribution.

More precisely: s_J = |J| - da(J) - db(J) = 3 * (number of times 0 appears in J).
Since J is a subset of {0,1,2}, this is 3 * [0 in J].

So g(J) - EMD = 3*(delta_M + [0 in J]).

For g(J) to be in {EMD, EMD+3}, we need delta_M + [0 in J] in {0, 1}.

delta_M = M(a+da, b+db) - M(a, b).

For J NOT containing 0 (i.e., J in {{}, {1}, {2}, {1,2}}):
  We need delta_M in {0, 1}.
  {}: (a,b) -> (a,b), delta_M = 0. g = EMD. CHECK.
  {1}: (a,b) -> (a+1, b), delta_M = M(a+1,b) - M(a,b).
    If a+1 > M(a,b): delta_M = 1. Happens when a+1 > max(0, a, b), i.e., a >= max(0, b).
    If a+1 <= M(a,b): delta_M = 0. Happens when max(0, b) > a.
    So delta_M in {0, 1}. CHECK.
  {2}: (a,b) -> (a, b+1), delta_M = M(a,b+1) - M(a,b). Similarly delta_M in {0,1}. CHECK.
  {1,2}: (a,b) -> (a+1, b+1), delta_M = M(a+1,b+1) - M(a,b).
    max(0, a+1, b+1) - max(0, a, b).
    If M = 0: new max = max(0, 1, 1) = 1. delta_M = 1. 
    If M = a > 0: new max = max(0, a+1, b+1). If a >= b: = a+1. delta_M = 1.
    If M = b > 0: new max = max(0, a+1, b+1). If b >= a: = b+1. delta_M = 1.
    So delta_M = 1 always. g = EMD + 3*1 = EMD + 3? 
    Wait, [0 in {1,2}] = 0, so g - EMD = 3 * delta_M = 3. g = EMD + 3. 
    But our region analysis showed {1,2} gives g = EMD in region R0!

    In R0: alpha <= 0, beta <= 0. M = 0. delta_M = max(0, alpha+1, beta+1) - 0.
    alpha+1 <= 1, beta+1 <= 1. So delta_M = max(0, alpha+1, beta+1).
    If alpha = -1 and beta = -1: delta_M = 0. g = EMD + 0 = EMD. OK!
    If alpha = 0 or beta = 0: delta_M = 1. But alpha = beta = 0 is excluded (c=c').
    If alpha = -1, beta = 0: excluded (c=c' requires alpha=beta=0).
    Wait, alpha and beta can be anything with c != c'.
    alpha = -1, beta = -2: delta_M = max(0, 0, -1) = 0. g = EMD. OK!
    alpha = 0, beta = -1: delta_M = max(0, 1, 0) = 1. g = EMD+3. 
    But we said R0 has alpha <= 0, beta <= 0. alpha=0, beta=-1 is on boundary of R0/R1.
    In R0 formula: EMD = -0 - (-1) = 1. With delta_M = 1: g = 1 + 3 = 4.
    In the region analysis, {1,2} in R0 had g = EMD. But here it's EMD+3.
    
    Hmm, let me recheck. alpha = 0, beta = -1:
    M(0, -1) = 0 (since max(0, 0, -1) = 0). EMD = 0 + 1 = 1.
    {1,2}: a' = 1, b' = 0. M(1, 0) = 1. E(1,0) = 3-1-0 = 2. g = 2+2 = 4 = EMD+3. 
    But in the general R0 analysis I said g({1,2}) = EMD. Let me recheck.
    
    R0 analysis had: alpha <= 0, beta <= 0.
    g({1,2}) = 2 + E(alpha+1, beta+1) = 2 + 3*max(0, alpha+1, beta+1) - (alpha+1) - (beta+1)
             = 2 + 3*max(0, alpha+1, beta+1) - alpha - beta - 2
             = 3*max(0, alpha+1, beta+1) - alpha - beta
    
    EMD = -alpha - beta (in R0).
    g - EMD = 3*max(0, alpha+1, beta+1).
    
    In R0: alpha <= 0, beta <= 0. So alpha+1 <= 1, beta+1 <= 1.
    max(0, alpha+1, beta+1) = max(0, alpha+1, beta+1).
    If alpha <= -1 and beta <= -1: max = max(0, <=0, <=0) = 0. g = EMD. OK.
    If alpha = 0 and beta <= -1: max = max(0, 1, <=0) = 1. g = EMD + 3. 
    If alpha <= -1 and beta = 0: max = max(0, <=0, 1) = 1. g = EMD + 3.
    
    So my original region analysis was wrong when alpha or beta = 0!
    The "deep interior" analysis was correct but boundaries need care.

print("The formula g(J) - EMD = 3*(delta_M(J) + [0 in J]) is EXACT.")
print()
print("delta_M(J) = max(0, alpha+da_J, beta+db_J) - max(0, alpha, beta)")
print()
print("We need delta_M + [0 in J] in {0, 1} for g in {EMD, EMD+3}.")
print()
print("Since max changes by at most 1 per unit change in args,")
print("and each shift changes alpha by at most 1 and beta by at most 1:")
print("  delta_M in {-1, 0, 1} (at most)")
print()
print("For J not containing 0: need delta_M in {0, 1}.")
print("  delta_M = -1 would require max to DECREASE despite args not all decreasing.")
print("  {1}: a -> a+1, b -> b. If a was the max, increasing a doesn't decrease max.")
print("        If b was the max and b > a+1, max stays b. If 0 was max, still 0 if a+1 <= 0.")
print("        Actually delta_M >= 0 since we're only increasing coordinates. CHECK.")
print("  {2}: similarly delta_M >= 0. CHECK.")
print("  {1,2}: a+1, b+1. max(0,a+1,b+1) >= max(0,a,b) since both args increase.")
print("        And max(0,a+1,b+1) <= max(0,a,b) + 1 (max increases by at most 1 step).")
print("        Wait, max(0,a+1,b+1) could be max(0,a,b)+1 (if old max was a or b)")
print("        or max(0,a,b) (if old max was 0 and a+1,b+1 <= 0).")
print("        Actually max(0,a+1,b+1) = max(0, a+1, b+1).")
print("        If max(0,a,b) = 0: new max = max(0, a+1, b+1) <= 1. delta_M in {0,1}.")
print("        If max(0,a,b) = a > 0: new max = max(a, a+1, b+1) = a+1. delta_M = 1.")
print("        If max(0,a,b) = b > 0: new max = max(b, a+1, b+1) = b+1. delta_M = 1.")
print("        So delta_M in {0, 1}. CHECK.")
print()
print("For J containing 0: need delta_M + 1 in {0, 1}, i.e., delta_M in {-1, 0}.")
print("  {0}: a -> a-1, b -> b-1. max(0,a-1,b-1) <= max(0,a,b).")
print("    If max = 0: new max = max(0, a-1, b-1) = 0 (since a<=0, b<=0 -> a-1<=0,b-1<=0).")
print("      Actually a could be > 0 with max = a. Then a-1 >= 0 or a-1 < 0.")
print("    max(0,a-1,b-1) = max(0, max(0,a,b)-1, ...). In general:")
print("    delta_M = max(0,a-1,b-1) - max(0,a,b) <= 0 (both args decrease).")
print("    And delta_M >= -1 (max decreases by at most 1 per unit decrease in one arg,")
print("    here both decrease by 1 but max only tracks the largest).")
print("    Specifically: if max=a>0: new max = max(0,a-1,b-1). If b-1<a-1: = max(0,a-1).")
print("      If a-1>=0: delta_M = -1. If a-1<0 (a=0, contradiction a>0).")
print("    If max=b>0: similarly delta_M=-1.")
print("    If max=0: a<=0,b<=0. new max=0. delta_M=0.")
print("    So delta_M in {-1, 0}. CHECK!")
print()
print("  {0,1}: a -> a, b -> b-1. delta_M = max(0,a,b-1) - max(0,a,b).")
print("    If max=b>0: new max = max(0,a,b-1). If a>=b-1: = max(0,a).")
print("      If a>=b: = a = max (delta_M = a-b or 0). Wait, max was b.")
print("      If a >= b: impossible since max=b>=a, so a<=b. Then a<=b, b-1<=b.")
print("      max(0,a,b-1) = max(0,a,b-1). If b-1>=a and b-1>=0: =b-1. delta_M=-1.")
print("      If a>b-1 and a>=0: = a. delta_M = a-b <= 0. If a=b-1: =b-1. delta_M=-1.")
print("      So delta_M=-1 when max=b>0.")
print("    If max=a>0 and a>b: new max = max(0,a,b-1) = a. delta_M = 0.")
print("    If max=0: delta_M = max(0,0,b-1) - 0 = 0 (since b<=0, b-1<=0).")
print("    delta_M in {-1, 0}. CHECK!")
print()
print("  {0,2}: a -> a-1, b -> b. delta_M = max(0,a-1,b) - max(0,a,b).")
print("    Similar to {0,1}. delta_M in {-1, 0}. CHECK!")
print()
print("  {0,1,2}: a -> a, b -> b. delta_M = 0. delta_M + 1 = 1. g = EMD+3. CHECK!")
print()
print("CONCLUSION: For ALL subsets J and ALL (alpha, beta) != (0,0):")
print("  g(J) - EMD = 3 * (delta_M + [0 in J]) where delta_M + [0 in J] in {0, 1}.")
print("  Therefore g(J) in {EMD, EMD+3}.")
print()
print("Moreover, for each J:")
print("  g(J) = EMD iff delta_M + [0 in J] = 0")
print("  g(J) = EMD+3 iff delta_M + [0 in J] = 1")

# Now verify the signed sums
# Partition subsets into G_0 = {J: g(J)=EMD} and G_3 = {J: g(J)=EMD+3}.
# Need: sum_{J in G_0} (-1)^|J| = 0 and sum_{J in G_3} (-1)^|J| = 0.

# G_0 = {J: delta_M(J) + [0 in J] = 0}
#      = {J: 0 not in J and delta_M(J) = 0} union {J: 0 in J and delta_M(J) = -1}
# G_3 = {J: delta_M(J) + [0 in J] = 1}
#      = {J: 0 not in J and delta_M(J) = 1} union {J: 0 in J and delta_M(J) = 0}

# The crucial observation: the mapping J -> J Delta {0} (symmetric difference with {0})
# is a sign-reversing involution on the power set of I_c, AND it maps G_0 to G_3 and vice versa.

# J -> J Delta {0} changes |J| by +-1, so it reverses sign (-1)^|J|.
# It flips [0 in J] by 1.
# And it changes delta_M by... what?

# If J does not contain 0: J' = J union {0}. 
#   Shift changes: da' = da-1, db' = db-1 (adding {0} subtracts 1 from each).
#   Wait, the shift for J' = J + {0} is c(J union {0}).
#   The effect on (alpha, beta) is:
#   Adding 0 to J: changes da by -1 and db by -1 (the {0} contribution is -1 to a and -1 to b).
#   So delta_M(J') = max(0, a+da-1, b+db-1) - max(0,a,b)
#   delta_M(J) = max(0, a+da, b+db) - max(0,a,b)
#   delta_M(J') = max(0, a+da-1, b+db-1) - max(0,a,b)
#               <= max(0, a+da, b+db) - 1 - max(0,a,b) + something
#   
#   Actually: max(0, x-1, y-1) = max(0, x-1, y-1).
#   If max(0,x,y) = 0: both x,y <= 0. Then x-1,y-1 <= -1 <= 0. max(0,x-1,y-1) = 0. Change: 0.
#   If max(0,x,y) = x > 0: max(0,x-1,y-1) = max(0,x-1,y-1).
#     If x-1 >= y-1 and x-1 >= 0: = x-1. Change: -1.
#     If x-1 < 0 (x=0, contradiction): impossible.
#     Hmm wait, x could be 1, then x-1 = 0. max(0,0,y-1) = max(0,y-1).
#     If y <= 0: = 0. Change = 0 - x = -1 (since x = 1). 
#     Wait I need to be more careful.
#   
#   Let x = a+da, y = b+db.
#   M_J = max(0, x, y), M_J' = max(0, x-1, y-1)
#   
#   Claim: M_J' = max(0, M_J - 1)
#   Proof: M_J - 1 = max(0,x,y) - 1 = max(-1, x-1, y-1).
#   M_J' = max(0, x-1, y-1) = max(0, max(-1, x-1, y-1)) = max(0, M_J - 1). YES!
#   
#   So delta_M(J') = max(0, M_J - 1) - M = max(0, M_J - 1) - M
#   where M = max(0, a, b) and M_J = max(0, a+da, b+db) = M + delta_M(J).
#   
#   delta_M(J') = max(0, M + delta_M(J) - 1) - M
#   
#   If delta_M(J) = 0: M_J = M. delta_M(J') = max(0, M-1) - M.
#     If M >= 1: = M-1 - M = -1. 
#     If M = 0: = 0 - 0 = 0.
#   If delta_M(J) = 1: M_J = M+1. delta_M(J') = max(0, M) - M = 0.
#   If delta_M(J) = -1: M_J = M-1. delta_M(J') = max(0, M-2) - M.
#     If M >= 2: = M-2 - M = -2. But we showed delta_M in {-1,0,1}. Contradiction!
#     Actually delta_M(J) = -1 only happens for J containing 0. But here J' = J + {0},
#     so J doesn't contain 0. And we showed delta_M in {0,1} for J not containing 0.
#     So delta_M(J) in {0, 1} when 0 not in J.

# So for 0 not in J:
#   delta_M(J) = 0: delta_M(J') = -1 (if M >= 1), or 0 (if M = 0).
#     [0 in J] = 0, [0 in J'] = 1.
#     g(J) - EMD = 3*(0 + 0) = 0. g(J) = EMD.
#     g(J') - EMD = 3*(-1 + 1) = 0 (if M >= 1). g(J') = EMD. SAME!
#                  = 3*(0 + 1) = 3 (if M = 0). g(J') = EMD+3. 
#     
#     Wait, M = 0 means alpha <= 0 and beta <= 0. But c != c', so EMD > 0 => alpha+beta < 0.
#     When M = 0, delta_M(J) = 0 means max(0, a+da, b+db) = 0.
#     delta_M(J') = 0, so g(J') = 3*(0+1) = 3. g(J') = EMD + 3.
#     And g(J) = EMD. So J and J' are in DIFFERENT groups! The involution works!
#     
#     When M >= 1: delta_M(J') = -1. g(J') = 3*(-1+1) = 0. g(J') = EMD.
#     Both J and J' in G_0. The involution does NOT separate them!

# Hmm, so J -> J Delta {0} does NOT always pair G_0 with G_3.
# The involution approach with toggling {0} doesn't directly work.

# Let me reconsider. The signed sum in each group G_0 and G_3 is 0.
# This can be verified by noting that:
# In each region (R0, R1, R2), the partition into {g=EMD, g=EMD+3}
# has a clean combinatorial structure.

# For R1 (alpha >= max(0, beta)):
# G_0 = {{}, {0}, {2}, {0,2}}: signed sum = 1 - 1 - 1 + 1 = 0
# G_3 = {{1}, {0,1}, {1,2}, {0,1,2}}: signed sum = -1 + 1 + 1 - 1 = 0
# Observation: G_0 = {J: 1 not in J} and G_3 = {J: 1 in J}.
# The involution J -> J Delta {1} pairs them!

# For R0 (alpha <= 0, beta <= 0):
# G_0 = {{}, {1}, {2}, {1,2}}: signed sum = 1 - 1 - 1 + 1 = 0
# G_3 = {{0}, {0,1}, {0,2}, {0,1,2}}: signed sum = -1 + 1 + 1 - 1 = 0
# Observation: G_0 = {J: 0 not in J} and G_3 = {J: 0 in J}.
# The involution J -> J Delta {0} pairs them!

# For R2 (beta >= max(0, alpha)):
# G_0 = {{}, {0}, {1}, {0,1}}: signed sum = 1 - 1 - 1 + 1 = 0
# G_3 = {{2}, {0,2}, {1,2}, {0,1,2}}: signed sum = -1 + 1 + 1 - 1 = 0
# Observation: G_0 = {J: 2 not in J} and G_3 = {J: 2 in J}.
# The involution J -> J Delta {2} pairs them!

# PATTERN: In region R_k (where M = alpha, beta, or 0 respectively for k=1,2,0):
# G_0 = {J: k not in J} and G_3 = {J: k in J}
# where k = 1 in R1, k = 0 in R0, k = 2 in R2.

# Actually: k is the index such that adding mass at k costs 3 (i.e., increases g by 3).
# In R1 (M = alpha), the "expensive direction" is 1 (shift {1} adds to alpha, the dominant term).
# In R2 (M = beta), it's 2 (shift {2} adds to beta).
# In R0 (M = 0), it's 0 (shift {0} decreases both, but with |J|=1 adds 3).

# The involution is J -> J Delta {k} where k depends on the region.
# This toggles membership in G_0/G_3 and reverses sign, giving sum = 0 in each group.

# This is the key to the proof!

print("PROOF OF THE SIGNED SUM CANCELLATION:")
print("In each region R_k (k = 0, 1, 2), there exists an index i_k such that")
print("  g(J) = EMD iff i_k not in J")
print("  g(J) = EMD+3 iff i_k in J")
print("The involution J -> J Delta {i_k} reverses sign (changes |J| by +-1)")
print("and pairs each J in G_0 with J' in G_3.")
print("Therefore sum_{J in G_0} (-1)^|J| = 0 and sum_{J in G_3} (-1)^|J| = 0.")
print("Hence S(c,c') = 0.")
print()
print("The index i_k is:")
print("  R0 (M=0): i_0 = 0")  
print("  R1 (M=alpha>0, alpha>=beta): i_1 = 1")
print("  R2 (M=beta>0, beta>=alpha): i_2 = 2")
print()
print("Verification: the partition G_0 = {J: i_k not in J} matches the computed")
print("region analysis exactly.")

# But wait: at region boundaries (e.g., alpha = beta > 0), 
# both R1 and R2 analyses apply, and they give different i_k values.
# But both give the same partition! Let me verify.

# On R1-R2 boundary: alpha = beta > 0. M = alpha = beta.
# R1 analysis: i_1 = 1. G_0 = {J: 1 not in J}.
# R2 analysis: i_2 = 2. G_0 = {J: 2 not in J}.
# These are DIFFERENT sets! But both should give sum 0.
# Actually both DO give sum 0 since |G_0| = |G_3| = 4 with equal positive/negative.
# The point is that g(J) values must be consistent, not the partition.

# Let me check alpha = beta = 1 (on R1-R2 boundary):
# {}: g = 0 + E(1,1) = 0 + 3-1-1 = 1 = EMD
# {0}: g = 1 + E(0,0) = 1 + 0 = 1 = EMD !!!
# {1}: g = 1 + E(2,1) = 1 + 6-2-1 = 4 = EMD+3
# {2}: g = 1 + E(1,2) = 1 + 6-1-2 = 4 = EMD+3
# {0,1}: g = 2 + E(1,0) = 2 + 3-1-0 = 4 = EMD+3
# {0,2}: g = 2 + E(0,1) = 2 + 3-0-1 = 4 = EMD+3
# {1,2}: g = 2 + E(2,2) = 2 + 6-2-2 = 4 = EMD+3
# {0,1,2}: g = 3 + E(1,1) = 3 + 1 = 4 = EMD+3

# G_0 = {{}, {0}} (signed sum: 1-1 = 0)
# G_3 = {{1},{2},{0,1},{0,2},{1,2},{0,1,2}} (signed sum: -1-1+1+1+1-1 = 0)

# So at the R1-R2 boundary, the partition changes but the signed sum still works!
# Here G_0 has only 2 elements instead of 4.

# The R1 analysis would predict G_0 = {J: 1 not in J} = {{},{0},{2},{0,2}}, but
# g({2}) = EMD+3 and g({0,2}) = EMD+3, so this prediction is WRONG at the boundary!

# So my "region analysis" only works in the interior of each region. At boundaries,
# the partition changes. But the signed sum is always 0.

# I need a different proof of the signed sum cancellation that works at boundaries.

# KEY INSIGHT: g(J) - EMD = 3*(delta_M(J) + [0 in J]).
# We need: for all (alpha, beta) != (0,0),
# sum_{J: delta_M(J) + [0 in J] = 0} (-1)^|J| = 0
# AND
# sum_{J: delta_M(J) + [0 in J] = 1} (-1)^|J| = 0.

# Equivalently: sum_J (-1)^|J| t^{delta_M(J) + [0 in J]} = 0 for t = 1 and t = -1.
# But this is stronger than needed. We just need the sum is 0 for each value of the exponent.

# Actually, we need the TOTAL sum sum_J (-1)^|J| x^{g(J)} = 0.
# Since g(J) only takes values EMD and EMD+3, this is:
# (sum_{g=EMD} (-1)^|J|) * x^EMD + (sum_{g=EMD+3} (-1)^|J|) * x^{EMD+3} = 0.
# For this to be 0 as a polynomial in x, we need BOTH coefficient sums to be 0.

# The total sum over ALL J of (-1)^|J| = sum_{k=0}^3 C(3,k)(-1)^k = 0 (for |I_c|=3).
# So the sum over G_0 plus sum over G_3 = 0. 
# If we could show the sum over G_0 = sum over G_3, then both = 0.
# But sum over G_0 + sum over G_3 = 0, so if sum G_0 = -sum G_3, both are 0.
# This is automatically satisfied! Wait, no: sum G_0 + sum G_3 = 0 means
# sum G_0 = -(sum G_3), so both sums are 0 IFF sum G_0 = 0 (then sum G_3 = 0 too).

# So we only need to show ONE of the sums is 0. Say sum_{J in G_0} (-1)^|J| = 0.

# G_0 = {J subset I_c : delta_M(J) + [0 in J] = 0}
#      = {J not containing 0 : delta_M(J) = 0} union {J containing 0 : delta_M(J) = -1}

# This is getting complicated. Let me try yet another approach.

# CLEANER APPROACH: Just verify the identity directly for |I_c| = 1, 2, 3 
# by expanding the EMD formula in all regions. This is what I did computationally
# and it works. The algebraic proof is a finite (though tedious) case analysis.

print("\n\nFINAL APPROACH: Direct algebraic verification")
print("The identity g(J) in {EMD, EMD+3} and the signed sum cancellation")
print("are verified ALGEBRAICALLY by:")
print("1. g(J) - EMD = 3*(delta_M + [0 in J]) where delta_M = M(shifted) - M(original)")
print("2. delta_M + [0 in J] in {0, 1} (proved above for each subset type)")
print("3. The signed sum is 0 because sum_J (-1)^|J| = 0 (binomial theorem)")
print("   AND for each J, exactly one of J and J Delta {k} is in G_0 (for suitable k)")
print("   where k depends on the region.")
print("")
print("For a rigorous proof not depending on region analysis,")
print("observe that sum_{J subset I_c} (-1)^|J| = 0 whenever |I_c| >= 1.")
print("So S = a * x^EMD + b * x^{EMD+3} where a + b = 0.")  
print("Then S = a * (x^EMD - x^{EMD+3}) = a * x^EMD * (1 - x^3).")
print("For S = 0 when c != c', we need a = 0.")
print("")
print("a = sum_{J: g(J)=EMD} (-1)^|J| = sum_{J: delta_M(J)+[0 in J]=0} (-1)^|J|.")
print("")
print("THIS IS THE REMAINING THING TO PROVE: a = 0.")

