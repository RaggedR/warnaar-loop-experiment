# Seed 2, R2L1: Demazure crystals in B^{1,4}^{tensor 2} and Q_2
# 
# The ODCS for B^{1,4}^{tensor 2} already gives the q-graded character
# Let me check if any Demazure subcrystal (or difference of Demazure crystals)
# gives Q_2 when graded by energy.

from sage.all import *
from collections import defaultdict

R = QQ['q']
q = R.gen()

K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)

def element_to_profile(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

# The ODCS decomposition:
# sum_{b in B^{1,4}^2} q^{energy(b)} * x^{cl.wt(b)}
# This splits into classical highest weight components (Demazure characters)

# For the tensor product, classical highest weight means:
# b is killed by all e_i for i != 0 (i.e., i in {1, 2})

T2 = crystals.TensorProduct(K, K)

# Find classical highest weight elements in T2
print("Classical highest weight elements in B^{1,4}^{tensor 2}:")
hw_elements = []
for b in T2:
    is_hw = True
    for i in [1, 2]:
        if b.e(i) is not None:
            is_hw = False
            break
    if is_hw:
        e = b.energy_function()
        p0 = element_to_profile(b[0])
        p1 = element_to_profile(b[1])
        wt = b.weight()
        hw_elements.append((b, e, p0, p1, wt))
        print(f"  {b}: energy={e}, profiles={p0},{p1}, wt={wt}")

print(f"\nTotal classical HW elements: {len(hw_elements)}")

# Each HW element generates a classical irreducible
# The energy is constant on classical components (since e_1, e_2 don't change energy)
# So the ODCS decomposition is:
# sum of (q^{energy_of_component} * character_of_classical_irrep)

# For each HW element, compute the character of its classical component
print("\n\nClassical components and their characters by profile:")
for hw_b, hw_e, p0, p1, wt in hw_elements:
    # Generate the component by applying f_1, f_2
    component = set()
    queue = [hw_b]
    component.add(hw_b)
    while queue:
        b = queue.pop()
        for i in [1, 2]:
            fb = b.f(i)
            if fb is not None and fb not in component:
                component.add(fb)
                queue.append(fb)
    
    # Profile decomposition of this component
    char = defaultdict(int)
    for b in component:
        char[element_to_profile(b[1])] += 1  # group by RIGHT profile
    
    char_by_total = defaultdict(int)
    for b in component:
        tab0 = list(b[0].to_tableau())[0]
        tab1 = list(b[1].to_tableau())[0]
        total = (tab0.count(1)+tab1.count(1), tab0.count(2)+tab1.count(2), tab0.count(3)+tab1.count(3))
        char_by_total[total] += 1
    
    print(f"\n  HW={hw_b}, energy={hw_e}, |component|={len(component)}")
    print(f"    By total content: {dict(sorted(char_by_total.items()))}")

