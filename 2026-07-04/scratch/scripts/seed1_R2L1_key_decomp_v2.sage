# Decompose Q_n into GL_3 key polynomials at specialisation (q, q^2, q^3)
from sage.all import *

R = PolynomialRing(QQ, 'q')
q = R.gen()

# GL_3 key polynomials
P3 = PolynomialRing(QQ, 'x1,x2,x3')
x1, x2, x3 = P3.gens()

def demazure_op(i, f):
    """i-th Demazure operator (1-indexed: pi_1 swaps x1,x2; pi_2 swaps x2,x3)"""
    vars = [x1, x2, x3]
    xi = vars[i-1]
    xj = vars[i]
    subs_dict = {xi: xj, xj: xi}
    sf = f.subs(subs_dict)
    num = xi * f - xj * sf
    result = P3(num) // P3(xi - xj)
    return result

def key_polynomial(alpha):
    """Compute key polynomial kappa_alpha for GL_3."""
    a = list(alpha)
    if all(a[i] >= a[i+1] for i in range(2)):
        return x1**a[0] * x2**a[1] * x3**a[2]
    for i in range(2):
        if a[i] < a[i+1]:
            a_new = list(a)
            a_new[i], a_new[i+1] = a_new[i+1], a_new[i]
            kappa_s = key_polynomial(tuple(a_new))
            return demazure_op(i+1, kappa_s)

def specialise(poly):
    """Evaluate polynomial at x1=q, x2=q^2, x3=q^3."""
    result = R(0)
    for coeff, mon in zip(poly.coefficients(), poly.monomials()):
        exp = mon.degrees()
        power = exp[0] * 1 + exp[1] * 2 + exp[2] * 3
        result += coeff * q**power
    return result

# Generate all GL_3 key polynomials up to a given total degree
# Total degree of kappa_alpha at (q, q^2, q^3) is at most 1*a1 + 2*a2 + 3*a3
# But we need to cover the degree of Q_n

# Q_n for d=2 has degree n*(n+1)/2 * something... let's see:
# Q_1 degree 3, Q_2 degree 10, Q_3 degree 21, Q_4 degree 36
# This is n*(3n+3)/2 - n? Actually 3, 10, 21, 36 = n(3n+1)/2... 
# n=1: 2, n=2: 7, no. Let me check: 3, 10, 21, 36. Differences: 7, 11, 15. Second differences: 4, 4. So quadratic: 2n^2 + n for n>=1? n=1: 3, n=2: 10, n=3: 21, n=4: 36. 2+1=3, 8+2=10, 18+3=21, 32+4=36. Yes!
# deg(Q_n) = 2n^2 + n

# Need key polynomials with specialisation degree up to 2n^2 + n
# kappa_{(a,b,c)} at (q,q^2,q^3) has terms of degree at most a + 2b + 3c
# and the max weight monomial is a + 2b + 3c (from x1^a * x2^b * x3^c if dominant)

