# Independent Verification: h_m Dispute

## Summary

**VERDICT: Seed 8 is correct. Agent A's negative coefficients were a precision artifact.**

## The Disputed Instances

From Agent A's notes (`2026-07-03/scratch/prove-agentA.md`):
- d=4, c=(2,1,1), m=2: claimed `h_2 = [0,0,3,4,5,3,3,2,2,1,1,0,1,0,...,0,-3,-7,-12,-14,-9,-4,-1]`, `h_2(1) = -25`
- d=7, c=(3,2,2), m=2: claimed `h_2` has negatives starting at degree 23

## Method

Independent implementation in two ways:

1. **Brute-force column enumeration** (exact integers): enumerate all valid triples `(s^i_h)` for heights `h=1..m` satisfying the interlacing constraints, accumulate by total weight. This is entirely independent of both agents' code.

2. **Transfer matrix** (for cross-check): Corteel-Welsh functional equation via matrix inverse in power series ring.

## Results

### d=4, c=(2,1,1), m=2

**Full enumeration (weight_limit=100):**
- `h_2 = [0, 0, 3, 4, 5, 3, 3, 2, 2, 1, 1, 0, 1]` (degree 12)
- `h_2(1) = 25` (positive)
- **No negative coefficients**

**g_2 is an infinite power series**: `3q^2 + 7q^3 + 15q^4 + 22q^5 + 33q^6 + ...` (quasi-polynomial with linearly growing coefficients, confirmed by `h_2/(q;q)_2`).

### Why Agent A Got Negatives (Truncation Artifact)

Agent A's code uses `max_s = min(prec // (2*k), 40) = 10` for PREC=60 (but the notes say PREC=80, giving max_s=13). This bounds each column value `s^i_h <= max_s`, so g_2 coefficients at weight > ~78 are missing.

Since `(q;q)_2 = 1 - q - q^2 + q^3`, we have:
```
h_2[k] = g_2[k] - g_2[k-1] - g_2[k-2] + g_2[k-3]
```
When g_2 is truncated at weight T (with g_2 still growing quasi-polynomially), the terms `g_2[T], g_2[T-1], ...` suddenly drop to zero, creating spurious negatives:
```
h_2[T+1] ≈ 0 - g_2[T] - g_2[T-1] + g_2[T-2] ≈ -2*15 = -30  (at T=54)
```
At T=54: spurious `h_2[55] = 0 - 629 - 614 + 604 = -639`.

**Agent A's g_2 matches the true g_2 exactly at all weights they enumerated** — their enumeration was correct, but the power series was truncated, and multiplying by `(q;q)_2` then showed the missing tail as spurious negatives.

### d=7, c=(3,2,2), m=2

**Transfer matrix (PREC=250):**
- `h_2 = [0, 0, 3, 6, 10, 11, 13, 12, 13, 10, 11, 9, 9, 7, 7, 5, 5, 3, 3, 2, 2, 1, 1, 0, 1]` (degree 24)
- `h_2(1) = 144` (positive)
- **No negative coefficients**

## Cross-Check

- `g_2 = h_2 / (q;q)_2` recovers exactly the enumerated power series (confirmed for d=4, coefficients match at all computed weights).
- Agent A's enumeration is correct up to their truncation point; the divergence only appears after the truncation.

## Scripts

- `2026-07-04/scratch/scripts/verify_hm_dispute.sage` — brute-force enumeration + Agent A truncation reproduction
- Analysis in `/tmp/verify_analysis.sage` — truncation artifact explanation + d=7 transfer matrix check

## Confidence

**High (>95%).** The mechanism is fully understood and directly verified:
1. h_2 polynomial terminates at degree 12 (d=4) and degree 24 (d=7), both fully within enumeration range
2. Agent A's g_2 values ARE correct — the error is purely in truncating the power series before multiplying by (q;q)_2
3. The spurious negative is mechanistically explained: at the truncation boundary, (q;q)_2 "sees" g_2 suddenly drop to zero while its coefficients were still growing
