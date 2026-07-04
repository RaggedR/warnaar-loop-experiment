# Test H = ceil(inversions / d) for d=3 and d=4
from sage.all import *
import math

def compute_H(d):
    K = crystals.KirillovReshetikhin(['A',2,1], 1, d)
    T = crystals.TensorProduct(K, K)
    def prof(b):
        tab = list(b.to_tableau())[0]
        return (tab.count(1), tab.count(2), tab.count(3))
    H = {}
    for b in T:
        H[(prof(b[0]), prof(b[1]))] = b.energy_function()
    profiles = sorted(set(prof(b) for b in K))
    return H, profiles

def inversions(c, cp):
    """Count pairs where letter in c > letter in c'"""
    inv = 0
    for a in range(1, 4):
        for b in range(1, 4):
            if a > b:
                inv += c[a-1] * cp[b-1]
    return inv

for d in [2, 3, 4, 5]:
    try:
        H, profs = compute_H(d)
    except:
        print(f"d={d}: computation too large, skipping")
        continue
    
    all_ok_ceil = True
    all_ok_floor = True
    failures = []
    for c in profs:
        for cp in profs:
            inv = inversions(c, cp)
            h = H[(c, cp)]
            pred_ceil = int(math.ceil(inv / d)) if inv > 0 else 0
            pred_floor = inv // d
            if pred_ceil != h:
                all_ok_ceil = False
                failures.append((c, cp, h, inv, pred_ceil))
            if pred_floor != h:
                all_ok_floor = False
    
    print(f"d={d}: ceil(inv/d)={all_ok_ceil}, floor(inv/d)={all_ok_floor}")
    if not all_ok_ceil:
        for c, cp, h, inv, pred in failures[:5]:
            print(f"  FAIL: H({c},{cp})={h}, inv={inv}, ceil={pred}")

    # Check if inv is always divisible by d (making ceil=floor)
    all_div = True
    for c in profs:
        for cp in profs:
            if inversions(c, cp) % d != 0:
                all_div = False
                break
    print(f"  inv always divisible by d? {all_div}")

    # Check alternative: H = ceil(inv/n) where n=3
    all_ok_n = True
    for c in profs:
        for cp in profs:
            inv = inversions(c, cp)
            h = H[(c, cp)]
            pred = int(math.ceil(inv / 3)) if inv > 0 else 0
            if pred != h:
                all_ok_n = False
                break
    print(f"  ceil(inv/3)={all_ok_n}")

    # Check: H = (inv + d - 1) // d
    all_ok_alt = True
    for c in profs:
        for cp in profs:
            inv = inversions(c, cp)
            h = H[(c, cp)]
            pred = (inv + d - 1) // d if inv > 0 else 0
            if pred != h:
                all_ok_alt = False
                break
    print(f"  (inv+d-1)//d={all_ok_alt}")

