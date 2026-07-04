"""
Seed 2, Layer 1: Correct computation of Q_{n,c}(q).

Key insight: Q_{n,c}(q) = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))

The issue with truncation: F_c(z,q) = sum_Lambda q^|Lambda| z^max(Lambda)
is an infinite series in both z and q. When we truncate max to N,
we need ALL cylindric partitions with max = m for m <= N and ALL sizes.
But we also truncate q-degree. The (zq;q)_inf factor has alternating signs,
so insufficient q-truncation creates spurious negatives.

Better approach: for a fixed n, Q_{n,c}(q) should be a polynomial of
known degree. Let me figure out the degree bound.

For c=(c_0,c_1,c_2) with d=c_0+c_1+c_2, k=3, t=k+d=3+d:
- The "weight" of the cylindric diagram (the partition into distinct parts
  piece from Tingley/Kursungoz decomposition) contributes terms that grow.
- For bounded cylindric partitions (max <= n), the size is bounded.

Actually, the maximum possible size of a cylindric partition with k=3
parts of profile c and max entry n:
  Each lam^(i) has parts <= n, and the interlacing constraints limit
  the number of parts. The max size grows like O(n * d).

For Q_{n,c}(q) to be a polynomial, we need the product (q;q)_n * [z^n](...)
to terminate. Welsh proved this. The degree should be computable.

Let me approach this differently: compute F_{c,n}(q) = sum_{max<=n} q^|Lambda|
directly, and then use the relation:
  Q_{n,c}(q) = (q;q)_n * sum_{j=0}^n (-1)^j q^{j(j+1)/2} / (q;q)_j * F_{c,n-j}(q) ... no.

Actually wait. [z^n] F_c(z,q) = b_n(q) = sum_{max=n} q^|Lambda|.
This is NOT F_{c,n}(q) which is sum_{max<=n}.

b_n(q) = F_{c,n}(q) - F_{c,n-1}(q).

For finite n, b_n(q) is a power series (infinite in q) because there are
infinitely many cylindric partitions with max exactly n (you can have
arbitrarily many small parts).

So Q_{n,c}(q) involves infinite q-series b_m(q) that are combined with
alternating signs from (zq;q)_inf. The miracle is that the result is a polynomial.

For computation, I need VERY high q-truncation to see the polynomial correctly.
Let me increase q_max significantly and also ensure all relevant cylindric
partitions are enumerated.

Alternative approach: Use the EXPLICIT FORMULA for bounded cylindric partitions.

F_{c,n}(q) = sum_{Lambda in C_{c,n}} q^|Lambda|

For c = (c_0,c_1,c_2) with k=3, this is the generating function for
3-tuples of partitions (each with parts <= n) satisfying cyclic interlacing.

We have: b_n(q) = F_{c,n}(q) - F_{c,n-1}(q)

Then Q_{n,c}(q) = (q;q)_n * sum_{j=0}^n a_j * b_{n-j}
where a_j = (-1)^j q^{j(j+1)/2} / (q;q)_j

Now (q;q)_n * a_j = (-1)^j q^{j(j+1)/2} * (q;q)_n/(q;q)_j
                   = (-1)^j q^{j(j+1)/2} * prod_{i=j+1}^n (1-q^i)

So Q_n = sum_j (-1)^j q^{j(j+1)/2} * prod_{i=j+1}^n (1-q^i) * b_{n-j}

Let me substitute b_{n-j} = F_{c,n-j} - F_{c,n-j-1}:
Q_n = sum_j (-1)^j q^{j(j+1)/2} * R_j * (F_{c,n-j} - F_{c,n-j-1})

where R_j = prod_{i=j+1}^n (1-q^i).

Let me reindex via Abel summation / summation by parts:

Actually, there's a cleaner way. Note that
Q_n = (q;q)_n * [z^n] (zq;q)_inf F_c(z,q)

And F_c(z,q) = sum_{m>=0} b_m z^m = sum_{m>=0} (F_{c,m} - F_{c,m-1}) z^m

Also F_c(z,q) = sum_{N>=0} F_{c,N} (z^N - z^{N+1}) ... no, let me think.

sum_m b_m z^m = sum_m (F_{c,m} - F_{c,m-1}) z^m
              = sum_m F_{c,m} z^m - sum_m F_{c,m-1} z^m
              = sum_m F_{c,m} z^m - z sum_{m>=1} F_{c,m-1} z^{m-1}
              = sum_m F_{c,m} z^m - z sum_{m>=0} F_{c,m} z^m
              = (1-z) sum_m F_{c,m} z^m

So F_c(z,q) = (1-z) sum_{N>=0} F_{c,N} z^N.

Therefore (zq;q)_inf F_c(z,q) = (zq;q)_inf (1-z) sum_N F_{c,N} z^N
                                = (z;q)_inf sum_N F_{c,N} z^N   ... wait

(zq;q)_inf * (1-z) = (z;q)_inf? Let's check:
(z;q)_inf = prod_{j>=0}(1-zq^j) = (1-z)(1-zq)(1-zq^2)... = (1-z)(zq;q)_inf.

YES! So (zq;q)_inf (1-z) = (z;q)_inf.

So Q_n = (q;q)_n * [z^n] (z;q)_inf sum_N F_{c,N} z^N

Now (z;q)_inf = sum_{m>=0} (-z)^m q^{m(m-1)/2} / (q;q)_m  (Euler's identity)

So [z^n] of (z;q)_inf sum_N F_{c,N} z^N
= sum_{j+k=n} (-1)^j q^{j(j-1)/2} / (q;q)_j * F_{c,k}

And Q_n = (q;q)_n * sum_{j=0}^n (-1)^j q^{j(j-1)/2} / (q;q)_j * F_{c,n-j}
        = sum_{j=0}^n (-1)^j q^{j(j-1)/2} * prod_{i=j+1}^n (1-q^i) * F_{c,n-j}

This is MUCH nicer because F_{c,N} is the cumulative count and is a simpler object.
Also, F_{c,0} = 1 (only the empty partition has max <= 0).

Now the key question: for what q-degree does Q_n stabilize?

For bounded cylindric partitions with max <= N and profile c with k=3, d=sum(c):
The maximum possible total size is bounded by N * (number of parts across all 3 partitions).
Each partition in the tuple has at most about N + d parts (from the interlacing),
so total size <= about 3N(N+d). This is a loose bound.

For Q_n to be a polynomial, the cancellation must kill all terms beyond some degree.
"""