# Build basis of specialised key polynomials
def build_key_basis(max_degree):
    """Build all distinct specialised key polynomials up to given degree."""
    basis = {}
    # alpha = (a, b, c) with a + 2b + 3c <= max_degree
    for c_val in range(max_degree // 3 + 1):
        for b_val in range((max_degree - 3*c_val) // 2 + 1):
            for a_val in range(max_degree - 2*b_val - 3*c_val + 1):
                alpha = (a_val, b_val, c_val)
                kp = key_polynomial(alpha)
                sp = specialise(kp)
                if sp != 0 and sp not in basis.values():
                    basis[alpha] = sp
    return basis

# For Q_1, max degree = 3
print("=== Decomposing Q_1 for d=2, c=(1,1,0) ===")
Q1 = q^3 + 2*q^2 + q + 1

# Build key polynomial basis
basis = build_key_basis(3)
print(f"Key polynomial basis (degree <= 3):")
for alpha, sp in sorted(basis.items()):
    print(f"  kappa_{alpha} = {sp}")

# Try to decompose Q_1 as nonneg sum of key polynomials
# This is a nonneg integer linear programming problem
# Let's do it greedily or by LP

# Actually, let me just enumerate
# Q_1 = q^3 + 2*q^2 + q + 1
# Available key polynomials at (q, q^2, q^3):
# kappa_(0,0,0) = 1
# kappa_(1,0,0) = q
# kappa_(0,1,0) = q^2 + q
# kappa_(0,0,1) = q^3 + q^2 + q
# kappa_(2,0,0) = q^2
# kappa_(1,1,0) = q^3
# kappa_(1,0,1) = q^4 + q^3 (too big)
# kappa_(3,0,0) = q^3
# kappa_(0,1,0) = q^2 + q  -> different from kappa_(2,0,0)

# Let me list them all carefully
print("\nAll specialised key polys up to degree 3:")
for total in range(4):
    for c_val in range(total // 3 + 1):
        for b_val in range((total - 3*c_val) // 2 + 1):
            a_val = total - 2*b_val - 3*c_val
            if a_val >= 0:
                alpha = (a_val, b_val, c_val)
                kp = key_polynomial(alpha)
                sp = specialise(kp)
                print(f"  kappa_{alpha} = {sp}  [kp = {kp}]")

# Let me solve the decomposition problem systematically
from sage.numerical.mip import MixedIntegerLinearProgram

def decompose_into_keys(target_poly, max_degree):
    """Decompose target_poly into nonneg integer combination of specialised key polys."""
    # Build all key polys
    key_list = []
    for c_val in range(max_degree // 3 + 1):
        for b_val in range((max_degree - 3*c_val) // 2 + 1):
            for a_val in range(max_degree - 2*b_val - 3*c_val + 1):
                alpha = (a_val, b_val, c_val)
                sp = specialise(key_polynomial(alpha))
                if sp != 0:
                    key_list.append((alpha, sp))
    
    # Set up ILP
    p = MixedIntegerLinearProgram(maximization=False, solver='GLPK')
    x = p.new_variable(integer=True, nonneg=True)
    
    # For each degree d, sum of coefficients must equal target[d]
    for deg in range(max_degree + 1):
        target_coeff = target_poly[deg] if deg <= target_poly.degree() else 0
        constraint = sum(x[i] * sp[deg] for i, (alpha, sp) in enumerate(key_list) if deg <= sp.degree()) 
        p.add_constraint(constraint == target_coeff)
    
    # Minimize total (or just find feasible)
    p.set_objective(sum(x[i] for i in range(len(key_list))))
    
    try:
        p.solve()
        solution = {}
        for i, (alpha, sp) in enumerate(key_list):
            val = int(round(p.get_values(x[i])))
            if val > 0:
                solution[alpha] = val
        return solution
    except Exception as e:
        print(f"  No decomposition found: {e}")
        return None

print("\n\n=== Decomposition of Q_1 ===")
Q1 = q**3 + 2*q**2 + q + 1
sol = decompose_into_keys(Q1, 3)
if sol:
    print(f"Q_1 = " + " + ".join(f"{v}*kappa_{k}" for k, v in sorted(sol.items())))
    # Verify
    check = sum(v * specialise(key_polynomial(k)) for k, v in sol.items())
    print(f"Verification: {check == Q1}")

print("\n\n=== Decomposition of Q_2 ===")
Q2 = q**10 + q**9 + 3*q**8 + 3*q**7 + 6*q**6 + 4*q**5 + 3*q**4 + q**3 + q**2 + q + 1
sol2 = decompose_into_keys(Q2, 10)
if sol2:
    print(f"Q_2 = " + " + ".join(f"{v}*kappa_{k}" for k, v in sorted(sol2.items())))
    check = sum(v * specialise(key_polynomial(k)) for k, v in sol2.items())
    print(f"Verification: {check == Q2}")

print("\n\n=== Decomposition of Q_3 ===")
Q3 = q**21 + q**20 + 2*q**19 + 3*q**18 + 5*q**17 + 7*q**16 + 9*q**15 + 12*q**14 + 14*q**13 + 15*q**12 + 14*q**11 + 13*q**10 + 8*q**9 + 6*q**8 + 3*q**7 + 4*q**6 + 3*q**5 + 2*q**4 + q**2 + q + 1
sol3 = decompose_into_keys(Q3, 21)
if sol3:
    print(f"Q_3 = " + " + ".join(f"{v}*kappa_{k}" for k, v in sorted(sol3.items())))
    check = sum(v * specialise(key_polynomial(k)) for k, v in sol3.items())
    print(f"Verification: {check == Q3}")

