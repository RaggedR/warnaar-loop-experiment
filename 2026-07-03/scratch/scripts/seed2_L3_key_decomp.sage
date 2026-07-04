"""
Seed 2, Layer 3: Decompose D_k^m into GL_3 key polynomials.

Key polynomial K_u(x1,x2,x3) for u=(u1,u2,u3) with u1>=u2>=u3 is the
Schur polynomial s_u. For non-dominant u, it's the Demazure character.

We specialize at (x1,x2,x3) = (q, q^2, q^3) and try to express
D_k^m as a nonneg integer combination of K_u(q, q^2, q^3).
"""
from sage.all import *

R = PolynomialRing(ZZ, 'q')
q = R.gen()

# GL_3 key polynomials at specialization (q, q^2, q^3)
# Using WeylCharacterRing
W = WeylCharacterRing("A2", style="cocharacters")

def key_poly_spec(u, max_deg=200):
    """Compute the GL_3 key polynomial K_u at (q, q^2, q^3).
    
    For dominant u (u1>=u2>=u3>=0), this is the Schur polynomial.
    For non-dominant u, we use the Demazure character formula.
    """
    # Use Demazure character via crystal
    try:
        # For dominant weight, use WeylCharacterRing directly
        u_sorted = tuple(sorted(u, reverse=True))
        if u == u_sorted and all(x >= 0 for x in u):
            chi = W(u)
            # Get weight multiplicities
            result = R(0)
            for wt, mult in chi.weight_multiplicities().items():
                wt_tuple = tuple(wt.to_vector())
                # Specialization: x_i -> q^i means weight (a,b,c) -> q^(a+2b+3c)
                deg = int(wt_tuple[0] + 2*wt_tuple[1] + 3*wt_tuple[2])
                if deg <= max_deg:
                    result += mult * q**deg
            return result
    except Exception as e:
        print(f"Error for u={u}: {e}")
    return None

