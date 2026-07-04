"""
Independent verifier (Seed-3-Layer-4 audit): system parse + positivity + exact symbolic
replay of every derivation chain, all in Z[y,q] (NO truncation anywhere in this file).

Row representation: {(src_orbit, shift): poly}, poly = {(ydeg, qdeg): int}.
A row for target t asserts G_t(y) = sum m_{r,s}(y,q) G_r(y q^s).

Everything here is written from scratch by the verifier; the 12 rows below are
transcribed BY HAND from proofs/prove-seed3-layer4.tex (Lemmas 1 and 2).
"""
from itertools import combinations

# ---------- orbits ----------
def rot(c): return (c[1], c[2], c[0])
def orep(c): return min(c, rot(c), rot(rot(c)))

Z1=(0,0,7); Z2=(0,6,1); Z3=(0,1,6); Z4=(0,5,2); Z5=(0,2,5); Z6=(0,4,3); Z7=(0,3,4)
C1=(1,1,5); C2=(1,4,2); C3=(1,2,4); C4=(1,3,3); C5=(2,2,3)
NAMES={Z1:"Z1",Z2:"Z2",Z3:"Z3",Z4:"Z4",Z5:"Z5",Z6:"Z6",Z7:"Z7",
       C1:"C1",C2:"C2",C3:"C3",C4:"C4",C5:"C5"}
REPS=list(NAMES)

# sanity: these are exactly the 12 orbit reps at d=7
def profiles(d): return [(a,b,d-a-b) for a in range(d+1) for b in range(d+1-a)]
assert sorted(set(orep(c) for c in profiles(7))) == sorted(REPS)

# ---------- poly ops on {(j,a):coeff} ----------
def padd(p, q2, mult=1):
    r=dict(p)
    for k,v in q2.items():
        r[k]=r.get(k,0)+mult*v
        if r[k]==0: del r[k]
    return r
def pmul(p, q2):
    r={}
    for (j1,a1),v1 in p.items():
        for (j2,a2),v2 in q2.items():
            k=(j1+j2,a1+a2); r[k]=r.get(k,0)+v1*v2
            if r[k]==0: del r[k]
    return r
def pshift_y(p, s):
    # m(y,q) -> m(y q^s, q)
    return {(j,a+j*s):v for (j,a),v in p.items()}

def radd(row, key, poly):
    cur=row.get(key,{})
    new=padd(cur,poly)
    if new: row[key]=new
    elif key in row: del row[key]

# ---------- raw CW row (my own implementation, conjecture.tex c(J) rule) ----------
POCHY={1:{(0,0):1}, 2:{(0,0):1,(1,1):-1}, 3:{(0,0):1,(1,1):-1,(1,2):-1,(2,3):1}}
def cJ(c,J):
    out=[]
    for i in range(3):
        prev=(i-1)%3; v=c[i]
        if i in J and prev not in J: v-=1
        elif i not in J and prev in J: v+=1
        out.append(v)
    return tuple(out)
def raw_row_profile(c):
    I=[i for i in range(3) if c[i]>0]
    row={}
    for sz in range(1,len(I)+1):
        for J in combinations(I,sz):
            sgn=(-1)**(sz-1)
            radd(row,(orep(cJ(c,set(J))),sz),{k:sgn*v for k,v in POCHY[sz].items()})
    return row
def raw_row(rep):
    # orbit-level raw row; assert rotation-equivariance (well-definedness)
    rows=[raw_row_profile(c) for c in {rep,rot(rep),rot(rot(rep))}]
    assert all(r==rows[0] for r in rows), f"raw row not rotation-equivariant at {rep}"
    return rows[0]

# ---------- exact substitution ----------
def substitute(row, key, subrow):
    """Replace term m(y,q) G_r(yq^s) (key=(r,s)) using subrow for G_r. Exact."""
    assert key in row, f"term {key} not present"
    m=row[key]; r,s=key
    out={k:dict(v) for k,v in row.items()}
    del out[r,s]
    for (rp,sp),mp in subrow.items():
        radd(out,(rp,s+sp),pmul(m,pshift_y(mp,s)))
    return out

