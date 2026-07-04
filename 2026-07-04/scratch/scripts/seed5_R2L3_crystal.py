#!/usr/bin/env python3
"""Tingley-style colored crystal operators (colors mod d) on BOUNDED chains.

Chain A = (a^(1),...,a^(m)), a^(s) in S(c). Boxes (i,j,s): present iff a_i^(s) >= j.
Addable (component-partition validity): per s with (s==1 or a_i^(s-1) > a_i^(s)),
  box (i, a_i^(s)+1, s).   [bounded: s <= m only]
Removable: per s with a_i^(s) > a_i^(s+1) (a^(m+1)=0): box (i, a_i^(s), s).
Color(i,j,s) = (s - j + sgn*off_i) mod d, off_i = sum_{u<=i} c[u] (off_0 = c[0]?? --
  we use off_0 = 0, off_1 = c[1], off_2 = c[1]+c[2]; consistent since full loop = d).
t-order: T(i,j,s) = tdir * (d*i + 3*(j - s)).
Bracket rule: addable -> "(", removable -> ")", sorted by T increasing; cancel "()" pairs;
f_k adds leftmost surviving "("; e_k removes rightmost surviving ")".
We scan all 4 conventions (sgn, tdir) and test axioms exhaustively.
"""
import sys
from itertools import product
sys.setrecursionlimit(100000)

def in_S(a, c):
    return all(a[i] <= a[(i-1) % 3] + c[i] for i in range(3))

def states_upto(c, W):
    out = []
    for a0 in range(W+1):
        for a1 in range(W+1-a0):
            for a2 in range(W+1-a0-a1):
                a = (a0,a1,a2)
                if in_S(a, c):
                    out.append(a)
    return out

def geq(a, b): return all(a[i] >= b[i] for i in range(3))

def all_chains(c, m, W, require_bottom_nonzero=True):
    Svals = [a for a in states_upto(c, W)]
    if require_bottom_nonzero:
        bots = [a for a in Svals if sum(a) >= 1]
    else:
        bots = Svals
    result = []
    def extend(chain_rev, wt):
        if len(chain_rev) == m:
            result.append(tuple(reversed(chain_rev)))
            return
        top = chain_rev[-1]
        for nxt in Svals:
            sn = sum(nxt)
            if sn < sum(top) or wt + sn > W: continue
            if not geq(nxt, top): continue
            extend(chain_rev + [nxt], wt + sn)
    for bot in bots:
        if sum(bot)*m <= W:
            extend([bot], sum(bot))
    return result

def weight(A): return sum(sum(a) for a in A)

def offsets(c):
    return [0, c[1], c[1]+c[2]]

def boxes_add_remove(A, c, m, kappa, d, sgn, tdir):
    """Return bracket list [(T, type, (i,s))] for color kappa. type: 1='(' add, 0=')' rem."""
    off = offsets(c)
    br = []
    for i in range(3):
        for s in range(1, m+1):
            ais = A[s-1][i]
            prev = A[s-2][i] if s >= 2 else None
            nxt = A[s][i] if s <= m-1 else 0
            # addable: column s can grow by one: j = ais+1; need s==1 or a_i^(s-1) >= j i.e. prev > ais... prev >= ais+1
            if (s == 1) or (prev is not None and prev > ais):
                j = ais + 1
                col = (s - j + sgn*off[i]) % d
                if col == kappa:
                    T = tdir * (d*i + 3*(j - sgn*off[i] - s))
                    br.append((T, 1, (i, s)))
            # removable: a_i^(s) > a_i^(s+1), j = ais
            if ais > nxt:
                j = ais
                col = (s - j + sgn*off[i]) % d
                if col == kappa:
                    T = tdir * (d*i + 3*(j - sgn*off[i] - s))
                    br.append((T, 0, (i, s)))
    br.sort(key=lambda x: x[0])
    return br

def reduce_brackets(br):
    """Cancel '()' adjacent pairs: '(' = 1 then ')' = 0. Standard: stack '('; when ')' comes, cancel top '('.
    Surviving: some ')' at left then '(' at right.
    Returns (surviving_adds_list_in_order, surviving_rems_list_in_order)."""
    stack = []  # indices of surviving '('
    rems = []
    for idx, (T, typ, pos) in enumerate(br):
        if typ == 1:
            stack.append((T, pos))
        else:
            if stack:
                stack.pop()
            else:
                rems.append((T, pos))
    return stack, rems  # stack: surviving '(' in order; rems: surviving ')' in order

def apply_add(A, i, s):
    B = [list(a) for a in A]
    B[s-1][i] += 1
    return tuple(tuple(x) for x in B)

def apply_rem(A, i, s):
    B = [list(a) for a in A]
    B[s-1][i] -= 1
    return tuple(tuple(x) for x in B)

def f_op(A, c, m, kappa, d, sgn, tdir):
    br = boxes_add_remove(A, c, m, kappa, d, sgn, tdir)
    adds, rems = reduce_brackets(br)
    if not adds: return None
    T, (i, s) = adds[0]   # leftmost surviving '('
    return apply_add(A, i, s)

def e_op(A, c, m, kappa, d, sgn, tdir):
    br = boxes_add_remove(A, c, m, kappa, d, sgn, tdir)
    adds, rems = reduce_brackets(br)
    if not rems: return None
    T, (i, s) = rems[-1]  # rightmost surviving ')'
    return apply_rem(A, i, s)

def phi_eps(A, c, m, kappa, d, sgn, tdir):
    br = boxes_add_remove(A, c, m, kappa, d, sgn, tdir)
    adds, rems = reduce_brackets(br)
    return len(adds), len(rems)

def valid_chain(A, c, m):
    for s in range(m):
        if not in_S(A[s], c): return False
        if s+1 < m and not geq(A[s], A[s+1]): return False
    return True

def test(c, m, W, d):
    CH = all_chains(c, m, W, require_bottom_nonzero=False)  # include bottom-zero (max < m) chains too: crystal on all bounded CPs
    CHset = set(CH)
    results = {}
    for sgn in (1, -1):
        for tdir in (1, -1):
            closure_fail = invol_fail = 0
            checked = 0
            for A in CH:
                for kappa in range(d):
                    B = f_op(A, c, m, kappa, d, sgn, tdir)
                    if B is not None:
                        checked += 1
                        if not valid_chain(B, c, m):
                            closure_fail += 1
                            continue
                        back = e_op(B, c, m, kappa, d, sgn, tdir)
                        if back != A:
                            invol_fail += 1
                    Bp = e_op(A, c, m, kappa, d, sgn, tdir)
                    if Bp is not None:
                        if not valid_chain(Bp, c, m):
                            closure_fail += 1
                            continue
                        back = f_op(Bp, c, m, kappa, d, sgn, tdir)
                        if back != A:
                            invol_fail += 1
            results[(sgn,tdir)] = (closure_fail, invol_fail, checked)
    return results

if __name__ == "__main__":
    for (d, c, m, W) in [(4,(2,1,1),2,9), (4,(0,2,2),2,9), (4,(2,1,1),3,10), (5,(3,1,1),2,9)]:
        res = test(c, m, W, d)
        print(f"d={d} c={c} m={m} W={W}:")
        for k, v in res.items():
            print(f"  sgn={k[0]:+d} tdir={k[1]:+d}: closure_fail={v[0]} invol_fail={v[1]} ops_checked={v[2]}")
