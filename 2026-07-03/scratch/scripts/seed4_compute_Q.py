"""
Seed 4, Layer 1: Compute Q_{n,c}(q) for small cases.
Direct computation using enumeration of cylindric partitions.
"""
from math import gcd
from itertools import product as iproduct

def multiply_series(a, b, prec):
    """Multiply two truncated power series."""
    result = [0] * prec
    la, lb = len(a), len(b)
    for i in range(min(la, prec)):
        if a[i] == 0:
            continue
        for j in range(min(lb, prec - i)):
            result[i + j] += a[i] * b[j]
    return result

def qpoch_series(a_exp, q_exp, n, prec):
    """Compute (q^a_exp; q^q_exp)_n as a truncated power series."""
    result = [0] * prec
    result[0] = 1
    for i in range(n):
        power = a_exp + i * q_exp
        if power >= prec:
            continue
        new_result = list(result)
        for j in range(prec):
            if j + power < prec:
                new_result[j + power] -= result[j]
        result = new_result
    return result

def inverse_series(s, prec):
    """Compute 1/s as a truncated power series, assuming s[0] = 1."""
    assert s[0] == 1
    result = [0] * prec
    result[0] = 1
    for n in range(1, prec):
        val = 0
        for k in range(1, n + 1):
            if k < len(s):
                val += s[k] * result[n - k]
        result[n] = -val
    return result

def gen_partitions(max_val, num_parts):
    """Generate weakly decreasing sequences of given length with values in [0, max_val]."""
    if num_parts == 0:
        yield ()
        return
    for first in range(max_val, -1, -1):
        for rest in gen_partitions(first, num_parts - 1):
            yield (first,) + rest

def enumerate_F_bounded(c, max_entry, max_parts, prec):
    """
    Compute F_{c,max_entry}(q) by enumerating cylindric partitions.
    c = (c_0, c_1, ..., c_{k-1}), 0-indexed.
    Returns coefficient list.
    """
    k = len(c)
    all_parts = list(gen_partitions(max_entry, max_parts))
    
    result = [0] * prec
    
    for combo in iproduct(*([all_parts] * k)):
        valid = True
        for i in range(k):
            i_next = (i + 1) % k
            ci_next = c[i_next]
            for j in range(max_parts):
                lhs = combo[i][j]
                rhs_idx = j + ci_next
                rhs = combo[i_next][rhs_idx] if rhs_idx < max_parts else 0
                if lhs < rhs:
                    valid = False
                    break
            if not valid:
                break
        
        if valid:
            size = sum(sum(p) for p in combo)
            if size < prec:
                result[size] += 1
    
    return result

def compute_Q(c, n, prec, max_parts=4):
    """Compute Q_{n,c}(q)."""
    k = len(c)
    d = sum(c)
    l = gcd(d, k)
    
    # Compute F_{c,m}(q) for m = 0, ..., n
    F = {}
    for m in range(n + 1):
        F[m] = enumerate_F_bounded(c, m, max_parts, prec)
    
    # a_m(q) = F_{c,m} - F_{c,m-1}  (partitions with max exactly m)
    a = {}
    a[0] = list(F[0])
    for m in range(1, n + 1):
        a[m] = [F[m][i] - F[m-1][i] for i in range(prec)]
    
    # Euler coefficients: (zq;q)_inf = sum_m (-1)^m q^{m(m+1)/2} / (q;q)_m z^m
    euler_coeffs = {}
    for m in range(n + 1):
        qpoch_m = qpoch_series(1, 1, m, prec)
        inv_qpoch = inverse_series(qpoch_m, prec)
        shift = m * (m + 1) // 2
        sign = (-1) ** m
        ec = [0] * prec
        for i in range(prec):
            if i + shift < prec:
                ec[i + shift] = sign * inv_qpoch[i]
        euler_coeffs[m] = ec
    
    # b_n(q) = [z^n]((zq;q)_inf * F_c(z,q))
    b_n = [0] * prec
    for j in range(n + 1):
        conv = multiply_series(euler_coeffs[j], a[n - j], prec)
        for i in range(prec):
            b_n[i] += conv[i]
    
    # Q_{n,c}(q) = (q^l; q^l)_n * b_n(q)
    qpoch_l_n = qpoch_series(l, l, n, prec)
    Q = multiply_series(qpoch_l_n, b_n, prec)
    
    return Q

# Main computation
print("=" * 60)
print("Computing Q_{n,c}(q) for small cases")
print("=" * 60)

prec = 25

for c in [(1, 1, 0), (0, 1, 1), (1, 0, 1), (2, 0, 0)]:
    d = sum(c)
    k = len(c)
    l = gcd(d, k)
    if d % 3 == 0:
        print(f"\nc = {c}, d = {d} -- SKIPPING (d divisible by 3)")
        continue
    print(f"\nc = {c}, d = {d}, k = {k}, l = {l}")
    for n in range(1, 4):
        Q = compute_Q(c, n, prec, max_parts=4)
        nonzero = [(i, Q[i]) for i in range(prec) if Q[i] != 0]
        print(f"  Q_{{{n}}}(q) = {nonzero}")
        neg = [(i, Q[i]) for i in range(prec) if Q[i] < 0]
        if neg:
            print(f"  ** NEGATIVE coefficients: {neg}")
        else:
            print(f"  All coefficients nonneg (checked to degree {prec-1})")
        val_at_1 = sum(Q)
        expected = ((d+1)*(d+2)//6 - 1) ** n
        print(f"  Q(1) = {val_at_1}, expected = {expected}")
