"""
Seed 3 v3: Transfer matrix computation of F_{c,N}(q) and Q_{n,c}(q).

Key idea: A cylindric partition of profile c = (c0,c1,c2) with max entry <= N
can be viewed as an infinite sequence of "column states" that eventually
become all-zero. Each column j contributes (lam^0_j, lam^1_j, lam^2_j) to
the weight.

The transition from column j to j+1 is constrained by:
1. Each partition is weakly decreasing: lam^i_{j+1} <= lam^i_j
2. Interlacing: lam^0_j >= lam^1_{j+c1}, lam^1_j >= lam^2_{j+c2}, lam^2_j >= lam^0_{j+c0}

For c = (1,1,0): c0=1, c1=1, c2=0
  lam^0_j >= lam^1_{j+1}  (shift by c1=1)
  lam^1_j >= lam^2_j       (shift by c2=0)
  lam^2_j >= lam^0_{j+1}  (shift by c0=1)

So: lam^1_j >= lam^2_j >= lam^0_{j+1} >= lam^1_{j+2}
and: lam^0_j >= lam^1_{j+1} >= lam^2_{j+1} >= lam^0_{j+2}

The state at column j is (a,b,c) = (lam^0_j, lam^1_j, lam^2_j).
All values in {0,...,N}. Within a column: b >= c (from c2=0).
Between columns: a_j >= b_{j+1} (from c1=1 shifted), 
                 c_j >= a_{j+1} (from c0=1 shifted).
And partition decreasing: a_{j+1} <= a_j, b_{j+1} <= b_j, c_{j+1} <= c_j.

BUT WAIT — the interlacing constraints cross columns, and the shift means
we need to track state across multiple columns. Specifically:

For c1=1: lam^0_j >= lam^1_{j+1}, so the constraint involves column j and j+1.
For c0=1: lam^2_j >= lam^0_{j+1}, constraint between columns j and j+1.  
For c2=0: lam^1_j >= lam^2_j, constraint within column j.

So the transfer matrix connects state (a,b,c) at column j to state (a',b',c')
at column j+1 with constraints:
- a >= b' (from lam^0_j >= lam^1_{j+1}, using c1=1)
- c >= a' (from lam^2_j >= lam^0_{j+1}, using c0=1)
- b' >= c' (within-column at j+1, from c2=0)
- a' <= a, b' <= b, c' <= c (partition decreasing)

Weight of column j: q^{a+b+c}.

This is a finite-state transfer matrix! States are (a,b,c) with 
0 <= a <= N, 0 <= b <= N, 0 <= c <= N, and b >= c (within-column constraint).

Actually wait, let me re-derive. For general profile c = (c0,c1,c2):
lam^0_j >= lam^1_{j+c1}
lam^1_j >= lam^2_{j+c2}
lam^2_j >= lam^0_{j+c0}

For the transfer matrix, the "state" at column j needs to remember enough
past columns to evaluate all constraints. The constraints involve shifts
up to max(c0,c1,c2). So we need a sliding window of max(c_i) columns.

For c=(1,1,0): max shift = 1, so we need window of 1 (current column
constrains next column).

Let me implement this for c = (1,1,0) first, then generalize.

F_{c,N}(q) = sum over all valid sequences of states (s_1, s_2, ..., s_L, 0, 0, ...)
           = sum_L sum_{s_1,...,s_L} T(init, s_1) T(s_1, s_2) ... T(s_{L-1}, s_L) T(s_L, 0)
           
But there's a subtlety: the INITIAL column also has constraints. Actually,
the cylinder has no "beginning" — the sequence of columns forms an infinite
path where s_1 is the largest state and the path goes to the zero state.

There's no cylindric (wraparound) constraint in the column direction —
the cylindric condition is in the k=3 "layers" direction. The columns
go from 1 to infinity, each column being a weakly smaller state.

Let me write the transfer matrix properly.

For F_{c,N}(q) where c=(1,1,0), N=1:
States: (a,b,c) with 0<=a<=1, 0<=b<=1, 0<=c<=1, b>=c.
Valid states: (0,0,0), (1,0,0), (1,1,0), (1,1,1), (0,0,0) is the absorbing state.
Wait, also (0,0,0) has b>=c satisfied. And (1,0,0) has b=0>=c=0.
Actually we need b >= c from the c2=0 constraint (lam^1_j >= lam^2_j).
So: (a,b,c) with a in {0,1}, b in {0,1}, c in {0,1}, b >= c.
States: (0,0,0), (1,0,0), (1,1,0), (1,1,1), (0,0,0) already listed.
Also: (0,1,0), (0,1,1) — wait, do we need a>=b? No, the within-column
constraint for c=(1,1,0) is only b>=c (from c2=0: lam^1_j >= lam^2_j).
There's no within-column constraint relating a and b for this profile.

Hmm, but lam^0_j >= lam^1_{j+1} relates adjacent columns, not same column.
So within column j, the only "within-column" constraint is from c_i = 0:
- c2=0 gives lam^1_j >= lam^2_{j+0} = lam^2_j.

What about a vs c? No within-column constraint.

So states for N=1: all (a,b,c) with a,b,c in {0,1} and b>=c.
That's: (0,0,0), (1,0,0), (0,1,0), (1,1,0), (0,1,1), (1,1,1), (1,0,0) already, plus we're missing some.
Let me list: a in {0,1}, b in {0,1}, c in {0,1}, b >= c:
b=0,c=0: (0,0,0), (1,0,0)
b=1,c=0: (0,1,0), (1,1,0)
b=1,c=1: (0,1,1), (1,1,1)
Total: 6 states.

Transition (a,b,c) -> (a',b',c'):
1. a >= b' (lam^0_j >= lam^1_{j+1})
2. c >= a' (lam^2_j >= lam^0_{j+1})
3. b' >= c' (within column j+1)
4. a' <= a, b' <= b, c' <= c (decreasing)

F_{c,N}(q) = sum over all valid infinite paths starting from any state,
each column contributing q^{a+b+c}.

The GF is: sum_{s} q^{w(s)} (I - T)^{-1} ... 

Actually, let me think of it as: F_{c,N}(q) counts all valid paths 
(s_1, s_2, s_3, ...) where s_j are states and s_j = (0,0,0) for all
sufficiently large j. The weight is q^{sum w(s_j)}.

The start state s_1 can be anything (no constraint from a hypothetical s_0).
Wait, actually the constraint from the "previous" column (j=0, which doesn't exist)
is that s_1 is unconstrained except that it must satisfy within-column.

But there IS a constraint: lam^0_0 doesn't exist... Actually, partitions
start at index 1. So s_1 = (lam^0_1, lam^1_1, lam^2_1) is the first column.
The interlacing lam^0_j >= lam^1_{j+c1} for j=0 doesn't apply since j starts at 1.
So the first column is only constrained by the within-column constraint and
that parts <= N.

Hmm wait, I need to be more careful. Let me re-index. Partitions have parts
lam^i_1 >= lam^i_2 >= ... >= 0 with lam^i_1 <= N. The interlacing:
lam^0_j >= lam^1_{j+c1} for all j >= 1.

This means for j=1: lam^0_1 >= lam^1_{1+c1}. For c1=1: lam^0_1 >= lam^1_2.
For j=2: lam^0_2 >= lam^1_3.
etc.

So the transfer between column j and column j+1 needs:
lam^0_j >= lam^1_{j+1}  (from c1=1, j shifts by 1)
lam^2_j >= lam^0_{j+1}  (from c0=1, j shifts by 1)
No constraint involving j+2 or beyond... good.

BUT ALSO: lam^1_j >= lam^2_j (from c2=0, no shift).

So for the transfer matrix:
State s_j = (a_j, b_j, c_j) = (lam^0_j, lam^1_j, lam^2_j).
Within-column: b_j >= c_j.
Between columns j and j+1:
- a_j >= b_{j+1}  (from c1=1)
- c_j >= a_{j+1}  (from c0=1)
- a_{j+1} <= a_j   (lam^0 decreasing)
- b_{j+1} <= b_j   (lam^1 decreasing)
- c_{j+1} <= c_j   (lam^2 decreasing)

And: b_{j+1} >= c_{j+1} (within column j+1).

The GF F_{c,N}(q) = sum over all valid paths with weight prod_j q^{a_j+b_j+c_j}.

This is: (sum over starting states s_1 with within-column constraint) *
         q^{w(s_1)} * sum_{s_2} T(s_1,s_2) q^{w(s_2)} * ...
       = sum_s1 q^{w(s1)} * sum_s2 T(s1,s2) q^{w(s2)} * ... (geometric sum)

Let T be the transfer matrix: T[s, s'] = 1 if transition s -> s' is valid.
Weight matrix W: diagonal with W[s,s] = q^{w(s)}.

Then F_{c,N}(q) = sum_{s: valid} sum_{L>=1} [W T]^{L-1} [s, 0] * q^{w(s)}
Wait, let me be more careful. Actually the path can be of arbitrary length
(partitions can have any number of nonzero parts). The "zero" state (0,0,0) 
is absorbing. Once we reach (0,0,0), all subsequent columns are also (0,0,0)
and contribute nothing to the weight.

So: F_{c,N}(q) = 1 + sum_{L>=1} sum_{s1,...,sL not all 0} q^{sum w(si)}
                  where each transition si -> si+1 is valid and sL -> 0 is valid.

Let states be indexed, let M be the weighted transfer matrix:
M[s, s'] = q^{w(s')} if transition s -> s' is valid and s' != 0.

Then the generating function from state s is:
G(s) = 1 + sum_{L>=1} sum_{s1,...,sL} M[s,s1] M[s1,s2] ... M[sL-1,sL]
     * (does sL transition to 0?)

Hmm, this is getting notationally messy. Let me just think of it as:

Let A be the matrix with A[s,s'] = q^{w(s')} if transition s -> s' valid, s' nonzero.
(Remove the zero state from A.)

Then F_{c,N}(q) = 1 + v^T (I - A)^{-1} w

where v[s] = q^{w(s)} if s is reachable from "infinity" (i.e., any valid start state)
and w[s] = 1 for all s (or something like that).

Actually, simpler: 

F_{c,N}(q) = 1 + sum_{s nonzero, valid start} q^{w(s)} * G(s)

where G(s) = 1 + sum_{s' nonzero, valid transition s->s'} q^{w(s')} G(s')

So G = 1 + A G, giving G = (I-A)^{-1} 1.

And F_{c,N}(q) = 1 + u^T (I-A)^{-1} 1

where u[s] = q^{w(s)} for all valid starting states s (nonzero).

Wait, but u already includes the first column weight, and (I-A)^{-1} 1 gives
the sum of all subsequent path weights. Let me think again.

Path of length L >= 1: (s_1, s_2, ..., s_L) where all s_i nonzero, all transitions valid,
and s_L -> 0 is a valid transition. Weight = q^{sum w(s_i)}.

The requirement for s_L -> 0 to be valid:
- a_L >= b' = 0 (always true)
- c_L >= a' = 0 (always true)  
- 0 >= 0 (within-column of 0)
- 0 <= a_L, 0 <= b_L, 0 <= c_L (always true)

So s_L -> 0 is always a valid transition. Good.

The requirement for s_1 to be a valid start: s_1 must satisfy within-column constraint
and parts <= N. There's no constraint from a "previous" column (since there is none).
Actually... does s_1 need ANY column-to-column constraint? The interlacing
lam^0_j >= lam^1_{j+c1} for j >= 1: this constrains column 1 and column 1+c1.
For c1=1, it constrains column 1 and column 2. So the constraint between
s_1 and s_2 will be handled by the transfer matrix. Good.

But what about lam^i_0? lam^i_0 doesn't exist (parts are 1-indexed).
Actually... hmm. Partitions are defined for j >= 1. The interlacing:
lam^0_j >= lam^1_{j+c1} for ALL j >= 1.

The question is: are there constraints that s_1 must satisfy that come from
the interlacing, beyond within-column? I think not, because the interlacing
only relates lam^i_j to lam^{i'}_{j+shift}, and the smallest j is 1.
For j=1 and shift c1=1: lam^0_1 >= lam^1_2, which is a constraint between
columns 1 and 2, handled by the transfer matrix.

So s_1 is unconstrained except: within-column (b_1 >= c_1) and parts <= N.

Therefore:
F_{c,N}(q) = 1 + sum_{L>=1} sum_{s1,...,sL nonzero} q^{sum w(si)} * prod T(si, si+1)
           = 1 + sum_{s1 nonzero} q^{w(s1)} sum_{L>=1} sum_{s2,...,sL} ...
           = 1 + sum_{s1 nonzero} q^{w(s1)} [1 + sum_{s2 nonzero, T(s1,s2)=1} q^{w(s2)} [1 + ...]]

This is: F_{c,N}(q) = 1 + u^T G where G = (I - A)^{-1} * 1_vec

Here:
- States: nonzero states s = (a,b,c) with 0<=a<=N, 0<=b<=N, 0<=c<=N, b>=c, not all zero.
- A[s,s'] = q^{w(s')} if transition s -> s' is valid (s' nonzero).
- u[s] = q^{w(s)} for all nonzero valid start states.
- 1_vec = vector of all 1s.
- G = (I-A)^{-1} 1_vec.

This gives F_{c,N}(q) = 1 + u^T (I-A)^{-1} 1_vec.

For numerical computation, I'll work with polynomials in q truncated to high degree.

Let me implement this. For N=1, c=(1,1,0): states are 5 nonzero states.
(I-A) is 5x5. This is very tractable.

For N=2: number of nonzero states (a,b,c) with b>=c, 0<=a,b,c<=2:
b=0,c=0: a=1,2 -> 2 states
b=1,c=0: a=0,1,2 -> 3 states
b=1,c=1: a=0,1,2 -> 3 states
b=2,c=0: a=0,1,2 -> 3 states
b=2,c=1: a=0,1,2 -> 3 states
b=2,c=2: a=0,1,2 -> 3 states
Total: 2+3+3+3+3+3 = 17 nonzero states. Still very tractable.

For general N: about (N+1)^2 * (N+2)/2 states, which is O(N^3).
For N up to 5-6 this is fine.
"""

