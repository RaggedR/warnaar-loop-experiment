"""
Seed 2, Layer 1: Explore the multiplicative/q-analogue structure of Q_{n,c}(q).

Key question: Is Q_{n,c}(q) expressible as a product or iterated convolution
of simpler positive polynomials?

For Q(1) = B^n, we need Q_{n,c}(q) to be a q-analogue of B^n.
The natural candidates:
1. Q_n(q) = sum over (i_1,...,i_n) in S^n of q^{w(i_1,...,i_n)} for some weight function w
2. Q_n(q) is a "q-multinomial" type object
3. Q_n(q) = [n]_q! * something / something

Let me check if Q_n satisfies any recurrence in n.
"""

# Data from previous computation
Q_data = {
    (2,1,1): {
        0: {0: 1},
        1: {1: 2, 2: 1, 3: 1},
        2: {3: 1, 4: 3, 5: 2, 6: 3, 7: 2, 8: 2, 9: 1, 10: 1, 12: 1},
        3: {7: 2, 8: 2, 9: 5, 10: 4, 11: 6, 12: 6, 13: 6, 14: 5, 15: 6, 16: 4, 17: 4, 18: 3, 19: 3, 20: 2, 21: 2, 22: 1, 23: 1, 24: 1, 27: 1},
    },
    (2,2,1): {
        0: {0: 1},
        1: {1: 2, 2: 2, 3: 1, 4: 1},
        2: {3: 1, 4: 4, 5: 4, 6: 5, 7: 4, 8: 5, 9: 3, 10: 3, 11: 2, 12: 2, 13: 1, 14: 1, 16: 1},
        3: {7: 2, 8: 4, 9: 8, 10: 9, 11: 12, 12: 14, 13: 15, 14: 15, 15: 16, 16: 15, 17: 14, 18: 14, 19: 12, 20: 11, 21: 10, 22: 8, 23: 7, 24: 7, 25: 5, 26: 4, 27: 3, 28: 3, 29: 2, 30: 2, 31: 1, 32: 1, 33: 1, 36: 1},
    },
}


def poly_mul_dict(a, b):
    """Multiply two polynomials represented as dicts."""
    from collections import defaultdict
    result = defaultdict(int)
    for i, ai in a.items():
        for j, bj in b.items():
            result[i+j] += ai * bj
    return dict(result)


def check_recurrence(Q_dict, profile):
    """Check if Q_n satisfies a linear recurrence in n over Q[q]."""
    print(f"\nProfile {profile}:")
    
    # Check: does Q_2 = f(q) * Q_1 for some polynomial f?
    # If Q_n = f(q)^{n-1} * Q_1, this would give Q_2/Q_1.
    # But division in polynomial ring might not work.
    
    # Instead, check: Q_2(q) = A(q) * Q_1(q) + B(q) * Q_0(q)?
    # Q_0 = 1, Q_1 = known, Q_2 = known.
    # Q_2(q) = A(q) * Q_1(q) + B(q)
    # This gives B(q) = Q_2(q) - A(q)*Q_1(q).
    # For this to work, A and B must be polynomials.
    
    Q0 = Q_dict[0]
    Q1 = Q_dict[1]
    Q2 = Q_dict[2]
    
    # Try: Q_2 = c * Q_1^2 for some constant c?
    Q1sq = poly_mul_dict(Q1, Q1)
    print(f"  Q_1^2 = {sorted(Q1sq.items())}")
    print(f"  Q_2   = {sorted(Q2.items())}")
    
    # Check ratio Q_2 / Q_1 (if Q_1 divides Q_2)
    # Q_1 for (2,1,1) = 2q + q^2 + q^3 = q(2 + q + q^2)
    # Q_2 for (2,1,1) starts at q^3
    # Q_2 / Q_1 would start at q^2... let's compute
    
    # Actually, let me check if Q_{n+1} / Q_n stabilizes or has a pattern
    # by looking at the generating function sum_n Q_n z^n.
    
    # Better: compute Q_n(q) for n=0,1,2,3 and check if
    # Q_3 = a(q) Q_2 + b(q) Q_1 + c(q) Q_0 for polynomial a,b,c.
    
    if 3 in Q_dict:
        Q3 = Q_dict[3]
        
        # Min and max degrees
        for n, Qn in Q_dict.items():
            nonzero = sorted(Qn.keys())
            if nonzero:
                print(f"  Q_{n}: degrees {nonzero[0]} to {nonzero[-1]}, sum = {sum(Qn.values())}")
    
    # Check the "convolution" structure: 
    # If Q_n counts n-tuples from a set S with q-weight,
    # then Q_n(q) = sum_{s1+...+sn = total} q^total * c(s1,...,sn)
    # which is the n-fold convolution of the single-object distribution.
    # But the n-fold convolution of Q_1 with itself would give different degrees.
    
    # For (2,1,1): Q_1 has deg 3, so Q_1^n would have deg 3n.
    # But Q_n has deg 3n^2, not 3n. So it's NOT a simple convolution.
    
    # This means the "product at q=1" comes from a more subtle structure.
    # Perhaps Q_n is a q-multinomial coefficient times something.
    
    # Check: is Q_n related to the q-analogue [B]_q^n?
    # [B]_q = 1 + q + q^2 + ... + q^{B-1} = (1-q^B)/(1-q)
    # [B]_q^n = [(1-q^B)/(1-q)]^n
    # For B=4: [4]_q = 1+q+q^2+q^3, [4]_q^2 = 1+2q+3q^2+4q^3+3q^4+2q^5+q^6
    # But Q_2 for (2,1,1) = q^3+3q^4+2q^5+3q^6+2q^7+2q^8+q^9+q^10+q^12
    # Very different from [4]_q^2.
    
    print(f"\n  Degree of Q_n: {[max(Q_dict[n].keys()) if Q_dict[n] else 0 for n in sorted(Q_dict.keys())]}")
    print(f"  Min degree: {[min(Q_dict[n].keys()) if Q_dict[n] else 0 for n in sorted(Q_dict.keys())]}")
    
    # The min degree sequence for (2,1,1): 0, 1, 3, 7
    # These are 2^0-1, 2^1-1, 2^2-1, 2^3-1. Hmm coincidence?
    # Actually 0, 1, 3, 7 = 0, 1, 1+2, 1+2+4 = sum_{i=0}^{n-1} 2^i = 2^n - 1.
    # This is interesting! Does this generalize?
    
    # For (2,2,1): min degrees 0, 1, 3, 7. Same!
    # For (3,1,0): min degrees 0, 1, 4, 8. Different: 0, 1, 4, 8.
    # 4 = 1+3, 8 = 1+3+4. Not powers of 2.
    
    # For (2,1,1): min_deg(n) = n(n-1)/2 * 2/1? 0, 1, 3, 7: no.
    # 0, 1, 3, 7: differences 1, 2, 4 — doubling. So min_deg(n) = 2^n - 1.
    # This suggests the minimum-weight configuration has weight 2^n - 1.
    
    # For the bead model: the minimum weight cylindric partition contributing to Q_n
    # has total size 2^n - 1. What kind of configuration achieves this?


