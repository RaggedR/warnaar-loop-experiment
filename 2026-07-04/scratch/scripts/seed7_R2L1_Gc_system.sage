# Implement the CW equation for G_c(z,q) = (zq;q)_inf * F_c(z,q)
# G_c(z,q) = sum_J (-1)^{|J|-1} (zq;q)_{|J|-1} * G_{c(J)}(zq^{|J|}, q)
#
# Extract [z^n] to get a recurrence for g_{c,n} = [z^n] G_c(z,q).
# Then Q_{n,c} = (q^ell;q^ell)_n * g_{c,n}.

from itertools import combinations

def profiles(d):
    result = []
    for c0 in range(d+1):
        for c1 in range(d-c0+1):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def I_c(c):
    return [i for i in range(3) if c[i] > 0]

def shifted_profile(c, J):
    J_set = set(J)
    result = list(c)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J_set and prev not in J_set:
            result[i] -= 1
        elif i not in J_set and prev in J_set:
            result[i] += 1
    return tuple(result)

def compute_gn_coefficients(d, n_max, prec):
    """Compute g_{c,n} = [z^n] G_c(z,q) for all profiles c, n = 0..n_max.
    
    G_c(z,q) = sum_J (-1)^{|J|-1} (zq;q)_{|J|-1} * G_{c(J)}(zq^|J|, q)
    
    (zq;q)_0 = 1
    (zq;q)_1 = 1-zq
    (zq;q)_2 = (1-zq)(1-zq^2)
    
    G_{c(J)}(zq^s, q) = sum_m g_{c(J),m} (zq^s)^m = sum_m g_{c(J),m} q^{sm} z^m
    
    So [z^n] of the J-term is:
    [z^n] (-1)^{|J|-1} (zq;q)_{|J|-1} * sum_m g_{c(J),m} q^{|J|m} z^m
    
    For |J| = 1: (zq;q)_0 = 1, so contribution is g_{c(J),n} * q^n
    For |J| = 2: (zq;q)_1 = 1-zq, so contribution is 
        [z^n](1-zq) * sum_m g_{c(J),m} q^{2m} z^m
        = g_{c(J),n} q^{2n} - q * g_{c(J),n-1} * q^{2(n-1)}
        = q^{2n} g_{c(J),n} - q^{2n-1} g_{c(J),n-1}
    For |J| = 3: (zq;q)_2 = 1 - zq(1+q) + z^2 q^3, so contribution is
        [z^n](1-z(q+q^2)+z^2 q^3) * sum_m g_{c(J),m} q^{3m} z^m
        = q^{3n} g_{c(J),n} - (q+q^2)*q^{3(n-1)} g_{c(J),n-1} + q^3*q^{3(n-2)} g_{c(J),n-2}
        = q^{3n} g_{c(J),n} - (q^{3n-2}+q^{3n-1}) g_{c(J),n-1} + q^{3n-3} g_{c(J),n-2}
    """
    profs = profiles(d)
    R = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = R.gen()
    
    # Initial conditions: G_c(0,q) = 1, so g_{c,0} = 1 for all c.
    g = {}
    for c in profs:
        g[(c, 0)] = R(1)
    
    for n in range(1, n_max + 1):
        # For each profile c, set up the equation:
        # g_{c,n} = sum_J (-1)^{|J|-1} * [z^n contribution from J]
        # 
        # The tricky part: some of the [z^n] contributions involve g_{c(J),n}
        # at the CURRENT level, making this a linear system.
        
        # For |J|=1: contribution = q^n * g_{c(J),n}  [involves current level!]
        # For |J|=2: contribution = -q^{2n} * g_{c(J),n} + q^{2n-1} * g_{c(J),n-1}  
        #            (note sign: (-1)^{|J|-1} = (-1)^1 = -1, and then the (zq;q)_1 terms)
        # For |J|=3: contribution = q^{3n} * g_{c(J),n} - (q^{3n-2}+q^{3n-1}) g_{c(J),n-1} + q^{3n-3} g_{c(J),n-2}
        #            ((-1)^{|J|-1} = 1)
        
        # Let me be very careful. The equation is:
        # g_{c,n} = sum over (J, sign, polynomial coeffs) of terms involving g values
        
        # This is a LINEAR system: (I - A_n) * g_n = b_n where b_n involves g_{.,n-1} and g_{.,n-2}
        
        N = len(profs)
        prof_idx = {p: i for i, p in enumerate(profs)}
        
        # Build the system matrix and RHS
        A_n = matrix(R, N, N)  # coefficient of g_{c',n} in equation for g_{c,n}
        b_n = vector(R, N)     # known terms from g_{.,n-1} and g_{.,n-2}
        
        for idx, c in enumerate(profs):
            ic = I_c(c)
            for size in range(1, len(ic)+1):
                for J in combinations(ic, size):
                    cp = shifted_profile(c, J)
                    if any(ci < 0 for ci in cp) or sum(cp) != d:
                        continue
                    j_idx = prof_idx[cp]
                    s = size  # |J|
                    sign = (-1)**(s-1)
                    
                    # (zq;q)_{s-1} expanded: coefficients of z^k for k=0,...,s-1
                    # (zq;q)_0 = 1
                    # (zq;q)_1 = 1 - zq
                    # (zq;q)_2 = 1 - zq - zq^2 + z^2 q^3 = 1 - z(q+q^2) + z^2*q^3
                    
                    # General: (zq;q)_{s-1} = sum_{k=0}^{s-1} a_k(q) z^k
                    # where a_k are known q-series coefficients
                    
                    # [z^n] of sign * (zq;q)_{s-1} * sum_m g_{cp,m} q^{s*m} z^m
                    # = sign * sum_{k=0}^{min(s-1,n)} a_k * q^{s*(n-k)} * g_{cp,n-k}
                    
                    # Compute a_k = [z^k] (zq;q)_{s-1}
                    if s == 1:
                        # (zq;q)_0 = 1, a_0 = 1
                        # [z^n] = q^n * g_{cp,n}
                        A_n[idx, j_idx] += sign * q**n
                    elif s == 2:
                        # (zq;q)_1 = 1 - zq, a_0 = 1, a_1 = -q
                        # [z^n] = q^{2n} g_{cp,n} + (-q) * q^{2(n-1)} g_{cp,n-1}
                        #        = q^{2n} g_{cp,n} - q^{2n-1} g_{cp,n-1}
                        A_n[idx, j_idx] += sign * q**(2*n)
                        if n >= 1:
                            b_n[idx] += sign * (-q**(2*n-1)) * g[(cp, n-1)]
                    elif s == 3:
                        # (zq;q)_2 = (1-zq)(1-zq^2) = 1 - z(q+q^2) + z^2*q^3
                        # a_0 = 1, a_1 = -(q+q^2), a_2 = q^3
                        # [z^n] = q^{3n} g_{cp,n} + (-(q+q^2)) * q^{3(n-1)} g_{cp,n-1} + q^3 * q^{3(n-2)} g_{cp,n-2}
                        A_n[idx, j_idx] += sign * q**(3*n)
                        if n >= 1:
                            b_n[idx] += sign * (-(q + q**2)) * q**(3*(n-1)) * g[(cp, n-1)]
                        if n >= 2:
                            b_n[idx] += sign * q**3 * q**(3*(n-2)) * g[(cp, n-2)]
        
        # Solve (I - A_n) * g_n = b_n
        # But wait: the equation is g_{c,n} = sum of A terms + b terms
        # So g_{c,n} - sum A[c,c'] g_{c',n} = b_n[c]
        # (I - A_n) g_n = b_n
        
        I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
        M = I_mat - A_n
        # Move b_n to RHS
        g_n = M.solve_right(b_n)
        
        for i, c in enumerate(profs):
            g[(c, n)] = g_n[i]
    
    return g, profs

# Test with d=2
d = 2
prec = 30
print(f"Computing g_{{c,n}} for d={d}...")
g, profs = compute_gn_coefficients(d, 3, prec)

ell = gcd(d, 3)
R = PowerSeriesRing(QQ, 'q', default_prec=prec)
q = R.gen()

print(f"\ng values and Q values for d={d}:")
for c in profs:
    for n in range(4):
        gval = g[(c, n)]
        # Q_{n,c} = (q^ell;q^ell)_n * g_{c,n}
        qpoch = R(1)
        for i in range(n):
            qpoch *= (1 - q**(ell*(i+1)))
        Qval = qpoch * gval
        
        # Check if polynomial (finite)
        is_poly = all(gval[i] == 0 for i in range(20, prec))
        poly_str = str(Qval.polynomial()) if is_poly else str(Qval)[:80] + "..."
        
        neg = any(Qval[i] < 0 for i in range(prec))
        marker = " [NEG!]" if neg else ""
        print(f"  Q_{n},{c} = {poly_str}{marker}")
    print()
