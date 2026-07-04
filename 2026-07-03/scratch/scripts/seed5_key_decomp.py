"""
Seed 5: Find positive key polynomial decomposition of Q_{n,(2,1,1)} for n=1,2,3.

Strategy: For 2 variables at specialization (q, q^2), the key polynomial 
K_{(a,b)} with a >= b is just q^{a+2b} (a monomial).
K_{(a,b)} with a < b has b-a+1 terms: sum_{j=0}^{b-a} q^{(a+j) + 2(b-j)} 
= sum_{j=0}^{b-a} q^{2b+a-j} = q^{a+b} * sum_{j=0}^{b-a} q^{b-a-j}
= q^{a+b} * (1 + q + ... + q^{b-a}).

So K_{(a,b)}(q,q^2) for a < b equals q^{a+b} * [b-a+1]_q where [m]_q = 1+q+...+q^{m-1}.

And K_{(a,b)}(q,q^2) for a >= b is just q^{a+2b}.

This means a positive key-polynomial decomposition of Q is equivalent to 
writing Q(q) as a nonneg integer combination of:
- Monomials q^{a+2b} (from K with a >= b)
- "q-integers" q^{a+b} * [b-a+1]_q (from K with a < b)

The q-integer [m]_q = 1 + q + ... + q^{m-1} = (1-q^m)/(1-q).
"""

# Q polynomials from previous computation
Q1 = {1: 2, 2: 1, 3: 1}
Q2 = {3:1, 4:3, 5:2, 6:3, 7:2, 8:2, 9:1, 10:1, 12:1}
Q3 = {7:2, 8:2, 9:5, 10:4, 11:6, 12:6, 13:6, 14:5, 15:6, 16:4, 17:4, 18:3, 19:3, 20:2, 21:2, 22:1, 23:1, 24:1, 27:1}