def analyze_Q1_objects(Q1, d, profile):
    """Interpret Q_1(q) as counting B objects with specific q-weights."""
    B = (d+1)*(d+2)//6 - 1
    print(f"\n  Q_1 counts {B} objects. Q_1(q) = ", end="")
    terms = []
    for exp in sorted(Q1.keys()):
        if Q1[exp] > 0:
            terms.append(f"{Q1[exp]}q^{exp}")
    print(" + ".join(terms))
    
    # List the q-weights of the B objects
    weights = []
    for exp, mult in sorted(Q1.items()):
        weights.extend([exp] * mult)
    print(f"  Object weights: {weights}")
    
    # For the bead model: each "object" at q=1 corresponds to a specific
    # bead move or cylindric diagram configuration. What are they?
    # 
    # For c=(2,1,1), d=4: B=4, weights = [1, 1, 2, 3]
    # For c=(2,2,1), d=5: B=6, weights = [1, 1, 2, 2, 3, 4]
    
    # The objects counted by Q_1 are essentially the "atoms" of the
    # Q_n generating function. Understanding what they are is key.
    
    # Q_1 = (q;q)_1 * [z^1] (z;q)_inf F_c(z,q)
    #      = (1-q) * sum_j (-1)^j q^{j(j-1)/2}/(q;q)_j * b_{1-j}
    #      = (1-q) * (b_1 - q^0/(q;q)_1 * b_0)  ... wait
    # 
    # [z^1] (z;q)_inf F_c(z,q) = sum_j [z^j](z;q)_inf * b_{1-j}
    # j=0: [z^0](z;q)_inf * b_1 = 1 * b_1
    # j=1: [z^1](z;q)_inf * b_0 = (-1)q^0/(q;q)_1 * b_0 ... 
    # Actually [z^1](z;q)_inf = coefficient of z in prod(1-zq^j) = -sum_{j>=0} q^j = -1/(1-q)
    # Wait that's wrong. (z;q)_inf = prod_{j>=0}(1-zq^j)
    # [z^1] = -sum_{j>=0} q^j = -1/(1-q). But this is an infinite series!
    # 
    # Hmm, but the Euler formula gives:
    # (z;q)_inf = sum_{m>=0} (-z)^m q^{m(m-1)/2} / (q;q)_m
    # [z^1] = -1/(q;q)_1 = -1/(1-q)
    # 
    # So [z^1]((z;q)_inf F_c(z,q)) = b_1 - b_0/(1-q)
    # And Q_1 = (1-q) * (b_1 - b_0/(1-q)) = (1-q)*b_1 - b_0
    # = (1-q)*b_1 - 1   (since b_0 = 1, the empty partition has max=0)
    #
    # Now b_1 = sum_{Lambda:max=1} q^|Lambda| is the generating function for
    # cylindric partitions of profile c with max entry exactly 1.
    
    # For c=(2,1,1): b_1 should start as... let me compute from earlier data
    # From F_{c,1}(q) = sum_{max<=1} q^|Lambda|, we have F_{c,1}(1) = 748 for transfer matrix
    # And F_{c,0} = 1.
    # So b_1 = F_{c,1} - F_{c,0} = F_{c,1} - 1.
    
    # Q_1 = (1-q)*b_1 - 1 = (1-q)*(F_{c,1}-1) - 1 = (1-q)*F_{c,1} - (1-q) - 1
    #      = (1-q)*F_{c,1} - 2 + q
    # For c=(2,1,1): Q_1 = 2q + q^2 + q^3. Let's verify:
    # (1-q)*F_{c,1} = F_{c,1} - q*F_{c,1}
    # Q_1 = (1-q)*F_{c,1} + q - 2... this should give 2q+q^2+q^3.
    # So (1-q)*F_{c,1} = 2q + q^2 + q^3 - q + 2 = 2 + q + q^2 + q^3
    # So F_{c,1} = (2+q+q^2+q^3)/(1-q) = 2/(1-q) + q/(1-q) + q^2/(1-q) + q^3/(1-q)
    # = 2(1+q+q^2+...) + q(1+q+q^2+...) + q^2(1+q+...) + q^3(1+q+...)
    # Coefficient of q^k in F_{c,1}: 2 + (k>=1) + (k>=2) + (k>=3)
    # k=0: 2, k=1: 3, k=2: 4, k>=3: 5
    # Hmm, from transfer matrix: F_{c,1} first coeffs were [1, ...] wait let me recheck.
    # Actually my earlier F_{c,1} for (1,1,0) was [1,2,2,2,...] with F(1)=201.
    # For (2,1,1) with N=1: coeffs should start [1, 3, 4, 5, 5, 5, 5, ...]
    # (1-q)*F_{c,1} = 1 + (3-1)q + (4-3)q^2 + (5-4)q^3 + (5-5)q^4 + ...
    #               = 1 + 2q + q^2 + q^3
    # Q_1 = (1-q)*F_{c,1} - 1 = 2q + q^2 + q^3. YES!


