"""
INDEPENDENT VERIFIER: settle disputes C2 and Gauss-inversion claim.
All arithmetic exact in ZZ[q]. No truncation.

ITEM 1 (C2): Which 2 of 5 d=4 C_3-orbits lack fermionic H-forms?
ITEM 2 (Gauss inversion): a_n from q-binomial inversion of H_{c,m} == Q_{n,c}?

Definitions:
  H_{c,m} = (q;q)_m * F_{c,m}   (standing notation)
  H-recursion (GREEN): (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1}
  Q-transform claim: Q_{n,c} = sum_{m=0}^n (-1)^{n-m} q^{C(n-m,2)} [n,m]_q H_{c,m}
  EMD: min-cost transport on cycle Z/3Z.
"""

R.<q> = ZZ[]

# ---- q-combinatorics ----

def qpoch(n):
    """(q;q)_n in ZZ[q]"""
    r = R(1)
    for i in range(n):
        r *= (1 - q^(i+1))
    return r

def qbinom(n, k):
    """[n choose k]_q"""
    if k < 0 or k > n:
        return R(0)
    r = R(1)
    for i in range(k):
        r *= (1 - q^(n-i))
        r //= (1 - q^(i+1))
    return R(r)

# ---- EMD on cycle Z/3Z ----

def emd(c, cprime):
    """
    Earth Mover Distance: min-cost flow from c to c' on 3-cycle 0->1->2->0.
    Formula verified against brute-force below.
    From adjugate: EMD(c,c') = 3*max(0, c'1-c1, c0-c'0) + (c'0-c0) - (c'1-c1)
    """
    c0,c1,c2 = c
    d0,d1,d2 = cprime
    return 3*max(0, d1-c1, c0-d0) + (d0-c0) - (d1-c1)

def emd_brute(c, cprime):
    """Brute force EMD via min-cost flow on 3-cycle."""
    # net excess at each node: excess[i] = cprime[i] - c[i]
    s = [cprime[i] - c[i] for i in range(3)]
    # Clockwise flows f[0],f[1],f[2]: f[i] from i to (i+1)%3
    # conservation: f[i] - f[(i-1)%3] = s[i] for all i
    # One free variable f[0]; minimize f[0]+f[1]+f[2] subject to all >=0.
    # f[1] = f[0]+s[1], f[2] = f[0]+s[1]+s[2]
    # All >=0: f[0]>=0, f[0]>=-s[1], f[0]>=-s[1]-s[2]
    f0 = max(0, -s[1], -s[1]-s[2])
    f1 = f0 + s[1]
    f2 = f0 + s[1] + s[2]
    cw = f0 + f1 + f2
    # Counterclockwise: g[i] from i to (i-1)%3
    # g[0] >= 0, g[0]+s[0] >= 0, g[0]+s[0]+s[1] >= 0
    g0 = max(0, -s[0], -s[0]-s[1])
    g1 = g0 + s[0]
    g2 = g0 + s[0] + s[1]
    ccw = g0 + g1 + g2
    return min(cw, ccw)

# Verify EMD formula
def verify_emd():
    ok = True
    for d in [4,5]:
        for c0 in range(d+1):
            for c1 in range(d+1-c0):
                c2 = d-c0-c1
                c = (c0,c1,c2)
                for d0 in range(d+1):
                    for d1 in range(d+1-d0):
                        d2 = d-d0-d1
                        cp = (d0,d1,d2)
                        v1 = emd(c,cp)
                        v2 = emd_brute(c,cp)
                        if v1 != v2:
                            print(f"  EMD MISMATCH: emd{c,cp} formula={v1} brute={v2}")
                            ok = False
    print(f"EMD formula verification: {'OK' if ok else 'FAILED'}")
    return ok

# ---- H_{c,m} via H-recursion ----

