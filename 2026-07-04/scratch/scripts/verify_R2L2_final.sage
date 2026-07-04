"""
INDEPENDENT VERIFIER: settle disputes C2 and Gauss-inversion claim.
Exact ZZ[q] arithmetic throughout. No truncation.

ITEM 1 (C2): Which 2 of 5 d=4 C_3-orbits lack fermionic H-forms?
ITEM 2 (Gauss inversion): a_n from q-binomial inversion of H == Q_{n,c}?

EMD formula (from seed4 implementation, verified to give exact division):
  emd(c, c') = 3*max(0, a, b) - a - b  where a=c'[1]-c[1], b=c[0]-c'[0]
  This is NOT the physical min-cost flow but is the algebraic EMD giving:
    - emd(c,c) = 0
    - emd(rho c, rho c') = emd(c, c')  (rotation invariant)
    - emd(c, rho c') = emd(c, c') + d (mod 3)  [key property]
"""

R.<q> = ZZ[]

def qpoch(n):
    r = R(1)
    for i in range(n): r *= (1 - q^(i+1))
    return r

def qbinom(n, k):
    if k < 0 or k > n: return R(0)
    r = R(1)
    for i in range(k):
        r *= (1 - q^(n-i))
        r //= (1 - q^(i+1))
    return R(r)

def emd(c, cp):
    """Algebraic EMD from seed4: 3*max(0,a,b) - a - b, a=cp[1]-c[1], b=c[0]-cp[0]."""
    a = cp[1]-c[1]; b = c[0]-cp[0]
    return 3*max(0, a, b) - a - b

