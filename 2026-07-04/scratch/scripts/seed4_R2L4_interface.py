#!/usr/bin/env python3
"""Check the INTERFACE structure of v-chain words:
 (1) letters of W_kappa(v-chain) = per-interface pairs + top-gap addables. 
 (2) per interface: multiset of ')' colors == multiset of '(' colors.
 (3) per interface & color: every '(' strictly left (smaller T) of every ')'.
 (4) canonical partner: ')' col i <-> '(' col i' = (i + k''-k) % 3 at T-distance d(k-k'').
Exhaustive: d<=8, all profiles, m<=5, k1<=6."""
import sys
from collections import Counter
sys.path.insert(0, '.')
from seed5_R2L3_crystal import boxes_add_remove, offsets

def vvec(c, k):
    return tuple(sum(c[(i - t) % 3] for t in range(k)) for i in range(3))

def profiles(d):
    return [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]

def ksequences(m, kmax):
    def rec(prefix, hi):
        if len(prefix) == m-1:
            yield tuple(prefix) + (0,)
            return
        for k in range(hi, -1, -1):
            yield from rec(prefix + [k], k)
    if m == 1:
        yield (0,)
    else:
        yield from rec([], kmax)

fail = [0,0,0,0]
checked = 0
for d in range(2, 9):
    for c in profiles(d):
        off = offsets(c)
        for m in range(1, 6):
            for ks in ksequences(m, 6):
                A = tuple(vvec(c, k) for k in ks)
                checked += 1
                # gather all letters from the crystal code, all colors
                letters = []   # (T, type, color, (i,s))
                for kappa in range(d):
                    for (T, typ, pos) in boxes_add_remove(A, c, m, kappa, d, 1, 1):
                        letters.append((T, typ, kappa, pos))
                # predicted letters from interface structure
                pred = []  # (T, typ, color, tag)
                # interfaces: s2 in 1..m-1 with ks[s2-1] > ks[s2]; also bottom interface if ks[m-1] > 0 (can't happen, k_m=0)
                intfs = [(s2, ks[s2-1], ks[s2]) for s2 in range(1, m) if ks[s2-1] > ks[s2]]
                for (s2, k, k2) in intfs:
                    for i in range(3):
                        W = vvec(c, k)[i] - vvec(c, k2)[i]
                        if W > 0:
                            # ')' at (i, delta_r = v_k,i - s2), '(' at (i, delta_a = v_k2,i - s2)
                            dr = vvec(c, k)[i] - s2
                            da = vvec(c, k2)[i] - s2
                            Tr = d*i + 3*(dr - off[i])
                            Ta = d*i + 3*(da - off[i])
                            colr = (off[i] - dr) % d
                            cola = (off[i] - da) % d
                            pred.append((Tr, 0, colr, ('int', s2, i)))
                            pred.append((Ta, 1, cola, ('int', s2, i)))
                # top-gap addables: level-1 addable at (i, v_{k1,i}+1, 1), delta = v_{k1,i}
                k1 = ks[0]
                for i in range(3):
                    dtop = vvec(c, k1)[i]
                    T = d*i + 3*(dtop - off[i])
                    pred.append((T, 1, (off[i]-dtop) % d, ('top', i)))
                # (1) compare letter sets
                got = sorted((T, typ, kappa) for (T, typ, kappa, _) in letters)
                exp = sorted((T, typ, kappa) for (T, typ, kappa, _) in pred)
                if got != exp:
                    fail[0] += 1
                    if fail[0] <= 3:
                        print("STRUCT MISMATCH:", d, c, m, ks)
                        print("  got:", got); print("  exp:", exp)
                # per-interface checks
                for (s2, k, k2) in intfs:
                    ints = [(T,typ,col,tag) for (T,typ,col,tag) in pred
                            if tag[0]=='int' and tag[1]==s2]
                    remc = Counter(col for (T,typ,col,_) in ints if typ==0)
                    addc = Counter(col for (T,typ,col,_) in ints if typ==1)
                    if remc != addc:
                        fail[1] += 1
                        if fail[1] <= 3: print("COLOR MULTISET FAIL:", d,c,m,ks,s2, remc, addc)
                    # (3) all-left per color
                    for col in remc:
                        rTs = [T for (T,typ,cc,_) in ints if typ==0 and cc==col]
                        aTs = [T for (T,typ,cc,_) in ints if typ==1 and cc==col]
                        if not all(a < r for a in aTs for r in rTs):
                            fail[2] += 1
                            if fail[2] <= 5:
                                print("ALLLEFT FAIL:", d,c,m,ks,"s2",s2,"col",col,
                                      "addT",aTs,"remT",rTs)
                    # (4) canonical partner distance
                    for i in range(3):
                        W = vvec(c,k)[i] - vvec(c,k2)[i]
                        if W > 0:
                            ip = (i + k2 - k) % 3
                            Wp = vvec(c,k)[ip] - vvec(c,k2)[ip]
                            if Wp > 0:
                                dr = vvec(c,k)[i] - s2
                                da = vvec(c,k2)[ip] - s2
                                Tr = d*i + 3*(dr - off[i])
                                Ta = d*ip + 3*(da - off[ip])
                                colr = (off[i]-dr) % d; cola = (off[ip]-da) % d
                                if colr != cola or Tr - Ta != d*(k-k2):
                                    fail[3] += 1
                                    if fail[3] <= 3:
                                        print("CANONICAL FAIL:", d,c,m,ks,s2,i,ip,
                                              "col", colr, cola, "Tdiff", Tr-Ta, "want", d*(k-k2))
print(f"v-chains checked: {checked}; fails struct/multiset/allleft/canonical = {fail}")
