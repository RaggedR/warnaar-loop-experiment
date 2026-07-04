"""
Seed 2, Layer 2: Degree analysis of h_m.

Observation: h_m has deg(h_m) that seems to grow like deg(Q_n).
For c=(2,1,1): deg(h_1) = 3, deg(h_2) = 12, deg(h_3) = 27.
These are exactly 3*1^2, 3*2^2, 3*3^2.
Same as deg(Q_n) = 3n^2!

So deg(h_m) = deg(Q_m). This makes sense from the formula
Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}.
The highest degree term comes from j=0: h_n.
So deg(Q_n) = deg(h_n), which explains why they match.

But h_m(1) = 5^m means h_m needs to have coefficients summing to 5^m.
With deg(h_m) = 3m^2, the average coefficient is 5^m / (3m^2 + 1),
which grows exponentially. So h_m coefficients must grow.

Key question: is h_m = Q_m? Let me check.
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
    def one(md=300): return QPoly({0: 1}, md)
    @staticmethod
    def zero(md=300): return QPoly({}, md)

    def __add__(self, o):
        r = QPoly(max_deg=self.max_deg)
        for k,v in self.coeffs.items(): r.coeffs[k] += v
        for k,v in o.coeffs.items():
            if k <= self.max_deg: r.coeffs[k] += v
        return r

    def __sub__(self, o):
        r = QPoly(max_deg=self.max_deg)
        for k,v in self.coeffs.items(): r.coeffs[k] += v
        for k,v in o.coeffs.items():
            if k <= self.max_deg: r.coeffs[k] -= v
        return r

    def __mul__(self, o):
        r = QPoly(max_deg=self.max_deg)
        for i,ai in self.coeffs.items():
            if ai == 0: continue
            for j,bj in o.coeffs.items():
                if bj == 0 or i+j > self.max_deg: continue
                r.coeffs[i+j] += ai * bj
        return r

    def scale(self, c):
        r = QPoly(max_deg=self.max_deg)
        for k,v in self.coeffs.items(): r.coeffs[k] = v * c
        return r

    def shift(self, s):
        r = QPoly(max_deg=self.max_deg)
        for k,v in self.coeffs.items():
            if 0 <= k+s <= self.max_deg: r.coeffs[k+s] = v
        return r

    def to_list(self):
        if not self.coeffs: return [0]
        nz = [k for k,v in self.coeffs.items() if v != 0]
        if not nz: return [0]
        return [self.coeffs.get(i, 0) for i in range(max(nz) + 1)]

    def eval_at_1(self): return sum(self.coeffs.values())
    def is_nonneg(self): return all(v >= 0 for v in self.coeffs.values())
    def degree(self):
        nz = [k for k,v in self.coeffs.items() if v != 0]
        return max(nz) if nz else -1


def compute_FcN_stable(c, N, q_max):
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
            if lam[j] < mv: return False
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
        if prev is not None and cur == prev: return result
        prev = cur
        if mp >= q_max: return result
    return result


def main():
    profile = (2, 1, 1)
    q_max = 30
    base = 5

    FcN = []
    for N in range(5):
        print(f"Computing F_{{c,{N}}}...", end=" ", flush=True)
        F = compute_FcN_stable(profile, N, q_max)
        FcN.append(F)
        print(f"F(1)={F.eval_at_1()}")

    # Compute h_m and Q_n and compare
    print(f"\n--- h_m vs Q_m comparison ---")
    for m in range(1, len(FcN)):
        # h_m
        g = FcN[m] - FcN[m-1]
        qq = QPoly.one(q_max)
        for i in range(1, m+1):
            qq = qq * QPoly({0: 1, i: -1}, q_max)
        h = qq * g

        # Q_m
        Q = QPoly.zero(q_max)
        for j in range(m + 1):
            sign = (-1) ** j
            q_shift = j * (j - 1) // 2
            ratio = QPoly.one(q_max)
            for i in range(j + 1, m + 1):
                ratio = ratio * QPoly({0: 1, i: -1}, q_max)
            term = ratio * FcN[m - j]
            term = term.scale(sign).shift(q_shift)
            Q = Q + term

        h_list = h.to_list()
        q_list = Q.to_list()
        
        print(f"\n  m={m}:")
        print(f"    h_{m} = {h_list}")
        print(f"    Q_{m} = {q_list}")
        print(f"    h_{m}(1) = {h.eval_at_1()}, Q_{m}(1) = {Q.eval_at_1()}")
        
        # Difference
        diff = h - Q
        diff_list = diff.to_list()
        print(f"    h_{m} - Q_{m} = {diff_list}")
        print(f"    (h-Q)(1) = {diff.eval_at_1()}")

    # Key relationship between h and Q:
    # Q_n = h_n + sum_{j=1}^n (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}
    # So Q_n = h_n - correction terms.
    # If all h_m >= 0 and the correction terms are "smaller" than h_n,
    # then Q_n >= 0.
    #
    # Let me compute: for the formula Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j},
    # what fraction of h_n survives as Q_n?
    print(f"\n--- Survival fraction h_n(1) -> Q_n(1) ---")
    for m in range(1, len(FcN)):
        g = FcN[m] - FcN[m-1]
        qq = QPoly.one(q_max)
        for i in range(1, m+1):
            qq = qq * QPoly({0: 1, i: -1}, q_max)
        h = qq * g
        
        Q = QPoly.zero(q_max)
        for j in range(m + 1):
            sign = (-1) ** j
            q_shift = j * (j - 1) // 2
            ratio = QPoly.one(q_max)
            for i in range(j + 1, m + 1):
                ratio = ratio * QPoly({0: 1, i: -1}, q_max)
            term = ratio * FcN[m - j]
            term = term.scale(sign).shift(q_shift)
            Q = Q + term
        
        h1 = h.eval_at_1()
        q1 = Q.eval_at_1()
        print(f"  m={m}: h(1)={h1} ({base}^{m}={base**m}), Q(1)={q1} ({base-1}^{m}={(base-1)**m})")
        if h1 > 0:
            print(f"    ratio Q/h = {q1/h1:.4f}, expected (base-1)/base = {(base-1)/base:.4f}")


if __name__ == "__main__":
    main()