def demazure_char_spec(lam, w_reduced, max_deg=200):
    """Compute Demazure character D_w(lambda) at specialization (q, q^2, q^3).
    
    lam: dominant weight (a,b,c) with a>=b>=c>=0
    w_reduced: reduced word for w as a list of simple reflections [s_1, s_2, ...]
    """
    # Start with the weight lambda (monomial x^lambda)
    # Demazure operator: pi_i(f) = (x_i * f - x_{i+1} * s_i(f)) / (x_i - x_{i+1})
    
    # Work in the polynomial ring
    S = PolynomialRing(ZZ, ['x1', 'x2', 'x3'])
    x1, x2, x3 = S.gens()
    xs = [x1, x2, x3]
    
    f = x1**lam[0] * x2**lam[1] * x3**lam[2]
    
    for si in w_reduced:
        # Apply Demazure operator pi_{si}
        # si is 1 or 2 (for s_1 swapping x1,x2 or s_2 swapping x2,x3)
        i = si - 1  # 0-indexed
        # pi_i(f) = (x_i * f - x_{i+1} * s_i(f)) / (x_i - x_{i+1})
        swap = {xs[i]: xs[i+1], xs[i+1]: xs[i]}
        sf = f.subs(swap)
        num = xs[i] * f - xs[i+1] * sf
        denom = xs[i] - xs[i+1]
        f = S(num // denom)
    
    # Specialize x1=q, x2=q^2, x3=q^3
    result = R(0)
    for coeff, mon in zip(f.coefficients(), f.monomials()):
        degs = mon.degrees()
        deg = degs[0] + 2*degs[1] + 3*degs[2]
        if deg <= max_deg:
            result += ZZ(coeff) * q**deg
    
    return result


# First, let me compute all key polynomials up to a certain total degree
print("Computing GL_3 key polynomials at (q, q^2, q^3)...")

# For GL_3, key polynomials are indexed by compositions (a,b,c) with a,b,c >= 0
# The key polynomial K_{(a,b,c)} = Demazure character of weight (a,b,c)
# For dominant weights (a>=b>=c), K = Schur polynomial

# Generate all dominant weights with total specialization degree <= 30
key_polys = {}
max_total = 20  # a + 2b + 3c <= max_deg at minimum

for a in range(max_total + 1):
    for b in range(a + 1):
        for c in range(b + 1):
            if c < 0: continue
            # Dominant weight (a,b,c)
            kp = key_poly_spec((a, b, c))
            if kp is not None and kp != 0:
                key_polys[(a, b, c)] = kp

print(f"Computed {len(key_polys)} dominant GL_3 key polynomials")

# Also compute some non-dominant key polynomials
# For A2: Weyl group has 6 elements: e, s1, s2, s1s2, s2s1, s1s2s1
# Demazure characters correspond to w * lambda for w in W

# For each dominant weight and each Weyl group element, compute the key poly
weyl_words = {
    'e': [],
    's1': [1],
    's2': [2],
    's1s2': [1, 2],
    's2s1': [2, 1],
    'w0': [1, 2, 1]  # longest element
}

print("\nComputing non-dominant key polynomials...")
nd_key_polys = {}

for a in range(8):
    for b in range(a + 1):
        for c in range(b + 1):
            lam = (a, b, c)
            for wname, word in weyl_words.items():
                if wname == 'w0':
                    continue  # w0 gives the full Schur = dominant case
                if not word:
                    continue  # identity = monomial
                try:
                    kp = demazure_char_spec(lam, word)
                    if kp is not None and kp != 0:
                        key = f"D_{wname}({a},{b},{c})"
                        nd_key_polys[key] = kp
                except Exception as e:
                    pass

print(f"Computed {len(nd_key_polys)} non-dominant key polynomials")

# Now let's compute D_k^m for d=4 and try to decompose
# First, recreate D_k^m values from the previous computation

# D_k^m for d=4, c=(2,1,1) (from the output above):
D_4 = {}
D_4[(0,0)] = R(1)
D_4[(0,1)] = 3*q + q**2 + q**3
D_4[(0,2)] = 3*q**2 + 4*q**3 + 5*q**4 + 3*q**5 + 3*q**6 + 2*q**7 + 2*q**8 + q**9 + q**10 + q**12
D_4[(1,1)] = 2*q + q**2 + q**3
D_4[(1,2)] = 3*q**3 + 4*q**4 + 3*q**5 + 3*q**6 + 2*q**7 + 2*q**8 + q**9 + q**10 + q**12
D_4[(2,2)] = q**3 + 3*q**4 + 2*q**5 + 3*q**6 + 2*q**7 + 2*q**8 + q**9 + q**10 + q**12

# D_k^m for d=7, c=(3,2,2):
D_7 = {}
D_7[(0,0)] = R(1)
D_7[(0,1)] = 3*q + 3*q**2 + 2*q**3 + 2*q**4 + q**5 + q**6
D_7[(1,1)] = 2*q + 3*q**2 + 2*q**3 + 2*q**4 + q**5 + q**6
D_7[(2,2)] = q**3 + 5*q**4 + 7*q**5 + 10*q**6 + 10*q**7 + 12*q**8 + 10*q**9 + 11*q**10 + 9*q**11 + 9*q**12 + 7*q**13 + 7*q**14 + 5*q**15 + 5*q**16 + 3*q**17 + 3*q**18 + 2*q**19 + 2*q**20 + q**21 + q**22 + q**24

print("\n" + "="*70)
print("Attempting GL_3 key polynomial decomposition of D_k^m")
print("="*70)

# Try greedy decomposition of D_1^1 for d=4
print("\n--- D_1^1 for d=4: 2q + q^2 + q^3 ---")
target = D_4[(1,1)]
print(f"Target: {target}")
print(f"eval1 = {target(1)}")

# Check which key polys match
for key, kp in sorted(key_polys.items()):
    if kp == target:
        print(f"  EXACT MATCH: K_{key} = {kp}")

# Try to decompose as sum
print("\nKey polys with eval1 <= 4:")
for key, kp in sorted(key_polys.items()):
    if kp(1) <= 4 and kp(1) > 0:
        print(f"  K_{key}: {kp}, eval1={kp(1)}")

for key, kp in sorted(nd_key_polys.items()):
    if kp(1) <= 4 and kp(1) > 0:
        print(f"  {key}: {kp}, eval1={kp(1)}")

# Q_1 = D_1^1 for d=4
print("\n--- Q_1 for d=4: 2q + q^2 + q^3 ---")
print("This should decompose into key polys (known from Seed 5)")

# For d=4 the Schur polys s_{(a,b)} at (q,q^2,q^3) are:
# s_{(1,0,0)}(q,q^2,q^3) = q + q^2 + q^3 (eval1=3)
# s_{(0,0,0)} = 1 (eval1=1)
# So Q_1 = 4, and we need to express as sum of key polys
# K_{(0,0,0)} = 1 (monomial)
# The non-dominant key K_{sigma(1,0,0)} gives different polys

# Let me be more systematic
print("\n--- Systematic decomposition attempt ---")

# List all Demazure chars with small degree
all_keys = {}
for key, kp in key_polys.items():
    all_keys[f"S_{key}"] = kp
for key, kp in nd_key_polys.items():
    all_keys[key] = kp

# Add monomials (Demazure chars for identity element)
for a in range(10):
    for b in range(10):
        for c in range(10):
            deg = a + 2*b + 3*c
            if deg <= 30:
                mon = q**deg
                name = f"mon({a},{b},{c})"
                if name not in all_keys:
                    all_keys[name] = mon

# Try to decompose D_2^2 for d=4
print("\n--- D_2^2 for d=4 ---")
target = D_4[(2,2)]
print(f"Target: {target}")
print(f"eval1 = {target(1)} = 4^2 = 16")

# Check Schur polys that could appear
print("\nSchur polys at (q,q^2,q^3):")
for key, kp in sorted(key_polys.items()):
    if kp(1) <= 20 and kp(1) > 0 and max(kp.dict().keys()) <= 15:
        print(f"  S_{key}: {kp}, eval1={kp(1)}")

# D_2^2 for d=7
print("\n--- D_2^2 for d=7 ---")
target = D_7[(2,2)]
print(f"Target: {target}")
print(f"eval1 = {target(1)} = 11^2 = {target(1)}")
