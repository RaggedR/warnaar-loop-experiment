# Verify key polynomial decomposition of Q_1 for d=4
R.<q> = PowerSeriesRing(ZZ, default_prec=50)

# From computation above, Demazure chars at x_i = q^i:
D = {}  # D[(hw, word)] = polynomial
# lambda = (1,0): V = C^3
D[((1,0), ())] = R(q)
D[((1,0), (1,))] = R(q + q^2)
D[((1,0), (2,))] = R(q)
D[((1,0), (1,2))] = R(q + q^2)
D[((1,0), (2,1))] = R(q + q^2 + q^3)
D[((1,0), (1,2,1))] = R(q + q^2 + q^3)  # = Schur s_{(1,0)}

# lambda = (0,1): V = wedge^2(C^3) = C^3*
D[((0,1), ())] = R(q^3)
D[((0,1), (1,))] = R(q^3)
D[((0,1), (2,))] = R(q^3 + q^4)
D[((0,1), (1,2))] = R(q^3 + q^4 + q^5)
D[((0,1), (2,1))] = R(q^3 + q^4)
D[((0,1), (1,2,1))] = R(q^3 + q^4 + q^5)  # = Schur s_{(1,1)}

# lambda = (2,0): S^2(C^3)
D[((2,0), ())] = R(q^2)
D[((2,0), (1,))] = R(q^2 + q^3 + q^4)
D[((2,0), (2,))] = R(q^2)
D[((2,0), (1,2))] = R(q^2 + q^3 + q^4)
D[((2,0), (2,1))] = R(q^2 + q^3 + 2*q^4 + q^5 + q^6)
D[((2,0), (1,2,1))] = R(q^2 + q^3 + 2*q^4 + q^5 + q^6)  # = Schur s_{(2,0)}

# lambda = (0,2):
D[((0,2), ())] = R(q^6)

# lambda = (3,0):
D[((3,0), ())] = R(q^3)
D[((3,0), (1,))] = R(q^3 + q^4 + q^5 + q^6)

# lambda = (4,0):
D[((4,0), ())] = R(q^4)
D[((4,0), (1,))] = R(q^4 + q^5 + q^6 + q^7 + q^8)

# Q_1 values for d=4:
Q1 = {
    (4,0,0): R(q^2 + q^3 + q^4 + q^6),
    (3,1,0): R(q + q^2 + q^3 + q^4),
    (2,2,0): R(q + 2*q^2 + q^4),
    (2,1,1): R(2*q + q^2 + q^3),
    (3,0,1): R(q + q^2 + q^3 + q^5),
}

# Try decompositions:
print("=== Key polynomial decompositions of Q_1, d=4 ===")

# Q_1((2,1,1)) = 2q + q^2 + q^3
# = D_id((1,0)) + D_{s2s1}((1,0))
# = q + (q + q^2 + q^3)
check = D[((1,0), ())] + D[((1,0), (2,1))]
print(f"Q_1((2,1,1)) = {Q1[(2,1,1)]}")
print(f"D_id((1,0)) + D_{{s2s1}}((1,0)) = {check}")
print(f"Match: {Q1[(2,1,1)] == check}")

# Q_1((3,1,0)) = q + q^2 + q^3 + q^4
# This is D_{s1}((2,0)) = q^2 + q^3 + q^4 plus D_id((1,0)) = q
check2 = D[((1,0), ())] + D[((2,0), (1,))]
print(f"\nQ_1((3,1,0)) = {Q1[(3,1,0)]}")
print(f"D_id((1,0)) + D_{{s1}}((2,0)) = {check2}")
print(f"Match: {Q1[(3,1,0)] == check2}")

# Q_1((4,0,0)) = q^2 + q^3 + q^4 + q^6
# = D_{s1}((2,0)) + D_id((0,2))
# = (q^2 + q^3 + q^4) + q^6
check3 = D[((2,0), (1,))] + D[((0,2), ())]
print(f"\nQ_1((4,0,0)) = {Q1[(4,0,0)]}")
print(f"D_{{s1}}((2,0)) + D_id((0,2)) = {check3}")
print(f"Match: {Q1[(4,0,0)] == check3}")

