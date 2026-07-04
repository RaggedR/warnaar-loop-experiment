# Compute Q_1 for d=2, c=(1,1,0) by brute force
# Q_{n,c} = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
# For n=1: Q_1 = (1-q) * [z^1]((zq;q)_inf * F_c(z,q))
# = (1-q) * [z^1]((1-zq)(1-zq^2)... * sum_m F_{c,m} z^m)
# = (1-q) * [z^1](sum_m F_{c,m} z^m - zq * sum_m F_{c,m} z^m + O(z^2))
# = (1-q) * (F_{c,1} - q * F_{c,0})
# = (1-q) * (F_{c,1} - q)  since F_{c,0} = 1

# Wait, (zq;q)_inf * F_c(z,q) = (1 - zq)(1-zq^2)... * sum_m F_{c,m} z^m
# [z^0] = F_{c,0} = 1
# [z^1] = F_{c,1} - q*F_{c,0} = F_{c,1} - q
# Q_1 = (1-q)(F_{c,1} - q)

# From brute force: F_{(1,1,0),1} = 1+2q+2q^2+...+q^15
# But this is the BOUNDED generating function (max <= 1), not [z^1] of F_c(z,q).

# Wait. F_c(z,q) = sum_Lambda z^{max(Lambda)} q^{size(Lambda)}
# So [z^m] F_c(z,q) = sum over Lambda with max(Lambda) = m of q^{size(Lambda)}
# This is different from F_{c,m}^bounded = sum over Lambda with max(Lambda) <= m.

# F_{c,m}^bounded = sum_{j=0}^m [z^j] F_c(z,q)

# From brute force:
# F_{(1,1,0),0}^bounded = 1 (only the empty CP)
# F_{(1,1,0),1}^bounded = 1+2q+2q^2+...+q^15

# So [z^0] F = 1 (the empty CP has max 0)
# [z^1] F = F^bounded_1 - F^bounded_0 = (1+2q+2q^2+...+q^15) - 1 = 2q+2q^2+...+q^15

R = PolynomialRing(QQ, 'q')
q = R.gen()

# From brute force earlier
F_bounded_0 = R(1)
F_bounded_1 = sum(c * q**i for i, c in enumerate([1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1]))

f1 = F_bounded_1 - F_bounded_0  # [z^1] F_c(z,q) = GF for CPs with max exactly 1
print(f"[z^1] F_c(z,q) for c=(1,1,0): {f1}")

# [z^1] of (zq;q)_inf * F_c(z,q)
# = [z^1] of (1 - zq)(1-zq^2)... * (F_{c,0} + F_{c,1}*z + ...)
# = [z^1] of (sum terms)
# = f1 - q * F_{c,0} ... wait, (zq;q)_inf's [z^0] coefficient is 1.
# (zq;q)_inf = 1 - zq - zq^2 + z^2 q^3 + ... (this is the expansion)
# Actually (zq;q)_inf = prod_{j>=1} (1 - zq^j)
# [z^0] = 1
# [z^1] = -sum_{j>=1} q^j = -q/(1-q) (infinite series!)

# This is wrong for polynomial computation. Let me use power series.

R2 = PowerSeriesRing(QQ, 'q', default_prec=50)
q2 = R2.gen()

# (zq;q)_inf as coefficients of z^k
# [z^0] = 1
# [z^1] = -sum_{j>=1} q^j = -q/(1-q)
# [z^2] = sum_{1<=i<j} q^{i+j} = ...

# So [z^1] of (zq;q)_inf * F_c(z,q) 
# = 1 * f1 + (-q/(1-q)) * F_{c,0}
# = f1 - q/(1-q)

# Using power series
f1_ps = R2([0, 2,2,2,2,2,2,2,2,2,2,2,2,2,2,1])  # [z^1] F = GF for max exactly 1
g1 = f1_ps - q2/(1-q2)  # [z^1] of G_c(z,q)

print(f"\ng_1 = [z^1] G_c(z,q) for (1,1,0):")
print(f"  = {[g1[i] for i in range(20)]}")

# Q_1 = (1-q) * g_1
Q1 = (1 - q2) * g1
print(f"\nQ_1((1,1,0)) = (1-q) * g_1:")
print(f"  first 20 coeffs: {[Q1[i] for i in range(20)]}")

# So Q_1 = (1-q) * (f1 - q/(1-q))
# = (1-q)*f1 - q
# f1 = 2q + 2q^2 + ... + q^15
# (1-q)*f1 = 2q + 0 + 0 + ... + 0 - q^15 + q^16... wait let me compute

Q1_poly = (1-q) * f1 - q  # but f1 is polynomial, q/(1-q) is series, need to be careful
print(f"\nUsing polynomials: (1-q)*f1 - q = {(1-q)*f1 - q}")
# But this is wrong because (1-q)*(-q/(1-q)) = -q, not q/(1-q)

# Let me just check: (1-q) * g_1 should be a polynomial
# g_1 = f1 - q/(1-q) = (2q+2q^2+...+q^15) - q - q^2 - q^3 - ...
# = q + q^2 + q^3 + ... + q^14 + q^15 - q^16 - q^17 - ...
# Hmm that doesn't look right.

# Actually: f1 = 2q + 2q^2 + 2q^3 + ... + 2q^14 + q^15
# q/(1-q) = q + q^2 + q^3 + ...
# g_1 = f1 - q/(1-q) = (2-1)q + (2-1)q^2 + ... + (2-1)q^14 + (1-1)q^15 + (0-1)q^16 + ...
# = q + q^2 + ... + q^14 - q^16 - q^17 - ...

# Q_1 = (1-q) * g_1
# = (1-q)(q + q^2 + ... + q^14 - q^16 - ...)
# = q + q^2 + ... + q^14 - q^16 - ... 
#   - q^2 - q^3 - ... - q^15 + q^17 + ...
# = q - q^15 - q^16 + q^17 + ... hmm this is getting messy

# Let me just compute numerically
print(f"\nNumerical Q_1 coeffs: {[Q1[i] for i in range(30)]}")
