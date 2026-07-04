"""
Seed 2, Layer 1: Compute Q_{n,c}(q) for d=4,5 profiles using transfer matrix.
"""
from collections import defaultdict
import sys


class QPoly:
    def __init__(self, coeffs=None, max_deg=200):
        self.max_deg = max_deg
        self.coeffs = defaultdict(int)
        if coeffs:
            for k, v in (coeffs.items() if isinstance(coeffs, dict) else enumerate(coeffs)):
                if k <= max_deg and v != 0:
                    self.coeffs[k] = v

    @staticmethod
    def one(md=200): return QPoly({0: 1}, md)
    @staticmethod
    def zero(md=200): return QPoly({}, md)

    def __add__(self, other):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items(): r.coeffs[k] += v
        for k, v in other.coeffs.items():
            if k <= self.max_deg: r.coeffs[k] += v
        return r

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
            if k+s <= self.max_deg: r.coeffs[k+s] = v
        return r

    def scale(self, c):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items(): r.coeffs[k] = v * c
        return r

    def to_list(self):
        if not self.coeffs: return [0]
        md = max(self.coeffs.keys())
        result = [self.coeffs.get(i, 0) for i in range(md + 1)]
        while len(result) > 1 and result[-1] == 0: result.pop()
        return result

    def eval_at_1(self): return sum(self.coeffs.values())
    def is_nonneg(self): return all(v >= 0 for v in self.coeffs.values())
    def degree(self):
        if not self.coeffs: return -1
        return max(k for k, v in self.coeffs.items() if v != 0)


def compute_FcN_transfer(c, N, q_max):
    """Transfer matrix computation of F_{c,N}(q)."""
    k = len(c)
    assert k == 3
    mem = max(c)
    
    if mem == 0:
        # All c_i = 0. Cylindric partition = 3 copies of same partition with max <= N.
        # Wait, if all c_i = 0: lam^0_j >= lam^1_j, lam^1_j >= lam^2_j, lam^2_j >= lam^0_j
        # So lam^0 = lam^1 = lam^2. F_{c,N} = sum_{partitions with max<=N} q^{3|lambda|}.
        result = QPoly.zero(q_max)
        # Generate partitions with parts <= N, sum <= q_max//3
        def gen_p(max_val, max_sum):
            yield 0
            for first in range(1, min(max_val, max_sum) + 1):
                for rest in _gen(first, max_sum - first):
                    yield first + rest
        # Actually simpler: generating function is prod_{j=1}^N 1/(1-q^{3j}) truncated
        gf = QPoly.one(q_max)
        for j in range(1, N + 1):
            # multiply by 1/(1-q^{3j}) = sum q^{3jk}
            new_gf = QPoly.zero(q_max)
            for exp, coeff in gf.coeffs.items():
                e = exp
                while e <= q_max:
                    new_gf.coeffs[e] += coeff
                    e += 3 * j
            gf = new_gf
        return gf
    
    init_col = (N, N, N)
    init_state = tuple([init_col] * mem)
    dp = {init_state: QPoly.one(q_max)}
    
    max_steps = q_max + 5
    
    zero_state = tuple([(0,0,0)] * mem)
    
    for p in range(max_steps):
        new_dp = defaultdict(lambda: QPoly.zero(q_max))
        
        for state, poly in dp.items():
            if state == zero_state:
                new_dp[zero_state] = new_dp[zero_state] + poly
                continue
            
            prev_col = state[0]
            
            max_v0 = prev_col[0]
            max_v1 = prev_col[1]
            max_v2 = prev_col[2]
            
            # Interlacing from past positions
            if c[1] > 0 and p >= c[1] and c[1] <= mem:
                max_v1 = min(max_v1, state[c[1]-1][0])
            
            if c[2] > 0 and p >= c[2] and c[2] <= mem:
                max_v2 = min(max_v2, state[c[2]-1][1])
            
            if c[0] > 0 and p >= c[0] and c[0] <= mem:
                max_v0 = min(max_v0, state[c[0]-1][2])
            
            for v0 in range(max_v0, -1, -1):
                ub_v1 = max_v1
                if c[1] == 0:
                    ub_v1 = min(ub_v1, v0)
                
                for v1 in range(ub_v1, -1, -1):
                    ub_v2 = max_v2
                    if c[2] == 0:
                        ub_v2 = min(ub_v2, v1)
                    
                    for v2 in range(ub_v2, -1, -1):
                        if c[0] == 0 and v0 > v2:
                            continue
                        
                        weight = v0 + v1 + v2
                        
                        if v0 == 0 and v1 == 0 and v2 == 0:
                            new_dp[zero_state] = new_dp[zero_state] + poly
                        else:
                            new_col = (v0, v1, v2)
                            new_state = (new_col,) + state[:-1]
                            new_dp[new_state] = new_dp[new_state] + poly.shift(weight)
        
        dp = dict(new_dp)
        dp = {s: p for s, p in dp.items() if any(v != 0 for v in p.coeffs.values())}
        
        if len(dp) == 0:
            break
        if len(dp) == 1 and zero_state in dp:
            break
    
    result = dp.get(zero_state, QPoly.zero(q_max))
    return result


def compute_Qn(FcN_list, n, q_max):
    """Compute Q_n(q) from FcN_list."""
    Q_n = QPoly.zero(q_max)
    for j in range(n + 1):
        sign = (-1) ** j
        q_shift = j * (j - 1) // 2
        
        ratio = QPoly.one(q_max)
        for i in range(j + 1, n + 1):
            factor = QPoly({0: 1, i: -1}, q_max)
            ratio = ratio * factor
        
        term = ratio * FcN_list[n - j]
        term = term.scale(sign).shift(q_shift)
        Q_n = Q_n + term
    
    return Q_n


def main():
    q_max = 150
    
    for profile in [(2, 1, 1), (1, 2, 1), (1, 1, 2), (3, 1, 0), (2, 2, 1), (1, 3, 1)]:
        d = sum(profile)
        if d % 3 == 0:
            print(f"\nSkipping c={profile}, d={d} (div by 3)")
            continue
        expected_base = (d+1)*(d+2)//6 - 1
        print(f"\n{'='*60}")
        print(f"Profile c = {profile}, d = {d}")
        print(f"Expected Q_{{n,c}}(1) = {expected_base}^n")
        print(f"{'='*60}")
        
        n_max = 3
        FcN = []
        for N in range(n_max + 1):
            print(f"  Computing F_{{c,{N}}}(q)...", end=" ", flush=True)
            F = compute_FcN_transfer(profile, N, q_max)
            FcN.append(F)
            print(f"F(1) = {F.eval_at_1()}")
        
        for n in range(n_max + 1):
            Q_n = compute_Qn(FcN, n, q_max)
            coeffs = Q_n.to_list()
            print(f"\n  Q_{{{n},c}}(q) = {coeffs}")
            print(f"    Q(1) = {Q_n.eval_at_1()}, expected = {expected_base**n}, deg = {Q_n.degree()}, nonneg = {Q_n.is_nonneg()}")


if __name__ == "__main__":
    main()
