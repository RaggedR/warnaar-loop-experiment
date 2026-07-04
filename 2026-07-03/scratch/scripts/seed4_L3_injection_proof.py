"""
Seed 4, Layer 3: Try to construct the injection g_m >= q * g_{m-1}.

g_m counts cylindric partitions with max = m, weighted by q^size.
The claim is g_m >= q * g_{m-1}, meaning: for every CP Lambda with max=m-1
and size w, there exists a CP Lambda' with max=m and size w+1.

For a CP Lambda = (lambda^(0), lambda^(1), lambda^(2)) with profile c=(c0,c1,c2)
and max(Lambda) = m-1, we need to find Lambda' with max(Lambda') = m and
|Lambda'| = |Lambda| + 1.

Proposed injection: Choose one partition lambda^(i) that achieves the max (i.e.,
lambda^(i)_1 = m-1). Add a new part of size m to this partition at position 1,
shifting all other parts down. But wait -- cylindric partitions have interlacing
conditions, so we can't just add a part.

Alternative: Since each lambda^(i) has parts <= m-1, and we want max = m,
we need to create at least one part equal to m. The simplest way: for some i,
add 1 to lambda^(i)_1 (from m-1 to m). This increases size by 1. But we need
to verify the interlacing conditions still hold.

Let's check this concretely.
"""

from itertools import combinations

def check_interlacing(partitions, c):
    """Check if (lambda^(0), ..., lambda^(k-1)) with profile c satisfies interlacing."""
    k = len(c)
    for i in range(k):
        i_next = (i + 1) % k
        lam = partitions[i]
        lam_next = partitions[i_next]
        c_next = c[i_next]
        # Condition: lambda^(i)_j >= lambda^(i_next)_{j + c_{i_next}} for all j >= 1
        for j in range(1, max(len(lam), len(lam_next) + c_next) + 1):
            val_i = lam[j-1] if j <= len(lam) else 0
            idx_next = j + c_next
            val_next = lam_next[idx_next - 1] if idx_next <= len(lam_next) else 0
            if val_i < val_next:
                return False
    return True

def generate_cps(c, max_val, max_parts=10):
    """Generate all CPs of profile c with max <= max_val."""
    k = len(c)
    # Each partition has parts in [0, max_val]
    # Generate all partitions with max <= max_val and at most max_parts parts
    def gen_partitions(max_v, max_p):
        if max_p == 0:
            yield ()
            return
        for v in range(max_v, -1, -1):
            for rest in gen_partitions(v, max_p - 1):
                yield (v,) + rest
    
    all_parts = list(gen_partitions(max_val, max_parts))
    
    # Trim trailing zeros
    def trim(p):
        p = list(p)
        while p and p[-1] == 0:
            p.pop()
        return tuple(p)
    
    all_parts_trimmed = list(set(trim(p) for p in all_parts))
    
    # For k partitions, check interlacing
    from itertools import product as iproduct
    cps = []
    for combo in iproduct(all_parts_trimmed, repeat=k):
        lam_list = [list(p) for p in combo]
        if check_interlacing(lam_list, c):
            max_entry = max(max(p) if p else 0 for p in lam_list)
            size = sum(sum(p) for p in lam_list)
            cps.append((max_entry, size, combo))
    return cps

# Test with d=4, c=(2,1,1), small max values
c = (2, 1, 1)
print(f"Profile c={c}, d={sum(c)}")
print()

# Generate CPs with max <= 3 and limited parts
max_parts = 5
for max_val in range(4):
    cps = generate_cps(c, max_val, max_parts)
    
    # Group by max value
    by_max = {}
    for mv, sz, combo in cps:
        by_max.setdefault(mv, []).append((sz, combo))
    
    print(f"CPs with max <= {max_val}:")
    for m in sorted(by_max.keys()):
        sizes = sorted([s for s, _ in by_max[m]])
        # Count by size
        from collections import Counter
        size_counts = Counter(sizes)
        print(f"  max={m}: {len(by_max[m])} CPs, by size: {dict(sorted(size_counts.items()))}")

# Now test the injection: for each CP with max=m-1 and size w,
# try to find a CP with max=m and size w+1 by adding 1 to one part
print("\n" + "="*60)
print("Testing injection: add 1 to lambda^(i)_1")
print("="*60)

cps = generate_cps(c, 2, 5)
by_max = {}
for mv, sz, combo in cps:
    by_max.setdefault(mv, []).append((sz, combo))

target_cps = set()
for sz, combo in by_max.get(2, []):
    target_cps.add((sz, combo))

# For each CP with max=1, try injection
for sz, combo in sorted(by_max.get(1, []), key=lambda x: x[0]):
    print(f"\nSource CP (max=1, size={sz}): {combo}")
    found = False
    for i in range(3):  # try each partition
        new_combo = list(list(p) for p in combo)
        if new_combo[i]:
            new_combo[i] = list(new_combo[i])
            new_combo[i][0] += 1  # add 1 to first part
        else:
            new_combo[i] = [1]
        
        new_combo_tuple = tuple(tuple(p) for p in new_combo)
        new_max = max(max(p) if p else 0 for p in new_combo)
        new_size = sum(sum(p) for p in new_combo)
        
        # Check interlacing
        valid = check_interlacing(new_combo, c)
        
        if valid and new_max == 2:
            print(f"  -> Adding 1 to lambda^({i})_1: {new_combo_tuple} (size={new_size}), VALID, max={new_max}")
            found = True
            break
        else:
            reason = f"max={new_max}" if new_max != 2 else "interlacing fails"
            print(f"  -> Adding 1 to lambda^({i})_1: {new_combo_tuple}, INVALID ({reason})")
    
    if not found:
        print(f"  *** NO VALID INJECTION FOUND ***")

