"""
Seed 2, Layer 2: Test higher Hankel minors of {F_{c,N}}.
Also compute h_m for d=7.

With properly stabilized F_{c,N}, check:
1. 2x2 Hankel minors (log-concavity of g_m)
2. 3x3 and 4x4 Hankel minors
3. h_m for d=7 profiles

Key question: is {F_{c,N}} log-concave? log-convex? totally positive?
"""
from collections import defaultdict

class QPoly:
    def __init__(self, coeffs=None, max_deg=300):
        self.max_deg = max_deg
        self.coeffs = defaultdict(int)
        if coeffs:
            for k, v in (coeffs.items() if isinstance(coeffs, dict) else enumerate(coeffs)):
                if k <= max_deg and v != 0:
                    self.coeffs[k] = v

    @staticmethod
    def one(md=300):
        return QPoly({0: 1}, md)

    @staticmethod
    def zero(md=300):
        return QPoly({}, md)

    def __add__(self, other):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            r.coeffs[k] += v
        for k, v in other.coeffs.items():
            if k <= self.max_deg:
                r.coeffs[k] += v
        return r

    def __sub__(self, other):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            r.coeffs[k] += v
        for k, v in other.coeffs.items():
            if k <= self.max_deg:
                r.coeffs[k] -= v
        return r

    def __mul__(self, other):
        r = QPoly(max_deg=self.max_deg)
        for i, ai in self.coeffs.items():
            if ai == 0: continue
            for j, bj in other.coeffs.items():
                if bj == 0 or i+j > self.max_deg: continue
                r.coeffs[i+j] += ai * bj
        return r

    def scale(self, c):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            r.coeffs[k] = v * c
        return r

    def shift(self, s):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            if 0 <= k+s <= self.max_deg:
                r.coeffs[k+s] = v
        return r

    def to_list(self):
        if not self.coeffs:
            return [0]
        nz = [k for k, v in self.coeffs.items() if v != 0]
        if not nz:
            return [0]
        md = max(nz)
        return [self.coeffs.get(i, 0) for i in range(md + 1)]

    def eval_at_1(self):
        return sum(self.coeffs.values())

    def is_nonneg(self):
        return all(v >= 0 for v in self.coeffs.values())

    def min_coeff(self):
        vals = [v for v in self.coeffs.values() if v != 0]
        return min(vals) if vals else 0

    def degree(self):
        nz = [k for k, v in self.coeffs.items() if v != 0]
        return max(nz) if nz else -1


def compute_FcN_stable(c, N, q_max):
    """Compute F_{c,N}(q) with enough parts for stability."""
    k = len(c)
    assert k == 3

    def gen_parts(max_val, nparts, max_size):
        if nparts == 0:
            yield ()
            return
        for first in range(min(max_val, max_size), -1, -1):
            for rest in gen_parts(first, nparts - 1, max_size - first):
                yield (first,) + rest

    def interlaces(lam, mu, shift):
        for j in range(len(lam)):
            js = j + shift
            mv = mu[js] if js < len(mu) else 0
            if lam[j] < mv:
                return False
        return True

    prev = None
    for mp in range(N + max(c) + 2, q_max + 3, 2):
        all_p = list(gen_parts(N, mp, q_max))
        result = QPoly.zero(q_max)
        for lam0 in all_p:
            s0 = sum(lam0)
            if s0 > q_max: continue
            for lam1 in all_p:
                if not interlaces(lam0, lam1, c[1]): continue
                s1 = sum(lam1)
                if s0+s1 > q_max: continue
                for lam2 in all_p:
                    if not interlaces(lam1, lam2, c[2]): continue
                    if not interlaces(lam2, lam0, c[0]): continue
                    s2 = sum(lam2)
                    total = s0+s1+s2
                    if total > q_max: continue
                    result.coeffs[total] += 1
        cur = result.to_list()
        if prev is not None and cur == prev:
            return result
        prev = cur
        if mp >= q_max:
            return result
    return result


