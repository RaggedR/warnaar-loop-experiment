"""
Independent verification of the h_m dispute.
Agent A claimed: h_2 has NEGATIVE coefficients for d=4, c=(2,1,1) and d=7, c=(3,2,2).
Seed 8 claimed: This was a precision artifact from truncated enumeration.
MY APPROACH: Brute-force enumeration with EXACT integer arithmetic, and
explicit truncation analysis.
"""
from sage.all import *

def enumerate_gm_exact(c, m, weight_limit):
    """
    Enumerate all cylindric partitions with profile c=(c0,c1,c2), max entry <= m,
    total weight <= weight_limit. Column representation: s^i_h = # parts of lambda^i >= h.
    Returns (gm_coeffs, fm_coeffs) where gm = F_{c,m} - F_{c,m-1}.
    """
    c0, c1, c2 = c
    count_max_m = [0] * (weight_limit + 1)
    count_max_m1 = [0] * (weight_limit + 1)

    def enum_height(h, s0_lb, s1_lb, s2_lb, weight_used, target_arr):
        for s0 in range(s0_lb, weight_limit - weight_used + 1):
            s1_ub = s0 + c1
            for s1 in range(s1_lb, min(s1_ub, weight_limit - weight_used - s0) + 1):
                s2_lb2 = max(s2_lb, s0 - c0)
                s2_ub = s1 + c2
                for s2 in range(s2_lb2, min(s2_ub, weight_limit - weight_used - s0 - s1) + 1):
                    w = weight_used + s0 + s1 + s2
                    if w > weight_limit:
                        break
                    if h == 1:
                        target_arr[w] += 1
                    else:
                        enum_height(h-1, s0, s1, s2, w, target_arr)

    if m > 0:
        enum_height(m, 0, 0, 0, 0, count_max_m)
    else:
        count_max_m[0] = 1

    if m > 1:
        enum_height(m-1, 0, 0, 0, 0, count_max_m1)
    elif m == 1:
        count_max_m1[0] = 1
    else:
        count_max_m1[0] = 1

    gm = [count_max_m[w] - count_max_m1[w] for w in range(weight_limit + 1)]
    return gm, count_max_m

def multiply_by_qpoch(coeffs, m):
    """Multiply coefficient list by (q;q)_m = prod_{j=1}^m (1-q^j) exactly."""
    result = list(coeffs)
    for j in range(1, m+1):
        new_result = list(result)
        for k in range(j, len(result)):
            new_result[k] -= result[k-j]
        result = new_result
    return result

def agentA_gm_truncated(c, max_s):
    """Reproduce Agent A's truncated m=2 enumeration exactly."""
    c0, c1, c2 = c
    counts = {}
    for a0 in range(max_s):
        for a1 in range(min(a0+c1+1, max_s)):
            for a2 in range(min(a1+c2+1, max_s)):
                if a0 <= a2+c0:
                    for b0 in range(min(a0+1, max_s)):
                        for b1 in range(min(b0+c1+1, a1+1, max_s)):
                            for b2 in range(min(b1+c2+1, a2+1, max_s)):
                                if b0 <= b2+c0:
                                    if max(b0,b1,b2) >= 1:
                                        tot = a0+a1+a2+b0+b1+b2
                                        counts[tot] = counts.get(tot, 0) + 1
    return counts

print("="*70)
print("STEP 1: Full enumeration for d=4, c=(2,1,1), m=2")
print("="*70)
c = (2,1,1); m = 2; WL = 100
gm, fm = enumerate_gm_exact(c, m, WL)
last_gm = max((i for i in range(len(gm)) if gm[i] != 0), default=0)
print(f"g_2 last nonzero at weight {last_gm}")
print(f"g_2 = {gm[:last_gm+2]}")
hm = multiply_by_qpoch(gm, m)
last_hm = max((i for i in range(len(hm)) if hm[i] != 0), default=0)
print(f"h_2 = {hm[:last_hm+2]}")
print(f"h_2(1) = {sum(hm[:last_hm+2])}")
negs = [i for i in range(last_hm+2) if hm[i] < 0]
print(f"Negative positions: {negs if negs else 'NONE - ALL NONNEG'}")
# Verify truncation safe: g_m near boundary
tail = gm[last_gm+1:last_gm+5]
print(f"g_2 beyond last_nz: {tail} (should be all zero)")
print()