def compute_H(d, M_max):
    """
    Compute H_{c,m} for all profiles of sum d, m=0..M_max.
    H_{c,0} = 1; exact division by (1+q^m+q^{2m}) at each step.
    """
    profiles = [(c0,c1,c2) for c0 in range(d+1) for c1 in range(d+1-c0)
                for c2 in [d-c0-c1]]
    H = {c: [R(1)] + [R(0)]*M_max for c in profiles}

    for m in range(1, M_max+1):
        denom = 1 + q^m + q^(2*m)
        for c in profiles:
            rhs = R(0)
            for cp in profiles:
                rhs += q^(m*emd(cp,c)) * H[cp][m-1]
            quo, rem = rhs.quo_rem(denom)
            if rem != 0:
                print(f"  ERROR: non-zero remainder at c={c}, m={m}")
            H[c][m] = quo

    return H, profiles

# ---- C_3-orbit representatives ----

def orbit_reps(d):
    """Return one representative per C_3-rotation-orbit of profiles of sum d."""
    all_p = [(c0,c1,c2) for c0 in range(d+1) for c1 in range(d+1-c0)
             for c2 in [d-c0-c1]]
    seen = set()
    reps = []
    for c in all_p:
        if c not in seen:
            rot = lambda x: (x[1],x[2],x[0])
            orb = [c, rot(c), rot(rot(c))]
            reps.append(min(orb))  # canonical = lex-min
            for x in orb:
                seen.add(x)
    return sorted(set(reps))

# ---- Fermionic form fitting ----

def ferm_single(m, a, b):
    """sum_j q^{a*j^2+b*j} [m,j]_q"""
    return sum(q^(a*j*j+b*j) * qbinom(m,j) for j in range(m+1))

def ferm_double(m, a, b, eps):
    """ASW double sum: sum_{n1,n2} q^{n1^2+n2^2-n1*n2+a*n1+b*n2} [m,n1]_q [2*n1+eps,n2]_q"""
    val = R(0)
    for n1 in range(m+1):
        f = 2*n1 + eps
        if f < 0:
            continue
        for n2 in range(f+1):
            e = n1*n1 + n2*n2 - n1*n2 + a*n1 + b*n2
            val += q^e * qbinom(m,n1) * qbinom(f,n2)
    return val

def fit_fermionic_d4(H, reps, M_test=6):
    """Try single and double sum fits for each d=4 orbit representative."""
    print("\n=== ITEM 1: d=4 fermionic form fitting (m=0..{}) ===".format(M_test))
    results = {}

    for c in reps:
        print(f"\n  Orbit rep c={c}:")
        for m in range(M_test+1):
            print(f"    H[{m}] = {H[c][m]}")

        # Single-sum scan
        found = False
        for a in range(-2, 8):
            for b in range(-8, 8):
                if all(ferm_single(m,a,b) == H[c][m] for m in range(M_test+1)):
                    print(f"    -> SINGLE-SUM MATCH: a={a}, b={b}")
                    found = True
                    results[c] = ('single', a, b)
                    break
            if found:
                break

        if not found:
            # Double-sum scan
            for a in range(-2, 6):
                for b in range(-8, 8):
                    for eps in [-2,-1,0,1,2,3]:
                        if all(ferm_double(m,a,b,eps) == H[c][m] for m in range(M_test+1)):
                            print(f"    -> DOUBLE-SUM MATCH: a={a}, b={b}, eps={eps}")
                            found = True
                            results[c] = ('double', a, b, eps)
                            break
                    if found:
                        break
                if found:
                    break

        if not found:
            print(f"    -> NO MATCH (tried single/double sum)")
            results[c] = ('none',)

    return results

# ---- Gauss inversion (Item 2) ----

