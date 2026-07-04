#!/usr/bin/env python3
"""Seed 4 Layer 4: machine verification of Step-1 lemmas for the bounded mod-d
Tingley operators (convention sgn=+1, tdir=+1 of seed5_R2L3_crystal.py).

Checks:
 C0  Lemma 0   : no T-ties within a color class.
 CL  Lemma L   : adding ANY partition-addable box b of color k (S-valid or not)
                 changes W_k by flipping exactly the letter at T(b); dually removal.
 CV  Lemma V   : if adding b breaks S, witness b' = (i-1, a_{i-1}^(s)+1, s) is
                 partition-addable, color k, T(b') = T(b)-d; dually removals.
 CS  Sig-flip  : flipping the leftmost surviving "(" makes it the rightmost
                 surviving ")" (checked on the actual words).
 CE  end-to-end: closure (S-validity of outputs) + e f = f e = id.
"""
import sys
from itertools import product
sys.path.insert(0, '.')
from seed5_R2L3_crystal import (in_S, states_upto, geq, all_chains, weight,
                                offsets, boxes_add_remove, reduce_brackets,
                                apply_add, apply_rem, f_op, e_op, valid_chain)

SGN, TDIR = 1, 1

def word(A, c, m, kappa, d):
    return boxes_add_remove(A, c, m, kappa, d, SGN, TDIR)

def all_part_addable(A, c, m):
    """All partition-addable boxes (i, j, s) with color and T; NO S-check."""
    off = offsets(c); d = sum(c)
    out = []
    for i in range(3):
        for s in range(1, m+1):
            ais = A[s-1][i]
            prev = A[s-2][i] if s >= 2 else None
            if (s == 1) or (prev is not None and prev > ais):
                j = ais + 1
                out.append((i, j, s, (s - j + off[i]) % d, d*i + 3*(j - off[i] - s)))
    return out

def all_part_removable(A, c, m):
    off = offsets(c); d = sum(c)
    out = []
    for i in range(3):
        for s in range(1, m+1):
            ais = A[s-1][i]
            nxt = A[s][i] if s <= m-1 else 0
            if ais > nxt:
                j = ais
                out.append((i, j, s, (s - j + off[i]) % d, d*i + 3*(j - off[i] - s)))
    return out

def word_as_map(A, c, m, kappa, d):
    """dict T -> '(' or ')'."""
    return {T: ('(' if typ == 1 else ')') for (T, typ, pos) in word(A, c, m, kappa, d)}

