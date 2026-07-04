"""
Seed 8, Layer 3, Task 1: Level-rank dual Demazure character check.
For d=4 (t=7), check A_2^(1) at level 4.
Compare Demazure characters with Q_{n,c}(q).
"""

print("="*80)
print("Task 1: Demazure character computation via SageMath crystals")
print("="*80)

# Known Q values for matching:
# d=4, c=(2,1,1): Q_1 = q + 2q^2 + q^3 + q^4, Q_1(1) = 5 ... wait
# Actually from synthesis: base = (d+1)(d+2)/6 - 1. For d=4: 5*6/6 - 1 = 4.
# So Q_n(1) = 4^n. h_m(1) = 5^m.

# d=7, c=(3,2,2): Q_1 = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6, Q_1(1) = 11

print("\n--- A_2^(1) at level 4, weight 2*L0 + L1 + L2 ---")

ct = CartanType(['A', 2, 1])
P = RootSystem(ct).weight_lattice(extended=True)
Lambda = P.fundamental_weights()
alpha = P.simple_roots()
delta = alpha[0] + alpha[1] + alpha[2]  # null root

lam = 2*Lambda[0] + Lambda[1] + Lambda[2]
print(f"Lambda = {lam}, level = {lam.level()}")

C = crystals.LSPaths(lam)
hw_list = list(C.highest_weight_vectors())
hw = hw_list[0]
print(f"Highest weight vector: {hw}")
print(f"HW weight: {hw.weight()}")

# Function to compute grade (principal specialization depth)
# For affine type, the grade of element b is the number of times
# we've applied lowering operators = height of Lambda - wt(b) in root lattice
def compute_grade(b, lam_wt):
    """Compute the grade of crystal element b relative to highest weight lam_wt.
    Grade = <rho_check, lam - wt(b)> where rho_check is the sum of fundamental coweights.
    For principal specialization e^{-alpha_i} -> q, grade = sum of root coefficients.
    """
    wt = b.weight()
    diff = lam_wt - wt
    # For A_2^(1), diff is in the weight lattice.
    # We need to express it in terms of alpha_0, alpha_1, alpha_2.
    # Use the method .scalar() with coroots to extract coefficients.

    # Actually, for the principal specialization of affine type,
    # the correct grading is by the coefficient of delta (= null root).
    # The "energy" or "level" is related to delta.

    # For LS paths, weight is in extended weight lattice.
    # diff = lam - wt = n_0*alpha[0] + n_1*alpha[1] + n_2*alpha[2]
    # Grade = n_0 + n_1 + n_2 (for e^{-alpha_i} -> q)

    # Try to extract coefficients
    try:
        # In the extended weight lattice, express diff in terms of simple roots
        # and the null root/delta
        coeffs = {}
        for i in [0, 1, 2]:
            c_i = diff.scalar(RootSystem(ct).coroot_lattice().simple_root(i))
            coeffs[i] = c_i
        grade = sum(coeffs.values())
        return grade, coeffs
    except:
        return None, None

# Compute Demazure subcrystals with various words
print("\nDemazure subcrystals:")

# For A_2^(1), good Weyl group words to try:
# The Coxeter element: s_0 s_1 s_2 (or permutations)
# Translation elements: more complex

all_results = {}

for name, word in [
    ("s0", [0]),
    ("s1", [1]),
    ("s2", [2]),
    ("s0s1", [0,1]),
    ("s0s2", [0,2]),
    ("s1s0", [1,0]),
    ("s1s2", [1,2]),
    ("s2s0", [2,0]),
    ("s2s1", [2,1]),
    ("s0s1s2", [0,1,2]),
    ("s2s1s0", [2,1,0]),
    ("s0s2s1", [0,2,1]),
    ("s1s0s2", [1,0,2]),
    ("s1s2s0", [1,2,0]),
    ("s2s0s1", [2,0,1]),
    ("(012)^2", [0,1,2,0,1,2]),
    ("(210)^2", [2,1,0,2,1,0]),
    ("(012)^3", [0,1,2,0,1,2,0,1,2]),
    ("(210)^3", [2,1,0,2,1,0,2,1,0]),
    ("(012)^4", [0,1,2]*4),
    ("(210)^4", [2,1,0]*4),
    ("(012)^5", [0,1,2]*5),
    ("(210)^5", [2,1,0]*5),
    ("(012)^6", [0,1,2]*6),
    ("(012)^7", [0,1,2]*7),
    ("s0s1s0s2", [0,1,0,2]),
    ("s0s1s2s0s1s2", [0,1,2,0,1,2]),
    ("s2s0s1s2s0s1", [2,0,1,2,0,1]),
    ("s1s2s0s1", [1,2,0,1]),
]:
    try:
        D = C.demazure_subcrystal(hw, word)
        elts = list(D)
        n_elts = len(elts)

        # Compute graded character
        grade_dist = {}
        for b in elts:
            g, _ = compute_grade(b, lam)
            if g is not None:
                grade_dist[g] = grade_dist.get(g, 0) + 1

        # Format as polynomial
        if grade_dist:
            poly_str = " + ".join(f"{v}q^{k}" if v > 1 else f"q^{k}" 
                                   for k, v in sorted(grade_dist.items()))
        else:
            poly_str = "?"

        line = f"  {name:20s}: {n_elts:4d} elements"
        if n_elts in [4, 5, 16, 25, 64, 125, 256, 625]:
            line += " ***"
        print(line)
        if grade_dist and n_elts <= 30:
            print(f"    grades: {dict(sorted(grade_dist.items()))}")
            print(f"    char: {poly_str}")

        all_results[name] = (n_elts, grade_dist)

    except Exception as e:
        print(f"  {name:20s}: ERROR - {str(e)[:60]}")

# Check which Demazure crystals have graded character matching Q_n
# Q_1 for d=4 has coefficients at q^1, q^2, q^3, q^4
# Q_1(1) = 4 (or 5? let me check)
# From synthesis: d=4, base = (4+1)(4+2)/6 - 1 = 5-1 = 4. Q_1(1) = 4.

print("\n\nLooking for character matches with Q_{1,(2,1,1)}(q)...")
print("Q_1 should have sum = 4 and specific q-distribution")

# Also try with different highest weights (profiles)
print("\n\n--- Trying different level-4 weights ---")
for c in [(4,0,0), (3,1,0), (3,0,1), (2,2,0), (2,0,2), (2,1,1), (1,2,1), (1,1,2), (0,2,2)]:
    if sum(c) != 4:
        continue
    wt = sum(c[i]*Lambda[i] for i in range(3))
    try:
        Cc = crystals.LSPaths(wt)
        hwc = list(Cc.highest_weight_vectors())[0]
        for word_name, word in [("(012)^2", [0,1,2]*2), ("(012)^3", [0,1,2]*3)]:
            D = Cc.demazure_subcrystal(hwc, word)
            elts = list(D)
            n_elts = len(elts)

            grade_dist = {}
            for b in elts:
                g, _ = compute_grade(b, wt)
                if g is not None:
                    grade_dist[g] = grade_dist.get(g, 0) + 1

            line = f"  c={c}, {word_name}: {n_elts} elements"
            if n_elts in [4, 5, 16, 25, 64, 125]:
                line += " ***"
            if grade_dist:
                line += f", grades: {dict(sorted(grade_dist.items()))}"
            print(line)
    except Exception as e:
        print(f"  c={c}: ERROR - {str(e)[:60]}")

print("\n\nDone with Task 1.")
