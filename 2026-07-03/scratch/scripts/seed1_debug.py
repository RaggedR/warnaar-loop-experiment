"""
Debug: verify the cylindric partition enumeration for c=(1,1,0), d=2.
Profile (1,1,0): k=3, t = 3+2 = 5.

Cylindric partition of profile c = (c_1,c_2,c_3) = (1,1,0):
Three partitions (lam^1, lam^2, lam^3) with:
  lam^1_j >= lam^2_{j+c_2} = lam^2_{j+1}
  lam^2_j >= lam^3_{j+c_3} = lam^3_{j+0} = lam^3_j
  lam^3_j >= lam^1_{j+c_1} = lam^1_{j+1}

So: lam^1_j >= lam^2_{j+1}, lam^2_j >= lam^3_j, lam^3_j >= lam^1_{j+1}.

Wait, I need to be careful about the indexing. The problem says
c = (c_0, c_1, ..., c_{r-1}) in the Q definition, but the cylindric partition
uses c = (c_1, ..., c_k).

Let me re-read the conjecture.tex definition.

The conjecture defines c = (c_0, ..., c_{r-1}) for Q_{n,c}.
The cylindric partition definition uses c = (c_1, ..., c_k).

For k=3, profile (c_1,c_2,c_3):
  lam^i_j >= lam^{i+1}_{j+c_{i+1}} for i=1,2
  lam^3_j >= lam^1_{j+c_1}   (cyclic wrap)

So for c=(1,1,0):
  lam^1_j >= lam^2_{j+1}    (shift by c_2=1)
  lam^2_j >= lam^3_{j+0}    (shift by c_3=0)
  lam^3_j >= lam^1_{j+1}    (shift by c_1=1)

That means lam^2 >= lam^3 componentwise, and lam^1 dominates lam^2 shifted by 1,
and lam^3 dominates lam^1 shifted by 1.

For max entry = 0: only empty partitions. F_{c,0} = 1 (q^0 term). Good.

For max entry = 1: partitions have parts at most 1.
So each lam^i is a partition of the form (1,1,...,1,0,...) = (1^{a_i}).

lam^1 = (1^{a1}), lam^2 = (1^{a2}), lam^3 = (1^{a3}).

Conditions:
  lam^1_j >= lam^2_{j+1}: requires a1 >= a2 (since lam^1_j = 1 for j<=a1, lam^2_{j+1} = 1 for j+1<=a2 i.e. j<=a2-1)
    So we need: for j=1,...,a2-1: lam^1_j = 1 (need j <= a1), so a1 >= a2-1... wait let me be precise.
    lam^1_j >= lam^2_{j+1}: if j+1 <= a2 then lam^2_{j+1}=1 so need lam^1_j >= 1, i.e., j <= a1.
    So need a1 >= a2-1. Actually more precisely: the condition fails when lam^1_j < lam^2_{j+1},
    which happens when j > a1 and j+1 <= a2, i.e., j > a1 and j <= a2-1.
    This is impossible iff a1 >= a2-1, i.e., a2 <= a1+1.

  lam^2 >= lam^3: a2 >= a3.

  lam^3_j >= lam^1_{j+1}: a3 >= a1-1, i.e., a1 <= a3+1.

So: a2 <= a1+1, a2 >= a3, a1 <= a3+1.
Also: a1, a2, a3 >= 0.

From a1 <= a3+1 and a3 <= a2 and a2 <= a1+1:
  a1-1 <= a3 <= a2 <= a1+1

Let's enumerate for max_entry=1:
Total size = a1+a2+a3.

a1=0: a3 in {0}, a2 in {0}. -> (0,0,0): size 0 (already counted in max=0)
a1=1: a3 in {0,1}, a2 in [a3, 2]
  a3=0: a2 in {0,1,2}. Sizes: 1+0+0=1, 1+1+0=2, 1+2+0=3
  a3=1: a2 in {1,2}. Sizes: 1+1+1=3, 1+2+1=4
a1=2: a3 in {1,2}, a2 in [a3, 3]
  a3=1: a2 in {1,2,3}. Sizes: 2+1+1=4, 2+2+1=5, 2+3+1=6
  a3=2: a2 in {2,3}. Sizes: 2+2+2=6, 2+3+2=7
...

But wait, max_parts matters. Let me just focus on small cases.

For c=(1,1,0), t=5, the Borodin product formula gives:
F_c(q) = 1/(q^5;q^5)_inf * product terms.

Let me compute F_c(q) via Borodin and compare.
"""

