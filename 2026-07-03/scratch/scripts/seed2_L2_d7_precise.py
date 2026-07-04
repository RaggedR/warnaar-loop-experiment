"""
Seed 2, Layer 2: d=7 computation with higher q_max.
The Q_2(1)=84 vs expected 121 means q_max=12 was too low.
deg(Q_2) for d=7 should be ~(7-1)*4 = 24 or higher.
Need higher q_max. But brute force is too slow.

Let me use the Corteel-Welsh iterative approach instead,
which is more efficient.
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
        if not nz: return [0]
        return [self.coeffs.get(i, 0) for i in range(max(nz) + 1)]

    def eval_at_1(self):
        return sum(self.coeffs.values())

    def is_nonneg(self):
        return all(v >= 0 for v in self.coeffs.values())

    def degree(self):
        nz = [k for k, v in self.coeffs.items() if v != 0]
        return max(nz) if nz else -1


def borodin_product(c, q_max):
    """
    Compute F_c(q) using Borodin's product formula (truncated).
    F_c(q) = 1/(q^t;q^t)_inf * prod_{i<j} prod_{m=1}^{c_i} 1/(q^{...};q^t)_inf
             * prod_{i>j} prod_{m=1}^{c_i} 1/(q^{t-...};q^t)_inf
    
    Returns the product as a q-series truncated at q_max.
    """
    k = len(c)
    t = k + sum(c)
    
    # Compute d_{i,j} = c_i + c_{i+1} + ... + c_j (1-indexed in the formula)
    def d_sum(i, j):
        # i, j are 1-indexed
        return sum(c[ii-1] for ii in range(i, j+1))
    
    result = QPoly.one(q_max)
    
    # Factor 1/(q^t;q^t)_inf
    for power in range(t, q_max + 1, t):
        # 1/(1-q^power) = 1 + q^power + q^{2*power} + ...
        factor = QPoly.zero(q_max)
        for m in range(0, q_max // power + 1):
            factor.coeffs[m * power] = 1
        result = result * factor
    
    # Factor prod_{i=1}^k prod_{j=i+1}^k prod_{m=1}^{c_i} 1/(q^{m+d_{i+1,j}+j-i};q^t)_inf
    for i in range(1, k+1):
        for j in range(i+1, k+1):
            for m in range(1, c[i-1]+1):
                exp = m + d_sum(i+1, j) + j - i
                if exp <= 0 or exp > q_max:
                    continue
                for power in range(exp, q_max + 1, t):
                    factor = QPoly.zero(q_max)
                    for mm in range(0, q_max // power + 1):
                        factor.coeffs[mm * power] = 1
                    result = result * factor
    
    # Factor prod_{i=2}^k prod_{j=2}^{i-1} prod_{m=1}^{c_i} 1/(q^{t-(m+d_{j,i-1}+i-j)};q^t)_inf
    for i in range(2, k+1):
        for j in range(2, i):
            for m in range(1, c[i-1]+1):
                exp = t - (m + d_sum(j, i-1) + i - j)
                if exp <= 0 or exp > q_max:
                    continue
                for power in range(exp, q_max + 1, t):
                    factor = QPoly.zero(q_max)
                    for mm in range(0, q_max // power + 1):
                        factor.coeffs[mm * power] = 1
                    result = result * factor
    
    return result


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
    # ===== d=4, higher precision =====
    print("="*60)
    print("d=4, c=(2,1,1): h_m with q_max=30")
    print("="*60)
    
    profile = (2, 1, 1)
    d = 4
    base = 5  # (5*6)/6
    q_max = 30
    
    FcN = []
    for N in range(5):
        print(f"  Computing F_{{c,{N}}}...", end=" ", flush=True)
        F = compute_FcN_stable(profile, N, q_max)
        FcN.append(F)
        print(f"F(1)={F.eval_at_1()}")
    
    print(f"\n--- h_m values ---")
    for m in range(1, len(FcN)):
        g_m = FcN[m] - FcN[m-1]
        qq_m = QPoly.one(q_max)
        for i in range(1, m+1):
            qq_m = qq_m * QPoly({0: 1, i: -1}, q_max)
        h_m = qq_m * g_m
        print(f"  h_{m}: coeffs = {h_m.to_list()}")
        print(f"    eval1 = {h_m.eval_at_1()}, expected {base**m}, nonneg = {h_m.is_nonneg()}, deg = {h_m.degree()}")
    
    # Check: Q_n
    print(f"\n--- Q_n ---")
    for n in range(4):
        Q_n = QPoly.zero(q_max)
        for j in range(n + 1):
            sign = (-1) ** j
            q_shift = j * (j - 1) // 2
            ratio = QPoly.one(q_max)
            for i in range(j + 1, n + 1):
                ratio = ratio * QPoly({0: 1, i: -1}, q_max)
            term = ratio * FcN[n - j]
            term = term.scale(sign).shift(q_shift)
            Q_n = Q_n + term
        lst = Q_n.to_list()
        print(f"  Q_{n}: eval1 = {Q_n.eval_at_1()}, expected {(base-1)**n}, nonneg = {Q_n.is_nonneg()}, deg = {Q_n.degree()}")
        if len(lst) <= 30:
            print(f"    coeffs = {lst}")

    # ===== Relationship between h_m and Q_n =====
    print(f"\n{'='*60}")
    print("Relationship analysis: h_m >= 0 and Q_n >= 0")
    print("="*60)
    
    # The alternating sum: Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}
    # vs: Q_n = sum_j (-1)^j q^{j(j-1)/2} (q;q)_n/(q;q)_j * F_{c,n-j}
    # 
    # Using h_m = (q;q)_m * g_m and g_m = F_{c,m} - F_{c,m-1}:
    # sum_j (-1)^j q^{j(j-1)/2} (q;q)_n/(q;q)_j * F_{c,n-j}
    # = sum_j (-1)^j q^{j(j-1)/2} [n;j]_q * (q;q)_{n-j} * F_{c,n-j}
    #
    # And [n;j]_q * (q;q)_{n-j} * F_{c,n-j} is NOT the same as [n;j]_q * h_{n-j}.
    # h_{n-j} = (q;q)_{n-j} * g_{n-j} = (q;q)_{n-j} * (F_{c,n-j} - F_{c,n-j-1}).
    # 
    # So [n;j]_q * h_{n-j} = [n;j]_q * (q;q)_{n-j} * (F_{c,n-j} - F_{c,n-j-1}).
    # Let me verify the Seed 1 formula by computing Q_n both ways.
    
    print(f"\nVerify: Q_2 from h_m vs from F_{{c,N}}")
    n = 2
    
    # Method 1: from F_{c,N}
    Q_from_F = QPoly.zero(q_max)
    for j in range(n + 1):
        sign = (-1) ** j
        q_shift = j * (j - 1) // 2
        ratio = QPoly.one(q_max)
        for i in range(j + 1, n + 1):
            ratio = ratio * QPoly({0: 1, i: -1}, q_max)
        term = ratio * FcN[n - j]
        term = term.scale(sign).shift(q_shift)
        Q_from_F = Q_from_F + term
    
    # Method 2: from h_m using Seed 1 formula
    # Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}
    # where [n;j]_q = (q;q)_n / ((q;q)_j * (q;q)_{n-j})
    
    hm = [None] * (n+1)
    for m in range(n+1):
        if m == 0:
            hm[m] = QPoly.one(q_max)
        else:
            g = FcN[m] - FcN[m-1]
            qq = QPoly.one(q_max)
            for i in range(1, m+1):
                qq = qq * QPoly({0: 1, i: -1}, q_max)
            hm[m] = qq * g
    
    Q_from_h = QPoly.zero(q_max)
    for j in range(n + 1):
        sign = (-1) ** j
        q_shift = j * (j + 1) // 2  # NOTE: j(j+1)/2, not j(j-1)/2
        # [n;j]_q
        qbinom = QPoly.one(q_max)
        # (q;q)_n / ((q;q)_j * (q;q)_{n-j})
        # = prod_{i=1}^n (1-q^i) / (prod_{i=1}^j (1-q^i) * prod_{i=1}^{n-j} (1-q^i))
        # But this is a polynomial, not a rational function.
        # Actually [n;j]_q IS a polynomial. Let me compute it directly.
        # [n;j]_q = prod_{i=1}^j (1-q^{n-i+1})/(1-q^i)
        for i in range(1, j+1):
            num = QPoly({0: 1, n-i+1: -1}, q_max)
            # Divide by (1-q^i): multiply by 1 + q^i + q^{2i} + ...
            denom_inv = QPoly.zero(q_max)
            for p in range(0, q_max // i + 1):
                denom_inv.coeffs[p * i] = 1
            qbinom = qbinom * num * denom_inv
        
        term = qbinom * hm[n - j]
        term = term.scale(sign).shift(q_shift)
        Q_from_h = Q_from_h + term
    
    print(f"  Q_2 from F: {Q_from_F.to_list()[:20]}")
    print(f"  Q_2 from h: {Q_from_h.to_list()[:20]}")
    print(f"  Match: {Q_from_F.to_list()[:15] == Q_from_h.to_list()[:15]}")


if __name__ == "__main__":
    main()
