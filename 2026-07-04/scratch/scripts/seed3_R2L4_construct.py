"""
Seed 3 R2L4 Phase 2: exact expression algebra for constructing the positive y-system
at d=7 (modulus 10).

Expr = { (rep, shift) : { (ypow, qpow) : int } }  representing
    Sum_{(r,s)} m_{r,s}(y,q) * G_r(y q^s),
with G orbit-invariant (engine-verified), profiles normalized to orbit reps.

A ROW for target t is the exact identity G_t(y) = Expr in Z[[y,q]]. Raw rows (CW Prop
incex) are proved; substituting a proved row into a term of a proved row stays proved.
Positive class: coeffs >= 0, shifts >= 1  ==>  q-adic contraction per y-level:
uniqueness + positivity transmission.

Every derived row is verified numerically vs cached engine g (n<=NMAX, q^PREC).
"""
import pickle
from collections import defaultdict

import seed3_R2L4_engine as E

D = 7
NMAX = 8
PREC = E.PREC

def rep(c):
    return E.orbit_rep(tuple(c))

REPS = E.orbit_reps(D)
CORES = [r for r in REPS if all(x > 0 for x in r)]
ZEROS = [r for r in REPS if not all(x > 0 for x in r)]

# ---------- Expr algebra ----------
def enorm(expr):
    out = {}
    for k, m in expr.items():
        mm = {e: v for e, v in m.items() if v}
        if mm:
            out[k] = mm
    return out

def mmul(m1, m2):
    r = defaultdict(int)
    for (j1, a1), v1 in m1.items():
        for (j2, a2), v2 in m2.items():
            r[(j1 + j2, a1 + a2)] += v1 * v2
    return {e: v for e, v in r.items() if v}

def mshift_z(m, s):
    """m(z,q) with z = y q^s: y^j q^a -> y^j q^{a+j*s}."""
    return {(j, a + j * s): v for (j, a), v in m.items()}

def raw_row_expr(c):
    r = defaultdict(lambda: defaultdict(int))
    for (cp, s, coeff) in E.raw_row(tuple(c)):
        k = (rep(cp), s)
        for e, v in coeff.items():
            r[k][e] += v
    return enorm({k: dict(m) for k, m in r.items()})

def substitute(expr, key, row):
    """Replace the FULL term at key=(r,s) using a proved row for r (exact)."""
    r0, s = key
    m_out = expr[key]
    new = {k: dict(m) for k, m in expr.items() if k != key}
    add = defaultdict(lambda: defaultdict(int))
    for (r1, t), m_in in row.items():
        m = mmul(m_out, mshift_z(m_in, s))
        for e, v in m.items():
            add[(r1, s + t)][e] += v
    for k, m in add.items():
        base = new.setdefault(k, {})
        for e, v in m.items():
            base[e] = base.get(e, 0) + v
    return enorm(new)

def negatives(expr):
    return [(k, e, v) for k, m in expr.items() for e, v in m.items() if v < 0]

def is_positive_row(expr):
    return not negatives(expr) and all(s >= 1 for (_, s) in expr)

def head_of(expr):
    heads = [(k, a, v) for k, m in expr.items() for (j, a), v in m.items() if j == 0]
    if len(heads) == 1 and heads[0][2] == 1 and heads[0][1] == 0:
        return heads[0][0]
    return None

# ---------- numeric verification ----------
_G = None
def load_g():
    global _G
    if _G is None:
        with open("seed3_R2L4_g_d7.pkl", "rb") as f:
            _G = pickle.load(f)["g"]
    return _G

def rhs_series(expr, n, g):
    acc = E.snew()
    for (r, s), m in expr.items():
        for (j, a), v in m.items():
            if n - j < 0:
                continue
            sh = a + s * (n - j)
            if sh < PREC:
                E.sadd(acc, g[n - j][r], v, sh)
    return acc

def verify_row(t, expr, nmax=NMAX):
    g = load_g()
    for n in range(nmax + 1):
        if rhs_series(expr, n, g) != g[n][t]:
            return False, n
    return True, None

# ---------- Family A/B mechanical derivations (zero rows) ----------
def derive_A(a, b):
    c = (a, 0, b)
    if b == 0:
        return raw_row_expr(c)
    expr = raw_row_expr(c)
    sub = derive_A(a + 1, b - 1)
    return substitute(expr, (rep((a + 1, 0, b - 1)), 1), sub)

def derive_B(a, b):
    c = (a, b, 0)
    expr = raw_row_expr(c)
    if a == 1:
        sub = raw_row_expr((0, b + 1, 0))
        return substitute(expr, (rep((0, b + 1, 0)), 1), sub)
    sub = derive_A(b + 1, a - 1)
    return substitute(expr, (rep((a - 1, b + 1, 0)), 1), sub)

def derive_zero_rows():
    rows = defaultdict(list)   # rep -> list of (expr, tag)
    for a in range(1, D + 1):
        rows[rep((a, 0, D - a))].append((derive_A(a, D - a), f"A({a},0,{D-a})"))
    for a in range(1, D):
        rows[rep((a, D - a, 0))].append((derive_B(a, D - a), f"B({a},{D-a},0)"))
    return rows

def show(expr):
    def mono(j, a, v):
        s = ("" if v == 1 else "-" if v == -1 else str(v))
        t = s
        if j:
            t += "y" + (f"^{j}" if j > 1 else "")
        if a:
            t += "q" + (f"^{a}" if a > 1 else "")
        if not j and not a:
            t = str(v)
        return t
    parts = []
    for (r, s) in sorted(expr, key=lambda k: (k[1], k[0])):
        m = expr[(r, s)]
        ms = "+".join(mono(j, a, v) for (j, a), v in sorted(m.items())).replace("+-", "-")
        parts.append(f"({ms})*G{r}(yq^{s})")
    return "  +  ".join(parts)

if __name__ == "__main__":
    print(f"d={D}: {len(REPS)} orbits; cores={CORES}")
    print("zeros:", ZEROS)
    rows = derive_zero_rows()
    for r in ZEROS:
        for expr, tag in rows[r]:
            ok, n = verify_row(r, expr)
            pos = is_positive_row(expr)
            hd = head_of(expr)
            print(f"orbit {r} [{tag}]: verify={'PASS' if ok else f'FAIL@n={n}'} "
                  f"positive={pos} head={hd}")
            print("   ", show(expr))
