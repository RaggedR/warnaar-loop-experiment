"""
Seed 2, Layer 2: Investigate Connection A.
Is h_m >= 0 equivalent to total positivity of {F_{c,N}}?
Does one imply the other?

Recall:
  h_m(q) = (q;q)_m * g_m(q)  where g_m = [z^m] F_c(z,q) = F_{c,m} - F_{c,m-1}
  Q_n = sum_{j=0}^n (-1)^j q^{j(j-1)/2} [n choose j]_q h_{n-j}

Total positivity of {F_{c,N}}: ALL Hankel-type minors
  det[F_{c,N+i+j}]_{0<=i,j<=k} >= 0 for all N, k.

We test:
1. Compute h_m for several profiles and check positivity.
2. Compute Hankel minors of {F_{c,N}} (2x2, 3x3, 4x4).
3. Check if h_m >= 0 implies anything about Hankel minors, or vice versa.
"""
from collections import defaultdict


class QPoly:
    def __init__(self, coeffs=None, max_deg=200):
        self.max_deg = max_deg
        self.coeffs = defaultdict(int)
        if coeffs:
            for k, v in (coeffs.items() if isinstance(coeffs, dict) else enumerate(coeffs)):
                if k <= max_deg and v != 0:
                    self.coeffs[k] = v

    @staticmethod
    def one(md=200):
        return QPoly({0: 1}, md)

    @staticmethod
    def zero(md=200):
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
        return self + other.scale(-1)

    def __mul__(self, other):
        r = QPoly(max_deg=self.max_deg)
        for i, ai in self.coeffs.items():
            if ai == 0: continue
            for j, bj in other.coeffs.items():
                if bj == 0 or i+j > self.max_deg: continue
                r.coeffs[i+j] += ai * bj
        return r

    def shift(self, s):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            if 0 <= k+s <= self.max_deg:
                r.coeffs[k+s] = v
        return r

    def scale(self, c):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            r.coeffs[k] = v * c
        return r

    def to_list(self):
        if not self.coeffs:
            return [0]
        md = max(self.coeffs.keys())
        result = [self.coeffs.get(i, 0) for i in range(md + 1)]
        while len(result) > 1 and result[-1] == 0:
            result.pop()
        return result

    def eval_at_1(self):
        return sum(self.coeffs.values())

    def is_nonneg(self):
        return all(v >= 0 for v in self.coeffs.values())

    def min_coeff(self):
        if not self.coeffs:
            return 0
        return min(self.coeffs.values())

    def __repr__(self):
        lst = self.to_list()
        if len(lst) <= 30:
            terms = []
            for i, c in enumerate(lst):
                if c != 0:
                    if i == 0:
                        terms.append(str(c))
                    elif c == 1:
                        terms.append(f"q^{i}")
                    elif c == -1:
                        terms.append(f"-q^{i}")
                    else:
                        terms.append(f"{c}q^{i}")
            return " + ".join(terms) if terms else "0"
        return f"QPoly(deg={max(self.coeffs.keys()) if self.coeffs else 0}, eval1={self.eval_at_1()})"


def compute_FcN(c, N, q_max):
    k = len(c)
    assert k == 3
    max_parts = N + max(c) + 2

    def gen_parts(max_val, nparts, max_size):
        if nparts == 0:
            yield ()
            return
        for first in range(min(max_val, max_size), -1, -1):
            for rest in gen_parts(first, nparts - 1, max_size - first):
                yield (first,) + rest

    all_p = list(gen_parts(N, max_parts, q_max))

    def interlaces(lam, mu, shift):
        for j in range(len(lam)):
            js = j + shift
            mv = mu[js] if js < len(mu) else 0
            if lam[j] < mv:
                return False
        return True

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
    return result


def compute_hm(FcN_list, m, q_max):
    if m == 0:
        return QPoly.one(q_max)
    g_m = FcN_list[m] - FcN_list[m-1]
    # (q;q)_m
    qq_m = QPoly.one(q_max)
    for i in range(1, m+1):
        qq_m = qq_m * QPoly({0: 1, i: -1}, q_max)
    return qq_m * g_m


def hankel_det_2x2(seq, N):
    return seq[N] * seq[N+2] - seq[N+1] * seq[N+1]


def hankel_det_3x3(seq, N):
    a00, a01, a02 = seq[N], seq[N+1], seq[N+2]
    a10, a11, a12 = seq[N+1], seq[N+2], seq[N+3]
    a20, a21, a22 = seq[N+2], seq[N+3], seq[N+4]
    m00 = a11 * a22 - a12 * a21
    m01 = a10 * a22 - a12 * a20
    m02 = a10 * a21 - a11 * a20
    return a00 * m00 - a01 * m01 + a02 * m02


def main():
    q_max = 25

    test_profiles = [
        (1, 1, 0),   # d=2
        (2, 1, 1),   # d=4
        (2, 2, 1),   # d=5
    ]

    for profile in test_profiles:
        d = sum(profile)
        if d % 3 == 0:
            continue
        base = (d+1)*(d+2)//6
        print(f"\n{'='*60}")
        print(f"Profile c = {profile}, d = {d}, base = {base}")
        print(f"{'='*60}")

        n_max = 5
        FcN = []
        for N in range(n_max + 1):
            print(f"  Computing F_{{c,{N}}}(q)...", end=" ", flush=True)
            F = compute_FcN(profile, N, q_max)
            FcN.append(F)
            print(f"F(1) = {F.eval_at_1()}")

        print(f"\n--- h_m values ---")
        for m in range(n_max):
            h = compute_hm(FcN, m, q_max)
            print(f"  h_{m}: nonneg={h.is_nonneg()}, eval1={h.eval_at_1()}, expected={base**m}")
            coeffs = h.to_list()
            if len(coeffs) <= 20:
                print(f"    coeffs = {coeffs}")

        print(f"\n--- Log-concavity: F_{{N+1}}^2 - F_N * F_{{N+2}} ---")
        for N in range(n_max - 1):
            lc = FcN[N+1] * FcN[N+1] - FcN[N] * FcN[N+2]
            print(f"  LC({N}) nonneg={lc.is_nonneg()}, eval1={lc.eval_at_1()}, min_coeff={lc.min_coeff()}")

        print(f"\n--- Hankel 2x2: F_N*F_{{N+2}} - F_{{N+1}}^2  (log-convexity) ---")
        for N in range(n_max - 1):
            det2 = hankel_det_2x2(FcN, N)
            print(f"  H2({N}) nonneg={det2.is_nonneg()}, eval1={det2.eval_at_1()}, min_coeff={det2.min_coeff()}")

        if n_max >= 5:
            print(f"\n--- Hankel 3x3 at N=0 ---")
            det3 = hankel_det_3x3(FcN, 0)
            print(f"  H3(0) nonneg={det3.is_nonneg()}, eval1={det3.eval_at_1()}, min_coeff={det3.min_coeff()}")
            if not det3.is_nonneg():
                negs = {k: v for k, v in det3.coeffs.items() if v < 0}
                print(f"  NEGATIVE COEFFS (first 10): {dict(sorted(negs.items())[:10])}")

        print(f"\n--- g_m = F_{{c,m}} - F_{{c,m-1}} ---")
        for m in range(1, min(n_max, 4)):
            g = FcN[m] - FcN[m-1]
            print(f"  g_{m} first coeffs: {g.to_list()[:15]}")
            print(f"    g_{m}(1) = {g.eval_at_1()}")


if __name__ == "__main__":
    main()
