# Warnaar's Conjecture 2 for GK_{(c_0,c_1,c_2)}(z,q)
# For d=4, k=1: profiles (c_0,c_1,c_2) with c_0+c_1+c_2=4
# t = 4+3 = 7, modulus 7 = 3*1+4, so k=1 with 3k+1=4 type
# Wait: d = c_0+c_1+c_2, t = d+3
# For d=4: t=7, and 7 = 3*2+1 -> k=2 with modulus 3k+1 type
# or 7 = 3*1+4 which doesn't match standard form

# Actually Warnaar's formulas are parameterized differently
# The key profiles for explicit formulas are:
# For modulus 3k+2: profile (k,k,k-1), d=3k-1
# For modulus 3k+1: similar

# d=4 doesn't correspond to k=1 in the simplest way
# Let me instead focus on what I've already discovered
# and explore the structural connection between H and the transfer matrix

# The key new insight to explore:
# 1. H(c,c') is constant on profiles (proved)
# 2. H defines a 15x15 matrix for d=4
# 3. The transfer matrix A also gives a 15x15 system
# 4. Can we relate H to A?

# From Round 1: adj(I-A(x))[c,c'] = x^{EMD(c,c')}
# and det(I-A(x)) = -(x^3-1)
# So (I-A(x))^{-1}[c,c'] = x^{EMD(c,c')} / (1-x^3)

# The ODCS for B^{1,d}^{tensor n} gives:
# sum_{c1,...,cn} q^{sum H(c_i, c_{i+1})} = Tr(M_H(q)^{n-1} * 1)
# where M_H(q)[c,c'] = q^{H(c,c')}

# So the ODCS is governed by the matrix M_H
# while F_{c,n} is governed by the matrix (I-A(q^n))^{-1}

# The question: is there a transform connecting M_H to A?

from sage.all import *

# Let me compute M_H for d=2 (6x6) and see its structure

d = 2
K = crystals.KirillovReshetikhin(['A',2,1], 1, d)
T = crystals.TensorProduct(K, K)

def prof(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

profiles = sorted(set(prof(b) for b in K))
N = len(profiles)
prof_idx = {p: i for i, p in enumerate(profiles)}

H_mat = {}
for b in T:
    p1, p2 = prof(b[0]), prof(b[1])
    H_mat[(p1, p2)] = b.energy_function()

# Build M_H matrix
R = QQ['q']
q = R.gen()

MH = matrix(R, N, N)
for i, c in enumerate(profiles):
    for j, cp in enumerate(profiles):
        MH[i,j] = q**H_mat[(c,cp)]

print(f"M_H for d={d}:")
print(f"Profiles: {profiles}")
print(MH)

# Characteristic polynomial
cp_MH = MH.charpoly()
print(f"\nChar poly of M_H: {cp_MH}")

# Eigenvalues at q=1
MH_q1 = matrix(QQ, N, N, [MH[i,j](q=1) for i in range(N) for j in range(N)])
print(f"\nM_H at q=1:")
print(MH_q1)
print(f"Eigenvalues at q=1: {MH_q1.eigenvalues()}")

# Compare with the CW transfer matrix A
# A(x) for d=2 has entries that encode the CW recurrence
# From Round 1: adj(I-A(x))[c,c'] = x^{EMD(c,c')}

# Let me compute EMD for d=2
def emd(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

# Build EMD matrix
EMD_mat = matrix(ZZ, N, N)
for i, c in enumerate(profiles):
    for j, cp in enumerate(profiles):
        EMD_mat[i,j] = emd(c, cp)

print(f"\nEMD matrix for d={d}:")
print(EMD_mat)

# Build M_EMD = matrix with entries x^{EMD}
M_EMD = matrix(R, N, N)
for i, c in enumerate(profiles):
    for j, cp in enumerate(profiles):
        M_EMD[i,j] = q**emd(c, cp)

print(f"\nM_EMD:")
print(M_EMD)

# Now: adj(I-A(x)) = M_EMD means
# I - A(x) = M_EMD^{-1} * det(I-A(x)) = -M_EMD^{-1} * (x^3-1)
# So A(x) = I + M_EMD^{-1} * (x^3-1)

# But this means A(x) depends on x, and M_EMD is independent of x
# Hmm wait, M_EMD already has x (which is q here) in it
# The variable x in the transfer matrix is the "spectral parameter"
# while q in the energy function is a different variable

# Actually, in the cylindric partition context:
# F_c(z,q) = sum_n F_{c,n}(q) z^n
# The transfer matrix gives F_{c,n}(q) = [product of (I-A(q^k))^{-1}]_{c,c_0}
# So the "x" in A(x) is evaluated at x=q^k for different levels k

# While in the crystal context, the energy function uses q as the grading variable

# These are the SAME q! The question is whether the H-matrix
# is related to A evaluated at some specific q-value

# Let me check: does M_H = (I-A(q))^{-1} * (1-q^3) or something like that?

# First, let me try to extract A from the EMD data
# A(x) = I + M_EMD(x)^{-1} * (x^3-1) where M_EMD(x)[i,j] = x^{EMD(i,j)}
# Wait, adj(I-A(x)) = M_EMD(x), not (I-A(x))^{-1}

# adj(M) = det(M) * M^{-1}, so M_EMD = adj(I-A(x)) = det(I-A(x)) * (I-A(x))^{-1}
# det(I-A(x)) = -(x^3-1) = (1-x)(1+x+x^2)

# So (I-A(x))^{-1} = M_EMD(x) / det(I-A(x)) = M_EMD(x) / (-(x^3-1))

# And I - A(x) = det(I-A(x)) * M_EMD(x)^{-1} = -(x^3-1) * M_EMD(x)^{-1}
# A(x) = I + (x^3-1) * M_EMD(x)^{-1}

# Let me compute A(x) from this
M_EMD_x = matrix(R, N, N)
for i, c in enumerate(profiles):
    for j, cp in enumerate(profiles):
        M_EMD_x[i,j] = q**emd(c, cp)

try:
    M_EMD_inv = M_EMD_x.inverse()
    A_x = matrix(R, N, N, lambda i,j: (1 if i==j else 0) + (q**3-1)*M_EMD_inv[i,j])
    print(f"\nTransfer matrix A(q) for d={d}:")
    print(A_x)
except Exception as e:
    print(f"Error computing A: {e}")

# Now check: is M_H related to (I-A(q))^{-1}?
# (I-A(q))^{-1} = M_EMD(q) / (-(q^3-1)) = -M_EMD(q) / (q^3-1)
IminusA_inv = M_EMD_x * (1 / (-(q**3-1)))
print(f"\n(I-A(q))^{{-1}} for d={d}:")
print(IminusA_inv)

# Compare with M_H
print(f"\nM_H - (I-A(q))^{{-1}}:")
diff = MH - IminusA_inv
print(diff)

# Check if M_H is related to (I-A(q))^{-1} by a scalar
print("\nRatio M_H / (I-A(q))^{-1} element-wise:")
for i in range(N):
    for j in range(N):
        if IminusA_inv[i,j] != 0:
            ratio = MH[i,j] / IminusA_inv[i,j]
            print(f"  ({profiles[i]},{profiles[j]}): M_H={MH[i,j]}, inv={IminusA_inv[i,j]}, ratio={ratio}")

