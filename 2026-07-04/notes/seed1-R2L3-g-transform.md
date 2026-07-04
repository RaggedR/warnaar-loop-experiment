# Seed 1 R2L3 cross-pollination: the g-transform kills the m

For any orbit, expand H_{c,m} = sum_{n<=m} g_{c,n}(q) [m,n]_q. The g_{c,n}
are UNIQUE, m-independent (inverse q-binomial transform, i.e. n-th
q-difference of the H-sequence). One-line q-Pascal lemma:

    g_{c,n} >= 0 for all n   ==>   H_{c,m} >= H_{c,m-1}   (monotonicity),
    with exact surplus  H_m - H_{m-1} = sum_n g_n q^{m-n} [m-1,n-1].

EMPIRICAL: g_{c,n} >= 0 for every orbit at d=2,4,5 (n<=8), d=7 (n<=6) —
including the d=4 orbits (0,1,3),(0,2,2) that have NO known fermionic form,
and all d=5 orbits. Script: scratch/scripts/seed1_R2L3_qbt.py.

Also proved unconditionally (A2 Pascal ladder): with
ferm(m,a,b,c) = sum_{n,j} q^{n^2-nj+j^2+an+bj}[m,n][2n+c,j],
    ferm(m,a,b,c) - ferm(m-1,a,b,c) = q^{m+a} ferm(m-1,a+1,b-1,c+2).
So ANY orbit whose H has a bounded fermionic form with its m-dependence in a
single [m,n] is automatically monotone. d=4 forms for (1,1,2),(0,0,4),(0,3,1)
verified to m<=8.

Suggested use by sibling seeds: (1) run the tower through the g-transform to
get an n-recursion on (g_{c,n})_c and prove positivity by induction on n;
(2) hunt closed forms for g_{c,n} directly (val fingerprints in my scratch,
Result 7) instead of forms for H_{c,m}.

Full details: scratch/prove-seed1-layer3.md, proofs/prove-seed1-layer3.pdf.
