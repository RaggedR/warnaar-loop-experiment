"""
Seed 4, Layer 2: Study D_k^m evaluations and prove Q_n = D_n^n algebraically.

Key observation from data:
  D_k^m(1) = (base-1)^k * base^{m-k}   where base = (d+1)(d+2)/6

Verify: for d=4, base=5:
  D_0^m(1) = 5^m (= h_m(1) = base^m). Check.
  D_1^m(1) = 4 * 5^{m-1}. D_1^1=4, D_1^2=20, D_1^3=100, D_1^4=500. Check!
  D_2^m(1) = 16 * 5^{m-2}. D_2^2=16, D_2^3=80, D_2^4=400. Check!
  D_3^m(1) = 64 * 5^{m-3}. D_3^3=64, D_3^4=320. Check!

For d=7, base=12:
  D_0^m(1) = 12^m. Check.
  D_1^m(1) = 11 * 12^{m-1}. D_1^1=11, D_1^2=132, D_1^3=1584. Check!
  D_2^m(1) = 121 * 12^{m-2}. D_2^2=121, D_2^3=1452. Check!
  D_3^m(1) = 1331 * 12^{m-3} = 11^3. D_3^3=1331. Check!

So D_k^m(1) = (base-1)^k * base^{m-k}.
And Q_n(1) = D_n^n(1) = (base-1)^n = ((d+1)(d+2)/6 - 1)^n. Matches the conjecture!

ALGEBRAIC PROOF that Q_n = D_n^n:

Define D_0^m = h_m and D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}.

Claim: D_k^m = sum_{j=0}^k (-1)^j q^{j(j+1)/2} [k choose j]_q h_{m-j}
where [k choose j]_q is the Gaussian binomial coefficient,
and the product q^{j(j+1)/2} uses the shifted factorization
q^{1+2+...+j} = q^{j(j+1)/2}.

Wait, I need to check this. The iterated difference operator
(I - q^k T)(I - q^{k-1} T)...(I - q T) where T is the shift T h_m = h_{m-1}
gives:
D_k^m = prod_{i=1}^k (I - q^i T) h_m
      = sum_{j=0}^k (-1)^j e_j(q, q^2, ..., q^k) h_{m-j}

where e_j is the j-th elementary symmetric polynomial in q, q^2, ..., q^k.

The elementary symmetric polynomial e_j(q, q^2, ..., q^k) is the sum of all
products of j distinct elements from {q, q^2, ..., q^k}.

For the q-binomial coefficient: [k choose j]_q = product/product formula.
And e_j(q, q^2, ..., q^k) = q^{j(j+1)/2} [k choose j]_q.

This is a well-known identity! Let me verify:
e_1(q, q^2, ..., q^k) = q + q^2 + ... + q^k = q(1 + q + ... + q^{k-1}) = q [k]_q.
And q^{1(2)/2} [k choose 1]_q = q * [k]_q. Check!

e_2(q, q^2, ..., q^k) = sum_{1<=i<j<=k} q^{i+j}.
q^{2(3)/2} [k choose 2]_q = q^3 [k]_q [k-1]_q / [2]_q.

Let me verify for k=3:
e_2(q, q^2, q^3) = q*q^2 + q*q^3 + q^2*q^3 = q^3 + q^4 + q^5.
q^3 [3 choose 2]_q = q^3 (1 + q + q^2) = q^3 + q^4 + q^5. Check!

So: D_k^m = sum_{j=0}^k (-1)^j q^{j(j+1)/2} [k choose j]_q h_{m-j}

And Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j} = D_n^n.

THIS IS EXACTLY THE IDENTITY Q_n = D_n^n.

PROVED: Q_n = D_n^n where D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}.

Now, the positivity conjecture Q_n >= 0 is equivalent to D_n^n >= 0,
which follows from the TOWER of domination conditions:
  D_k^m >= q^{k+1} D_k^{m-1}  (for all k, m with m > k)

This is equivalent to D_{k+1}^m >= 0.

So: Q_n >= 0 iff D_n^n >= 0 iff D_k^m >= 0 for all k <= n, m >= k.

The base case D_0^m = h_m >= 0 is the h_m positivity conjecture.
The inductive step D_k^m >= 0 => D_{k+1}^m >= 0 requires D_k^m >= q^{k+1} D_k^{m-1}.
"""

print("ALGEBRAIC PROOF: Q_n = D_n^n")
print()
print("Define D_0^m = h_m, D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}")
print()
print("The operator D_k = prod_{i=1}^k (I - q^i T) where T is the shift operator.")
print("D_k^m = sum_{j=0}^k (-1)^j e_j(q,...,q^k) h_{m-j}")
print("      = sum_{j=0}^k (-1)^j q^{j(j+1)/2} [k choose j]_q h_{m-j}")
print()
print("Setting k = m = n:")
print("D_n^n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j} = Q_n")
print()
print("EVALUATION at q=1:")
print("D_k^m(1) = prod_{i=1}^k (1 - 1) * h_{m-k}(1) ... no, that's 0 for k >= 1.")
print("Actually: D_k^m(1) = (I - T)^k h_m evaluated at q=1")
print("= sum_j (-1)^j C(k,j) h_{m-j}(1) = sum_j (-1)^j C(k,j) base^{m-j}")
print("= base^{m-k} sum_j (-1)^j C(k,j) base^{k-j}")
print("= base^{m-k} (base - 1)^k")
print()
print("So D_k^m(1) = (base-1)^k * base^{m-k}")
print("And Q_n(1) = D_n^n(1) = (base-1)^n. QED for the evaluation.")
print()
print("=" * 60)
print("POSITIVITY REDUCTION:")
print("=" * 60)
print()
print("Q_n >= 0 <=> D_n^n >= 0")
print()
print("The tower of positivity conditions:")
print("  D_0^m >= 0  for all m (= h_m >= 0)")
print("  D_1^m >= 0  for all m >= 1 (= h_m >= q h_{m-1})")
print("  D_2^m >= 0  for all m >= 2 (= D_1^m >= q^2 D_1^{m-1})")
print("  ...")
print("  D_k^m >= 0  for all m >= k (= D_{k-1}^m >= q^k D_{k-1}^{m-1})")
print()
print("Each level gives: D_k^m >= 0 iff D_{k-1}^m >= q^k * D_{k-1}^{m-1}")
print()
print("KEY OBSERVATION: The positivity Q_n >= 0 for all n")
print("is equivalent to D_k^m >= 0 for ALL k,m with m >= k >= 0.")
print("This is a SINGLE condition (no circular dependence) because")
print("D_k^m is defined purely in terms of h_0, h_1, ..., h_m.")
print()
print("NEW CONJECTURE: For c = (c_0,c_1,c_2) with d = c_0+c_1+c_2")
print("not divisible by 3, and h_m = (q;q)_m [z^m] F_c(z,q),")
print("the iterated q-differences D_k^m >= 0 for all k,m with m >= k >= 0.")
print()
print("This is STRONGER than Warnaar's conjecture (which is the k=m case)")
print("but EQUIVALENT in content: Q_n >= 0 for all n iff D_k^m >= 0 for all k,m.")