# Verify key EMD properties
print("Verifying EMD algebraic properties...")
ok = True
for d in [4, 5]:
    profs = [(c0,c1,d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]
    def rho_p(c): return (c[1],c[2],c[0])
    # Property 1: emd(c,c) = 0
    for c in profs:
        if emd(c,c) != 0:
            print(f"  FAIL: emd({c},{c}) = {emd(c,c)} != 0"); ok = False
    # Property 2: rotation invariance emd(rho c, rho c') = emd(c,c')
    for c in profs[:5]:
        for cp in profs[:5]:
            if emd(rho_p(c), rho_p(cp)) != emd(c,cp):
                print(f"  FAIL rotation invariance c={c}, c'={cp}"); ok = False
    # Property 3: mod-3 shift emd(c, rho c') = emd(c,c') + d mod 3
    for c in profs[:5]:
        for cp in profs[:5]:
            diff = (emd(c, rho_p(cp)) - emd(c, cp)) % 3
            if diff != d % 3:
                print(f"  FAIL mod-3 shift d={d} c={c} c'={cp}"); ok = False
print(f"EMD algebraic properties: {'OK' if ok else 'FAILED'}")
print()

def compute_H(d, M_max):
    """Compute H_{c,m} for all profiles of sum d, m=0..M_max via H-recursion."""
    profs = [(c0,c1,d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]
    H = {c: [R(1)] + [R(0)]*M_max for c in profs}
    for m in range(1, M_max+1):
        denom = 1 + q^m + q^(2*m)
        for c in profs:
            rhs = sum(q^(m*emd(cp,c)) * H[cp][m-1] for cp in profs)
            quo, rem = rhs.quo_rem(denom)
            if rem != 0:
                print(f"  ERROR: nonzero rem at c={c}, m={m}: {rem}")
            H[c][m] = quo
    return H, profs

def orbit_reps_lex(d):
    """One canonical rep per C_3-orbit (lex-min over {c, rho c, rho^2 c})."""
    profs = [(c0,c1,d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]
    seen = set(); reps = []
    for c in profs:
        if c not in seen:
            o = [c, (c[1],c[2],c[0]), (c[2],c[0],c[1])]
            canon = min(o)
            reps.append(canon)
            for x in o: seen.add(x)
    return sorted(set(reps))

def ferm_double(m, a, b, eps):
    """ASW double sum: sum_{n1>=0,n2>=0} q^{n1^2+n2^2-n1*n2+a*n1+b*n2} [m,n1] [2n1+eps,n2]"""
    val = R(0)
    for n1 in range(m+1):
        f = 2*n1 + eps
        if f < 0: continue
        for n2 in range(f+1):
            e = n1*n1 + n2*n2 - n1*n2 + a*n1 + b*n2
            val += q^e * qbinom(m,n1) * qbinom(f,n2)
    return val

def fit_orbit(H_c, M_test=6):
    """Try double-sum fermionic fits. Returns ('double',a,b,eps) or ('none',)."""
    for a in range(-2, 8):
        for b in range(-10, 10):
            for eps in [-4,-3,-2,-1,0,1,2,3,4]:
                if all(ferm_double(m,a,b,eps) == H_c[m] for m in range(M_test+1)):
                    return ('double', a, b, eps)
    return ('none',)

# ========== ITEM 1: d=4 ==========
print("="*60)
print("ITEM 1: d=4 fermionic H-forms")
print("="*60)
print()
print("Computing H_{c,m} for d=4, m=0..6...")
H4, prof4 = compute_H(4, 6)
reps4 = orbit_reps_lex(4)
print(f"C_3-orbit reps: {reps4}  ({len(reps4)} orbits)")
print()

# Sanity: H[c][1](1) should be 5^1 = 5 (total over all 15 profiles = 15 = 3*5)
print("Sanity check H_{c,m}(1):")
for c in reps4[:3]:
    vals = [H4[c][m].subs(q=1) for m in range(4)]
    print(f"  H[{c}][0..3](1) = {vals}")
print()

fit_results = {}
for c in reps4:
    print(f"c={c}:")
    print(f"  H[0..3] = {[str(H4[c][m]) for m in range(4)]}")
    fit = fit_orbit(H4[c])
    fit_results[c] = fit
    if fit[0] == 'none':
        print(f"  -> NO fermionic double-sum fit")
    else:
        a,b,eps = fit[1],fit[2],fit[3]
        print(f"  -> MATCH: a={a}, b={b}, eps={eps}")
        ok_check = all(ferm_double(m,a,b,eps) == H4[c][m] for m in range(7))
        print(f"     Verified m=0..6: {ok_check}")
    print()

no_form = [c for c in reps4 if fit_results[c][0]=='none']
yes_form = [c for c in reps4 if fit_results[c][0]!='none']

print("ITEM 1 VERDICT:")
print(f"  Orbits WITH fermionic forms  : {yes_form}")
print(f"  Orbits WITHOUT fermionic forms: {no_form}")
print()

seed3_missing = sorted([(0,2,2),(0,3,1)])  # Note: these are orbit reps in seed3's convention
seed4_missing = sorted([(0,1,3),(0,2,2)])  # Seed 4's convention

no_form_sorted = sorted(no_form)
print(f"  This computation: missing = {no_form_sorted}")
print(f"  Seed 3 claimed: missing = {seed3_missing}")
print(f"  Seed 4 claimed: missing = {seed4_missing}")
print()

s3_correct = (no_form_sorted == seed3_missing)
s4_correct = (no_form_sorted == seed4_missing)
print(f"  Seed 3 is {'CORRECT' if s3_correct else 'WRONG'}")
print(f"  Seed 4 is {'CORRECT' if s4_correct else 'WRONG'}")
if not s3_correct and not s4_correct:
    print(f"  NEITHER: actual missing = {no_form_sorted}")
print()

# ========== ITEM 2: Gauss inversion ==========
print("="*60)
print("ITEM 2: Gauss inversion check")
print("="*60)
print()
print("Testing: a_n := sum_{m=0}^n (-1)^{n-m} q^{C(n-m,2)} [n,m] H_{c,m}")
print("      == Q_{n,c} := (q^ell;q^ell)_n [z^n] G_c(z)")
print("where G_c(z) = (zq;q)_inf * F_c(z,q).")
print()

# Work in QQ(q) to handle G_c computation
Rq.<qq> = QQ[]
Fq = Rq.fraction_field()

def qp_rat(n):
    r = Rq(1)
    for i in range(n): r *= (1 - qq^(i+1))
    return r

def compute_Q_from_Gc(H_c, ell, N_max, label=""):
    """
    Independent Q_n via [z^n] G_c * (q^ell;q^ell)_n.
    G_c(z) = (zq;q)_inf F_c(z,q) = sum_m c_{n-m} g_{c,m}
    c_k = (-1)^k q^{k(k+1)/2} / (q;q)_k  (coeff of z^k in (zq;q)_inf)
    g_{c,m} = F_{c,m} - F_{c,m-1}  (max part exactly m)
    F_{c,m} = H_{c,m} / (q;q)_m.
    """
    Q_list = []
    for n in range(N_max+1):
        val = Fq(0)
        for m in range(n+1):
            k = n - m
            ck = (-1)^k * qq^(k*(k+1)//2) / Fq(qp_rat(k))
            H_m_q = Rq(list(H_c[m]))
            if m == 0:
                gcm = Fq(H_m_q)  # F_{c,0}=1, g_{c,0}=1
            else:
                H_m1_q = Rq(list(H_c[m-1]))
                gcm = Fq(H_m_q)/Fq(qp_rat(m)) - Fq(H_m1_q)/Fq(qp_rat(m-1))
            val += ck * gcm

        qell_n = Rq(1)
        for i in range(n): qell_n *= (1 - qq^(ell*(i+1)))
        Q_rat = Fq(qell_n) * val

        num = Q_rat.numerator()
        den = Q_rat.denominator()
        g_cd = gcd(num, den)
        n2 = num // g_cd; d2 = den // g_cd
        if d2.degree() > 0:
            print(f"  WARNING {label} n={n}: denom not a unit: {d2}")
            Q_list.append(None)
            continue
        lc = d2.leading_coefficient()
        Q_list.append(R(list(n2 // lc)))
    return Q_list

def check_gauss(H, profs, d, N_max, label=""):
    """Compare Q-transform with direct G_c extraction."""
    ell = gcd(d, 3)
    all_ok = True
    mismatch_examples = []

    for c in profs:
        Q_dir = compute_Q_from_Gc(H[c], ell, N_max, str(c))
        for n in range(N_max+1):
            a_n = sum((-1)^(n-m) * q^((n-m)*(n-m-1)//2) * qbinom(n,m) * H[c][m]
                      for m in range(n+1))
            Q_n = Q_dir[n]
            if Q_n is None:
                all_ok = False; continue
            if a_n != Q_n:
                all_ok = False
                mismatch_examples.append((c, n, a_n, Q_n))

    if mismatch_examples:
        print(f"  d={d}: MISMATCHES:")
        for c, n, an, qn in mismatch_examples[:3]:
            print(f"    c={c}, n={n}: a_n={an}")
            print(f"                  Q_n={qn}")
    return all_ok

print("d=2 (sanity check)...")
H2, prof2 = compute_H(2, 6)
ok2 = check_gauss(H2, prof2, 2, 5, "d=2")
print(f"  d=2: {'ALL MATCH' if ok2 else 'MISMATCHES'}")
print()

print("d=4, all 15 profiles, n=0..5...")
ok4 = check_gauss(H4, prof4, 4, 5, "d=4")
print(f"  d=4: {'ALL MATCH' if ok4 else 'MISMATCHES'}")
print()

print("Computing H for d=5, m=0..6...")
H5, prof5 = compute_H(5, 6)
print("d=5, all 21 profiles, n=0..5...")
ok5 = check_gauss(H5, prof5, 5, 5, "d=5")
print(f"  d=5: {'ALL MATCH' if ok5 else 'MISMATCHES'}")
print()

# Print sample Q values for positivity check
print("Sample Q_n values for d=4 orbit reps (n=1,2,3):")
for c in reps4:
    Q_vals = compute_Q_from_Gc(H4[c], 1, 3, str(c))
    for n in [1,2,3]:
        qv = Q_vals[n]
        neg = any(x < 0 for x in (qv.list() if qv else []))
        print(f"  c={c}, n={n}: {'NEGATIVE' if neg else 'positive'}  Q_n={qv}")
    print()

# ========== FINAL SUMMARY ==========
print("="*60)
print("FINAL SUMMARY")
print("="*60)
print()
print("ITEM 1 (Conflict C2 -- which d=4 orbits lack fermionic H-forms):")
print(f"  Orbit reps: {reps4}")
print(f"  WITHOUT forms: {no_form_sorted}")
if s4_correct:
    print(f"  => SEED 4 IS CORRECT: missing orbits are (0,1,3) and (0,2,2)")
elif s3_correct:
    print(f"  => SEED 3 IS CORRECT: missing orbits are (0,2,2) and (0,3,1)")
else:
    print(f"  => NEITHER SEED IS EXACTLY RIGHT: actual missing = {no_form_sorted}")
    if (0,3,1) in no_form:
        print("     (0,3,1) DOES resist (Seed 3 was right about this one)")
    if (0,1,3) in no_form:
        print("     (0,1,3) DOES resist (Seed 4 was right about this one)")
    if (0,3,1) not in no_form:
        print("     (0,3,1) does NOT resist (Seed 4 was right to exclude it)")
    if (0,1,3) not in no_form:
        print("     (0,1,3) does NOT resist (Seed 3 was right to exclude it)")
print()
print("ITEM 2 (Gauss inversion -- Q-transform a_n == Q_{n,c}):")
print(f"  d=2: {'CONFIRMED' if ok2 else 'FAILED'}")
print(f"  d=4: {'CONFIRMED' if ok4 else 'FAILED'}")
print(f"  d=5: {'CONFIRMED' if ok5 else 'FAILED'}")
if ok2 and ok4 and ok5:
    print("  => Q-transform holds for d=2,4,5 (all profiles, n=0..5)")
    print("     Seed 3's formula is CONFIRMED beyond d=2.")
    print("     Status upgrade: YELLOW -> confirmed for d=2,4,5.")
