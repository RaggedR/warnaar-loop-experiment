"""
Seed 5, Layer 3: Investigate the correct grading for Demazure crystal characters.

The [1,2] crystal has 12 elements. The distance distribution gives
1 + 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6 = 12
but h_1 = 3q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6 (starts at q, not 1).

Need to find the correct grading.
"""

R_poly = PolynomialRing(ZZ, 'q')
q_var = R_poly.gen()

C = crystals.LSPaths(['A',2,1], [3,2,2])
hw = list(C.highest_weight_vectors())[0]

def build_demazure_word(root, word, max_size=50000):
    elements = {root}
    for i in reversed(word):
        new_elements = set(elements)
        for b in list(elements):
            current = b
            while True:
                next_b = current.f(i)
                if next_b is None or next_b in new_elements: break
                new_elements.add(next_b)
                current = next_b
                if len(new_elements) > max_size: return new_elements
        elements = new_elements
    return elements

elems_12 = build_demazure_word(hw, [1, 2])

# Try different gradings
print("Investigating gradings on the [1,2] Demazure crystal for c=(3,2,2)")
print(f"h_1 = 3q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6")
print()

# Grading 1: Lambda_0 coefficient
# The weights are: a0 Lambda_0 + a1 Lambda_1 + a2 Lambda_2
# All at level 7 (a0+a1+a2 = 7)
# The finite-type weight is determined by (a1, a2).

# For principal specialization of sl_3 at (q, q^2, q^3):
# A weight (a1, a2) in the finite type gets q-degree = a1 + 2*a2
# But wait, we need to be careful about conventions.

# In the finite-type A_2 picture:
# The fundamental weights are omega_1, omega_2
# omega_1 = (2/3, -1/3, -1/3) in epsilon basis
# omega_2 = (1/3, 1/3, -2/3) in epsilon basis

# For GL_3: weight (u1, u2, u3) -> monomial x1^u1 x2^u2 x3^u3
# At x_i = q^i: q-degree = u1 + 2u2 + 3u3

# The affine weight a0 Lambda_0 + a1 Lambda_1 + a2 Lambda_2 at level d:
# a0 + a1 + a2 = d = 7
# The finite part is a1 omega_1 + a2 omega_2 (with a0 = d - a1 - a2)
# In GL_3 coordinates:
# omega_1 ~ e_1, omega_2 ~ e_1 + e_2
# So a1 omega_1 + a2 omega_2 ~ (a1 + a2) e_1 + a2 e_2
# GL_3 weight: (a1+a2, a2, 0)
# q-degree = (a1+a2) + 2*a2 = a1 + 3*a2

# But we also need to account for the a0 part.
# The affine root alpha_0 = delta - alpha_1 - alpha_2
# Lambda_0 = delta - omega_1 - omega_2 (up to normalization?)

# Actually, for the principal specialization:
# In affine type A_n^(1), the principal specialization is x_i = q^i for i=0,...,n
# or equivalently, the grading is by the "depth" = level function on the crystal

# For the type A_2^(1) LS paths crystal, the principal specialization should be:
# For a weight Lambda = sum a_i Lambda_i at level d,
# the q-degree is related to the scalar product with the Weyl vector rho_affine.
# rho_affine = Lambda_0 + Lambda_1 + Lambda_2 + ...

# Let me try: q-degree = <hw_wt - wt, rho_hat>
# where rho_hat = Lambda_0 + Lambda_1 + Lambda_2 is the affine Weyl vector

# For weights in our crystal:
hw_wt = hw.weight()
WL = hw_wt.parent()

# The Weyl vector
rho_hat = WL.fundamental_weights()[0] + WL.fundamental_weights()[1] + WL.fundamental_weights()[2]