def main():
    import sys
    
    # ===== Part 1: Hankel minors for d=4 =====
    print("="*60)
    print("Part 1: Hankel minors of {F_{c,N}} for c=(2,1,1), d=4")
    print("="*60)
    
    profile = (2, 1, 1)
    d = sum(profile)
    q_max = 15
    
    N_max = 5
    FcN = []
    for N in range(N_max + 1):
        print(f"  Computing F_{{c,{N}}}...", end=" ", flush=True)
        F = compute_FcN_stable(profile, N, q_max)
        FcN.append(F)
        print(f"F(1)={F.eval_at_1()}")
    
    # Log-concavity: F_{N+1}^2 - F_N * F_{N+2}
    print(f"\n--- Log-concavity: F_{{N+1}}^2 - F_N * F_{{N+2}} ---")
    for N in range(N_max - 1):
        lc = FcN[N+1] * FcN[N+1] - FcN[N] * FcN[N+2]
        print(f"  N={N}: nonneg={lc.is_nonneg()}, eval1={lc.eval_at_1()}, min={lc.min_coeff()}")
        if not lc.is_nonneg():
            negs = sorted([(k,v) for k,v in lc.coeffs.items() if v < 0])
            print(f"    NEGATIVE: {negs[:5]}")
    
    # Hankel 3x3
    print(f"\n--- Hankel 3x3: det[F_{{N+i+j}}] ---")
    for N in range(N_max - 3):
        a = [[FcN[N+i+j] for j in range(3)] for i in range(3)]
        # Cofactor expansion
        m00 = a[1][1]*a[2][2] - a[1][2]*a[2][1]
        m01 = a[1][0]*a[2][2] - a[1][2]*a[2][0]
        m02 = a[1][0]*a[2][1] - a[1][1]*a[2][0]
        det3 = a[0][0]*m00 - a[0][1]*m01 + a[0][2]*m02
        print(f"  N={N}: nonneg={det3.is_nonneg()}, eval1={det3.eval_at_1()}, min={det3.min_coeff()}")
        if not det3.is_nonneg():
            negs = sorted([(k,v) for k,v in det3.coeffs.items() if v < 0])
            print(f"    NEGATIVE: {negs[:10]}")
    
    # ===== Part 2: h_m for d=7 =====
    print(f"\n{'='*60}")
    print("Part 2: h_m for d=7, profile c=(3,2,2)")
    print("="*60)
    
    profile7 = (3, 2, 2)
    d7 = sum(profile7)
    base7 = (d7+1)*(d7+2)//6  # = 8*9/6 = 12
    q_max7 = 12
    
    print(f"Profile c = {profile7}, d = {d7}, base = {base7}")
    
    FcN7 = []
    for N in range(4):
        print(f"  Computing F_{{c,{N}}}...", end=" ", flush=True)
        F = compute_FcN_stable(profile7, N, q_max7)
        FcN7.append(F)
        print(f"F(1)={F.eval_at_1()}, coeffs={F.to_list()}")
    
    for m in range(1, len(FcN7)):
        g_m = FcN7[m] - FcN7[m-1]
        print(f"\n  g_{m} = {g_m.to_list()}")
        
        qq_m = QPoly.one(q_max7)
        for i in range(1, m+1):
            qq_m = qq_m * QPoly({0: 1, i: -1}, q_max7)
        
        h_m = qq_m * g_m
        print(f"  h_{m} = {h_m.to_list()}")
        print(f"  h_{m}(1) = {h_m.eval_at_1()}, expected {base7}^{m} = {base7**m}")
        print(f"  nonneg = {h_m.is_nonneg()}")
    
    # Q_n for d=7
    print(f"\n--- Q_n for d=7, c=(3,2,2) ---")
    for n in range(3):
        Q_n = QPoly.zero(q_max7)
        for j in range(n + 1):
            sign = (-1) ** j
            q_shift = j * (j - 1) // 2
            ratio = QPoly.one(q_max7)
            for i in range(j + 1, n + 1):
                ratio = ratio * QPoly({0: 1, i: -1}, q_max7)
            term = ratio * FcN7[n - j]
            term = term.scale(sign).shift(q_shift)
            Q_n = Q_n + term
        print(f"  Q_{n} = {Q_n.to_list()}")
        print(f"    Q(1) = {Q_n.eval_at_1()}, expected {(base7-1)**n}, nonneg = {Q_n.is_nonneg()}")
    
    # ===== Part 3: h_m for d=7, profile (4,2,1) =====
    print(f"\n{'='*60}")
    print("Part 3: h_m for d=7, profile c=(4,2,1)")
    print("="*60)
    
    profile7b = (4, 2, 1)
    q_max7b = 12
    
    print(f"Profile c = {profile7b}, d = {d7}, base = {base7}")
    
    FcN7b = []
    for N in range(4):
        print(f"  Computing F_{{c,{N}}}...", end=" ", flush=True)
        F = compute_FcN_stable(profile7b, N, q_max7b)
        FcN7b.append(F)
        print(f"F(1)={F.eval_at_1()}, coeffs={F.to_list()}")
    
    for m in range(1, len(FcN7b)):
        g_m = FcN7b[m] - FcN7b[m-1]
        qq_m = QPoly.one(q_max7b)
        for i in range(1, m+1):
            qq_m = qq_m * QPoly({0: 1, i: -1}, q_max7b)
        h_m = qq_m * g_m
        print(f"  h_{m} = {h_m.to_list()}")
        print(f"  h_{m}(1) = {h_m.eval_at_1()}, expected {base7**m}, nonneg = {h_m.is_nonneg()}")
    
    # Q_n for (4,2,1)
    print(f"\n--- Q_n for d=7, c=(4,2,1) ---")
    for n in range(3):
        Q_n = QPoly.zero(q_max7b)
        for j in range(n + 1):
            sign = (-1) ** j
            q_shift = j * (j - 1) // 2
            ratio = QPoly.one(q_max7b)
            for i in range(j + 1, n + 1):
                ratio = ratio * QPoly({0: 1, i: -1}, q_max7b)
            term = ratio * FcN7b[n - j]
            term = term.scale(sign).shift(q_shift)
            Q_n = Q_n + term
        print(f"  Q_{n} = {Q_n.to_list()}")
        print(f"    Q(1) = {Q_n.eval_at_1()}, expected {(base7-1)**n}, nonneg = {Q_n.is_nonneg()}")


if __name__ == "__main__":
    main()
