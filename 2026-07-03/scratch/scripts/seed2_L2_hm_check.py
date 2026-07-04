"""
Seed 2, Layer 2: Careful check of h_m.

The Layer 1 synthesis says h_m >= 0 was "verified for d <= 7, m <= 5".
But our computation shows h_1 has NEGATIVE coefficients for d=2,4,5!

This could be a truncation artifact -- g_m is an INFINITE power series.
h_m = (q;q)_m * g_m. If g_m is infinite, then h_m is also infinite,
and we need to check whether it's actually a polynomial.

Wait -- the synthesis says h_m = (q;q)_m * g_m where g_m = [z^m] F_c(z,q).
g_m is indeed an infinite series (cylindric partitions with max=m can have
arbitrarily many small parts).

So h_m = (q;q)_m * g_m. Is this actually a polynomial?
(q;q)_m is a polynomial of degree m(m+1)/2.
g_m is an infinite series.
Their product is an infinite series, NOT a polynomial!

BUT WAIT -- the synthesis says h_m is defined differently in Seed 1:
"h_m(q) = (q;q)_m * [z^m] GK_c(z,q)"
where GK_c(z,q) = F_c(z,q).

So h_m = (q;q)_m * g_m = (q;q)_m * (F_{c,m} - F_{c,m-1}).

This IS an infinite series. The synthesis was wrong to claim h_m is a polynomial
with nonneg coefficients, or perhaps they used a different definition.

Let me re-read the conjecture definition of Q_n:
Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * GK_c(z,q))

For r=3, ell = gcd(d,3). When d not equiv 0 mod 3, ell = 1.
So Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))

And F_c(z,q) = (1-z) sum_N F_{c,N} z^N (established above).

So (zq;q)_inf * F_c(z,q) = (zq;q)_inf * (1-z) * sum_N F_{c,N} z^N
                          = (z;q)_inf * sum_N F_{c,N} z^N

[z^n] of this = sum_{j=0}^n (-1)^j q^{j(j-1)/2}/(q;q)_j * F_{c,n-j}

And Q_n = (q;q)_n * [z^n](...) = sum_j (-1)^j q^{j(j-1)/2} * (q;q)_n/(q;q)_j * F_{c,n-j}

Now Seed 1's formula: Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j}

Let me reconcile. [n choose j]_q = (q;q)_n / ((q;q)_j * (q;q)_{n-j}).

So the Seed 1 formula gives:
Q_n = sum_j (-1)^j q^{j(j+1)/2} * (q;q)_n/((q;q)_j * (q;q)_{n-j}) * h_{n-j}

Comparing: sum_j (-1)^j q^{j(j-1)/2} * (q;q)_n/(q;q)_j * F_{c,n-j}
         = sum_j (-1)^j q^{j(j+1)/2} * (q;q)_n/((q;q)_j * (q;q)_{n-j}) * h_{n-j}

Let k = n-j:
LHS = sum_k (-1)^{n-k} q^{(n-k)(n-k-1)/2} * (q;q)_n/(q;q)_{n-k} * F_{c,k}
RHS = sum_k (-1)^{n-k} q^{(n-k)(n-k+1)/2} * (q;q)_n/((q;q)_{n-k} * (q;q)_k) * h_k

Hmm, the q-shifts are different: j(j-1)/2 vs j(j+1)/2. Let me check more carefully.

Actually I suspect there's a sign convention issue. Let me just compute Q_n
both ways and compare.

The key question now: is h_m a polynomial or an infinite series?
If it's a polynomial, it should have a well-defined degree.
If it's infinite, the "h_m nonneg" claim doesn't make sense as stated.

Let me look at the actual Seed 1 computation more carefully.
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
        return self + self._scale(other, -1)

    def _scale(self, poly, c):
        r = QPoly(max_deg=self.max_deg)
        for k, v in poly.coeffs.items():
            r.coeffs[k] = v * c
        return r

    def scale(self, c):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            r.coeffs[k] = v * c
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


def main():
    q_max = 40
    profile = (1, 1, 0)  # d=2, simplest case
    d = sum(profile)

    print(f"Profile c = {profile}, d = {d}")
    print(f"\nComputing F_{{c,N}} for N=0,1,2 with q_max={q_max}")

    FcN = []
    for N in range(3):
        F = compute_FcN(profile, N, q_max)
        FcN.append(F)
        lst = F.to_list()
        print(f"\nF_{{c,{N}}} coeffs = {lst[:25]}...")
        print(f"  F(1) = {F.eval_at_1()}")

    # g_1 = F_{c,1} - F_{c,0}
    g1 = FcN[1] - FcN[0]
    print(f"\ng_1 = F_{{c,1}} - F_{{c,0}}:")
    print(f"  coeffs = {g1.to_list()}")
    print(f"  g_1(1) = {g1.eval_at_1()}")

    # h_1 = (1-q) * g_1
    qq1 = QPoly({0: 1, 1: -1}, q_max)
    h1 = qq1 * g1
    print(f"\nh_1 = (1-q) * g_1:")
    lst_h1 = h1.to_list()
    print(f"  coeffs = {lst_h1}")
    print(f"  h_1(1) = {h1.eval_at_1()}")
    print(f"  nonneg = {h1.is_nonneg()}")

    # The issue: g_1 is TRUNCATED. In reality g_1 is an infinite series.
    # For c=(1,1,0), d=2: g_1 counts cylindric partitions of max exactly 1.
    # These are triples (lam0, lam1, lam2) with parts in {0,1} satisfying
    # the interlacing conditions.
    # The coefficient of q^k in g_1 grows -- there are more such partitions
    # of larger total size because there can be more parts.
    # 
    # So g_1 is INFINITE, and h_1 = (1-q)*g_1 is also infinite.
    # The negative coefficients I see are truncation artifacts!
    #
    # When we truncate at q_max and g_1's coefficients are still growing,
    # (1-q)*g_1 will have artificial negative terms near the truncation boundary.

    print(f"\n--- DIAGNOSIS ---")
    print(f"g_1 coefficients near truncation boundary:")
    lst_g1 = g1.to_list()
    for i in range(max(0, len(lst_g1)-5), len(lst_g1)):
        print(f"  g_1[{i}] = {lst_g1[i]}")
    print(f"h_1 = (1-q)*g_1. Near boundary, h_1[k] = g_1[k] - g_1[k-1].")
    print(f"If g_1 is truncated (g_1[q_max+1] = 0 artificially),")
    print(f"then h_1[q_max] = g_1[q_max] - g_1[q_max-1], but")
    print(f"h_1[q_max+1] = 0 - g_1[q_max] = -g_1[q_max] < 0.")
    print(f"So the negative coefficients ARE truncation artifacts.")

    # Now the REAL question: is (1-q)*g_1 actually a polynomial?
    # For c=(1,1,0), d=2: g_1 stabilizes (all coefficients = 2 for q^1 through q^10).
    # (1-q)*g_1 = g_1[0] + sum_{k>=1} (g_1[k] - g_1[k-1]) q^k
    # If g_1 stabilizes at value S, then eventually g_1[k] - g_1[k-1] = 0,
    # making (1-q)*g_1 a polynomial.
    
    # Check: does g_1 stabilize?
    print(f"\n--- Does g_1 stabilize? ---")
    diffs = []
    for k in range(1, len(lst_g1)):
        diffs.append(lst_g1[k] - lst_g1[k-1])
    print(f"  g_1[k] - g_1[k-1] for k=1..{len(diffs)}: {diffs}")
    
    # For d=2, c=(1,1,0): g_1 stabilizes at 2 (the stable coefficient).
    # So h_1 = (1-q)*g_1 is a polynomial with coefficients:
    # h_1[0] = 0, h_1[1] = 2, then zeros after stabilization.
    # But before stabilization there could be transient terms.
    
    # The key insight: g_m eventually stabilizes because the "boundary effects"
    # of the cylindric partition conditions die out for large parts.
    # The stable coefficient is (d+1)(d+2)/6 = base.
    # So h_1 = (1-q)*g_1 should be a polynomial.
    
    # But for m >= 2, h_m = (q;q)_m * g_m. g_m is an infinite series
    # whose coefficients GROW (not stabilize), because more parts allow
    # more configurations of total weight k with max exactly m.
    # The growth rate is polynomial in k of degree roughly m-1.
    # Then (q;q)_m = prod_{i=1}^m (1-q^i) is a polynomial of degree m(m+1)/2.
    # 
    # For h_m to be a polynomial, we'd need (q;q)_m to kill the growth.
    # (q;q)_m has a zero of order m at q=1 (each factor vanishes).
    # g_m(q) ~ c * (some rational function in q near q=1).
    # 
    # Actually: g_m is the coefficient [z^m] of a generating function
    # that has a pole of order m at z=1/q^j for various j.
    # The product (q;q)_m * g_m might or might not terminate.

    # Let me check for m=2:
    print(f"\n--- g_2 analysis ---")
    g2 = FcN[2] - FcN[1]
    lst_g2 = g2.to_list()
    print(f"g_2 coeffs: {lst_g2[:25]}...")
    diffs2 = []
    for k in range(1, min(25, len(lst_g2))):
        diffs2.append(lst_g2[k] - lst_g2[k-1])
    print(f"First differences: {diffs2[:20]}")
    
    # Second differences
    diffs2_2 = []
    for k in range(1, len(diffs2)):
        diffs2_2.append(diffs2[k] - diffs2[k-1])
    print(f"Second differences: {diffs2_2[:15]}")

    # For an infinite series with polynomial growth rate ~ a*k + b,
    # the first differences stabilize, second differences vanish.
    # If second differences stabilize to 0, the growth is linear.
    # Then (1-q)^2 * g_2 would be a polynomial (or rational with denom at q=1 only).
    # And (q;q)_2 = (1-q)(1-q^2) = (1-q)^2(1+q).
    # So h_2 = (q;q)_2 * g_2 = (1-q)^2(1+q) * g_2.
    # If g_2 has linear growth, (1-q)^2 * g_2 would be a polynomial,
    # and (1+q) * that is still a polynomial.

    # Let me verify by direct computation with higher truncation
    print(f"\n--- h_1 with only 'real' terms (before truncation artifacts) ---")
    # h_1[k] = g_1[k] - g_1[k-1]. Real as long as both g_1[k] and g_1[k-1] are real.
    # Our g_1 data is real up to about q_max - (max partition size with max=1).
    # Actually, our enumeration catches ALL partitions with total size <= q_max,
    # so g_1 is exact up to degree q_max.
    # But (1-q)*g_1 at degree k uses g_1[k] and g_1[k-1], both of which are exact
    # as long as k <= q_max.
    # The issue is that g_1 is infinite, so h_1 = (1-q)*g_1 is also infinite.
    # The negative coefficients near the END of g_1's range are real, not artifacts!
    
    # Wait -- re-examine g_1 for c=(1,1,0):
    print(f"g_1 full: {lst_g1}")
    # g_1 = [0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, ...]
    # The coefficient DROPS from 2 to 1 near the end -- that's truncation.
    # But the coefficient of q^k in g_1 for c=(1,1,0) with max=1 and total=k:
    # We need triples (lam0, lam1, lam2) with parts in {0,1}, interlacing,
    # max=1, total=k. With parts in {0,1}, each partition is (1,1,...,1,0,0,...).
    # The number of parts in lam_i that equal 1 determines the size.
    # The interlacing lam0_j >= lam1_{j+c1} etc constrains the lengths.
    # For c=(1,1,0), c1=1: lam0_j >= lam1_{j+1} for all j.
    # c2=0: lam1_j >= lam2_j for all j (same shift).
    # c0=1: lam2_j >= lam0_{j+1} for all j.
    # So lengths satisfy: len(lam0) >= len(lam1)+1, len(lam1) >= len(lam2),
    # len(lam2) >= len(lam0)+1 -- WAIT that gives len(lam0) >= len(lam1)+1 >= len(lam2)+1 >= len(lam0)+2.
    # Contradiction! So the only possibility is all lengths are the same or
    # I'm reading the conditions wrong.
    
    # Actually the interlacing is:
    # lam0_j >= lam1_{j+c1} where c1 = c[1] = 1
    # lam1_j >= lam2_{j+c2} where c2 = c[2] = 0
    # lam2_j >= lam0_{j+c0} where c0 = c[0] = 1
    # 
    # With all parts in {0,1}: lam_i = (1,1,...,1,0,...) with n_i ones.
    # lam0_j >= lam1_{j+1}: for j <= n0, lam0_j=1 >= lam1_{j+1}. Need j+1 <= n1, so n1 >= j+1.
    #                        For j = n0, lam0_{n0}=0 >= lam1_{n0+1}=0 OK.
    #                        Critical: n1 >= n0 (since for j=n0-1, need lam1_{n0} = 1, i.e. n1 >= n0).
    #                        Wait no: lam0_{n0} = 1 (the last 1). Need lam1_{n0+1} <= 1.
    #                        This is automatic. The constraint is: 
    #                        for j with lam0_j = 1: lam1_{j+1} <= 1 (auto).
    #                        for j with lam0_j = 0: lam1_{j+1} <= 0, i.e. lam1_{j+1} = 0.
    #                        So lam1 can have at most n0 ones (since lam1_{n0+1} must be 0).
    #                        i.e. n1 <= n0.
    # Similarly: lam1_j >= lam2_j (shift 0): means n2 <= n1.
    # And: lam2_j >= lam0_{j+1} (shift 1): means n0 <= n2.
    # 
    # So n0 <= n2 <= n1 <= n0, meaning n0 = n1 = n2.
    # And max = 1 (at least one partition has a part equal to 1), so all n_i >= 1.
    # Total = n0 + n1 + n2 = 3*n0. And n0 >= 1.
    # 
    # Wait, but we also need max=1 for g_1 = F_{c,1} - F_{c,0}.
    # F_{c,0} = 1 (empty partition only). F_{c,1} counts partitions with max <= 1.
    # g_1 = F_{c,1} - F_{c,0} counts partitions with max EXACTLY 1.
    # With n0 = n1 = n2, and at least one part = 1, total = 3n0.
    # But also can have n0=n1=n2=0 (empty), but that has max=0.
    # So for max exactly 1: n0=n1=n2=n for n >= 1, total = 3n.
    # g_1 should have coefficient 1 at q^{3n} for each n >= 1? 
    # But computation shows g_1[1] = 2, g_1[2] = 2.
    
    # I'm making an error -- parts can be 0 or 1 but there can be MANY parts.
    # Actually for max <= 1, each partition has parts in {0,1}, and trailing zeros
    # don't matter. So lam_i is determined by its number of ones, n_i.
    # The interlacing gives n0 = n1 = n2 = n for some n >= 0.
    # Total size = 3n. g_1[k] = 1 if k = 3n for some n >= 1, else 0.
    # But computation shows g_1 = [0, 2, 2, 2, ...]. That's not right.
    
    # I must be getting the interlacing wrong. Let me re-read the definition.
    # lam0_j >= lam1_{j+c1} means for ALL j >= 1.
    # With c = (1, 1, 0): c0=1, c1=1, c2=0.
    # k=3 partitions: lam^(1), lam^(2), lam^(3).
    # Condition: lam^(i)_j >= lam^(i+1)_{j+c_{i+1}} for i=1,2.
    # And lam^(3)_j >= lam^(1)_{j+c_1} for the wrap-around.
    #
    # So: lam^(1)_j >= lam^(2)_{j+c_2} = lam^(2)_{j+1}   (c_2 = c[2] = 0??)
    
    # Wait. The profile c = (c_1, ..., c_k). For c = (1, 1, 0), k=3.
    # c_1=1, c_2=1, c_3=0.
    # lam^(i)_j >= lam^(i+1)_{j+c_{i+1}}:
    # i=1: lam^(1)_j >= lam^(2)_{j+c_2} = lam^(2)_{j+1}
    # i=2: lam^(2)_j >= lam^(3)_{j+c_3} = lam^(3)_{j+0} = lam^(3)_j
    # Wrap: lam^(3)_j >= lam^(1)_{j+c_1} = lam^(1)_{j+1}
    
    # So with parts in {0,1}:
    # n1 ones in lam^(1), n2 in lam^(2), n3 in lam^(3).
    # i=1: lam^(1)_j >= lam^(2)_{j+1} => n2 <= n1 (n2-1 ones starting at pos 2 fit)
    #   Actually: lam^(1)_j = 1 for j <= n1, 0 for j > n1.
    #   lam^(2)_{j+1} = 1 for j+1 <= n2 i.e. j <= n2-1.
    #   Need: for j > n1, lam^(2)_{j+1} = 0, i.e. j+1 > n2, i.e. j >= n2.
    #   So need n1 >= n2 (since for j = n1, need j >= n2, i.e. n1 >= n2). YES.
    # i=2: lam^(2)_j >= lam^(3)_j => n3 <= n2.
    # Wrap: lam^(3)_j >= lam^(1)_{j+1} => n1-1 <= n3, i.e. n1 <= n3 + 1.
    #   Actually: need for j > n3, lam^(1)_{j+1} = 0, i.e. j+1 > n1, i.e. j >= n1.
    #   So n3 >= n1 - 1, i.e. n1 <= n3 + 1.
    
    # So constraints: n3 <= n2 <= n1 <= n3 + 1.
    # Case 1: n1 = n2 = n3 = n. Total = 3n.
    # Case 2: n1 = n3 + 1, and n3 <= n2 <= n1.
    #   Sub-case 2a: n2 = n1 = n3+1. Total = n3 + (n3+1) + (n3+1) = 3n3+2.
    #   Sub-case 2b: n2 = n3. Total = (n3+1) + n3 + n3 = 3n3+1.
    
    # So:
    # Total 3n (n>=1): one partition (n1=n2=n3=n). g_1[3n] gets +1.
    # Total 3n+1 (n>=0): n1=n+1, n2=n3=n. g_1[3n+1] gets +1.
    # Total 3n+2 (n>=0): n1=n2=n+1, n3=n. g_1[3n+2] gets +1.
    # 
    # But wait, n >= 0 for the latter two, and we need max = 1 (at least one part = 1).
    # For total = 1: n1=1, n2=n3=0. Max = 1. OK, g_1[1] = 1.
    # For total = 2: n1=n2=1, n3=0. Max = 1. OK, g_1[2] = 1.
    # For total = 3: n1=n2=n3=1. Max = 1. OK, g_1[3] = 1.
    #   Also: n1=2, n2=n3=1 from 3n+1 pattern? No, 3*1+1=4 not 3.
    # 
    # Hmm, but the computation shows g_1[1] = 2, not 1!
    # I must be miscounting. Let me enumerate directly for small cases.
    print(f"\n--- Direct enumeration for c=(1,1,0), max=1, total=1 ---")
    count = 0
    N = 1
    for n1 in range(N+1):
        for n2 in range(N+1):
            for n3 in range(N+1):
                lam1 = tuple([1]*n1 + [0]*5)
                lam2 = tuple([1]*n2 + [0]*5)
                lam3 = tuple([1]*n3 + [0]*5)
                # Check interlacing with c = (1,1,0)
                ok = True
                # lam^(1)_j >= lam^(2)_{j+1} for all j>=1 (1-indexed)
                for j in range(6):  # j from 0 (0-indexed = 1 in 1-indexed)
                    if lam1[j] < lam2[j+1 if j+1 < 6 else 5]:
                        ok = False; break
                if not ok: continue
                # lam^(2)_j >= lam^(3)_j for all j>=1
                for j in range(6):
                    if lam2[j] < lam3[j]:
                        ok = False; break
                if not ok: continue
                # lam^(3)_j >= lam^(1)_{j+1} for all j>=1
                for j in range(6):
                    if lam3[j] < lam1[j+1 if j+1 < 6 else 5]:
                        ok = False; break
                if not ok: continue
                total = n1 + n2 + n3
                mx = max(max(lam1), max(lam2), max(lam3))
                if mx == 1 and total == 1:
                    count += 1
                    print(f"  lam=({n1},{n2},{n3})")
    print(f"  count = {count}")
    
    # Wait -- I think the issue is that the conjecture uses c=(c_0,...,c_{r-1})
    # which might be 0-indexed, and my compute_FcN uses a different convention.
    # The profile (1,1,0) has c_0=1, c_1=1, c_2=0.
    # In the conjecture definition (from conjecture.tex):
    # lam^(i)_j >= lam^(i+1)_{j+c_{i+1}} for 1 <= i <= k-1
    # lam^(k)_j >= lam^(1)_{j+c_1}
    #
    # So for k=3:
    # lam^(1)_j >= lam^(2)_{j+c_2} for all j >= 1
    # lam^(2)_j >= lam^(3)_{j+c_3} for all j >= 1  
    # lam^(3)_j >= lam^(1)_{j+c_1} for all j >= 1
    #
    # With c = (c_1, c_2, c_3) = (1, 1, 0):
    # lam^(1)_j >= lam^(2)_{j+1}
    # lam^(2)_j >= lam^(3)_{j+0} = lam^(3)_j
    # lam^(3)_j >= lam^(1)_{j+1}
    #
    # Now in compute_FcN, the profile is passed as (1,1,0) and used as c[0]=1, c[1]=1, c[2]=0.
    # The interlacing check:
    # interlaces(lam0, lam1, c[1]) means lam0_j >= lam1_{j+c[1]} = lam1_{j+1}
    # interlaces(lam1, lam2, c[2]) means lam1_j >= lam2_{j+c[2]} = lam2_{j+0}
    # interlaces(lam2, lam0, c[0]) means lam2_j >= lam0_{j+c[0]} = lam0_{j+1}
    #
    # So lam0 = lam^(1), lam1 = lam^(2), lam2 = lam^(3). This matches!
    # The count should be correct.
    
    # So why does g_1[1] = 2? Let me enumerate more carefully.
    # For total = 1 with max = 1: exactly one partition has a part equal to 1.
    # Possible: n1=1,n2=0,n3=0. Check: n2 <= n1=1 OK, n3 <= n2=0 OK, n1 <= n3+1=1 OK.
    #   Total = 1. YES.
    # Or: n1=0,n2=1,n3=0. Check: n2=1 <= n1=0? NO. Invalid.
    # Or: n1=0,n2=0,n3=1. Check: n2=0 <= n1=0 OK, n3=1 <= n2=0? NO. Invalid.
    # Or: n1=1,n2=1,n3=0. Total = 2. Not 1.
    # So g_1[1] should be 1, not 2!
    # 
    # The computation gives 2. Something is wrong with the enumeration code.
    # Let me trace through compute_FcN for N=1 directly.
    
    print(f"\n--- Tracing F_{{c,1}} for c=(1,1,0) ---")
    # All partitions with max <= 1, up to max_parts = 1 + 1 + 2 = 4 parts
    # Partitions: (0,0,0,0), (1,0,0,0), (1,1,0,0), (1,1,1,0), (1,1,1,1)
    # That's 5 partitions of sizes 0, 1, 2, 3, 4.
    # But we also need to count all valid triples.
    
    # Actually, the number of partitions with parts <= 1 and any number of parts
    # is infinite: (1,1,...,1,0,...) for any length. Our code limits to max_parts.
    # max_parts = N + max(c) + 2 = 1 + 1 + 2 = 4.
    # So we only consider partitions with at most 4 parts.
    # That might miss some!
    
    # For F_{c,1} we need triples of partitions with max <= 1.
    # With max_parts = 4, we can have at most 4 ones in each partition.
    # But the interlacing constraints with c=(1,1,0) give n3 <= n2 <= n1 <= n3+1.
    # So n1 <= n3+1 <= n2+1 <= n1+1. All are close.
    # For total = 1: n1=1, n2=n3=0. Total = 1.
    # For total = 2: n1=n2=1, n3=0. Total = 2.
    # For total = 3: n1=n2=n3=1. Total = 3.
    # For total = 4: n1=2, n2=n3=1. Total = 4. (from n1=n3+1=2, n2=n3=1 or n2=n1=2)
    #   Wait: n3=1, n1<=n3+1=2, so n1=2. n2 can be 1 or 2.
    #   n2=1: total = 2+1+1 = 4.
    #   n2=2: total = 2+2+1 = 5.
    # So for total=4: one partition (2,1,1).
    # For total=5: one partition (2,2,1).
    # etc.
    # All coefficients should be 1 for each possible total.
    # 
    # But the code computes g_1[1] = 2! There must be MULTIPLE valid triples.
    # OH WAIT -- I was thinking each partition is determined solely by its length,
    # but that's only true for max=1. Let me reconsider.
    
    # With max <= 1, lam = (1,...,1,0,...,0) with some number of 1s.
    # With max_parts = 4, these are: (), (1), (1,1), (1,1,1), (1,1,1,1).
    # Yes, each is determined by its length (number of 1s).
    
    # Then F_{c,1} = number of valid triples (n1,n2,n3) with 0<=ni<=4 (due to truncation).
    # And g_1 = F_{c,1} - F_{c,0}.
    # F_{c,0} = 1 (only (0,0,0)).
    
    # Valid triples for max<=1: n3 <= n2 <= n1 <= n3+1.
    # With 0 <= ni <= 4:
    # n3=0: n1 in {0,1}, n2 in [n3,n1] = [0,n1].
    #   (0,0,0): total 0
    #   (1,0,0): total 1
    #   (1,1,0): total 2
    # n3=1: n1 in {1,2}, n2 in [1,n1].
    #   (1,1,1): total 3
    #   (2,1,1): total 4
    #   (2,2,1): total 5
    # n3=2: n1 in {2,3}, n2 in [2,n1].
    #   (2,2,2): total 6
    #   (3,2,2): total 7
    #   (3,3,2): total 8
    # n3=3: n1 in {3,4}, n2 in [3,n1].
    #   (3,3,3): total 9
    #   (4,3,3): total 10
    #   (4,4,3): total 11
    # n3=4: n1 in {4}, n2 in [4,4].
    #   (4,4,4): total 12
    
    # So F_{c,1}[k] = 1 for k=0,1,2,...,12 and 0 otherwise.
    # F_{c,1}(1) = 13. But computation says F_{c,1}(1) = 24!
    
    # This means max_parts = 4 is NOT enough! There are triples with
    # n1 > 4 that still satisfy the interlacing.
    # With n3 = 4: n1 can be 4 or 5. But max_parts = 4 limits to n1 <= 4.
    # With unlimited parts: n3 = N for any N, giving total = 3N, 3N+1, 3N+2.
    # Each total weight k gives exactly 1 valid triple for each of the
    # three residue classes of k mod 3... WAIT that gives coefficient 1 per k,
    # but computation says coefficient 2.
    
    # I think the issue is that with parts = (1,1,...,1,0,...,0), the number of 
    # parts is not limited by max_parts in the enumeration.
    # The code gen_parts generates partitions with AT MOST max_parts parts.
    # For max_parts = 4, it only goes up to (1,1,1,1) for max-1 partitions.
    # But cylindric partitions can have ARBITRARILY MANY parts with value 1!
    
    # So the code IS truncating, and g_1's coefficient drops artificially.
    # With max_parts large enough (say 20), g_1 would have coefficient 1 up to q^{3*20+2}.
    # 
    # BUT the computation showed g_1[1] = 2, which is MORE than 1.
    # So either my analysis is wrong, or the code has a different issue.
    
    print(f"\nLet me verify F_{{c,0}} and F_{{c,1}} more carefully...")
    print(f"F_{{c,0}} = {FcN[0].to_list()}")
    print(f"F_{{c,1}} first 15 = {FcN[1].to_list()[:15]}")
    
    # F_{c,0}: partitions with max <= 0 means all parts are 0 = empty partition.
    # Should be just {((), (), ())} with total weight 0.
    # So F_{c,0} = 1. Matches.
    
    # F_{c,1}: partitions with max <= 1.
    # For c=(1,1,0), k=3: lam^(1), lam^(2), lam^(3) with parts in {0,1}.
    # But... the definition says partitions are SEQUENCES (lambda_1, lambda_2, ...) 
    # that are weakly decreasing. With parts in {0,1}, this is (1,...,1,0,...).
    # Length n_i = number of 1s. The size is n_i.
    # The INTERLACING conditions determine which (n1,n2,n3) are valid.
    
    # Wait, maybe my indexing of the profile is wrong in the code.
    # In the code, compute_FcN(c, N, q_max) with c=(1,1,0):
    # interlaces(lam0, lam1, c[1]) checks lam0_j >= lam1_{j+c[1]} = lam1_{j+1}
    # interlaces(lam1, lam2, c[2]) checks lam1_j >= lam2_{j+c[2]} = lam2_{j+0} = lam2_j
    # interlaces(lam2, lam0, c[0]) checks lam2_j >= lam0_{j+c[0]} = lam0_{j+1}
    # 
    # These correspond to:
    # lam^(1)_j >= lam^(2)_{j+1}   (from c_2 = 1)
    # lam^(2)_j >= lam^(3)_j       (from c_3 = 0)
    # lam^(3)_j >= lam^(1)_{j+1}   (from c_1 = 1)
    
    # Hmm wait, but in the conjecture definition, the condition is:
    # lam^(i)_j >= lam^(i+1)_{j+c_{i+1}}
    # So for i=1: lam^(1)_j >= lam^(2)_{j+c_2}
    # For profile c = (c_1,c_2,c_3) = (1,1,0), c_2 = 1.
    # So lam^(1)_j >= lam^(2)_{j+1}.
    
    # In the code, lam0 = lam^(1), lam1 = lam^(2), lam2 = lam^(3).
    # The code checks:
    # interlaces(lam0, lam1, c[1]) = interlaces(lam^(1), lam^(2), 1) => lam^(1)_j >= lam^(2)_{j+1}
    # interlaces(lam1, lam2, c[2]) = interlaces(lam^(2), lam^(3), 0) => lam^(2)_j >= lam^(3)_j
    # interlaces(lam2, lam0, c[0]) = interlaces(lam^(3), lam^(1), 1) => lam^(3)_j >= lam^(1)_{j+1}
    
    # So: from code, c[0]=1, c[1]=1, c[2]=0.
    # The checks use c[1], c[2], c[0] in order. 
    # This corresponds to shifts c_2, c_3, c_1 in the mathematical notation.
    # If the mathematical profile is (c_1,c_2,c_3) = (1,1,0), then:
    # shift for lam^(1)->lam^(2) is c_2 = 1 (code uses c[1] = 1) ✓
    # shift for lam^(2)->lam^(3) is c_3 = 0 (code uses c[2] = 0) ✓  
    # shift for lam^(3)->lam^(1) is c_1 = 1 (code uses c[0] = 1) ✓
    # OK so the code is correct.
    
    # But then my hand calculation gives only 1 triple per total weight!
    # Let me count them:
    # (n1,n2,n3) valid means: n2<=n1, n3<=n2, n1<=n3+1.
    # That means n1-1 <= n3 <= n2 <= n1.
    # So either n3 = n1-1 or n3 = n1.
    # And n2 can be anything between n3 and n1.
    # If n3 = n1 = n: n2 in [n, n], so n2 = n. One triple: (n,n,n). Total = 3n.
    # If n3 = n1-1 = n: n2 in [n, n+1].
    #   n2 = n: triple (n+1, n, n). Total = 3n+1.
    #   n2 = n+1: triple (n+1, n+1, n). Total = 3n+2.
    # 
    # So for each total k:
    #   k = 0: (0,0,0). One triple.
    #   k = 1: (1,0,0). One triple. 
    #   k = 2: (1,1,0). One triple.
    #   k = 3: (1,1,1). One triple.
    #   k = 4: (2,1,1). One triple.
    #   k = 5: (2,2,1). One triple.
    #   ...
    # Coefficient is always 1! So F_{c,1}[k] = k//3 + 1... no.
    # F_{c,1} counts partitions with max <= 1, so it includes BOTH max=0 and max=1.
    # F_{c,1}[k] = number of valid triples with total k and all parts <= 1.
    # From my enumeration: exactly one triple per k for k=0,1,2,...
    # But this is an infinite sequence! F_{c,1} would be 1/(1-q)(1-q^2)... no,
    # it's 1 + q + q^2 + q^3 + ... = 1/(1-q) with all coefficients 1.
    # 
    # But computation says F_{c,1}(1) = 24 up to q^40 truncation, not infinity!
    # Something is very wrong with my analysis.
    
    # OH! The partitions are sequences lambda = (lambda_1, lambda_2, ...) 
    # that are WEAKLY DECREASING and NONNEG. With max <= 1, parts are in {0,1}.
    # But weakly decreasing with values in {0,1} means (1,1,...,1,0,0,...).
    # The partition IS determined by its length (number of 1s).
    # BUT the code's gen_parts generates sequences of length max_parts.
    # For max_parts = 4, it generates ALL weakly decreasing sequences of length 4
    # with max value <= 1: (0,0,0,0), (1,0,0,0), (1,1,0,0), (1,1,1,0), (1,1,1,1).
    # That's n_i in {0,1,2,3,4}. With max_parts = N + max(c) + 2 = 1+1+2 = 4.
    # So n_i goes up to 4, giving max total = 12.
    # 
    # But our data shows F_{c,1}(1) = 24, with coefficients 1 for q^0 through...
    # wait let me print F_{c,1} properly.
    
    # The issue might be that there are MULTIPLE valid orderings when
    # the c values create different interlacing patterns.
    # Let me look at the actual F_{c,1} coefficients.

    F1 = compute_FcN((1,1,0), 1, 15)
    print(f"\nF_{{c,1}} exact for c=(1,1,0), q_max=15:")
    print(f"  {F1.to_list()}")
    
    # Count triples (n1,n2,n3) with 0<=ni<=10 satisfying constraints
    print(f"\nManual triple count for max<=1:")
    counts = defaultdict(int)
    for n1 in range(11):
        for n2 in range(11):
            for n3 in range(11):
                # Check: n2 <= n1, n3 <= n2, n1 <= n3+1
                if n2 <= n1 and n3 <= n2 and n1 <= n3 + 1:
                    counts[n1+n2+n3] += 1
    for k in sorted(counts.keys())[:16]:
        print(f"  total={k}: count={counts[k]}")


if __name__ == "__main__":
    main()