for profile, Qs in Q_data.items():
    d = sum(profile)
    check_recurrence(Qs, profile)
    analyze_Q1_objects(Qs[1], d, profile)

# Extra analysis: the formula Q_1 = (1-q)*F_{c,1} - 1
# and more generally Q_n = (q;q)_n * [z^n]((z;q)_inf * F_c(z,q))
# The key structural formula is:
# (z;q)_inf * F_c(z,q) = (z;q)_inf * (1-z) * sum_N F_{c,N} z^N
#                       ... wait, F_c(z,q) = (1-z) sum_N F_{c,N} z^N?
# Earlier we showed F_c(z,q) = (1-z) sum_N F_{c,N} z^N since
# b_m = F_{c,m} - F_{c,m-1} and F_c(z,q) = sum_m b_m z^m.
# And (z;q)_inf (1-z) ... hmm, (z;q)_inf already has (1-z) as its j=0 factor.
# Actually: (z;q)_inf = prod_{j>=0}(1-zq^j) = (1-z)(1-zq)(1-zq^2)...
# So (z;q)_inf includes (1-z). Thus:
# (z;q)_inf * F_c(z,q) = (z;q)_inf * (1-z) * sum_N F_{c,N} z^N
# But (z;q)_inf already has (1-z). This means:
# (z;q)_inf * F_c(z,q) = (z;q)_inf * (1-z) * sum_N F_{c,N} z^N
# Let me NOT use this factorization and instead note:
# We already showed (zq;q)_inf * (1-z) = (z;q)_inf.
# And F_c(z,q) = (1-z) sum_N F_{c,N} z^N.
# So (zq;q)_inf * F_c(z,q) = (zq;q)_inf * (1-z) * sum_N F_{c,N} z^N
#                            = (z;q)_inf * sum_N F_{c,N} z^N.
# That's what we used. Good.

print("\n\nKey structural insight:")
print("Q_1 = (1-q)*F_{c,1} - 1")
print("Q_1 + 1 = (1-q)*F_{c,1}")
print("So F_{c,1} = (Q_1 + 1)/(1-q)")
print("This means F_{c,1}(q) = sum_{k>=0} q^k * (Q_1 evaluated cumulatively)")
print("Since Q_1 has nonneg coeffs, F_{c,1} does too (trivially).")
print("The interesting direction is: does positivity of Q_1 follow from structure of F_{c,1}?")
print("F_{c,1}(q) has coefficients that stabilize: the asymptotic coefficient = B+1")
print("where B = Q_1(1). And (1-q)*F_{c,1} = Q_1 + 1 shows the 'diff' is nonneg iff")
print("F_{c,1} coefficients are weakly increasing, which they ARE.")
