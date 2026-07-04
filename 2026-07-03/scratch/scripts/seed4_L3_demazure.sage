"""
Seed 4, Layer 3: Check if Q_n matches affine Demazure characters via SageMath.
Try hat{sl}_3 at level 7 with highest weight 3*Lambda_0 + 2*Lambda_1 + 2*Lambda_2.
"""

# SageMath has tools for affine Lie algebras
# Let's try to construct the relevant crystals/characters

from sage.combinat.root_system.weyl_characters import WeylCharacterRing

# First check what's available for affine type A
print("="*60)
print("Testing affine Demazure character computation")
print("="*60)

# For hat{sl}_3 = A_2^(1), level d=7
# The relevant Cartan type is ['A', 2, 1]
try:
    ct = CartanType(['A', 2, 1])
    print(f"Cartan type: {ct}")
    
    # Try to build the crystal
    from sage.combinat.crystals.kirillov_reshetikhin import KirillovReshetikhinCrystal
    
    # Level 7, hat{sl}_3
    # Highest weight lambda = 3*Lambda_0 + 2*Lambda_1 + 2*Lambda_2
    # In affine type A_2^(1), the fundamental weights are Lambda_0, Lambda_1, Lambda_2
    
    # Use the LS path model or Demazure crystal
    print("\nAttempting to construct highest weight crystal...")
    
    from sage.combinat.crystals.highest_weight_crystals import HighestWeightCrystal
    
    # For affine crystals at level 7, we need the weight lattice
    RootSystem_A2_aff = RootSystem(ct)
    wl = RootSystem_A2_aff.weight_lattice(extended=True)
    Lambda = wl.fundamental_weights()
    
    print(f"Fundamental weights: Lambda_0={Lambda[0]}, Lambda_1={Lambda[1]}, Lambda_2={Lambda[2]}")
    
    # The highest weight for profile (3,2,2)
    hw = 3*Lambda[0] + 2*Lambda[1] + 2*Lambda[2]
    print(f"Highest weight for (3,2,2): {hw}")
    print(f"Level = {hw.level()}")
    
    # Try to construct the crystal
    # SageMath can handle affine crystals but they're infinite
    # We need to use Demazure crystals which are finite truncations
    
    # The Demazure operator for the n-th step:
    # In hat{sl}_3, the Weyl group element w = s_0 s_1 s_2 s_0 s_1 s_2 ... (reduced word)
    # The Demazure crystal B_w(lambda) consists of all crystal elements reachable
    # from the highest weight vector by applying f_i operators in the order given by w
    
    # For depth n, the word should be (s_0 s_1 s_2)^n or similar
    # Let's try the LS path realization
    
    # Actually, let me try a simpler approach first: 
    # use the Kirillov-Reshetikhin (KR) crystals
    
    # KR crystal B^{r,s} for A_2^(1): r in {1,2}, s >= 1
    # B^{1,1} tensor B^{1,1} tensor ... might work
    
    # But this is not directly the Demazure crystal.
    # Let me try computing Q_1 and seeing if it matches any known object.
    
    # For d=7, c=(3,2,2), Q_1 = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6, sum=11
    # This has 11 = base-1 terms (where base = 12)
    
    # In the finite type A_2 setting:
    # Demazure characters of GL_3 are "key polynomials" K_u(x1,x2,x3)
    # At principal specialization x_i = q^i:
    # K_{(0,0,0)}(q,q^2,q^3) = 1
    # K_{(1,0,0)}(q,q^2,q^3) = q + q^2 + q^3
    # K_{(0,1,0)}(q,q^2,q^3) = q^2 + q^3  (?)
    # K_{(0,0,1)}(q,q^2,q^3) = q^3
    
    # Let me compute finite type A_2 Demazure characters
    print("\n" + "="*60)
    print("Finite type A_2 Demazure/key polynomial analysis")
    print("="*60)
    
    A2 = WeylCharacterRing("A2", style="coroots")
    
    # The Weyl character ring for A_2 with basis of Demazure characters
    # In SageMath, WeylCharacterRing computes irreducible characters (Schur functions)
    # For Demazure characters, we need a different approach
    
    # Let's use the crystal approach
    from sage.combinat.crystals.tensor_product import TensorProductOfCrystals
    from sage.combinat.crystals.letters import CrystalOfLetters
    
    C = CrystalOfLetters(['A', 2])
    print(f"Crystal of letters for A_2: {list(C)}")
    
    # B(Lambda_1) = standard crystal with elements 1, 2, 3
    # Principal specialization: weight (a,b,c) -> q^(a + 2b + 3c) at (q, q^2, q^3)
    # Actually, weight w = (w1, w2, w3) maps to x1^w1 x2^w2 x3^w3
    # Principal spec: x_i = q^i gives q^(w1 + 2w2 + 3w3)
    
    # For B(Lambda_1): weights are e_1, e_2, e_3
    # q^1, q^2, q^3 -> character = q + q^2 + q^3
    
    # For B(lambda) with lambda = (a,b): in coroot notation
    # s_{(a,b)} = irreducible character
    
    # Let's compute Q_1 for d=4, c=(2,1,1)
    # Q_1 = 2q + q^2 + q^3, sum=4 = base-1
    # Is this a Demazure character at principal specialization?
    
    # For A_2 with partition (1,0): s_{(1,0)} at (q,q^2,q^3) = q + q^2 + q^3
    # For A_2 with partition (1,1): s_{(1,1)} at (q,q^2,q^3) = ?
    
    # Let me compute characters at principal specialization
    R = PolynomialRing(QQ, 'q')
    q = R.gen()
    
    for wt in [(1,0), (0,1), (2,0), (1,1), (0,2), (3,0), (2,1), (1,2), (0,3)]:
        ch = A2(wt)
        # Get the weight multiplicities
        wm = ch.weight_multiplicities()
        # Principal specialization: weight (a,b,c) -> q^(a + 2b + 3c)
        # In coroot notation for A_2, weight Lambda = w1*eps1 + w2*eps2 + w3*eps3
        # with w1+w2+w3=0 (trace-free part)
        # Actually in SageMath's convention...
        poly = R(0)
        for w, m in wm.items():
            # w is a weight in the weight lattice
            # For A2, weights are linear combinations of eps_1, eps_2, eps_3
            # Principal spec: q^(w[0] + 2*w[1] + 3*w[2]) where w = (w[0], w[1], w[2])
            coeffs = list(w.to_vector())
            if len(coeffs) >= 3:
                exp = coeffs[0] + 2*coeffs[1] + 3*coeffs[2]
            else:
                exp = sum((i+1)*c for i,c in enumerate(coeffs))
            poly += m * q^int(exp)
        print(f"  s_{wt} at principal spec: {poly}, sum={poly(q=1)}")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()