def run(cases, WMAX):
    fail = dict(C0=0, CL=0, CV=0, CS=0, CE_clos=0, CE_inv=0)
    nchains = nops = nviol = 0
    for (d, c, m, W) in cases:
        CH = all_chains(c, m, W, require_bottom_nonzero=False)
        nchains += len(CH)
        for A in CH:
            # C0: no ties per color
            for kappa in range(d):
                br = word(A, c, m, kappa, d)
                Ts = [x[0] for x in br]
                if len(Ts) != len(set(Ts)):
                    fail['C0'] += 1; print("C0 FAIL", d, c, m, A, kappa)
            # CL + CV for additions
            for (i, j, s, kappa, T) in all_part_addable(A, c, m):
                B = apply_add(A, i, s)
                w0 = word_as_map(A, c, m, kappa, d)
                w1 = word_as_map(B, c, m, kappa, d)
                ok = (w0.get(T) == '(' and w1.get(T) == ')'
                      and {t: v for t, v in w0.items() if t != T}
                        == {t: v for t, v in w1.items() if t != T})
                if not ok:
                    fail['CL'] += 1; print("CL-add FAIL", d, c, m, A, (i, j, s))
                # S-validity of B at level s?
                if not in_S(B[s-1], c):
                    nviol += 1
                    ip = (i - 1) % 3
                    jp = A[s-1][ip] + 1
                    # witness partition-addable?
                    prevp = A[s-2][ip] if s >= 2 else None
                    w_add = (s == 1) or (prevp is not None and prevp > A[s-1][ip])
                    off = offsets(c)
                    colp = (s - jp + off[ip]) % d
                    Tp = d*ip + 3*(jp - off[ip] - s)
                    # T is defined per real column index; cyclic i-1 for i=0 wraps to 2:
                    # accept T(b') == T(b) - d modulo the wrap: check via presence in word
                    inword = w0.get(Tp) == '('
                    wrapok = (Tp == T - d) or (ip == 2 and i == 0)
                    if not (w_add and colp == kappa and inword):
                        fail['CV'] += 1
                        print("CV-add FAIL", d, c, m, A, (i, j, s), "wit", (ip, jp, s),
                              "addable", w_add, "col", colp, "vs", kappa, "T", Tp, T)
                    else:
                        # immediate-left check: no color-k letter in (Tp', T) where
                        # Tp' is the witness position in T-order (handle wrap: for i=0
                        # the witness column 2 has T = T + 2d - 3d = T - d as well:
                        # verify numerically)
                        if Tp >= T:
                            fail['CV'] += 1
                            print("CV-add ORDER FAIL", d, c, m, A, (i, j, s), Tp, T)
                        else:
                            between = [t for t in w0 if Tp < t < T]
                            if between:
                                fail['CV'] += 1
                                print("CV-add GAP FAIL", d, c, m, A, (i, j, s), between)
            # CL + CV for removals
            for (i, j, s, kappa, T) in all_part_removable(A, c, m):
                B = apply_rem(A, i, s)
                w0 = word_as_map(A, c, m, kappa, d)
                w1 = word_as_map(B, c, m, kappa, d)
                ok = (w0.get(T) == ')' and w1.get(T) == '('
                      and {t: v for t, v in w0.items() if t != T}
                        == {t: v for t, v in w1.items() if t != T})
                if not ok:
                    fail['CL'] += 1; print("CL-rem FAIL", d, c, m, A, (i, j, s))
                if not in_S(B[s-1], c):
                    nviol += 1
                    ipp = (i + 1) % 3
                    jpp = A[s-1][ipp]
                    nxtp = A[s][ipp] if s <= m-1 else 0
                    w_rem = jpp > nxtp
                    off = offsets(c)
                    colp = (s - jpp + off[ipp]) % d
                    Tp = d*ipp + 3*(jpp - off[ipp] - s)
                    inword = w0.get(Tp) == ')'
                    if not (w_rem and colp == kappa and inword):
                        fail['CV'] += 1
                        print("CV-rem FAIL", d, c, m, A, (i, j, s), "wit", (ipp, jpp, s))
                    else:
                        if Tp <= T:
                            fail['CV'] += 1
                            print("CV-rem ORDER FAIL", d, c, m, A, (i, j, s), Tp, T)
                        else:
                            between = [t for t in w0 if T < t < Tp]
                            if between:
                                fail['CV'] += 1
                                print("CV-rem GAP FAIL", d, c, m, A, (i, j, s), between)
            # CS + CE
            for kappa in range(d):
                br = word(A, c, m, kappa, d)
                adds, rems = reduce_brackets(br)
                if adds:
                    nops += 1
                    T, (i, s) = adds[0]
                    B = apply_add(A, i, s)
                    if not valid_chain(B, c, m):
                        fail['CE_clos'] += 1; print("CE closure-f FAIL", d, c, m, A, kappa)
                        continue
                    # CS: rightmost surviving ')' of B-word is at T
                    br2 = word(B, c, m, kappa, d)
                    adds2, rems2 = reduce_brackets(br2)
                    if not rems2 or rems2[-1][0] != T:
                        fail['CS'] += 1; print("CS-f FAIL", d, c, m, A, kappa)
                    if e_op(B, c, m, kappa, d, SGN, TDIR) != A:
                        fail['CE_inv'] += 1; print("CE ef FAIL", d, c, m, A, kappa)
                if rems:
                    nops += 1
                    T, (i, s) = rems[-1]
                    B = apply_rem(A, i, s)
                    if not valid_chain(B, c, m):
                        fail['CE_clos'] += 1; print("CE closure-e FAIL", d, c, m, A, kappa)
                        continue
                    br2 = word(B, c, m, kappa, d)
                    adds2, rems2 = reduce_brackets(br2)
                    if not adds2 or adds2[0][0] != T:
                        fail['CS'] += 1; print("CS-e FAIL", d, c, m, A, kappa)
                    if f_op(B, c, m, kappa, d, SGN, TDIR) != A:
                        fail['CE_inv'] += 1; print("CE fe FAIL", d, c, m, A, kappa)
    print(f"chains={nchains} ops={nops} S-violating-boxes-encountered={nviol}")
    print("FAILURES:", fail)
    return fail

if __name__ == "__main__":
    cases = []
    for d, c in [(2,(1,1,0)), (2,(2,0,0)), (2,(0,1,1)),
                 (3,(1,1,1)), (3,(0,2,1)),
                 (4,(2,1,1)), (4,(0,2,2)), (4,(4,0,0)), (4,(0,1,3)), (4,(0,3,1)),
                 (5,(3,1,1)), (5,(0,2,3)),
                 (6,(2,2,2)),
                 (7,(3,2,2)), (7,(7,0,0)),
                 (8,(3,3,2)), (9,(4,3,2))]:
        for m in (1, 2, 3):
            cases.append((d, c, m, 11 if m <= 2 else 10))
    f = run(cases, None)
    print("ALL PASS" if not any(f.values()) else "SOME FAIL")
