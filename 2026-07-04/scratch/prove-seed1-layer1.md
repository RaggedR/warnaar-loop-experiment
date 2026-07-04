# Seed 1, Layer 1, Round 2 — Demazure/Key Polynomial Decomposition

## Mission
Prove abstractly that Q_{n,c}(q) has nonneg coefficients via key polynomial / Demazure theory.

## Computational Evidence

### Correct Q_n values (verified from first principles)
- d=2, c=(1,1,0): Q_0=1, Q_1=q, Q_2=q^4, Q_3=q^9. **Pattern: Q_n = q^{n^2}.**
  This is trivially nonneg. Evaluation: Q_n(1) = 1^n.
- d=4, c=(2,1,1): Q_1 = 2q + q^2 + q^3, Q_2 = q^3+3q^4+2q^5+3q^6+2q^7+2q^8+q^9+q^{10}+q^{12}.
  Q_n(1) = 4^n. All nonneg verified.
- d=5, c=(2,2,1): Q_1 = 2q+2q^2+q^3+q^4, Q_1(1)=6. Q_2(1)=36. All nonneg.

### The g_m structure for d=2
For d=2, c=(1,1,0), g_m = [z^m]F_c(z,q) counts CPs with max exactly m.

**Key fact:** For d=2, g_1 has coefficient EXACTLY 2 for every q^w, w >= 1.
So g_1 = 2q/(1-q).

The valid column-count states at height h are triples (s0,s1,s2) in Z_>=0^3
satisfying s1 <= s0+1, s2 <= s1, s0 <= s2+1. For each weight w >= 1,
there are exactly 2 such states. The states come in natural pairs:
  w=1: (0,1,0), (1,0,0)
  w=2: (0,1,1), (1,1,0)  
  w=3: (1,1,1), (1,2,0)
  w=4: (1,2,1), (2,1,1)
The pairing appears to be: swap the first and last column counts and adjust.

### Critical correction of Round 1 errors

1. **The "key polynomial decomposition" from Round 1 is VACUOUS at the specialised level.**
   Any polynomial with nonneg coefficients trivially decomposes as sum a_k * kappa_{(k,0,0)}
   at specialisation (q, q^2, q^3), since kappa_{(k,0,0)} = x_1^k -> q^k.
   The decomposition is exactly equivalent to positivity itself.

2. **Column-count states have NO mutual ordering.** The column counts s^0, s^1, s^2
   for the three partitions at a given height are NOT required to satisfy
   s^0 >= s^1 >= s^2. My initial analytic computation made this error,
   giving F_{c,1} = 1/(1-q) instead of the correct (1+q)/(1-q).

3. **EMD path formula IS consistent** with the correct F_{c,n}. For d=2:
   P_1^{EMD} = (1-q^3)*F_{c,1} = (1-q^3)(1+q)/(1-q) = 1+2q+2q^2+q^3, which matches.
   The P_n in the EMD formula uses (q^3;q^3)_n (the r=3 factor), while
   Q_n uses (q^ell;q^ell)_n with ell=gcd(d,3). These are DIFFERENT for ell != 3.

## What a Counterexample Looks Like
Q_n with a negative coefficient would disprove the conjecture.

## Strategy: Understand the q-binomial cancellation

### The central identity
Q_n = (q;q)_n * sum_{j=0}^n (-1)^{n-j} q^{j(j+1)/2} / (q;q)_j * g_{n-j}

where g_m is a power series (not polynomial). The miracle is that (q;q)_n times
this alternating sum of power series produces a POLYNOMIAL with nonneg coefficients.

For d=2: g_m = 2q/(1-q) for all m >= 1 (since the states at each height
are independent up to the decreasing constraint). Actually, g_m may not all
be the same -- the multi-height transfer matrix creates dependencies.

### Approach 1: Verify g_m structure for d=2
If g_m = f(q) * (number of m-height configurations with given base state sequence),
and this factors nicely, then Q_n might have a closed form.