from fractions import Fraction
from collections import defaultdict
from math import gcd


def get_states(N, c):
    """
    Get all valid nonzero states for profile c with max entry <= N.
    A state is (a, b, c_val) where a,b,c_val in {0,...,N}.
    Within-column constraints depend on which c_i are 0.
    
    For c = (c0, c1, c2):
    c2 = 0 => lam^1_j >= lam^2_j => b >= c_val
    c1 = 0 => lam^0_j >= lam^1_j => a >= b
    c0 = 0 => lam^2_j >= lam^0_j => c_val >= a
    """
    c0, c1, c2 = c
    states = []
    for a in range(N + 1):
        for b in range(N + 1):
            for cv in range(N + 1):
                if a == 0 and b == 0 and cv == 0:
                    continue
                # Within-column constraints from c_i = 0
                ok = True
                if c2 == 0 and b < cv:
                    ok = False
                if c1 == 0 and a < b:
                    ok = False
                if c0 == 0 and cv < a:
                    ok = False
                if ok:
                    states.append((a, b, cv))
    return states


def is_valid_transition(s, sp, c, N):
    """
    Check if transition from state s = (a,b,cv) at column j to 
    state sp = (a',b',cv') at column j+1 is valid.
    
    For c = (c0, c1, c2):
    Between-column constraints (from shifts of 1):
    c1 >= 1: lam^0_j >= lam^1_{j+c1}  
    c2 >= 1: lam^1_j >= lam^2_{j+c2}
    c0 >= 1: lam^2_j >= lam^0_{j+c0}
    
    For c1=1: a >= b'  (column j's lam^0 >= column j+1's lam^1)
    For c0=1: cv >= a' (column j's lam^2 >= column j+1's lam^0)
    
    BUT if c1=2, then lam^0_j >= lam^1_{j+2}, which means column j constrains
    column j+2, not j+1. This requires a larger window.
    
    For simplicity, first handle the case where all c_i in {0,1}.
    """
    a, b, cv = s
    ap, bp, cvp = sp
    c0, c1, c2 = c
    
    # Partition decreasing
    if ap > a or bp > b or cvp > cv:
        return False
    
    # Within-column constraint for sp (already ensured by state validity)
    
    # Between-column constraints for shift = 1 only
    # For a general c_i, the constraint lam^{i-1}_j >= lam^i_{j+c_i} means:
    # If c_i = 1: column j constrains column j+1
    # If c_i = 2: column j constrains column j+2 (need wider window)
    # If c_i = 0: same-column constraint (handled in state)
    
    # Only handle shifts of 1 here
    if c1 == 1:
        # lam^0_j >= lam^1_{j+1}
        if a < bp:
            return False
    if c2 == 1:
        # lam^1_j >= lam^2_{j+1}
        if b < cvp:
            return False
    if c0 == 1:
        # lam^2_j >= lam^0_{j+1}
        if cv < ap:
            return False
    
    return True