# Q_1((2,2,0)) = q + 2q^2 + q^4
# Try: D_id((1,0)) + D_id((2,0)) + D_id((0,1)) ... no, that's q + q^2 + q^3
# Try: D_{s1}((1,0)) + D_id((2,0)) = (q + q^2) + q^2 = q + 2q^2 -- missing q^4
# Try: D_{s1}((1,0)) + D_id((4,0)) = (q + q^2) + q^4 = q + q^2 + q^4 -- missing q^2
# Try: D_{s1}((1,0)) + D_{s1}((1,0)) = 2q + 2q^2 -- wrong
# Try: D_id((1,0)) + D_{s2}((2,0)) + D_id((4,0)) = q + q^2 + q^4 -- missing q^2
# Try: D_{s1}((1,0)) + D_id((0,1)) + ... hmm
# q + 2q^2 + q^4 = (q + q^2) + q^2 + q^4 = D_{s1}((1,0)) + D_id((2,0)) + D_id((4,0))
# = (q + q^2) + q^2 + q^4 = q + 2q^2 + q^4. YES!
check4 = D[((1,0), (1,))] + D[((2,0), ())] + D[((4,0), ())]
print(f"\nQ_1((2,2,0)) = {Q1[(2,2,0)]}")
print(f"D_{{s1}}((1,0)) + D_id((2,0)) + D_id((4,0)) = {check4}")
print(f"Match: {Q1[(2,2,0)] == check4}")

# Hmm, that sum has dim 1+1+1+1 = 4 but involves 3 key polys. 
# Actually D_{s1}((1,0)) has 2 elements, D_id((2,0)) has 1, D_id((4,0)) has 1. Total = 4. ✓

# Q_1((3,0,1)) = q + q^2 + q^3 + q^5
# Try: D_{s2s1}((1,0)) + D_id((2,1))... D_id((2,1)) = q^5 at spec q^i? 
# lambda = (2,1): partition (3,1). At spec q^i: HW = SSYT with 3 ones, 1 two = [[1,1,1],[2]]
# degree = 1*3 + 2*1 = 5. D_id((2,1)) = q^5.
# D_{s2s1}((1,0)) + D_id((2,1)) = (q + q^2 + q^3) + q^5 = q + q^2 + q^3 + q^5. YES!
# Need to verify D_id((2,1)):
from sage.combinat.crystals.tensor_product import CrystalOfTableaux
C = CrystalOfTableaux(['A', 2], shape=[3, 1])
hw = C.highest_weight_vectors()[0]
tab_hw = hw.to_tableau()
w_hw = [0,0,0]
for row in tab_hw:
    for entry in row:
        w_hw[entry-1] += 1
deg_hw = sum((i+1)*w_hw[i] for i in range(3))
print(f"\nD_id((2,1)) at q^i = q^{deg_hw}")

check5 = D[((1,0), (2,1))] + R(q^deg_hw)
print(f"Q_1((3,0,1)) = {Q1[(3,0,1)]}")
print(f"D_{{s2s1}}((1,0)) + D_id((2,1)) = {check5}")
print(f"Match: {Q1[(3,0,1)] == check5}")

print("\n\n=== SUMMARY OF DECOMPOSITIONS ===")
print("Q_1((2,1,1)) = kappa_{(0,0,1)} + kappa_{(0,1,0)}")  
print("  = D_id(Lambda_1) + D_{s2s1}(Lambda_1)")
print("  = q + (q + q^2 + q^3)")
print()
print("Q_1((3,1,0)) = kappa_{(0,0,1)} + kappa_{(0,2,0)}")
print("  = D_id(Lambda_1) + D_{s1}(2*Lambda_1)")
print("  = q + (q^2 + q^3 + q^4)")
print()
print("Q_1((4,0,0)) = kappa_{(0,2,0)} + kappa_{(0,0,2)}")
print("  = D_{s1}(2*Lambda_1) + D_id(2*Lambda_2)")
print("  = (q^2 + q^3 + q^4) + q^6")
print()
print("Q_1((2,2,0)) = kappa_{(0,1,0)} + kappa_{(2,0,0)} + kappa_{(4,0,0)}")
print("  = D_{s1}(Lambda_1) + D_id(2*Lambda_1) + D_id(4*Lambda_1)")
print("  = (q + q^2) + q^2 + q^4")
print()
print("Q_1((3,0,1)) = kappa_{(0,1,0)} + kappa_{(3,1,0)}")
print("  = D_{s2s1}(Lambda_1) + D_id(2*Lambda_1 + Lambda_2)")
print("  = (q + q^2 + q^3) + q^5")

