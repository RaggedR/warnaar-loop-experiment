"""
Seed 8, Layer 2: Test whether Q_n is a (partial) trace of A^n for some q-weighted matrix A.

If Q_n(1) = base^n and Q_0 = 1, the simplest model would be:
  Q_n(q) = sum_{paths of length n in a graph G, starting and ending at vertex 0} q^{weight(path)}

where G has base = 11 vertices (for d=7) and edges weighted by q-powers.

Alternatively, Q_n could be a generalized trace: Q_n = tr(A(q)^n) for a matrix A(q).

If A is base x base with Q_0 = tr(I) = base, that doesn't match Q_0 = 1.
So either A is not square, or we use a row vector * A^n * column vector formulation.

Model: Q_n = e_1^T A^n e_1 where e_1 = (1,0,...,0)^T and A is base x base.
Then Q_0 = e_1^T e_1 = 1, Q_1 = A_{11}, Q_n = (A^n)_{11}.

For d=4, base=4, we need a 4x4 matrix A(q) with:
  (A^0)_{11} = 1
  (A^1)_{11} = Q_1 = 2q + q^2 + q^3
  (A^2)_{11} = Q_2 
  (A^3)_{11} = Q_3
  
The matrix A must have:
  A_{11} = Q_1 (the (1,1) entry)
  sum_j A_{1j} A_{j1} = Q_2 for j=1,...,4
  
So A_{11}^2 + sum_{j=2}^4 A_{1j} A_{j1} = Q_2.
A_{11}^2 = Q_1^2 = (2q+q^2+q^3)^2 = 4q^2+4q^3+5q^4+2q^5+2q^6+q^6 (computed below).

Let's check Q_2 - Q_1^2 and see if it can be written as sum of products A_{1j}*A_{j1}
with nonneg polynomial entries.
"""

MAX_Q = 80

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_sub(a, b):
    return poly_add(a, {k: -v for k, v in b.items()})

def poly_mul(a, b, max_deg=MAX_Q):
    result = {}
    for i, ai in a.items():
        if ai == 0 or i > max_deg: continue
        for j, bj in b.items():
            if bj == 0 or i+j > max_deg: continue
            result[i+j] = result.get(i+j, 0) + ai * bj
    return {k: v for k, v in result.items() if v != 0}

def poly_str(p, max_terms=25):
    if not p: return "0"
    parts = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0: continue
        if e == 0: parts.append(str(c))
        elif c == 1: parts.append(f"q^{e}")
        elif c == -1: parts.append(f"-q^{e}")
        else: parts.append(f"{c}q^{e}")
    if len(parts) > max_terms:
        return " + ".join(parts[:max_terms]).replace("+ -", "- ") + f" + ..."
    return " + ".join(parts).replace("+ -", "- ") if parts else "0"