def q_transform(H_c, n):
    """a_n = sum_{m=0}^n (-1)^{n-m} q^{C(n-m,2)} [n,m]_q H_{c,m}"""
    val = R(0)
    for m in range(n+1):
        k = n-m
        val += (-1)^k * q^(k*(k-1)//2) * qbinom(n,m) * H_c[m]
    return val

def compute_Q_direct(H, profiles, d, N_max):
    """
    Compute Q_{n,c} independently via:
    Q_{n,c} = (q^ell;q^ell)_n * [z^n] G_c(z)
    where G_c(z) = (zq;q)_inf * F_c(z,q), F_c(z,q) = sum_m g_{c,m} z^m.

    We compute [z^n] G_c * (q;q)_n exactly (to clear denominators), then
    multiply by (q^ell;q^ell)_n / (q;q)_n.

    Actually simpler: use the identity (proved by algebra):
    (q;q)_n [z^n] G_c = sum_{m=0}^n (-1)^{n-m} q^{C(n-m+1)} / ... hmm

    Let's use a clean independent route:
    [z^n] G_c = sum_{m=0}^n c_{n-m} g_{c,m}
    where c_k = (-1)^k q^{k(k+1)/2} / (q;q)_k  (coeff of z^k in (zq;q)_inf)
    and g_{c,m} = F_{c,m} - F_{c,m-1}  (max part exactly m)

    F_{c,m} = H_{c,m} / (q;q)_m  (rational function of q, but H is polynomial)

    We work in QQ(q) and verify the result is a polynomial.
    """
    ell = gcd(d, 3)

    # Work over QQ[q]
    Rq.<qq> = QQ[]
    Fq = Rq.fraction_field()

    def qp(n):
        """(q;q)_n in QQ[q]"""
        r = Rq(1)
        for i in range(n):
            r *= (1 - qq^(i+1))
        return r

    Q_direct = {}
    for c in profiles:
        Q_direct[c] = {}
        for n in range(N_max+1):
            # [z^n] G_c = sum_{m=0}^n c_{n-m} * g_{c,m}
            # c_k = (-1)^k q^{k(k+1)/2} / (q;q)_k
            # g_{c,m} = F_{c,m} - F_{c,m-1} = H_{c,m}/(q;q)_m - H_{c,m-1}/(q;q)_{m-1}
            val = Fq(0)
            for m in range(n+1):
                k = n-m
                # c_k in QQ(q):
                ck = (-1)^k * Fq(qq)^(k*(k+1)//2) / Fq(qp(k))
                # g_{c,m}:
                H_m_q = Rq(list(H[c][m]))  # convert ZZ[q] -> QQ[q]
                if m == 0:
                    gcm = Fq(H_m_q) / Fq(qp(0))  # F_{c,0}=1, g_{c,0}=1
                else:
                    H_m1_q = Rq(list(H[c][m-1]))
                    gcm = Fq(H_m_q)/Fq(qp(m)) - Fq(H_m1_q)/Fq(qp(m-1))
                val += ck * gcm

            # Q_{n,c} = (q^ell;q^ell)_n * val
            qell_n = Rq(1)
            for i in range(n):
                qell_n *= (1 - qq^(ell*(i+1)))
            Q_rat = Fq(qell_n) * val

            # Q should be a polynomial; extract
            num = Q_rat.numerator()
            den = Q_rat.denominator()
            g = gcd(num, den)
            num2 = num // g
            den2 = den // g
            # den2 should be a constant (unit)
            if den2.degree() > 0:
                print(f"  WARNING c={c}, n={n}: denominator = {den2}")
                Q_direct[c][n] = None
                continue
            # Scale by leading coeff of den2
            lc = den2.leading_coefficient()
            Q_direct[c][n] = R(list(num2 // lc))

    return Q_direct

def check_gauss_inversion(H, profiles, d, N_max):
    """Compare Q-transform a_n with direct Q_{n,c}."""
    Q_dir = compute_Q_direct(H, profiles, d, N_max)

    print(f"\n=== ITEM 2: Gauss inversion for d={d}, n=0..{N_max} ===")
    all_match = True
    results = {}

    for c in profiles:
        results[c] = {}
        for n in range(N_max+1):
            a_n = q_transform(H[c], n)
            Q_n = Q_dir[c][n]

            if Q_n is None:
                results[c][n] = 'error'
                all_match = False
                continue

            match = (a_n == Q_n)
            results[c][n] = match
            if not match:
                all_match = False
                print(f"  c={c}, n={n}: MISMATCH")
                print(f"    a_n = {a_n}")
                print(f"    Q_n = {Q_n}")
                print(f"    diff = {a_n - Q_n}")

    # Check positivity of Q_n
    print(f"  d={d}: all a_n == Q_n direct: {all_match}")
    if all_match:
        print(f"  Checking positivity of Q_n...")
        for c in profiles:
            for n in range(1, N_max+1):
                q_n = Q_dir[c][n]
                if q_n is not None:
                    coeffs = q_n.list()
                    if any(x < 0 for x in coeffs):
                        print(f"    c={c}, n={n}: NEGATIVE COEFFICIENTS in Q_n = {q_n}")

    return results, all_match

# ============================================================
# MAIN
# ============================================================

print("="*65)
print("VERIFIER: Warnaar Disputes Resolution")
print("="*65)

# Verify EMD
emd_ok = verify_emd()
print()

# d=4 setup
print("Computing H_{c,m} for d=4, m=0..6...")
H4, prof4 = compute_H(4, 6)
reps4 = orbit_reps(4)
print(f"C_3-orbits for d=4: {reps4}  ({len(reps4)} orbits)")

# Sanity: H_{c,m}(q=1) 
c0 = reps4[0]
print(f"Sanity H[{c0},m](1): {[H4[c0][m].subs(q=1) for m in range(5)]}")
print()

# ITEM 1
fit4 = fit_fermionic_d4(H4, reps4)

print("\n" + "="*40)
print("ITEM 1 VERDICT:")
no_form = [c for c in reps4 if fit4[c][0]=='none']
yes_form = [c for c in reps4 if fit4[c][0]!='none']
print(f"  Orbits WITH forms : {yes_form}")
print(f"  Orbits WITHOUT    : {no_form}")
if (0,1,3) in no_form and (0,3,1) not in no_form:
    print("  -> SEED 4 CORRECT: (0,1,3) resists, NOT (0,3,1)")
elif (0,3,1) in no_form and (0,1,3) not in no_form:
    print("  -> SEED 3 CORRECT: (0,3,1) resists, NOT (0,1,3)")
elif (0,1,3) in no_form and (0,3,1) in no_form:
    print("  -> BOTH (0,1,3) AND (0,3,1) resist (contradiction: both missing)")
    print("     [Check orbit representative convention]")
print()

# ITEM 2: Gauss inversion
print("Computing H_{c,m} for d=5, m=0..6...")
H5, prof5 = compute_H(5, 6)
print(f"  Profiles for d=5: {len(prof5)}")
print()

r4, ok4 = check_gauss_inversion(H4, prof4, 4, 5)
r5, ok5 = check_gauss_inversion(H5, prof5, 5, 5)

print()
print("="*65)
print("FINAL VERDICT SUMMARY")
print("="*65)
print()
print("ITEM 1 (Conflict C2 - which d=4 orbits lack fermionic H-forms):")
print(f"  5 C_3-orbit reps: {reps4}")
print(f"  Missing forms   : {no_form}")
print()
print("ITEM 2 (Gauss inversion a_n == Q_{n,c}):")
print(f"  d=4, n=0..5, all profiles: {'CONFIRMED' if ok4 else 'FAILED'}")
print(f"  d=5, n=0..5, all profiles: {'CONFIRMED' if ok5 else 'FAILED'}")
print()
if ok4 and ok5:
    print("  => Q-transform is CORRECT. Seed 3's claimed identity holds.")
    print("     (was 'stated but telescoping not exhibited' -- now VERIFIED independently)")