def compute_F_transfer(c, N, q_max):
    """
    Compute F_{c,N}(q) using transfer matrix, truncated to q^q_max.
    
    Only works for profiles where all c_i in {0, 1}.
    For larger c_i, need wider window — TODO.
    
    Returns polynomial as dict {degree: coefficient}.
    """
    c0, c1, c2 = c
    
    # Check if any c_i > 1 — if so, need wider window
    if any(ci > 1 for ci in c):
        raise NotImplementedError(f"Profile {c} has c_i > 1, need wider window")
    
    states = get_states(N, c)
    n_states = len(states)
    state_idx = {s: i for i, s in enumerate(states)}
    
    # Weight of a state
    def weight(s):
        return sum(s)
    
    # Build transfer matrix A as list of (i, j, q_power) triples
    # A[i,j] = q^{w(states[j])} if transition states[i] -> states[j] valid
    transitions = []
    for i, s in enumerate(states):
        for j, sp in enumerate(states):
            if is_valid_transition(s, sp, c, N):
                transitions.append((i, j, weight(sp)))
    
    # Compute G = (I - A)^{-1} * 1 using iterative power series
    # G = 1 + A*G => G = sum_{k=0}^inf A^k * 1
    # Since A has entries q^{w} with w >= 1, this converges in q-adic sense.
    # Truncate at q^q_max.
    
    # G[i] is a polynomial in q (as dict)
    G = [{0: 1} for _ in range(n_states)]  # Start with 1
    
    # Iteratively add A^k * 1 terms
    # current = A^{k-1} * 1, multiply by A to get A^k * 1
    current = [{0: 1} for _ in range(n_states)]
    
    for iteration in range(q_max + 1):
        # Multiply current by A
        new_current = [defaultdict(int) for _ in range(n_states)]
        any_nonzero = False
        for i, j, qp in transitions:
            for deg, coeff in current[j].items():
                new_deg = deg + qp
                if new_deg <= q_max:
                    new_current[i][new_deg] += coeff
                    any_nonzero = True
        
        if not any_nonzero:
            break
        
        current = [dict(d) for d in new_current]
        
        # Add to G
        for i in range(n_states):
            for deg, coeff in current[i].items():
                G[i][deg] = G[i].get(deg, 0) + coeff
    
    # F_{c,N}(q) = 1 + u^T G where u[i] = q^{w(states[i])}
    F = {0: 1}  # Start with 1
    for i, s in enumerate(states):
        w = weight(s)
        for deg, coeff in G[i].items():
            new_deg = deg + w
            if new_deg <= q_max:
                F[new_deg] = F.get(new_deg, 0) + coeff
    
    return {k: v for k, v in F.items() if v != 0}