# ---------- the 12 rows, transcribed by hand from prove-seed3-layer4.tex ----------
def T(*mono):  # poly from list of (j,a) unit monomials, with optional coeff via repetition
    p={}
    for (j,a) in mono: p[(j,a)]=p.get((j,a),0)+1
    return p

TEX={}
TEX[Z1]={(Z2,1):T((0,0))}
TEX[Z2]={(Z3,1):T((0,0)),(C1,2):T((1,1)),(C2,3):T((1,2)),(C4,4):T((1,3)),
         (C3,5):T((1,4)),(C1,6):T((1,5)),(Z2,7):T((1,6))}
TEX[Z3]={(C1,1):T((0,0)),(Z2,2):T((1,1))}
TEX[Z4]={(C1,1):T((0,0)),(C2,2):T((1,1)),(C4,3):T((1,2)),(C3,4):T((1,3)),
         (C1,5):T((1,4)),(Z2,6):T((1,5))}
TEX[Z5]={(C3,1):T((0,0)),(C1,2):T((1,1)),(Z2,3):T((1,2))}
TEX[Z6]={(C2,1):T((0,0)),(C4,2):T((1,1)),(C3,3):T((1,2)),(C1,4):T((1,3)),(Z2,5):T((1,4))}
TEX[Z7]={(C4,1):T((0,0)),(C3,2):T((1,1)),(C1,3):T((1,2)),(Z2,4):T((1,3))}

TEX[C1]={(C2,1):T((0,0)),(Z4,2):T((1,1)),(C3,2):T((1,1)),
         (C1,3):T((1,2),(2,3)),(Z2,4):T((1,3),(2,4))}
TEX[C3]={(C5,1):T((0,0)),(C4,2):T((1,1)),(C2,2):T((1,1)),(Z4,3):T((1,2)),
         (C3,3):T((1,2),(2,3)),(C1,4):T((1,3),(2,4),(2,5)),(Z2,5):T((1,4),(2,5),(2,6))}
TEX[C4]={(C5,1):T((0,0)),(C2,2):T((1,1)),(C5,2):T((1,1)),(C4,3):T((1,2),(2,3)),
         (C2,3):T((1,2)),(Z4,4):T((1,3)),(C3,4):T((1,3),(2,4),(2,5)),
         (C1,5):T((1,4),(2,5),(2,6),(2,7)),(Z2,6):T((1,5),(2,6),(2,7),(2,8))}
TEX[C2]={(C4,1):T((0,0)),(Z6,2):T((1,1)),(C5,2):T((1,1)),(C4,3):T((1,2)),
         (C2,3):T((1,2),(2,3)),(Z4,4):T((1,3),(2,4)),(C3,4):T((1,3),(2,4),(2,5)),
         (C1,5):T((1,4),(2,5),(2,6),(2,7),(3,8)),(Z2,6):T((1,5),(2,6),(2,7),(2,8),(3,9))}
TEX[C5]={(C5,1):T((0,0)),(C4,2):T((1,1)),(C5,2):T((1,1)),(Z6,3):T((1,2)),
         (C2,3):T((1,2)),(C5,3):T((1,2),(2,3)),(C4,4):T((1,3),(2,4),(2,5)),
         (C2,4):T((1,3),(2,4),(2,5)),(Z4,5):T((1,4),(2,5),(2,6)),
         (C3,5):T((1,4),(2,5),(2,6),(2,6),(2,7),(3,8)),
         (C1,6):T((1,5),(2,6),(2,7),(2,7),(2,8),(2,9),(3,9),(3,10),(3,11)),
         (Z2,7):T((1,6),(2,7),(2,8),(2,8),(2,9),(2,10),(3,10),(3,11),(3,12))}

# ---------- JOB 1a: manifest positivity of every tex row ----------
print("=== JOB 1a: positivity / shifts / heads of the 12 tex rows ===")
ok=True
for t in REPS:
    row=TEX[t]
    neg=[(k,mono,v) for k,m in row.items() for mono,v in m.items() if v<0]
    badshift=[k for k in row if k[1]<1]
    y0=[( k,a,v) for k,m in row.items() for (j,a),v in m.items() if j==0]
    headok = (len(y0)==1 and y0[0][1]==0 and y0[0][2]==1)
    stat = "PASS" if (not neg and not badshift and headok) else "FAIL"
    if stat=="FAIL": ok=False
    print(f"  {NAMES[t]}: {len(row)} terms; neg={neg}; shifts<1={badshift}; unit head={headok} -> {stat}")