print("Trying grading: <hw - wt, rho_affine>")
char_rho = R_poly(0)
for b in elems_12:
    wt = b.weight()
    diff = hw_wt - wt
    # diff is in the weight lattice. How to compute scalar product with rho_hat?
    # In SageMath, the scalar product uses the Cartan matrix.
    # Actually, for weights in the weight lattice, we can use
    # wt.scalar(coroot) for coroots.

    # The Weyl vector rho satisfies <rho, alpha_i^vee> = 1 for all i
    # So the "depth" = sum_i n_i where diff = sum n_i alpha_i
    # is approximately <diff, rho>... but rho is not a coweight.

    # Let me try: express diff in terms of simple roots
    # diff = n_0 alpha_0 + n_1 alpha_1 + n_2 alpha_2
    # Then depth = n_0 + n_1 + n_2

    # To find n_i: <diff, alpha_j^vee> = sum_i n_i <alpha_i, alpha_j^vee> = sum_i n_i A_{ij}
    # where A is the Cartan matrix.
    # So n = A^{-1} (<diff, alpha_0^vee>, <diff, alpha_1^vee>, <diff, alpha_2^vee>)

    RS = RootSystem(['A',2,1])
    CL = RS.coroot_lattice()
    alpha_vee = CL.simple_roots()

    # Compute <diff, alpha_i^vee>
    d_vals = []
    for i in [0, 1, 2]:
        d_val = diff.scalar(alpha_vee[i])
        d_vals.append(d_val)

    # Cartan matrix of A_2^(1)
    A_cartan = matrix(QQ, [[2, -1, -1], [-1, 2, -1], [-1, -1, 2]])

    # Solve A * n = d_vals
    d_vec = vector(QQ, d_vals)
    try:
        n_vec = A_cartan.solve_right(d_vec)
        depth = sum(n_vec)
    except:
        # Singular because affine Cartan matrix has det 0
        # Use pseudoinverse or other approach
        depth = "?"

    print(f"  wt = {wt}, diff_scalars = {d_vals}, depth = {depth}")

# Alternative: use the epsilon values to define grading
# The "string lengths" epsilon_i(b) tell us how far b is from the top of string i
# The grading for principal specialization should be sum of epsilon_i

print("\nTrying grading: sum(epsilon_i)")
char_eps = R_poly(0)
for b in elems_12:
    eps = sum(b.epsilon(i) for i in [0, 1, 2])
    char_eps += q_var**eps

print(f"  char = {char_eps}")
print(f"  h_1  = 3*q + 3*q^2 + 2*q^3 + 2*q^4 + q^5 + q^6")

# Try: sum(epsilon_i) for i in {1,2} only (finite type)
print("\nTrying grading: epsilon_1 + epsilon_2 (finite type only)")
char_eps12 = R_poly(0)
for b in elems_12:
    eps = b.epsilon(1) + b.epsilon(2)
    char_eps12 += q_var**eps

print(f"  char = {char_eps12}")

# Try epsilon_0 only
print("\nTrying grading: epsilon_0")
char_eps0 = R_poly(0)
for b in elems_12:
    eps = b.epsilon(0)
    char_eps0 += q_var**eps

print(f"  char = {char_eps0}")

# Try phi values
print("\nTrying grading: phi_1 + phi_2")
char_phi = R_poly(0)
for b in elems_12:
    phi_sum = b.phi(1) + b.phi(2)
    char_phi += q_var**phi_sum

print(f"  char = {char_phi}")

# Try: a0 coefficient (Lambda_0 component)
# Since all weights are at level 7, wt = a0 L0 + a1 L1 + a2 L2 with a0+a1+a2 = 7
# The "a0" is related to the affine part.
print("\nTrying grading by Lambda_0 coefficient")

for b in elems_12:
    wt = b.weight()
    # Extract Lambda_0 coefficient
    # In SageMath, wt is expressed in the weight lattice
    # We can compute a_i = <wt, alpha_i^vee>... no wait.
    # <Lambda_i, alpha_j^vee> = delta_{ij}
    # So a_i = <wt, alpha_i^vee>... but that's not right because
    # <Lambda_0, alpha_0^vee> = 1, <Lambda_0, alpha_1^vee> = 0, <Lambda_0, alpha_2^vee> = 0
    # Hmm, actually <Lambda_i, alpha_j^vee> = delta_{ij} IS the definition.

    RS = RootSystem(['A',2,1])
    CL = RS.coroot_lattice()
    alpha_vee = CL.simple_roots()

    a0 = wt.scalar(alpha_vee[0])
    a1 = wt.scalar(alpha_vee[1])
    a2 = wt.scalar(alpha_vee[2])

    print(f"  wt = {wt}: (a0,a1,a2) = ({a0},{a1},{a2}), sum = {a0+a1+a2}")