def compute_Q(c, n_target, q_max):
    """
    Compute Q_{n,c}(q) using:
    Q_n = sum_{j=0}^n (-1)^j q^{j(j-1)/2} * (q;q)_n/(q;q)_j * F_{c,n-j}(q)
    
    (Using the corrected formula from seed 2's derivation with (z;q)_inf.)
    """
    d = sum(c)
    ell = gcd(d, 3)
    
    # Compute F_{c,m} for m = 0, ..., n_target
    F_cm = {}
    for m in range(n_target + 1):
        F_cm[m] = compute_F_transfer(c, m, q_max)
        f1 = sum(F_cm[m].values())
        print(f"  F_{{c,{m}}}(1) = {f1}")
    
    # Compute Q_n
    Q = defaultdict(int)
    for j in range(n_target + 1):
        sign = (-1) ** j
        shift = j * (j - 1) // 2
        
        # (q;q)_n / (q;q)_j = prod_{i=j+1}^n (1-q^i)
        ratio = {0: 1}
        for i in range(j + 1, n_target + 1):
            new_ratio = {}
            for deg, coeff in ratio.items():
                if deg <= q_max:
                    new_ratio[deg] = new_ratio.get(deg, 0) + coeff
                if deg + i <= q_max:
                    new_ratio[deg + i] = new_ratio.get(deg + i, 0) - coeff
            ratio = {k: v for k, v in new_ratio.items() if v != 0}
        
        # Multiply ratio * F_{c,n-j}
        Fm = F_cm[n_target - j]
        term = {}
        for d1, c1 in ratio.items():
            for d2, c2 in Fm.items():
                d_total = d1 + d2
                if d_total <= q_max:
                    term[d_total] = term.get(d_total, 0) + c1 * c2
        
        # Apply sign and shift
        for deg, coeff in term.items():
            new_deg = deg + shift
            if new_deg <= q_max:
                Q[new_deg] += sign * coeff
    
    return {k: v for k, v in Q.items() if v != 0}