print("="*70)
print("STEP 2: Agent A's truncated enumeration (max_s=10) for same case")
print("="*70)
max_s_agentA = 10  # = min(60//(2*3), 40) = 10
agentA = agentA_gm_truncated((2,1,1), max_s_agentA)
max_w_a = max(agentA.keys()) if agentA else 0
agentA_list = [agentA.get(w,0) for w in range(max_w_a+1)]
print(f"Agent A g_2 (max_s=10): last weight = {max_w_a}")
hm_a = multiply_by_qpoch(agentA_list, m)
last_hm_a = max((i for i in range(len(hm_a)) if hm_a[i] != 0), default=0)
print(f"Agent A h_2: {hm_a[:last_hm_a+2]}")
print(f"Agent A h_2(1) = {sum(hm_a[:last_hm_a+2])}")
negs_a = [i for i in range(last_hm_a+2) if hm_a[i] < 0]
print(f"Negative positions: {negs_a if negs_a else 'NONE'}")
print()

print("="*70)
print("STEP 3: Divergence analysis - where does Agent A's g_2 differ from full?")
print("="*70)
print("w | AgentA | Full | Missing")
total_missing = 0
for w in range(max(max_w_a, last_gm)+1):
    a = agentA_list[w] if w < len(agentA_list) else 0
    f = gm[w] if w < len(gm) else 0
    diff = f - a
    if diff != 0:
        total_missing += diff
        print(f"w={w:3d}: {a:6d} {f:6d}  missing={diff}")
print(f"Total missing CPs: {total_missing}")
print()

print("="*70)
print("STEP 4: Full enumeration for d=7, c=(3,2,2), m=2")
print("="*70)
c2_test = (3,2,2); m2 = 2; WL2 = 120
gm2, fm2 = enumerate_gm_exact(c2_test, m2, WL2)
last_gm2 = max((i for i in range(len(gm2)) if gm2[i] != 0), default=0)
print(f"g_2 last nonzero at weight {last_gm2}")
hm2 = multiply_by_qpoch(gm2, m2)
last_hm2 = max((i for i in range(len(hm2)) if hm2[i] != 0), default=0)
print(f"h_2 = {hm2[:last_hm2+2]}")
print(f"h_2(1) = {sum(hm2[:last_hm2+2])}")
negs2 = [i for i in range(last_hm2+2) if hm2[i] < 0]
print(f"Negative positions: {negs2 if negs2 else 'NONE - ALL NONNEG'}")
tail2 = gm2[last_gm2+1:last_gm2+5]
print(f"g_2 beyond last_nz: {tail2} (should be all zero for polynomial)")
print()

print("="*70)
print("STEP 5: Also verify Agent A's max_s for d=7 case")
print("="*70)
max_s_a7 = min(60//(2*3), 40)  # same formula, same result = 10
print(f"Agent A max_s for d=7, c=(3,2,2): {max_s_a7}")
agentA7 = agentA_gm_truncated((3,2,2), max_s_a7)
max_w_a7 = max(agentA7.keys()) if agentA7 else 0
agentA7_list = [agentA7.get(w,0) for w in range(max_w_a7+1)]
hm_a7 = multiply_by_qpoch(agentA7_list, m2)
last_hm_a7 = max((i for i in range(len(hm_a7)) if hm_a7[i] != 0), default=0)
print(f"Agent A h_2 (d=7): {hm_a7[:last_hm_a7+2]}")
negs_a7 = [i for i in range(last_hm_a7+2) if hm_a7[i] < 0]
print(f"Negative positions: {negs_a7 if negs_a7 else 'NONE'}")
total_miss7 = sum(gm2[w] - (agentA7_list[w] if w < len(agentA7_list) else 0)
                  for w in range(max(max_w_a7, last_gm2)+1))
print(f"Total missing CPs in d=7 case: {total_miss7}")
print()

print("="*70)
print("VERDICT")
print("="*70)
d4_nonneg = all(hm[i] >= 0 for i in range(last_hm+2))
d7_nonneg = all(hm2[i] >= 0 for i in range(last_hm2+2))
d4_agentA_neg = any(hm_a[i] < 0 for i in range(last_hm_a+2))
d7_agentA_neg = any(hm_a7[i] < 0 for i in range(last_hm_a7+2))

if d4_nonneg and d7_nonneg:
    print("SEED 8 IS CORRECT: h_2 has NO negative coefficients for d=4 or d=7.")
    if d4_agentA_neg or d7_agentA_neg:
        print("AGENT A'S claim was a PRECISION/TRUNCATION ARTIFACT.")
        print(f"  d=4: Agent A had negatives: {d4_agentA_neg}, Full: NONNEG")
        print(f"  d=7: Agent A had negatives: {d7_agentA_neg}, Full: NONNEG")
else:
    print("AGENT A MIGHT BE PARTIALLY CORRECT - negatives found in full enumeration!")
    print(f"  d=4 h_2 nonneg: {d4_nonneg}")
    print(f"  d=7 h_2 nonneg: {d7_nonneg}")
