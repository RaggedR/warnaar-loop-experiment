"""
Seed 6, Layer 3: FIXED d=9 and d=12 positivity tests.

Key fix: CW computes G_n = [y^n] F_c(y,q), not F_{c,n}.
In the Q formula, use G_n directly without subtracting.
"""

from sage.all import *

def shifted_profile(c, J):
    result = list(c)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J and prev not in J:
            result[i] = c[i] - 1
        elif i not in J and prev in J:
            result[i] = c[i] + 1
    return tuple(result)

def all_nonempty_subsets(S):
    S = list(S)
    n = len(S)
    for mask in range(1, 1 << n):
        yield frozenset(S[j] for j in range(n) if mask & (1 << j))

def compute_Qn_fixed(c, n_max, q_prec=50):
    """Compute Q_n using CW recurrence (correctly computing G_n)."""
    c0, c1, c2 = c
    d = c0 + c1 + c2
    l = gcd(d, 3)
    
    R = PowerSeriesRing(QQ, 'q', default_prec=q_prec)
    q = R.gen()
    
    # Build the composition list
    compositions = []
    for a in range(d+1):
        for b in range(d+1-a):
            compositions.append((a, b, d-a-b))
    comp_idx = {comp: i for i, comp in enumerate(compositions)}
    NC = len(compositions)
    
    # CW recurrence computes G_n = [y^n] F_c(y,q)
    # G_0 = 1 for all profiles (empty partition has max 0)
    # For n >= 1: G_{c,n} = sum_J (-1)^{|J|-1} q^{|J|n} sum_{j=0}^n G_{c(J),j}
    # But wait -- this is the recurrence I derived before, which gives 
    # G_n (the y^n coeff), NOT F_{c,n}.
    
    # Actually the CW recurrence IS for [y^n]F_c(y,q):
    # [y^n] F_c(y,q) = sum_J (-1)^{|J|-1} [y^n](F_{c(J)}(yq^s)/(1-yq^s))
    # = sum_J (-1)^{|J|-1} q^{sn} sum_{j=0}^n [y^j] F_{c(J)}(y,q)  (shifted by q^s)
    # Wait, let me redo this.
    #
    # [y^n] (G(yq^s)/(1-yq^s)) where G(y) = sum_j G_j y^j
    # = sum_{m=0}^n (q^s)^m [y^{n-m}] G(yq^s)
    # = sum_{m=0}^n q^{sm} q^{s(n-m)} G_{n-m}
    # = q^{sn} sum_{m=0}^n G_{n-m}
    # = q^{sn} sum_{j=0}^n G_j
    #
    # So: G_{c,n} = sum_J (-1)^{|J|-1} q^{sn} S_{c(J),n}
    # where S_{c,n} = sum_{j=0}^n G_{c,j}.
    #
    # NOTE: S_{c,n} involves G_{c,n} itself, so this is implicit:
    # G_{c,n} = sum_J (-1)^{|J|-1} q^{sn} (S_{c(J),n-1} + G_{c(J),n})
    # => G_{c,n} - sum_J (-1)^{|J|-1} q^{sn} G_{c(J),n} = sum_J (-1)^{|J|-1} q^{sn} S_{c(J),n-1}
    
    # Initialize
    G = {}
    S = {}
    for comp in compositions:
        G[comp, 0] = R(1)
        S[comp, 0] = R(1)
    
    for n in range(1, n_max + 1):
        # Build linear system (I - A(q^n)) G_n = b
        # where b depends on S_{n-1}
        
        # Neumann series: (I - A)^{-1} b = sum_k A^k b
        # A has entries of degree >= n in q, so series converges rapidly.
        
        # First, compute b vector
        b = [R(0)] * NC
        A_entries = {}  # (i, j) -> polynomial
        
        for i, comp in enumerate(compositions):
            Ic = frozenset(idx for idx in range(3) if comp[idx] > 0)
            if not Ic:
                continue
            for J in all_nonempty_subsets(Ic):
                cp = shifted_profile(comp, J)
                if cp not in comp_idx:
                    continue
                j = comp_idx[cp]
                s = len(J)
                sign = (-1)**(s - 1)
                coeff = sign * q**(s * n)
                
                # A entry
                if (i, j) not in A_entries:
                    A_entries[(i, j)] = R(0)
                A_entries[(i, j)] += coeff
                
                # RHS
                b[i] += coeff * S[cp, n-1]
        
        # Neumann series: G_n = b + A*b + A^2*b + ...
        b_vec = vector(R, b)
        G_vec = vector(R, [R(0)] * NC)
        term = b_vec
        
        max_iter = q_prec // n + 2
        for k in range(max_iter):
            G_vec += term
            # Apply A to term
            new_term = vector(R, [R(0)] * NC)
            for (i, j), coeff in A_entries.items():
                new_term[i] += coeff * term[j]
            term = vector(R, [t.add_bigoh(q_prec) for t in new_term])
        
        for i, comp in enumerate(compositions):
            G[comp, n] = G_vec[i].add_bigoh(q_prec)
            S[comp, n] = S[comp, n-1] + G[comp, n]
    
    # Compute Q_n from G
    # Q_n = (q^l;q^l)_n * [z^n]((zq;q)_inf * sum_m G_m z^m)
    # = (q^l;q^l)_n * sum_{j=0}^n e_j G_{n-j}
    # where e_j = (-1)^j q^{j(j+1)/2} / (q;q)_j
    # and G is the CW output (which IS [z^m] F_c(z,q) = G_m)
    
    results = {}
    for n in range(1, n_max + 1):
        bracket = R(0)
        for j in range(n + 1):
            ej = (-1)**j * q**(j*(j+1)//2)
            denom = R(1)
            for i in range(1, j+1):
                denom *= (1 - q**i)
            ej = (ej * denom.inverse_of_unit()).add_bigoh(q_prec)
            
            Gm = G[c, n - j]
            bracket += ej * Gm
        
        bracket = bracket.add_bigoh(q_prec)
        
        ql_fac = R(1)
        for i in range(1, n+1):
            ql_fac *= (1 - q**(l*i))
        
        Qn = (ql_fac * bracket).add_bigoh(q_prec)
        results[n] = Qn
    
    return results

# =========================================================
# Sanity check: d=7
# =========================================================
print("=" * 60)
print("SANITY CHECK: d=7")
print("=" * 60)

for c in [(3,2,2), (4,2,1), (5,1,1)]:
    print(f"\nc = {c}:")
    Qs = compute_Qn_fixed(c, n_max=2, q_prec=30)
    for n in sorted(Qs.keys()):
        Qn = Qs[n]
        coeffs = [Qn[i] for i in range(min(20, 30))]
        neg = [i for i in range(30) if Qn[i] < 0]
        s = sum(Qn[i] for i in range(30))
        print(f"  Q_{n} = {coeffs}")
        print(f"  Q_{n}(1) = {s}, negative at: {neg[:10]}")

# =========================================================
# Test d=9
# =========================================================
print("\n" + "=" * 60)
print("TESTING d=9 (d equiv 0 mod 3)")
print("=" * 60)

for c in [(3,3,3), (4,3,2), (5,2,2), (5,3,1), (9,0,0)]:
    print(f"\nc = {c}:")
    try:
        Qs = compute_Qn_fixed(c, n_max=2, q_prec=40)
        for n in sorted(Qs.keys()):
            Qn = Qs[n]
            coeffs = [Qn[i] for i in range(min(20, 40))]
            neg = [i for i in range(40) if Qn[i] < 0]
            s = sum(Qn[i] for i in range(40))
            print(f"  Q_{n} coeffs: {coeffs}")
            print(f"  Q_{n}(1) ~ {s}, negative at: {neg[:10]}")
    except Exception as e:
        print(f"  Error: {e}")

# =========================================================
# Test d=12
# =========================================================
print("\n" + "=" * 60)
print("TESTING d=12 (d equiv 0 mod 3)")
print("=" * 60)

for c in [(4,4,4), (5,4,3), (6,3,3)]:
    print(f"\nc = {c}:")
    try:
        Qs = compute_Qn_fixed(c, n_max=2, q_prec=60)
        for n in sorted(Qs.keys()):
            Qn = Qs[n]
            coeffs = [Qn[i] for i in range(min(20, 60))]
            neg = [i for i in range(60) if Qn[i] < 0]
            s = sum(Qn[i] for i in range(60))
            print(f"  Q_{n} coeffs: {coeffs}")
            print(f"  Q_{n}(1) ~ {s}, negative at: {neg[:10]}")
    except Exception as e:
        print(f"  Error: {e}")