def poly_to_list(poly):
    if not poly:
        return [0]
    mx = max(poly.keys())
    return [poly.get(i, 0) for i in range(mx + 1)]


def main():
    print("=" * 60)
    print("Transfer matrix computation of Q_{n,c}(q)")
    print("=" * 60)
    
    # Start with c = (1,1,0) which has all c_i in {0,1}
    q_max = 80
    
    for c in [(1, 1, 0), (1, 0, 1), (0, 1, 1)]:
        d = sum(c)
        ell = gcd(d, 3)
        expected_base = (d+1)*(d+2)//6 - 1
        
        print(f"\n{'='*50}")
        print(f"Profile c = {c}, d = {d}, ell = {ell}")
        print(f"Expected Q_{{n,c}}(1) = {expected_base}^n")
        
        for n in range(1, 5):
            print(f"\n  Computing Q_{{{n},c}}(q):")
            Q = compute_Q(c, n, q_max)
            coeffs = poly_to_list(Q)
            while coeffs and coeffs[-1] == 0:
                coeffs.pop()
            if not coeffs:
                coeffs = [0]
            
            all_pos = all(x >= 0 for x in coeffs)
            eval_at_1 = sum(coeffs)
            
            if len(coeffs) <= 30:
                print(f"    Q = {coeffs}")
            else:
                print(f"    Q = {coeffs[:15]}... (total {len(coeffs)} terms)")
            print(f"    Q(1) = {eval_at_1} (expected {expected_base**n}), "
                  f"nonneg: {all_pos}, deg = {len(coeffs)-1}")


if __name__ == "__main__":
    main()