# Borodin product for c=(1,1,0):
# k=3, c=(1,1,0), d_{i,j} = sum c_a for a=i..j
# d_{1,1}=1, d_{1,2}=2, d_{1,3}=2, d_{2,2}=1, d_{2,3}=1, d_{3,3}=0
# t=5

# First product: i=1..3, j=i+1..3, m=1..c_i
# i=1,j=2: m=1..c_1=1: exp = 1 + d_{2,2} + 2-1 = 1+1+1 = 3
# i=1,j=3: m=1..c_1=1: exp = 1 + d_{2,3} + 3-1 = 1+1+2 = 4
# i=2,j=3: m=1..c_2=1: exp = 1 + d_{3,3} + 3-2 = 1+0+1 = 2

# Second product: i=2..3, j=2..i-1, m=1..c_i
# i=2: j range 2..1 -> empty
# i=3: j=2..2, m=1..c_3=0 -> empty

# So F_{(1,1,0)}(q) = 1/((q^5;q^5)_inf * (q^3;q^5)_inf * (q^4;q^5)_inf * (q^2;q^5)_inf)
# = 1/((q^2;q^5)(q^3;q^5)(q^4;q^5)(q^5;q^5))_inf
# = 1/((q^2,q^3,q^4,q^5;q^5)_inf)

# By Jacobi triple product considerations, this should equal:
# prod_{n>=1} 1/((1-q^{5n-3})(1-q^{5n-2})(1-q^{5n-1})(1-q^{5n}))
# = 1/((q^2,q^3,q^4,q^5;q^5)_inf)
# = prod 1/(1-q^n) for n not = 1 mod 5
# Hmm that's the Rogers-Ramanujan product side!

# Actually this is: 1/prod_{n>=1, n != 1 (mod 5)} (1-q^n)

# Let me compute this as a series and check
MAX = 40

def series_prod_inv(exponents, max_deg):
    """Compute 1/prod(1-q^e) for e in exponents, as series to max_deg."""
    result = {0: 1}
    for e in exponents:
        if e <= 0 or e > max_deg: continue
        new = {}
        for k, v in result.items():
            j = 0
            while k + j*e <= max_deg:
                new[k+j*e] = new.get(k+j*e, 0) + v
                j += 1
        result = new
    return result

# All n >= 1 not congruent to 1 mod 5
exps = [n for n in range(1, MAX+1) if n % 5 != 1]
F_borodin = series_prod_inv(exps, MAX)

# Compare with direct enumeration
print("Borodin F_{(1,1,0)}(q):")
for k in sorted(F_borodin.keys()):
    if k <= 15:
        print(f"  q^{k}: {F_borodin[k]}")

# Now let me compute F_{c,n} = sum over cylindric partitions with max <= n
# The issue might be in my enumeration. Let me trace through n=1 carefully.

def get_part(lam, j):
    return lam[j-1] if j <= len(lam) else 0

def check_cylindric(lams, c, max_j=20):
    k = len(c)
    for i in range(k):
        i_next = (i+1) % k
        shift = c[i_next]
        for j in range(1, max_j+1):
            left = get_part(lams[i], j)
            right = get_part(lams[i_next], j + shift)
            if left < right:
                return False
            if left == 0 and right == 0:
                break
    return True

# Wait - is the indexing right? The condition in conjecture.tex is:
# lam^i_j >= lam^{i+1}_{j + c_{i+1}}
# with indices cyclic: lam^k_j >= lam^1_{j+c_1}

# So for c=(c_1,c_2,c_3):
# lam^1_j >= lam^2_{j+c_2}
# lam^2_j >= lam^3_{j+c_3}
# lam^3_j >= lam^1_{j+c_1}

# My code has c[i_next] as the shift, with i_next = (i+1)%k.
# i=0 (lam^1): i_next=1, shift = c[1] = c_2. Condition: lam^1_j >= lam^2_{j+c_2}. Correct.
# i=1 (lam^2): i_next=2, shift = c[2] = c_3. Condition: lam^2_j >= lam^3_{j+c_3}. Correct.
# i=2 (lam^3): i_next=0, shift = c[0] = c_1. Condition: lam^3_j >= lam^1_{j+c_1}. Correct.

