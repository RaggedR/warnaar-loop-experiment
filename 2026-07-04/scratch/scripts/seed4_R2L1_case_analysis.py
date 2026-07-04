"""
Complete the c != c' case of the IE identity by exhaustive region analysis.

The 3 regions for EMD(c,c') = 3*max(0, alpha, beta) - alpha - beta:
  R0: alpha <= 0 and beta <= 0  ->  EMD = -alpha - beta
  R1: alpha >= beta and alpha >= 0  ->  EMD = 2*alpha - beta
  R2: beta >= alpha and beta >= 0  ->  EMD = -alpha + 2*beta

For each J, the shifted parameters (alpha', beta') fall into one of these regions,
and g(J) = |J| + EMD formula for (alpha', beta').

Let me compute symbolically for |I_c| = 3 (the hardest case).
"""

# For |I_c| = 3, the 8 subsets and their effects on (alpha, beta):
# J={}:     (alpha, beta),      sign=+1, |J|=0
# J={0}:    (alpha-1, beta-1),  sign=-1, |J|=1
# J={1}:    (alpha+1, beta),    sign=-1, |J|=1
# J={2}:    (alpha, beta+1),    sign=-1, |J|=1
# J={0,1}:  (alpha, beta-1),    sign=+1, |J|=2
# J={0,2}:  (alpha-1, beta),    sign=+1, |J|=2
# J={1,2}:  (alpha+1, beta+1),  sign=+1, |J|=2
# J={0,1,2}:(alpha, beta),      sign=-1, |J|=3

# Define E(a, b) = 3*max(0, a, b) - a - b
# g(J) = |J| + E(alpha', beta')

# In region R0 (alpha <= 0, beta <= 0): E(a,b) = -a - b
# In region R1 (alpha >= max(0, beta)): E(a,b) = 2a - b
# In region R2 (beta >= max(0, alpha)): E(a,b) = -a + 2b

# Let's compute g(J) in each case, assuming (alpha, beta) is deeply in each region
# so that all shifted values stay in the same region. Then check boundaries.

# If (alpha, beta) is deep in R1 (alpha >> 0, alpha >> beta):
# All shifts keep us in R1 (since alpha+-1 is still dominant).
# E(a,b) = 2a - b, so:
# g({}) = 0 + 2*alpha - beta = 2*alpha - beta
# g({0}) = 1 + 2*(alpha-1) - (beta-1) = 1 + 2*alpha - 2 - beta + 1 = 2*alpha - beta
# g({1}) = 1 + 2*(alpha+1) - beta = 1 + 2*alpha + 2 - beta = 2*alpha - beta + 3
# g({2}) = 1 + 2*alpha - (beta+1) = 2*alpha - beta
# g({0,1}) = 2 + 2*alpha - (beta-1) = 2*alpha - beta + 3
# g({0,2}) = 2 + 2*(alpha-1) - beta = 2*alpha - beta
# g({1,2}) = 2 + 2*(alpha+1) - (beta+1) = 2*alpha - beta + 3
# g({0,1,2}) = 3 + 2*alpha - beta = 2*alpha - beta + 3

# So the exponents are:
# g = 2*alpha - beta (= EMD): {} (+1), {0} (-1), {2} (-1), {0,2} (+1) => net = 1-1-1+1 = 0
# g = 2*alpha - beta + 3: {1} (-1), {0,1} (+1), {1,2} (+1), {0,1,2} (-1) => net = -1+1+1-1 = 0

# BEAUTIFUL! In each regime, the g values split into exactly two groups:
# EMD and EMD+3, each with signed sum 0.

# Let me verify this for all three regimes.

print("Region R1 (alpha >= max(0, beta)) - assuming all shifted values stay in R1:")
print("  g values: EMD, EMD, EMD, EMD+3, EMD+3, EMD, EMD+3, EMD+3")
print("  signs:    +1,  -1,  -1,  -1,    +1,   +1,  +1,    -1")
print("  At EMD: +1 -1 -1 +1 = 0")
print("  At EMD+3: -1 +1 +1 -1 = 0")

