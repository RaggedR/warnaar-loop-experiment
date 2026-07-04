"""
Seed 3, R2L2, Script 5: connect H-recursion to the CW matrix A(x).

A(x)[c,c'] = sum_{J subset I_c nonempty, c(J)=c'} (-1)^{|J|-1} x^{|J|}  (seed4 convention).
Adjugate Monomial Thm: adj(I-A)[c,c'] = x^{EMD(c,c')} (some EMD orientation), det(I-A)=1-x^3.
Our M(x)[c,c'] = x^{emd(c',c)} (emd(cp,c) with e=cp-c).
Check: M = (1-x^3)(I-A)^{-1} or transpose?
Then verify the EXACT cross-level identity:
   H_{m+1} = A-side * H_{m+1} + (1-q^{m+1}) H_m   (orientation as found)
and test inequalities (C1),(C1'),(C2 variants).
"""
Rx.<x> = PolynomialRing(QQ)

def profiles(d):
    return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]

def emd(cp, c):
    e = [cp[i] - c[i] for i in range(3)]
    return 2*e[0] + e[1] + 3*max(0, -e[0], -e[0]-e[1])

def I_c(c): return [i for i in range(3) if c[i] > 0]

def shifted_profile(c, J):
    J = set(J); res = list(c)
    for i in range(3):
        prev = (i-1) % 3
        if i in J and prev not in J: res[i] -= 1
        elif i not in J and prev in J: res[i] += 1
    return tuple(res)

from itertools import combinations
d = 4
profs = profiles(d)
n = len(profs)
idx = {p: i for i, p in enumerate(profs)}
A = matrix(Rx, n, n, 0)
for c in profs:
    for r in range(1, 4):
        for J in combinations(I_c(c), r):
            cJ = shifted_profile(c, J)
            A[idx[c], idx[cJ]] += (-1)^(len(J)-1) * x^len(J)

B = identity_matrix(Rx, n) - A
print("det(I-A) =", B.det())
Binv_scaled = B.adjugate()  # = det * B^{-1}
M = matrix(Rx, n, n, lambda i, j: x^emd(profs[j], profs[i]))
print("M == adj(I-A):", M == Binv_scaled)
print("M == adj(I-A)^T:", M == Binv_scaled.transpose())

# Whichever holds, we get M/(1+x+x^2) = (1-x) * (I-A)^{-1} (or transpose).
# Cross-level identity: (1+q^m+q^{2m}) H_m = M(q^m) H_{m-1}
# If M = (1-x^3)(I-A)^{-1}:  (I-A(q^m)) H_m = (1-q^m) H_{m-1}
#   i.e. H_{c,m} = sum_J (-1)^{|J|-1} q^{m|J|} H_{c(J),m} + (1-q^m) H_{c,m-1}
# If M = (1-x^3)(I-A^T)^{-1}: transposed sum.

Rq.<q> = PolynomialRing(ZZ)
def compute_H(d, m_max):
    profs = profiles(d)
    Hs = [{c: Rq(1) for c in profs}]
    for m in range(1, m_max+1):
        div = 1 + q^m + q^(2*m)
        Hnew = {}
        for c in profs:
            rhs = sum(q^(m*emd(cp, c)) * Hs[m-1][cp] for cp in profs)
            quo, rem = rhs.quo_rem(div)
            assert rem == 0
            Hnew[c] = quo
        Hs.append(Hnew)
    return Hs

m_max = 6
Hs = compute_H(d, m_max)

# verify cross-level identity, untransposed version:
ok_untr, ok_tr = True, True
for m in range(1, m_max+1):
    for c in profs:
        rhs = Rq(0)
        for r in range(1, 4):
            for J in combinations(I_c(c), r):
                cJ = shifted_profile(c, J)
                rhs += (-1)^(r-1) * q^(m*r) * Hs[m][cJ]
        if Hs[m][c] != rhs + (1 - q^m) * Hs[m-1][c]:
            ok_untr = False
        # transposed: sum over c' and J subset I_{c'} with c'(J) = c
        rhsT = Rq(0)
        for cp in profs:
            for r in range(1, 4):
                for J in combinations(I_c(cp), r):
                    if shifted_profile(cp, J) == c:
                        rhsT += (-1)^(r-1) * q^(m*r) * Hs[m][cp]
        if Hs[m][c] != rhsT + (1 - q^m) * Hs[m-1][c]:
            ok_tr = False
print("cross-level identity (J-sum over I_c, i.e. H_c,m = sum_J ... H_{c(J),m} + (1-q^m)H_{c,m-1}):", ok_untr)
print("cross-level identity transposed:", ok_tr)

# inequalities
def geq(f, g): return all(v >= 0 for v in (f - g).list())

for m in range(1, m_max+1):
    C1 = all(geq(Hs[m][shifted_profile(c, (i,))], Hs[m-1][c]) for c in profs for i in I_c(c))
    C1all = all(geq(Hs[m][shifted_profile(c, J)], Hs[m-1][c])
                for c in profs for r in range(1, 4) for J in combinations(I_c(c), r))
    # within-level shifted domination along CW edges: H_{c(i)} >= q^m H_{c(ij)}
    C2 = all(geq(Hs[m][shifted_profile(c, (i,))], q^m * Hs[m][shifted_profile(c, J)])
             for c in profs for r in [2] for J in combinations(I_c(c), r) for i in J)
    print(f"m={m}: C1(single J, cross-level):{C1}  C1'(all J):{C1all}  C2(within-level q^m dom):{C2}")
