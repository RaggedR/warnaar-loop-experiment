# BREAKTHROUGH: Energy function is constant on profile pairs!
# H(b1 tensor b2) depends only on profile(b1) and profile(b2)
# Let's extract the energy matrix and compare with EMD

from sage.all import *
from collections import defaultdict

K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)
T2 = crystals.TensorProduct(K, K)

def element_to_profile(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

# Extract energy matrix E[c, c'] = H(b tensor b') where profile(b)=c, profile(b')=c'
energy_mat = {}
for b in T2:
    prof1 = element_to_profile(b[0])
    prof2 = element_to_profile(b[1])
    e = b.energy_function()
    energy_mat[(prof1, prof2)] = e

profiles = sorted(set(element_to_profile(b) for b in K))
print("Energy matrix H[c, c'] for d=4:")
print("Profiles:", profiles)

# Print as matrix
print("\nH matrix (rows=left, cols=right):")
header = "          " + "  ".join(f"{p}" for p in profiles)
print(header)
for c in profiles:
    row = f"{str(c):10s}" + "  ".join(f"{energy_mat.get((c, cp), '?'):>12}" for cp in profiles)
    print(row)

# From Round 1: EMD(c, c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
# This is the Earth Mover's Distance on Z/3Z with clockwise metric

def emd(c, cp):
    """Earth Mover's Distance from Round 1"""
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

print("\n\nEMD matrix for d=4:")
print("          " + "  ".join(f"{p}" for p in profiles))
for c in profiles:
    row = f"{str(c):10s}" + "  ".join(f"{emd(c, cp):>12}" for cp in profiles)
    print(row)

# Compare
print("\n\nDifference (H - EMD):")
print("          " + "  ".join(f"{p}" for p in profiles))
all_match = True
for c in profiles:
    diffs = []
    for cp in profiles:
        d = energy_mat[(c, cp)] - emd(c, cp)
        diffs.append(d)
        if d != 0:
            all_match = False
    row = f"{str(c):10s}" + "  ".join(f"{d:>12}" for d in diffs)
    print(row)

print(f"\nH == EMD? {all_match}")

# If they don't match, check other possible relationships
if not all_match:
    # Check H = EMD for some ordering
    # Or H = EMD(c', c) (reversed)
    print("\nDifference (H - EMD(reversed)):")
    all_rev = True
    for c in profiles:
        diffs = []
        for cp in profiles:
            d = energy_mat[(c, cp)] - emd(cp, c)
            diffs.append(d)
            if d != 0:
                all_rev = False
        row = f"{str(c):10s}" + "  ".join(f"{d:>12}" for d in diffs)
        print(row)
    print(f"H == EMD(reversed)? {all_rev}")

    # Check if H is a simple function of the profiles
    print("\nLet's examine H values more carefully:")
    for c in profiles:
        for cp in profiles:
            h = energy_mat[(c, cp)]
            # What function could this be?
            # Maybe related to sum of absolute differences?
            # Or transport distance with different metric?
            pass
    
    # Print H as a simple matrix
    print("\nH values:")
    for c in profiles:
        vals = [energy_mat[(c, cp)] for cp in profiles]
        print(f"  {c}: {vals}")

# Also compute the "reversed" energy: swap b1, b2
print("\n\nChecking symmetry of H:")
symmetric = True
for c in profiles:
    for cp in profiles:
        if energy_mat[(c, cp)] != energy_mat[(cp, c)]:
            print(f"  H({c},{cp})={energy_mat[(c,cp)]} != H({cp},{c})={energy_mat[(cp,c)]}")
            symmetric = False
            break
print(f"H is symmetric? {symmetric}")