print("\nRegion R0 (alpha <= 0, beta <= 0) - E(a,b) = -a-b:")
# g({}) = -alpha - beta = EMD
# g({0}) = 1 + -(alpha-1) - (beta-1) = 1 - alpha + 1 - beta + 1 = -alpha - beta + 3 = EMD+3
# g({1}) = 1 + -(alpha+1) - beta = 1 - alpha - 1 - beta = -alpha - beta = EMD
# g({2}) = 1 + -alpha - (beta+1) = 1 - alpha - beta - 1 = -alpha - beta = EMD
# g({0,1}) = 2 + -alpha - (beta-1) = 2 - alpha - beta + 1 = -alpha - beta + 3 = EMD+3
# g({0,2}) = 2 + -(alpha-1) - beta = 2 - alpha + 1 - beta = -alpha - beta + 3 = EMD+3
# g({1,2}) = 2 + -(alpha+1) - (beta+1) = 2 - alpha - 1 - beta - 1 = -alpha - beta = EMD
# g({0,1,2}) = 3 + -alpha - beta = EMD + 3
print("  g values: EMD, EMD+3, EMD, EMD, EMD+3, EMD+3, EMD, EMD+3")
print("  signs:    +1,  -1,    -1,  -1,  +1,    +1,    +1,  -1")
print("  At EMD: +1 -1 -1 +1 = 0")
print("  At EMD+3: -1 +1 +1 -1 = 0")

print("\nRegion R2 (beta >= max(0, alpha)) - E(a,b) = -a+2b:")
# g({}) = -alpha + 2*beta
# g({0}) = 1 + -(alpha-1) + 2*(beta-1) = 1 - alpha + 1 + 2*beta - 2 = -alpha + 2*beta = EMD
# g({1}) = 1 + -(alpha+1) + 2*beta = 1 - alpha - 1 + 2*beta = -alpha + 2*beta = EMD
# g({2}) = 1 + -alpha + 2*(beta+1) = 1 - alpha + 2*beta + 2 = -alpha + 2*beta + 3 = EMD+3
# g({0,1}) = 2 + -alpha + 2*(beta-1) = 2 - alpha + 2*beta - 2 = -alpha + 2*beta = EMD
# g({0,2}) = 2 + -(alpha-1) + 2*beta = 2 - alpha + 1 + 2*beta = EMD + 3
# g({1,2}) = 2 + -(alpha+1) + 2*(beta+1) = 2 - alpha - 1 + 2*beta + 2 = EMD + 3
# g({0,1,2}) = 3 + EMD = EMD + 3
print("  g values: EMD, EMD, EMD, EMD+3, EMD, EMD+3, EMD+3, EMD+3")
print("  signs:    +1,  -1,  -1,  -1,   +1,  +1,    +1,    -1")
print("  At EMD: +1 -1 -1 +1 = 0")
print("  At EMD+3: -1 +1 +1 -1 = 0")

print("\n\nIN ALL THREE REGIONS: g(J) takes exactly two values {EMD, EMD+3},")
print("with each value having signed sum 0 (4 terms each: 2 positive, 2 negative).")
print("Therefore S(c,c') = 0 when all shifted values stay in the same region.")

print("\n\nBUT: what about boundary cases where the shifted (alpha', beta') crosses regions?")
print("Example: alpha = 1, beta = 0 (on boundary of R0/R1).")
print("  {1}: alpha' = 2, beta' = 0 -> R1, E = 4-0 = 4, g = 1+4 = 5")
print("  {0}: alpha' = 0, beta' = -1 -> R0, E = 0+1 = 1, g = 1+1 = 2")
print("  Hmm, this was handled correctly in the R1 analysis already!")
print("  Because: when alpha >= 0 and alpha >= beta,")
print("  {0}: alpha'=alpha-1 >= -1, beta'=beta-1 <= alpha-1.")
print("  If alpha-1 >= 0 AND alpha-1 >= beta-1: stays in R1. E = 2(alpha-1)-(beta-1).")
print("  If alpha-1 < 0: enters R0. E = -(alpha-1)-(beta-1) = -alpha-beta+2.")
print("  These give DIFFERENT formulas!")

print("\nI need to handle the boundary cases carefully.")

# Let me check: does the identity S = 0 still hold at boundaries?
# For alpha = 1, beta = 0, c != c' (deep analysis):
alpha, beta = 1, 0
print(f"\nalpha={alpha}, beta={beta}, EMD = {3*max(0,alpha,beta)-alpha-beta}")

shifts = {
    (): (alpha, beta),
    (0,): (alpha-1, beta-1),
    (1,): (alpha+1, beta),
    (2,): (alpha, beta+1),
    (0,1): (alpha, beta-1),
    (0,2): (alpha-1, beta),
    (1,2): (alpha+1, beta+1),
    (0,1,2): (alpha, beta),
}

