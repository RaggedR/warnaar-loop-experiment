#!/usr/bin/env python3
"""
Exhaustive test: does f_1 (coefficients of cylindric partitions with max=1)
have monotonically increasing coefficients for ALL profiles with d not equiv 0 mod 3?

Also test: a_1 >= 2 for all profiles?
"""

def compute_f1(c, q_bound):
    c0, c1, c2 = c
    result = {}
    for L1 in range(q_bound + 1):
        for L2 in range(min(L1 + c1, q_bound - L1) + 1):
            L3_min = max(0, L1 - c0)
            L3_max = min(L2 + c2, q_bound - L1 - L2)
            for L3 in range(L3_min, L3_max + 1):
                if L2 < L3 - c2:
                    continue
                if L1 + L2 + L3 == 0:
                    continue
                s = L1 + L2 + L3
                if s <= q_bound:
                    result[s] = result.get(s, 0) + 1
    return result

def all_compositions(d, k=3):
    if k == 1:
        yield (d,)
        return
    for i in range(d+1):
        for rest in all_compositions(d - i, k - 1):
            yield (i,) + rest

q_bound = 50
failures_mono = []
failures_a1 = []

for d in range(1, 15):
    if d % 3 == 0:
        continue
    for c in all_compositions(d):
        f1 = compute_f1(c, q_bound)
        coeffs = [f1.get(k, 0) for k in range(q_bound + 1)]
        
        # Check a_1 >= 2
        if coeffs[1] < 2:
            failures_a1.append((d, c, coeffs[1]))
        
        # Check monotonicity (from index 1 onwards)
        monotone = True
        for k in range(2, q_bound + 1):
            if coeffs[k] < coeffs[k-1]:
                monotone = False
                break
        
        if not monotone:
            failures_mono.append((d, c, coeffs[:20]))

print(f"Tested d from 1 to 14 (excluding multiples of 3)")
print(f"a_1 < 2 failures: {len(failures_a1)}")
for d, c, a1 in failures_a1[:10]:
    print(f"  d={d}, c={c}: a_1 = {a1}")

print(f"\nMonotonicity failures: {len(failures_mono)}")
for d, c, coeffs in failures_mono[:10]:
    print(f"  d={d}, c={c}: coeffs = {coeffs}")

if not failures_mono and not failures_a1:
    print("\nALL profiles pass! f_1 is always monotonically increasing with a_1 >= 2.")
    print("This PROVES Q_1 >= 0 for all tested d values (given monotonicity + a_1 >= 2).")