print("JOB1a overall:", "PASS" if ok else "FAIL")

# ---------- JOB 1b: Family A/B mechanical derivation of the zero rows ----------
print("=== JOB 1b: Family A and B replay for zero rows (exact) ===")
# Family A: c=(a,0,b), b>=1, uses row of (a+1,0,b-1); base (7,0,0) raw row.
A={}
A[orep((7,0,0))]=raw_row((7,0,0))
orderA=[(7-b,0,b) for b in range(1,7)]  # base orbit Z1=(7,0,0) is the raw row itself (tex: induction terminates there)
for c in orderA:
    r=raw_row_profile(c)
    up=orep((c[0]+1,0,c[2]-1))
    r=substitute(r,(up,1),A[up])
    A[orep(c)]=r
assert A[Z1]==TEX[Z1], "base raw row (7,0,0) != tex Z1 row"
okA=all(A[t]==TEX[t] for t in [Z1,Z2,Z3,Z4,Z5,Z6,Z7])
for t in [Z1,Z2,Z3,Z4,Z5,Z6,Z7]:
    print(f"  Family A row {NAMES[t]} == tex row: {A[t]==TEX[t]}")
print("JOB1b Family A:", "PASS" if okA else "FAIL")
# Family B: c=(a,b,0), a>=1, uses Family-A row of orbit((a-1,b+1,0)); a=1 -> raw |I|=1 row.
B={}
B[Z1]=raw_row((0,7,0))  # base of family B
print(f"  Family B base Z1 (raw row of (0,7,0)) == tex row: {B[Z1]==TEX[Z1]}")
okB = B[Z1]==TEX[Z1]
for a in range(1,7):
    b=7-a; c=(a,b,0)
    r=raw_row_profile(c)
    low=orep((a-1,b+1,0))
    subrow = A[low] if a>1 else raw_row((0,b+1,0))
    r=substitute(r,(low,1),subrow)
    B[orep(c)]=r
    same = r==TEX[orep(c)]
    okB = okB and same
    print(f"  Family B row {NAMES[orep(c)]} (from ({a},{b},0)) == tex row: {same}")
print("JOB1b Family B:", "PASS" if okB else "FAIL")

# ---------- JOB 1c: replay the five core chains (exact, incl. two depth-7) ----------
print("=== JOB 1c: core substitution chains, exact replay in Z[y,q] ===")
R=TEX  # R[Z_i] rows now independently re-derived above (A == TEX)
CH={
 C1:[("raw",Z2,(Z2,1)),("R",Z5,(Z5,1)),("R",Z3,(Z3,2))],
 C3:[("raw",C1,(C1,1)),("raw",Z2,(Z2,2)),("R",Z7,(Z7,1)),("R",Z5,(Z5,2)),("R",Z3,(Z3,3))],
 C4:[("raw",C3,(C3,1)),("raw",C1,(C1,2)),("raw",Z2,(Z2,3)),("R",Z6,(Z6,1)),
     ("R",Z7,(Z7,2)),("R",Z5,(Z5,3)),("R",Z3,(Z3,4))],
 C2:[("raw",Z4,(Z4,1)),("raw",C3,(C3,1)),("raw",C1,(C1,2)),("raw",Z2,(Z2,3)),
     ("R",Z7,(Z7,2)),("R",Z5,(Z5,3)),("R",Z3,(Z3,4))],
 C5:[("C",C4,(C4,1)),("C",C3,(C3,2)),("C",C2,(C2,1))],
}
DER={}
okC=True
for t in [C1,C3,C4,C2,C5]:
    r=raw_row(t)
    for kind,src,key in CH[t]:
        sub = raw_row(src) if kind=="raw" else (A[src] if kind=="R" else DER[src])
        r=substitute(r,key,sub)
    DER[t]=r
    same = r==TEX[t]
    okC = okC and same
    print(f"  chain {NAMES[t]} (depth {len(CH[t])}) endpoint == tex row: {same}")
print("JOB1c overall:", "PASS" if okC else "FAIL")
print()
print("ALL JOB1:", "PASS" if (ok and okA and okB and okC) else "FAIL")
