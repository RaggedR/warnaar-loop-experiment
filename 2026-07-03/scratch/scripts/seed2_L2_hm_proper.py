"""
Seed 2, Layer 2: Proper investigation of h_m.

Key insight from previous script: g_m is an INFINITE power series.
h_m = (q;q)_m * g_m. The claim that h_m is a polynomial requires 
careful analysis.

Let me use the transfer matrix approach to compute F_{c,N} to higher
precision, with more parts allowed, to see whether:
1. h_m = (q;q)_m * g_m is actually a polynomial (terminates)
2. If so, whether it has nonneg coefficients.

The issue with brute force: max_parts truncation causes g_m's last
few coefficients to be wrong.

Fix: use transfer matrix for F_{c,N}. The state space is the set of
interlacing conditions at one "slice" boundary. For each max entry bound N,
we can compute F_{c,N} as a matrix product/trace.
"""
from collections import defaultdict
from functools import lru_cache

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
        md = max(k for k, v in self.coeffs.items() if v != 0) if any(v != 0 for v in self.coeffs.values()) else 0
        result = [self.coeffs.get(i, 0) for i in range(md + 1)]
        return result

    def eval_at_1(self):
        return sum(self.coeffs.values())

    def is_nonneg(self):
        return all(v >= 0 for v in self.coeffs.values())

    def degree(self):
        nz = [k for k, v in self.coeffs.items() if v != 0]
        return max(nz) if nz else -1


def compute_FcN_proper(c, N, q_max):
    """
    Compute F_{c,N}(q) properly with enough parts.
    For cylindric partitions with max <= N and k=3, profile c,
    the max number of nonzero parts in each partition is unbounded,
    but the total weight is bounded by q_max.
    With parts <= N and total weight <= q_max, the number of parts
    is at most q_max // 1 = q_max (if all parts are 1).
    So max_parts = q_max is sufficient for exact computation up to q^{q_max}.
    
    But that makes the state space huge. Instead, use the observation that
    with parts in {0,1,...,N} and total weight <= q_max, the number of parts
    is at most q_max. But most parts will be 0, so we only need to track
    the number of nonzero parts.
    
    Better approach: use the interlacing structure. A cylindric partition
    of profile c with k=3 is determined by 3 partitions satisfying cyclic
    interlacing. For bounded max N, we can compute layer by layer.
    """
    k = len(c)
    assert k == 3
    
    # For exact computation, we need max_parts >= q_max.
    # But that's too slow for triple enumeration.
    # Instead, increase max_parts until the answer stabilizes.
    
    prev_result = None
    for max_parts in range(N + max(c) + 2, q_max + 2, 2):
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

        current_list = result.to_list()
        if prev_result is not None and current_list == prev_result:
            print(f"    Stabilized at max_parts={max_parts}")
            return result
        prev_result = current_list
        
        if max_parts > q_max:
            break
    
    print(f"    WARNING: Did not stabilize by max_parts={max_parts}")
    return result


def main():
    # Use moderate q_max for exact computation
    q_max = 20
    
    print("="*60)
    print("Proper h_m computation with stabilized F_{c,N}")
    print("="*60)
    
    # Start with simplest non-trivial case: c=(1,1,0), d=2
    profile = (1, 1, 0)
    d = sum(profile)
    base = (d+1)*(d+2)//6  # = 2
    
    print(f"\nProfile c = {profile}, d = {d}, base = {base}")
    
    FcN = []
    for N in range(4):
        print(f"\n  Computing F_{{c,{N}}}(q) with q_max={q_max}:")
        F = compute_FcN_proper(profile, N, q_max)
        FcN.append(F)
        lst = F.to_list()
        print(f"    F_{{c,{N}}} = {lst}")
        print(f"    F(1) = {F.eval_at_1()}")
    
    # Compute g_m and h_m
    for m in range(1, len(FcN)):
        g_m = FcN[m] - FcN[m-1]
        print(f"\n  g_{m} = {g_m.to_list()}")
        
        # (q;q)_m
        qq_m = QPoly.one(q_max)
        for i in range(1, m+1):
            qq_m = qq_m * QPoly({0: 1, i: -1}, q_max)
        
        h_m = qq_m * g_m
        lst_h = h_m.to_list()
        print(f"  h_{m} = {lst_h}")
        print(f"  h_{m}(1) = {h_m.eval_at_1()}")
        print(f"  nonneg = {h_m.is_nonneg()}")
        print(f"  degree = {h_m.degree()}")
    
    # Also check Q_n directly
    print(f"\n--- Q_n computation ---")
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
        print(f"  Q_{n} = {Q_n.to_list()}")
        print(f"    Q(1) = {Q_n.eval_at_1()}, nonneg = {Q_n.is_nonneg()}")
    
    # Now do d=4 case with smaller q_max for speed
    print(f"\n{'='*60}")
    profile = (2, 1, 1)
    d = sum(profile)
    base = (d+1)*(d+2)//6  # = 5
    q_max2 = 15
    
    print(f"Profile c = {profile}, d = {d}, base = {base}, q_max = {q_max2}")
    
    FcN2 = []
    for N in range(4):
        print(f"\n  Computing F_{{c,{N}}}(q):")
        F = compute_FcN_proper(profile, N, q_max2)
        FcN2.append(F)
        print(f"    F_{{c,{N}}} = {F.to_list()}")
        print(f"    F(1) = {F.eval_at_1()}")
    
    for m in range(1, len(FcN2)):
        g_m = FcN2[m] - FcN2[m-1]
        print(f"\n  g_{m} = {g_m.to_list()}")
        
        qq_m = QPoly.one(q_max2)
        for i in range(1, m+1):
            qq_m = qq_m * QPoly({0: 1, i: -1}, q_max2)
        
        h_m = qq_m * g_m
        lst_h = h_m.to_list()
        print(f"  h_{m} = {lst_h}")
        print(f"  h_{m}(1) = {h_m.eval_at_1()}, nonneg = {h_m.is_nonneg()}")


if __name__ == "__main__":
    main()