def main():
    # d=4 data
    Q = {}
    Q[0] = {0: 1}
    Q[1] = {1: 2, 2: 1, 3: 1}
    Q[2] = {3: 1, 4: 3, 5: 2, 6: 3, 7: 2, 8: 2, 9: 1, 10: 1, 12: 1}
    Q[3] = {7: 2, 8: 2, 9: 5, 10: 4, 11: 6, 12: 6, 13: 6, 14: 5, 15: 6, 16: 4, 17: 4, 18: 3, 19: 3, 20: 2, 21: 2, 22: 1, 23: 1, 24: 1, 27: 1}
    
    base = 4
    
    print("d=4, base=4")
    print("="*60)
    
    Q1_sq = poly_mul(Q[1], Q[1])
    diff = poly_sub(Q[2], Q1_sq)
    print(f"Q_1^2 = {poly_str(Q1_sq)}")
    print(f"Q_2 = {poly_str(Q[2])}")
    print(f"Q_2 - Q_1^2 = {poly_str(diff)}")
    
    # For a 4x4 matrix model, Q_2 - Q_1^2 = sum_{j=2}^4 A_{1j}*A_{j1}.
    # This sum must equal diff. For diff to be expressible as such a sum 
    # with nonneg polynomial entries, diff itself must be... well, it doesn't
    # need to be nonneg (because A_{1j} and A_{j1} are separate terms).
    # But each A_{1j}*A_{j1} must be nonneg (product of nonneg polys is nonneg).
    # So diff = sum of nonneg terms, i.e., diff must be nonneg!
    
    neg = {k: v for k, v in diff.items() if v < 0}
    print(f"Q_2 - Q_1^2 nonneg: {len(neg) == 0}")
    if neg:
        print(f"  Negative terms: {sorted(neg.items())}")
        print(f"  => Standard matrix model FAILS for d=4")
    
    # What if A has complex (polynomial) entries but A_{ij}*A_{ji} nonneg?
    # A_{ij} = f_ij(q), A_{ji} = g_ji(q), and f*g nonneg.
    # This allows f, g to have mixed signs as long as f*g >= 0.
    # For example, f = -q, g = -q gives f*g = q^2 >= 0.
    
    # But the stronger statement would be: Q_n = sum_paths q^{wt(path)} 
    # where the sum is over SIGNED paths. The positivity would then be 
    # a cancellation phenomenon (negative paths cancel).
    # This is just moving the problem.
    
    # Alternative model: Q_n = v^T M^n v where v = (1, 0, ..., 0)^T
    # and M is a symmetric matrix (so M_{ij} = M_{ji}).
    # Then Q_2 - Q_1^2 = sum_{j>=2} M_{1j}^2.
    # Since M_{1j}^2 is always a product of a poly with itself,
    # it's nonneg (square of a polynomial in q).
    # So we need diff = sum of squares of polynomials.
    
    print(f"\n\nQ_2 - Q_1^2 = {poly_str(diff)}")
    print(f"Can this be written as a sum of squares of polynomials?")
    
    # diff = -4q^2 - 3q^3 - 2q^4 + 2q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12
    # This has NEGATIVE coefficients, so it CANNOT be a sum of squares of polynomials
    # (sum of squares always has nonneg coefficients).
    
    print(f"NO: diff has negative coefficients => no symmetric matrix model.")
    
    # So Q_n is NOT (1,1) entry of M^n for any symmetric q-polynomial matrix M.
    # And it's NOT (1,1) entry of M^n for any nonneg q-polynomial matrix M.
    
    # What about a general (non-symmetric, possibly non-nonneg) matrix?
    # Then the constraint is: Q_2 = sum_j M_{1j} M_{j1}, Q_3 = sum_{j,k} M_{1j} M_{jk} M_{k1}.
    # With base=4, we have 8 unknowns (M_{1j}, M_{j1} for j=2,3,4) plus M_{11} = Q_1.
    # Q_2 gives 1 polynomial equation, Q_3 gives 1 more. With 8 unknowns and 2 equations,
    # the system is underdetermined.
    
    # But we also need M to be "well-defined" in the sense that Q_n >= 0 for all n.
    # This is a very strong condition.
    
    # Let me try a DIFFERENT model: quasi-particle / state machine.
    # Q_n counts "accepted paths" of length n in a q-weighted automaton.
    # The automaton has states {s_0, s_1, ..., s_{base-1}}, starts and ends at s_0.
    # Transition from s_i to s_j adds weight w_{ij} to the total.
    # Q_n = sum over accepted paths of q^{total_weight}.
    
    # For this to work with Q_0 = 1 (empty path, staying at s_0):
    # The automaton has a single accept state s_0.
    # Q_1 = sum_j w_{0j} * delta_{j,0} ... no, Q_1 should count paths of length 1 
    # starting and ending at s_0. That's just w_{00}. But Q_1 has 4 terms (sum=4),
    # so we need MORE STRUCTURE.
    
    # Better model: Q_n = sum_{all states j} (M^n)_{start,j} * accept_weight(j).
    # Or: Q_n counts paths of length n starting at s_0, ending at ANY state.
    # Then Q_0 = 1 (start at s_0, accept immediately) and 
    # Q_1 = sum_j M_{0,j} = sum of all outgoing edge weights from s_0.
    
    # For d=4: Q_1 = 2q + q^2 + q^3. Sum = 4 = base.
    # So there are 4 outgoing edges from s_0 with weights q, q, q^2, q^3.
    # Or equivalently, 4 target states with those edge weights.
    
    # For Q_2 = sum_{j,k} M_{0j} * M_{jk}: this counts 2-step paths from s_0.
    # Q_2(1) = 16 = 4^2, consistent with 4 choices at each step.
    
    # Now, the key question: does a weighted graph exist such that 
    # (M^n)_0 = Q_n for all n, with all edge weights being nonneg q-polynomials?
    
    # If so, Q_n >= 0 follows immediately (sum of nonneg terms).
    
    # For d=4, base=4: we need a 4x4 matrix M(q) with:
    # Row sums: each row sums to Q_1(1) = 4 at q=1? Not necessarily.
    # (0,0) entry: M_{00} = some nonneg poly.
    # We need: Q_1 = sum_j M_{0j}, Q_2 = sum_{j,k} M_{0j}M_{jk}, etc.
    
    # This is asking: is there a Markov-like q-chain with Q_n as the 
    # n-step "partition function"?
    
    # Actually, Q_n = e_0^T M^n mathbb{1} where mathbb{1} = (1,1,...,1)^T.
    # Q_0 = e_0^T 1 = 1 (just the start state contributes).
    # Q_1 = e_0^T M 1 = sum_j M_{0j} = Q_1. Good.
    # Q_n(1) = e_0^T M(1)^n 1 = base^n requires M(1) to have the 
    # property that e_0^T M(1)^n 1 = base^n. This means M(1) is a 
    # base x base matrix where 1 is an eigenvector of M(1) with 
    # eigenvalue base, and e_0^T is in the corresponding left eigenspace.
    # Simplest: M(1) is a matrix where each row sums to base.
    # Then M(1) * 1 = base * 1, so M(1)^n * 1 = base^n * 1, and 
    # e_0^T M(1)^n 1 = base^n. Perfect!
    
    # So we need: a base x base matrix M(q) with nonneg polynomial entries,
    # where each row sums to a polynomial with evaluation base at q=1,
    # and e_0^T M(q)^n 1 = Q_n(q).
    
    # For d=4, base=4: M is 4x4.
    # Row sums at q=1 must all be 4.
    # e_0^T M^n 1 = Q_n.
    
    # This is 16 unknowns (M_{ij}) with constraints:
    # - sum_j M_{ij}(1) = 4 for each i (4 constraints)
    # - e_0^T M^n 1 = Q_n for n=1,2,3,4 (4 constraints)
    # Total: 8 constraints, 16 unknowns (each unknown is a polynomial).
    
    # Lots of freedom! Let me try the simplest model: a CIRCULANT matrix.
    # M = circ(a, b, c, d) where M_{ij} = f_{(j-i) mod 4}.
    # Then row sums = a + b + c + d = Q_1 = 2q + q^2 + q^3.
    # And the eigenvalues of M are lambda_k = a + b*omega^k + c*omega^{2k} + d*omega^{3k}
    # where omega = exp(2pi*i/4) = i.
    
    # For a circulant: e_0^T M^n 1 = (1/4) sum_k lambda_k^n * 4 = sum_k lambda_k^n.
    # Wait, for circulant M, the eigenvectors are v_k = (1, omega^k, omega^{2k}, omega^{3k})/2.
    # e_0^T = (1,0,0,0), so e_0^T v_k = 1/2.
    # 1 = (1,1,1,1)^T, so v_k^T 1 = (1 + omega^k + omega^{2k} + omega^{3k})/2.
    # For k=0: v_0^T 1 = 4/2 = 2. For k != 0: v_k^T 1 = 0.
    # So e_0^T M^n 1 = sum_k (e_0^T v_k) * lambda_k^n * (v_k^T 1)
    #               = (1/2) * lambda_0^n * 2 = lambda_0^n.
    # And lambda_0 = a + b + c + d = Q_1.
    # So e_0^T M^n 1 = Q_1^n. But Q_n != Q_1^n for n >= 2!
    # Circulant model fails.
    
    # So M must NOT be circulant. The "asymmetry" between states is essential.
    
    # Let me try a BLOCK structure. Group the 4 states as {ground} + {3 excited}.
    # State 0 is the ground state (contributes to the start/end).
    # States 1,2,3 are "excited" states.
    
    # For Q_1 = 2q + q^2 + q^3 (sum=4):
    # M_{00} + M_{01} + M_{02} + M_{03} = Q_1 = 2q + q^2 + q^3.
    
    # For Q_2 - Q_1*Q_1 = diff (computed above):
    # Q_2 = Q_1 * M_{00} + Q_1 * M_{01} + ... wait no.
    # Q_2 = sum_j (M^2)_{0j} = sum_j sum_k M_{0k} M_{kj}
    #      = sum_j M_{00}*M_{0j} + sum_{k>=1} M_{0k}*M_{kj}
    
    # This is getting complicated. Let me just check: does Q_n have the
    # structure expected from an nonneg matrix model?
    
    # The key necessary condition is: if Q_n = e_0^T M^n 1 with nonneg M,
    # then Q_n must be coefficientwise dominated by Q_1^n (because each 
    # path of length n contributes q^{sum of edge weights}, and the maximum
    # weight path has weight at most n * max_edge_weight).
    
    # Check: is Q_n <= Q_1^n coefficientwise?
    print("\n\nChecking Q_n vs Q_1^n coefficientwise:")
    Q1_n = {0: 1}
    for n in range(1, 5):
        Q1_n = poly_mul(Q1_n, Q[1])
        if n in Q:
            diff = poly_sub(Q1_n, Q[n])
            neg = {k: v for k, v in diff.items() if v < 0}
            print(f"  Q_1^{n} - Q_{n}: nonneg = {len(neg)==0}")
            if neg:
                print(f"    Negative terms: {sorted(neg.items())[:5]}")
            # Also check if Q_n <= Q_1^n
            diff2 = poly_sub(Q[n], Q1_n)
            neg2 = {k: v for k, v in diff2.items() if v < 0}
            print(f"  Q_{n} - Q_1^{n}: nonneg = {len(neg2)==0}")
    
    # Now for d=7
    print("\n\n" + "="*60)
    print("d=7, base=11")
    print("="*60)
    
    Q7 = {}
    Q7[0] = {0: 1}
    Q7[1] = {1: 2, 2: 3, 3: 2, 4: 2, 5: 1, 6: 1}
    
    # Q_n(1) = 11^n. Is an 11x11 nonneg matrix model plausible?
    # Q_1 has 6 distinct degrees, sum = 11.
    # If the "alphabet" has 11 letters with weights 
    # [1,1,2,2,2,3,3,4,4,5,6] (matching Q_1 coefficients as multiplicities),
    # then Q_n at q=1 would be 11^n. But Q_n(q) would be the q-multinomial...
    # Actually, if the letters have weights w_1,...,w_11 and Q_n = sum q^{sum of n weights},
    # then Q_n = (sum q^{w_i})^n = Q_1^n. But Q_n != Q_1^n!
    # So the "letters" at different positions must have DIFFERENT weights,
    # i.e., the weight of a letter depends on its position in the word.
    
    # This is EXACTLY what a weighted automaton provides: the weight of a 
    # transition depends on the current state, not just the letter.
    
    # For the matrix model to work with nonneg entries:
    # Each row of M(q) must have nonneg polynomial entries summing to 
    # some polynomial (not necessarily Q_1) whose evaluation at q=1 is base.
    
    # Can we CONSTRUCT such a matrix?
    # For d=4, base=4, the simplest attempt:
    # M = [[a, b, c, d], [e, f, g, h], [i, j, k, l], [m, n, o, p]]
    # with a+b+c+d = Q_1, e+f+g+h = some poly with eval 4, etc.
    # and (M^n)_0 * 1 = Q_n.
    
    # With 16 polynomial unknowns and polynomial equations, this is 
    # a polynomial system. Let me see if a 2x2 model works for d=2.
    
    print("\n\nd=2 matrix model (base=1, trivial)")
    print("Q_n = q^{n^2}, base = 1.")
    print("1x1 matrix: M = [q^1]. Then M^n = [q^n]. (M^n)_{00} = q^n.")
    print("But Q_n = q^{n^2}, not q^n. So 1x1 model FAILS.")
    print()
    print("This is expected: Q_n = q^{n^2} has SUPER-LINEAR growth of degree.")
    print("No fixed-size matrix model can produce degree growing as n^2.")
    print()
    print("CONCLUSION: Q_n CANNOT be (0,0)-entry of M^n for any fixed-size matrix M(q).")
    print("The degree of Q_n grows quadratically in n (deg = (d-1)n^2 + ...),")
    print("while (M^n)_{00} would have degree at most n * max_deg(M).")
    print("For d >= 4 with deg(M) = d-1: n*(d-1) vs (d-1)*n^2. Mismatch for n >= 2.")
    print()
    print("This RULES OUT the standard weighted automaton model.")
    print("Q_n is NOT a path-counting quantity in any fixed q-weighted graph.")
    print()
    print("The correct model must have n-DEPENDENT weights (the weight structure")
    print("changes at each step, like a time-inhomogeneous Markov chain).")


if __name__ == "__main__":
    main()