# So the indexing is correct. Let me check c=(1,1,0):
# lam^1_j >= lam^2_{j+1}
# lam^2_j >= lam^3_j
# lam^3_j >= lam^1_{j+1}

# For max=1, all partitions are (1,...,1) of various lengths.
# Let me enumerate all valid triples for max=1, up to 5 parts each:
print("\nDirect enumeration for c=(1,1,0), max=1:")
count_by_size = {}
for a1 in range(8):
    for a2 in range(8):
        for a3 in range(8):
            l1 = tuple([1]*a1) if a1 > 0 else ()
            l2 = tuple([1]*a2) if a2 > 0 else ()
            l3 = tuple([1]*a3) if a3 > 0 else ()
            if check_cylindric([l1,l2,l3], (1,1,0), 10):
                s = a1+a2+a3
                count_by_size[s] = count_by_size.get(s, 0) + 1
                if s <= 6:
                    pass  # print(f"  ({a1},{a2},{a3}), size={s}")

print("F_{c,1}(q) from enumeration (max=1):")
for k in sorted(count_by_size.keys()):
    print(f"  q^{k}: {count_by_size[k]}")

# But F_{c,0}(q) should just count the empty partition tuple:
print("\nF_{c,0}: should be {0: 1} = 1")
print("F_{c,1} - F_{c,0} = g_1:")
g1 = dict(count_by_size)
g1[0] = g1.get(0, 0) - 1  # subtract the empty partition
if g1[0] == 0: del g1[0]
for k in sorted(g1.keys()):
    if k <= 10:
        print(f"  q^{k}: {g1[k]}")

# Now the issue: I need ALL partitions with parts <= 1, not just column partitions.
# But parts <= 1 means the only partitions are (1^a) for a >= 0.
# So this is correct. Let me also check with max=2.

print("\nDirect enumeration for c=(1,1,0), max=2:")
count2 = {}
# Partitions with parts <= 2: (2^a, 1^b) for a,b >= 0, length a+b
for a1_2 in range(5):
    for a1_1 in range(5):
        l1 = tuple([2]*a1_2 + [1]*a1_1)
        s1 = 2*a1_2 + a1_1
        if s1 > MAX: continue
        for a2_2 in range(5):
            for a2_1 in range(5):
                l2 = tuple([2]*a2_2 + [1]*a2_1)
                s2 = 2*a2_2 + a2_1
                if s1+s2 > MAX: continue
                for a3_2 in range(5):
                    for a3_1 in range(5):
                        l3 = tuple([2]*a3_2 + [1]*a3_1)
                        s3 = 2*a3_2 + a3_1
                        total = s1+s2+s3
                        if total > 20: continue
                        if check_cylindric([l1,l2,l3], (1,1,0), 12):
                            count2[total] = count2.get(total, 0) + 1

print("F_{c,2}:")
for k in sorted(count2.keys()):
    if k <= 15:
        print(f"  q^{k}: {count2[k]}")

# The real question: does sum_n F_{c,n}(q) as n->inf converge to F_c(q)?
# F_c(q) = Borodin product. Let me check if the enumerated F_{c,1} and F_{c,2} 
# are truncations of F_c(q).

# Actually no -- F_{c,n}(q) counts cylindric partitions with max at most n.
# F_c(q) = lim_{n->inf} F_{c,n}(q). So F_{c,n}(q) should have coefficients
# that are <= those of F_c(q), and converge to them.

# Let me check: is F_{c,1} <= F_c (coefficient by coefficient)?
print("\nComparing F_{c,1} with Borodin F_c:")
for k in range(16):
    enum_val = count_by_size.get(k, 0)
    bor_val = F_borodin.get(k, 0)
    ok = "OK" if enum_val <= bor_val else "PROBLEM"
    print(f"  q^{k}: enum={enum_val}, Borodin={bor_val}  {ok}")

print("\nComparing F_{c,2} with Borodin F_c:")
for k in range(16):
    enum_val = count2.get(k, 0)
    bor_val = F_borodin.get(k, 0)
    ok = "OK" if enum_val <= bor_val else "PROBLEM"
    print(f"  q^{k}: enum={enum_val}, Borodin={bor_val}  {ok}")