from collections import defaultdict
import sys


class QPoly:
    """Polynomial in q with integer coefficients, truncated."""
    def __init__(self, coeffs=None, max_deg=100):
        self.max_deg = max_deg
        self.coeffs = defaultdict(int)
        if coeffs:
            for k, v in (coeffs.items() if isinstance(coeffs, dict) else enumerate(coeffs)):
                if k <= max_deg and v != 0:
                    self.coeffs[k] = v

    @staticmethod
    def one(md=100):
        return QPoly({0: 1}, md)

    @staticmethod
    def zero(md=100):
        return QPoly({}, md)

    def __add__(self, other):
        r = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            r.coeffs[k] += v
        for k, v in other.coeffs.items():
            if k <= self.max_deg:
                r.coeffs[k] += v
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
            if k+s <= self.max_deg:
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

    def __repr__(self):
        lst = self.to_list()
        if len(lst) <= 20:
            return str(lst)
        return str(lst[:10]) + f"... ({len(lst)} terms)"


def compute_FcN(c, N, q_max):
    """
    Compute F_{c,N}(q) = sum_{Lambda in C_{c,N}} q^|Lambda|.

    Cylindric partitions with max entry <= N, profile c.
    Uses brute force enumeration.
    """
    k = len(c)
    assert k == 3
    max_parts = N + max(c) + 1

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


def compute_Q_from_FcN(FcN_list, n_max, q_max):
    """
    Given FcN_list[N] = F_{c,N}(q) for N=0..n_max,
    compute Q_n(q) using:

    Q_n = sum_{j=0}^n (-1)^j q^{j(j-1)/2} * prod_{i=j+1}^n (1-q^i) * F_{c,n-j}
    """
    results = {}
    for n in range(n_max + 1):
        Q_n = QPoly.zero(q_max)
        for j in range(n + 1):
            sign = (-1) ** j
            q_shift = j * (j - 1) // 2  # NOTE: j(j-1)/2 not j(j+1)/2 !!

            # prod_{i=j+1}^n (1-q^i)
            ratio = QPoly.one(q_max)
            for i in range(j + 1, n + 1):
                factor = QPoly({0: 1, i: -1}, q_max)
                ratio = ratio * factor

            # F_{c,n-j}
            FcNj = FcN_list[n - j]

            term = ratio * FcNj
            term = term.scale(sign).shift(q_shift)

            Q_n = Q_n + term

        results[n] = Q_n
    return results


def main():
    print("=" * 60)
    print("Correct Q_{n,c}(q) computation using F_{c,N} (cumulative)")
    print("=" * 60)

    test_cases = [
        # (profile, n_max, q_max)
        ((1, 1, 0), 4, 40),   # d=2, expected Q(1)=1
        ((2, 1, 1), 3, 40),   # d=4, expected Q(1)=4
    ]

    for profile, n_max, q_max in test_cases:
        d = sum(profile)
        if d % 3 == 0:
            continue
        expected_base = (d+1)*(d+2)//6 - 1
        print(f"\n{'='*50}")
        print(f"Profile c = {profile}, d = {d}")
        print(f"Expected Q_{{n,c}}(1) = {expected_base}^n")

        # Compute F_{c,N} for N = 0..n_max
        FcN = []
        for N in range(n_max + 1):
            print(f"  Computing F_{{c,{N}}}(q)...", end=" ", flush=True)
            F = compute_FcN(profile, N, q_max)
            FcN.append(F)
            print(f"F(1) = {F.eval_at_1()}")

        # Compute Q_n
        Qs = compute_Q_from_FcN(FcN, n_max, q_max)

        for n in range(n_max + 1):
            coeffs = Qs[n].to_list()
            eval1 = Qs[n].eval_at_1()
            nonneg = Qs[n].is_nonneg()
            print(f"\n  Q_{{{n},c}}(q) = {coeffs}")
            print(f"    Q(1) = {eval1}, expected = {expected_base**n}, match = {eval1 == expected_base**n}, nonneg = {nonneg}")
            if not nonneg:
                neg = {k: v for k, v in Qs[n].coeffs.items() if v < 0}
                print(f"    *** NEGATIVE: {dict(neg)}")


if __name__ == "__main__":
    main()
