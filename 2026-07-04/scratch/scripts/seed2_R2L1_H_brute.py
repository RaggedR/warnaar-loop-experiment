# Brute force search for H formula
# d=2 data:
# H((c0,c1,c2), (c0',c1',c2'))
# where c0+c1+c2 = c0'+c1'+c2' = 2

data_d2 = {
    ((0,0,2), (0,0,2)): 0, ((0,0,2), (0,1,1)): 1, ((0,0,2), (0,2,0)): 2,
    ((0,0,2), (1,0,1)): 1, ((0,0,2), (1,1,0)): 2, ((0,0,2), (2,0,0)): 2,
    ((0,1,1), (0,0,2)): 0, ((0,1,1), (0,1,1)): 1, ((0,1,1), (0,2,0)): 1,
    ((0,1,1), (1,0,1)): 1, ((0,1,1), (1,1,0)): 2, ((0,1,1), (2,0,0)): 2,
    ((0,2,0), (0,0,2)): 0, ((0,2,0), (0,1,1)): 0, ((0,2,0), (0,2,0)): 0,
    ((0,2,0), (1,0,1)): 1, ((0,2,0), (1,1,0)): 1, ((0,2,0), (2,0,0)): 2,
    ((1,0,1), (0,0,2)): 0, ((1,0,1), (0,1,1)): 1, ((1,0,1), (0,2,0)): 1,
    ((1,0,1), (1,0,1)): 1, ((1,0,1), (1,1,0)): 1, ((1,0,1), (2,0,0)): 1,
    ((1,1,0), (0,0,2)): 0, ((1,1,0), (0,1,1)): 0, ((1,1,0), (0,2,0)): 0,
    ((1,1,0), (1,0,1)): 1, ((1,1,0), (1,1,0)): 1, ((1,1,0), (2,0,0)): 1,
    ((2,0,0), (0,0,2)): 0, ((2,0,0), (0,1,1)): 0, ((2,0,0), (0,2,0)): 0,
    ((2,0,0), (1,0,1)): 0, ((2,0,0), (1,1,0)): 0, ((2,0,0), (2,0,0)): 0,
}

# Observe: H((2,0,0), *) = 0 always
# H(*, (0,0,2)) = 0 always
# This means: if c has all 1's, H=0. If c' has all 3's, H=0.
# H((0,0,2), c') = c'_0 + c'_1 = d - c'_2
# Not quite: H((0,0,2), (0,1,1)) = 1 = 0+1 = c'_1. And c'_0+c'_1 = 1. YES
# H((0,0,2), (0,2,0)) = 2. c'_0+c'_1 = 2. YES
# H((0,0,2), (1,0,1)) = 1. c'_0+c'_1 = 1. YES
# H((0,0,2), (1,1,0)) = 2. c'_0+c'_1 = 2. YES
# H((0,0,2), (2,0,0)) = 2. c'_0+c'_1 = 2. YES
# So H((0,0,2), c') = c'_0 + c'_1 = d - c'_2

# H(c, (2,0,0)): max values per row
# = c_2 + c_1 = d - c_0
# Check: H((0,0,2), (2,0,0)) = 2 = 0+2 YES
# H((0,1,1), (2,0,0)) = 2 = 1+1 YES  
# H((0,2,0), (2,0,0)) = 2 = 0+2 YES
# H((1,0,1), (2,0,0)) = 1 = 0+1 YES
# H((1,1,0), (2,0,0)) = 1 = 1+0 YES

# So H(c, (d,0,0)) = c_1 + c_2 = d - c_0
# And H((0,0,d), c') = c'_0 + c'_1 = d - c'_2

# Now let me look at the general pattern
# H seems to measure "how much c is above c' in the dominance order"
# but in a specific way related to the letters

# Let me think of it as: for each entry in b1, count how many entries 
# in b2 are strictly less. Then divide by d.
# For b1=[3,3], b2=[1,2]: inversions = 3>1, 3>2, 3>1, 3>2 = 4 inversions
# 4/d = 4/2 = 2. But H = 1.

# Hmm. Half? 4/4 = 1? That works for this case.
# For b1=[2,3], b2=[1,2]: inversions = 2>1, 3>1, 3>2 = 3. 3/? 
# H = 1. Nope.

# What about: count pairs (i,j) where b1[i] > b2[j], then subtract
# something?

# Actually, the right formula for A_2^(1), B^{1,d} is likely
# from the theory of "winding numbers" but with the promotion operator

# Let me try a different approach: since the formula is constant on profiles,
# and I know H((2,0,0), *) = 0, let me write H as a polynomial in the c_i, c'_i

# For d=2:
# H = a*c_1*c'_0 + b*c_2*c'_0 + e*c_2*c'_1 + f*c_1*c'_1 + ...
# Linear terms: g*c_0 + h*c_1 + k*c_2 + l*c'_0 + m*c'_1 + n*c'_2

# From H(c,(0,0,2)) = 0 for all c: setting c'=(0,0,2) gives 0
# So any term involving only c_i is 0.

# From H((2,0,0),c') = 0: setting c=(2,0,0) gives 0
# So terms with only c'_j that also satisfy this...

# This is getting unwieldy. Let me just set up a linear system.
import numpy as np

# Features: all products c_i * c'_j for i,j in {0,1,2}
# Plus linear terms c_i and c'_j
# H should be a linear combination of these

features = []
targets = []
for (c, cp), h in data_d2.items():
    f = [c[i]*cp[j] for i in range(3) for j in range(3)]  # 9 products
    f += [c[i] for i in range(3)]  # 3 linear
    f += [cp[j] for j in range(3)]  # 3 linear
    f += [1]  # constant
    features.append(f)
    targets.append(h)

A = np.array(features, dtype=float)
b = np.array(targets, dtype=float)

# Solve least squares
x, res, rank, sv = np.linalg.lstsq(A, b, rcond=None)

print("Coefficient fitting for d=2:")
labels = [f"c{i}*c'{j}" for i in range(3) for j in range(3)]
labels += [f"c{i}" for i in range(3)]
labels += [f"c'{j}" for j in range(3)]
labels += ["const"]

for label, coef in zip(labels, x):
    if abs(coef) > 1e-10:
        print(f"  {label}: {coef:.6f}")

# Check residual
pred = A @ x
print(f"\nMax residual: {max(abs(pred - b)):.10f}")

# Check if coefficients are rational
from fractions import Fraction
print("\nRational coefficients:")
for label, coef in zip(labels, x):
    if abs(coef) > 1e-10:
        frac = Fraction(coef).limit_denominator(100)
        print(f"  {label}: {frac}")