# Now construct principal spec character using a0 value
# For h_1: the "depth 1" contribution should have a specific a0 pattern
# The hw has a0=3. Lower a0 = more affine depth.
# q-degree could be hw_a0 - a0 = 3 - a0

print("\nTrying grading: hw_a0 - a0 = 3 - a0")
char_a0 = R_poly(0)
for b in elems_12:
    wt = b.weight()
    RS = RootSystem(['A',2,1])
    alpha_vee = RS.coroot_lattice().simple_roots()
    a0 = wt.scalar(alpha_vee[0])
    grade = 3 - a0
    if grade >= 0:
        char_a0 += q_var**int(grade)
    else:
        print(f"  WARNING: negative grade {grade} for a0={a0}")

print(f"  char = {char_a0}")

# The correct grading for the principally specialized character of hat{sl}_3
# comes from the energy function. For LS paths, the energy function is defined
# via the initial direction of the path.
# In SageMath, this might be accessible through the one-dimensional sum formula.

# Let me try the one_dimensional_configuration_sum
print("\n" + "="*60)
print("One-dimensional configuration sum")
print("="*60)

# For KR crystals, there's the one_dimensional_configuration_sum
# that gives the fermionic formula = principally specialized character

try:
    # For a single KR crystal B^{r,s}:
    KR = crystals.KirillovReshetikhin(['A',2,1], 1, 1)
    print(f"B^{{1,1}}: {KR}")
    print(f"  dim = {KR.cardinality()}")
    # Try to compute the 1d config sum
    T = crystals.TensorProduct(KR, KR)
    print(f"B^{{1,1}} x B^{{1,1}}: dim = {T.cardinality()}")
except Exception as e:
    print(f"Error: {e}")

# The connection might be through KR crystals rather than LS paths.
# For cylindric partitions with k=3, d=7:
# F_{c,n}(q) might equal the 1d config sum of a specific tensor product of KR crystals.

# Schilling-Shimozono proved that the 1d configuration sum for
# B^{r,s1} tensor ... tensor B^{r,sn} equals the principally specialized
# Demazure character. For our case, we might need specific KR crystals.

# For cylindric partitions at k=3 (sl_3), the natural KR modules are
# B^{1,c_i} for each column of the cylindric partition profile.
# The 1dsum would then give the principally specialized character at depth n.

# Let me try: tensor product of KR crystals B^{1,1}^{n} and compute 1dsum
print("\nKR crystal tensor products:")
for n in range(1, 5):
    Bs = [crystals.KirillovReshetikhin(['A',2,1], 1, 1)] * n
    T = crystals.TensorProduct(*Bs)
    dim = T.cardinality()
    print(f"  B^{{1,1}}^{{{n}}}: dim = {dim}")

# B^{1,1} has dim 3, so B^{1,1}^n has dim 3^n. Not 12^n.
# We need something bigger.

# For level-7 representation: try B^{1,7}
try:
    B17 = crystals.KirillovReshetikhin(['A',2,1], 1, 7)
    print(f"\n  B^{{1,7}}: dim = {B17.cardinality()}")
    B27 = crystals.KirillovReshetikhin(['A',2,1], 2, 7)
    print(f"  B^{{2,7}}: dim = {B27.cardinality()}")
except Exception as e:
    print(f"  Error: {e}")

# Profile-dependent: c=(3,2,2) -> maybe B^{1,3} tensor B^{1,2} tensor B^{1,2}?
try:
    B13 = crystals.KirillovReshetikhin(['A',2,1], 1, 3)
    B12 = crystals.KirillovReshetikhin(['A',2,1], 1, 2)
    print(f"\n  B^{{1,3}}: dim = {B13.cardinality()}")
    print(f"  B^{{1,2}}: dim = {B12.cardinality()}")
    T = crystals.TensorProduct(B13, B12, B12)
    print(f"  B^{{1,3}} x B^{{1,2}} x B^{{1,2}}: dim = {T.cardinality()}")
except Exception as e:
    print(f"  Error: {e}")
