"""
Seed 4, Layer 3: Compute h_1 for d=9 with very high precision.
For d=9, t = k + ell = 3 + 9 = 12. ell = gcd(9,3) = 3.
h_1 = (q;q)_1 * g_1 = (1-q) * g_1.
g_1 = [z^1] F_c(z,q) = sum over CPs with max=1 of q^size.

Since d=9, the profile space is huge (55 profiles).
But g_1 stabilizes quickly for CPs with max=1.

Actually for max=1, each partition lambda^(i) has parts <= 1,
so lambda^(i) is of the form (1,1,...,1,0,0,...) = (1^{a_i}).
The interlacing conditions become: a_i >= a_{i+1} + c_{i+1} (cyclically).
Wait, that's for specific profile structures. Let me think more carefully.

For a cylindric partition of profile c with max(Lambda) = 1,
each lambda^(i) is a partition with parts in {0,1}, so lambda^(i) = (1^{a_i})
where a_i >= 0.

The interlacing condition lambda^(i)_j >= lambda^(i+1)_{j+c_{i+1}} means:
if j <= a_i then 1 >= lambda^(i+1)_{j+c_{i+1}} (always true since parts <= 1)
if j > a_i then 0 >= lambda^(i+1)_{j+c_{i+1}}, so we need a_{i+1} < j + c_{i+1},
i.e., a_{i+1} <= j + c_{i+1} - 1. The binding constraint is j = a_i + 1:
a_{i+1} <= a_i + c_{i+1}.

Similarly for the cyclic wrap: a_1 <= a_k + c_1.

So CPs with max=1 and profile c = (c_0, c_1, c_2) (k=3) are tuples
(a_0, a_1, a_2) with a_i >= 0 and:
  a_1 <= a_0 + c_1
  a_2 <= a_1 + c_2
  a_0 <= a_2 + c_0

The size is |Lambda| = a_0 + a_1 + a_2.

This is exactly the lattice point counting problem from Seed 6!
g_1(q) = sum_{(a0,a1,a2) satisfying constraints} q^{a0+a1+a2}

For d=9, c=(3,3,3): constraints are a_i <= a_{i-1} + 3 cyclically.
For c=(4,3,2): a_1 <= a_0 + 3, a_2 <= a_1 + 2, a_0 <= a_2 + 4.

Let me compute g_1 directly and check if (1-q)*g_1 = h_1 is nonneg.
"""

# Direct computation of g_1 for d=9
def compute_g1_direct(c, max_size=500):
    """Compute g_1(q) = sum q^{a0+a1+a2} over valid (a0,a1,a2)."""
    c0, c1, c2 = c
    coeffs = {}  # degree -> count
    
    # For each total size w, count lattice points
    for w in range(max_size + 1):
        count = 0
        for a0 in range(w + 1):
            for a1 in range(w - a0 + 1):
                a2 = w - a0 - a1
                if a2 < 0: continue
                # Check constraints
                if a1 <= a0 + c1 and a2 <= a1 + c2 and a0 <= a2 + c0:
                    count += 1
        if count > 0:
            coeffs[w] = count
    return coeffs

def compute_h1(g1):
    """h_1 = (1-q) * g_1"""
    h1 = {}
    for deg, coeff in g1.items():
        h1[deg] = h1.get(deg, 0) + coeff
        h1[deg + 1] = h1.get(deg + 1, 0) - coeff
    return {k: v for k, v in h1.items() if v != 0}

# Test profiles for d=9
profiles_d9 = [(3,3,3), (4,3,2), (5,3,1), (5,2,2), (6,2,1), (7,1,1), (4,4,1)]

print("d=9, ell=gcd(9,3)=3")
print("base = (9+1)*(9+2)/6 = 110/6 = 18.33... -- NOT AN INTEGER!")
print("Since d=9 is divisible by 3, base is not an integer.")
print("The evaluation formula Q_n(1) = (base-1)^n does not apply.")
print()

# But Seed 7 says positivity still holds. Let's check h_1.
for c in profiles_d9:
    print(f"\nProfile c={c}:")
    max_size = 200  # go higher for convergence check
    g1 = compute_g1_direct(c, max_size)
    
    # Check stabilization
    last_few = [(w, g1.get(w, 0)) for w in range(max_size - 5, max_size + 1)]
    print(f"  g_1 stabilization (last few): {last_few}")
    
    # Check if g_1 coefficients are eventually constant
    stable_val = g1.get(max_size, 0)
    first_stable = None
    for w in range(max_size, -1, -1):
        if g1.get(w, 0) != stable_val:
            first_stable = w + 1
            break
    if first_stable is not None:
        print(f"  g_1 stabilizes to {stable_val} from w={first_stable}")
    
    # Compute h_1 = (1-q)*g_1
    h1 = compute_h1(g1)
    
    # Check if h_1 is nonneg
    h1_items = sorted(h1.items())
    neg_items = [(d, v) for d, v in h1_items if v < 0]
    print(f"  h_1 has {len(h1_items)} nonzero terms, negative: {neg_items[:5]}")
    if not neg_items:
        print(f"  h_1 >= 0 CONFIRMED (up to size {max_size})")
        h1_sum = sum(h1.values())
        print(f"  h_1(1) = {h1_sum}")
        print(f"  h_1 = {' + '.join(f'{v}q^{d}' for d,v in h1_items[:15])} + ...")
    else:
        print(f"  h_1 has NEGATIVE coefficients!")
        
    # Check monotonicity of g_1 coefficients (Seed 6's condition)
    g1_list = [g1.get(w, 0) for w in range(max_size + 1)]
    mono_breaks = [(w, g1_list[w], g1_list[w-1]) for w in range(1, len(g1_list)) 
                   if g1_list[w] < g1_list[w-1]]
    if not mono_breaks:
        print(f"  g_1 is monotonically increasing: TRUE")
    else:
        print(f"  g_1 monotonicity breaks: {mono_breaks[:5]}")

# For comparison, also do d=7 (known good case)
print("\n" + "="*60)
print("d=7 for comparison")
print("="*60)
for c in [(3,2,2), (4,2,1)]:
    g1 = compute_g1_direct(c, 50)
    h1 = compute_h1(g1)
    h1_items = sorted(h1.items())
    neg = [(d, v) for d, v in h1_items if v < 0]
    print(f"\nc={c}: h_1 = {' + '.join(f'{v}q^{d}' for d,v in h1_items[:10])}...")
    print(f"  h_1(1) = {sum(h1.values())}, neg = {neg[:5]}")
    stable = g1.get(50, 0)
    print(f"  g_1 stabilizes to {stable} = (d+1)(d+2)/6 = {(7+1)*(7+2)//6}")

