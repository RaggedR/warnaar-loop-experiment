from sage.all import *
K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)
T2 = crystals.TensorProduct(K, K)
b = next(iter(T2))
print(f"type: {type(b)}")
print(f"repr: {b}")
print(f"dir: {[x for x in dir(b) if not x.startswith('_')]}")
# Try various access patterns
try:
    print(f"list(b): {list(b)}")
except: pass
try:
    print(f"b[0]: {b[0]}")
except: pass
try:
    print(f"b.components: {b.components}")
except: pass