# For each Q, find the decomposition
def find_key_decomposition(Q, max_u=15):
    """
    Find nonneg integer coefficients a_{(i,j)} such that
    Q(q) = sum a_{(i,j)} * K_{(i,j)}(q, q^2).
    
    For i >= j: K = q^{i+2j} (monomial, contributes 1 to sum)
    For i < j:  K = q^{i+j} * (1 + q + ... + q^{j-i}) (contributes j-i+1 to sum)
    
    This is a linear system with nonneg integer constraints.
    Since the monomial keys are just q^{i+2j}, any coefficient of Q that 
    appears at a degree that is NOT of the form i+2j can only come from 
    the non-monomial keys.
    
    Let me use greedy: start with the highest degree term of Q and work down.
    """
    Q_remaining = dict(Q)
    decomposition = []
    
    # Sort degrees descending
    max_deg = max(Q_remaining.keys())
    
    for deg in range(max_deg, -1, -1):
        coeff = Q_remaining.get(deg, 0)
        if coeff <= 0:
            continue
        
        # This degree can be achieved by:
        # 1. A monomial key K_{(a,b)} with a >= b and a+2b = deg
        # 2. The highest term of a non-monomial key K_{(a,b)} with a < b
        #    where the highest term has degree 2b+a-0 = a+2b... wait
        #    K_{(a,b)}(q,q^2) for a < b = sum_{j=0}^{b-a} q^{2b+a-j}
        #    The highest term is q^{a+2b}, so deg = a+2b.
        #    The lowest term is q^{a+b+(b-a)} = q^{2b} ... wait
        #    Actually q^{2b+a-(b-a)} = q^{b+2a}. 
        #    Hmm: 2b + a - j for j = 0,...,b-a. Max at j=0: 2b+a. Min at j=b-a: 2b+a-(b-a) = b+2a.
        #    No wait: a < b, so a+2b > b+2a iff b > a, which is true. So max = a+2b, min = 2a+b.
        
        # For now, just try using monomial keys first
        # q^deg from K_{(a,b)} with a >= b, a+2b = deg
        # Solutions: b = 0,1,...,deg//2; a = deg - 2b; a >= b requires deg - 2b >= b => deg >= 3b => b <= deg//3.
        # Use all such as "free" monomials.
        pass
    
    # Better approach: enumerate all key polys with max degree <= max_deg
    # and solve the nonneg integer combination problem.
    
    # Build the dictionary of available key polys
    available = {}
    for a in range(max_deg + 1):
        for b in range(max_deg + 1):
            if a >= b:
                d = a + 2*b
                if d <= max_deg:
                    available[(a,b)] = {d: 1}
            else:
                # K_{(a,b)} = sum_{j=0}^{b-a} q^{2b+a-j}
                K = {}
                for j in range(b - a + 1):
                    K[2*b + a - j] = 1
                if max(K.keys()) <= max_deg:
                    available[(a,b)] = K
    
    # Greedy: subtract the longest non-monomial keys first (they cancel the most terms)
    Q_rem = dict(Q)
    result = {}
    
    # Sort by number of terms (larger first), then by max degree (larger first)
    sorted_keys = sorted(available.items(), key=lambda x: (-len(x[1]), -max(x[1].keys())))
    
    for (a, b), K in sorted_keys:
        if a >= b:
            continue  # skip monomials for now
        # How many times can we subtract K from Q_rem?
        max_mult = min(Q_rem.get(d, 0) for d in K.keys())
        if max_mult > 0:
            result[(a,b)] = max_mult
            for d in K.keys():
                Q_rem[d] = Q_rem.get(d, 0) - max_mult
    
    # Now handle remaining with monomials
    for d, c in sorted(Q_rem.items()):
        if c > 0:
            # Find (a,b) with a >= b, a+2b = d
            found = False
            for b in range(d // 3 + 1):
                a = d - 2*b
                if a >= b:
                    result[(a,b)] = result.get((a,b), 0) + c
                    found = True
                    break
            if not found:
                print(f"  Cannot decompose degree {d} with coeff {c}")
    
    # Verify
    check = {}
    for (a,b), mult in result.items():
        K = available.get((a,b), {})
        for d, c in K.items():
            check[d] = check.get(d, 0) + mult * c
    
    check = {k: v for k, v in check.items() if v != 0}
    Q_clean = {k: v for k, v in Q.items() if v != 0}
    
    if check == Q_clean:
        return result, True
    else:
        return result, False


print("=== Q_1 decomposition ===")
decomp1, ok1 = find_key_decomposition(Q1)
print(f"Decomposition: {decomp1}")
print(f"Correct: {ok1}")
for (a,b), mult in sorted(decomp1.items()):
    if a >= b:
        print(f"  {mult} * K_({a},{b})(q,q^2) = {mult} * q^{a+2*b}")
    else:
        print(f"  {mult} * K_({a},{b})(q,q^2) = {mult} * q^{b+2*a}(1+q+...+q^{b-a})")

print(f"\n=== Q_2 decomposition ===")
decomp2, ok2 = find_key_decomposition(Q2)
print(f"Decomposition: {decomp2}")
print(f"Correct: {ok2}")
for (a,b), mult in sorted(decomp2.items()):
    if a >= b:
        print(f"  {mult} * K_({a},{b})(q,q^2) = {mult} * q^{a+2*b}")
    else:
        K_str = " + ".join(f"q^{2*b+a-j}" for j in range(b-a+1))
        print(f"  {mult} * K_({a},{b})(q,q^2) = {mult} * ({K_str})")

print(f"\n=== Q_3 decomposition ===")
decomp3, ok3 = find_key_decomposition(Q3)
print(f"Decomposition: {decomp3}")
print(f"Correct: {ok3}")
for (a,b), mult in sorted(decomp3.items()):
    if a >= b:
        print(f"  {mult} * K_({a},{b})(q,q^2) = {mult} * q^{a+2*b}")
    else:
        K_str = f"q^{2*a+b}[{b-a+1}]_q"
        print(f"  {mult} * K_({a},{b})(q,q^2) = {mult} * {K_str}")

# Check total counts
print("\n=== Verification at q=1 ===")
for n, (decomp, ok) in enumerate([(decomp1, ok1), (decomp2, ok2), (decomp3, ok3)], 1):
    total = 0
    for (a,b), mult in decomp.items():
        if a >= b:
            total += mult  # monomial key has 1 term
        else:
            total += mult * (b - a + 1)  # non-monomial key has b-a+1 terms
    print(f"Q_{n}(1) = {total}, expected = {4**n}")