### Approach 2: Use the system recurrence
Agent C found: Q_n(c) = (1/(1+q^n+q^{2n})) sum_{c'} q^{n*EMD(c,c')} * R(c').
For d=2: by cyclic invariance, Q_n is the same for all profiles.
The recurrence might simplify dramatically for d=2.

## Attempt: Prove Q_n = q^{n^2} for d=2

**Proof sketch (assuming g_m structure):**

For d=2, the definition gives:
Q_n = (1-q)(1-q^2)...(1-q^n) * sum_{j=0}^n (-1)^{n-j} q^{j(j+1)/2} / ((1-q)(1-q^2)...(1-q^j)) * g_{n-j}

If all g_m = 2q/(1-q) for m >= 1 and g_0 = 1, then this becomes:
= (q;q)_n * [g_n + sum_{j=1}^n (-1)^{n-j} q^{j(j+1)/2}/(q;q)_j * g_{n-j}]

Wait, the indices: let k = n-j (so j runs over 0..n means k runs over n..0).
[z^n] = sum_{k=0}^n c_k * g_{n-k} = c_0 g_n + c_1 g_{n-1} + ... + c_n g_0
where c_k = (-1)^k q^{k(k+1)/2} / (q;q)_k.

For d=2, g_m = 2q/(1-q) for m >= 1:
[z^n] = g_n * 1 + g_{n-1} * (-q/(1-q)) + g_{n-2} * q^3/((1-q)(1-q^2)) + ... + g_0 * c_n

For n >= 2, the first n terms all have g_j = 2q/(1-q):
[z^n] = 2q/(1-q) * sum_{k=0}^{n-1} c_k + c_n * g_0
       = 2q/(1-q) * sum_{k=0}^{n-1} (-1)^k q^{k(k+1)/2} / (q;q)_k + c_n

Now, sum_{k=0}^{inf} (-1)^k q^{k(k+1)/2} / (q;q)_k = (zq;q)_inf evaluated at z=1.
(q;q)_inf = prod_{i>=1}(1-q^i). But we need the partial sum to n-1.

Actually, (zq;q)_inf = sum_k (-1)^k z^k q^{k(k+1)/2} / (q;q)_k. At z=1:
(q;q)_inf = prod_{i>=1}(1-q^i) = sum_k (-1)^k q^{k(k+1)/2} / (q;q)_k.

This is Euler's identity! So sum_{k>=0} c_k = (q;q)_inf.

The partial sum sum_{k=0}^{n-1} c_k = (q;q)_inf - sum_{k>=n} c_k.

This doesn't simplify easily. Let me try a different approach.

## Attempt 2: Direct verification of Q_n = q^{n^2} for d=2

Let me verify Q_n = q^{n^2} directly from the definition by showing
[z^n]((zq;q)_inf * F_c(z,q)) = q^{n^2} / (q;q)_n.

F_c(z,q) = g_0 + sum_{m>=1} g_m z^m = 1 + 2qz/((1-q)(1-z)).

Wait, for d=2 and multi-height m, does g_m = 2q/(1-q) for ALL m >= 1?
This would mean F_c(z,q) = 1 + z * 2q/((1-q)(1-z)).
But this is FALSE in general because the multi-height transfer matrix
introduces dependencies between levels.

Let me check g_2 numerically for d=2.

(From earlier computation: g_2 coefficients start 0,0,2,3,6,7,10,11,14,15,...)
So g_2 is NOT 2q/(1-q). The coefficients are growing.

This means the simple approach doesn't work. The g_m have different structures
for different m.

## Handoff

### State
Corrected several computational errors from Round 1 and from my own initial work.
Verified Q_n = q^{n^2} for d=2 (all profiles) numerically through n=3.
The "key polynomial decomposition" strategy (Seed 1's main directive) turns out to be 
vacuous at the specialised level — it is equivalent to positivity itself.

### Best Result: YELLOW
**Q_n = q^{n^2} for d=2** — verified but not proved. This is a clean, testable conjecture
that could serve as a base case or provide structural insight.

**The key polynomial decomposition from Round 1 is vacuous** — this eliminates a 
false lead, saving future agents from pursuing it.

### What the next layer should do
1. PROVE Q_n = q^{n^2} for d=2. This requires understanding the g_m power series 
   structure for all m and showing the alternating sum collapses.
2. Abandon the key polynomial decomposition approach (Seed 1 direction). 
3. Instead, focus on the system recurrence (Agent C) or Warnaar's bounded functional 
   equations (Seed 3). These are the most promising paths.
4. Investigate whether Q_n for d=4 also has a closed form analogous to q^{n^2}.