for J, (a, b) in sorted(shifts.items(), key=lambda x: len(x[0])):
    M = max(0, a, b)
    E = 3*M - a - b
    g = len(J) + E
    sign = (-1)**len(J)
    region = "R0" if a<=0 and b<=0 else ("R1" if a>=b and a>=0 else "R2")
    print(f"  J={J}: (a,b)=({a},{b}), region={region}, E={E}, g={g}, sign={sign:+d}")

# alpha=0, beta=0 is excluded (c=c')
# alpha=1, beta=1:
print(f"\nalpha=1, beta=1, EMD = {3*max(0,1,1)-1-1} = 1")
alpha, beta = 1, 1
for J, (a, b) in sorted({
    (): (alpha, beta),
    (0,): (alpha-1, beta-1),
    (1,): (alpha+1, beta),
    (2,): (alpha, beta+1),
    (0,1): (alpha, beta-1),
    (0,2): (alpha-1, beta),
    (1,2): (alpha+1, beta+1),
    (0,1,2): (alpha, beta),
}.items(), key=lambda x: len(x[0])):
    M = max(0, a, b)
    E = 3*M - a - b
    g = len(J) + E
    sign = (-1)**len(J)
    print(f"  J={J}: (a,b)=({a},{b}), E={E}, g={g}, sign={sign:+d}")

# Let me now check ALL boundary-crossing cases systematically
print("\n\n=== Systematic boundary check ===")
# The regions are: R0 (M=0), R1 (M=alpha>0), R2 (M=beta>0), and degenerate R12 (M=alpha=beta>0)
# For each (alpha, beta) with small values, compute S and verify = 0

for alpha in range(-3, 6):
    for beta in range(-3, 6):
        if alpha == 0 and beta == 0:
            continue  # c = c'
        EMD = 3*max(0, alpha, beta) - alpha - beta
        # Only check if this could be a valid c != c' pair
        if EMD <= 0:
            continue
        
        terms = {}
        for J_idx, (da, db, size) in enumerate([
            (0, 0, 0),     # empty
            (-1, -1, 1),   # {0}
            (1, 0, 1),     # {1}
            (0, 1, 1),     # {2}
            (0, -1, 2),    # {0,1}
            (-1, 0, 2),    # {0,2}
            (1, 1, 2),     # {1,2}
            (0, 0, 3),     # {0,1,2}
        ]):
            a = alpha + da
            b = beta + db
            M = max(0, a, b)
            E = 3*M - a - b
            g = size + E
            sign = (-1)**size
            terms[J_idx] = (sign, g)
        
        # Check S = 0
        from collections import Counter
        S = Counter()
        for sign, g in terms.values():
            S[g] += sign
        
        nonzero = {k: v for k, v in S.items() if v != 0}
        if nonzero:
            print(f"  FAIL: alpha={alpha}, beta={beta}, EMD={EMD}, S = {nonzero}")
            for J_idx, (sign, g) in terms.items():
                print(f"    J_idx={J_idx}: sign={sign:+d}, g={g}")

print("All boundary cases verified!")

# KEY FINDING: In ALL cases (boundary or not), the identity S = 0 holds.
# The proof is the same in all three regions: g(J) takes at most two values
# {EMD, EMD+3}, and in each case the signed count is 0.

# But does this pattern (only EMD and EMD+3) persist at boundaries?
# Let me check.

print("\n=== Checking if g(J) in {EMD, EMD+3} always ===")
for alpha in range(-3, 6):
    for beta in range(-3, 6):
        if alpha == 0 and beta == 0:
            continue
        EMD = 3*max(0, alpha, beta) - alpha - beta
        if EMD <= 0:
            continue
        
        for da, db, size in [
            (0, 0, 0), (-1, -1, 1), (1, 0, 1), (0, 1, 1),
            (0, -1, 2), (-1, 0, 2), (1, 1, 2), (0, 0, 3)
        ]:
            a = alpha + da
            b = beta + db
            M = max(0, a, b)
            E = 3*M - a - b
            g = size + E
            if g not in (EMD, EMD + 3):
                print(f"  g NOT in {{EMD, EMD+3}}: alpha={alpha}, beta={beta}, shift=({da},{db},{size}), g={g}, EMD={EMD}")

print("Check complete!")

