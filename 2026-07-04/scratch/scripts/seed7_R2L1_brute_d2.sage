# Brute force compute F_{c,n}(q) for d=2 by enumerating CPs
# Profile c = (c_0, c_1, c_2) with c_0+c_1+c_2 = 2
# A CP of profile c is (lam^(0), lam^(1), lam^(2)) with:
# lam^(i)_j >= lam^(i+1 mod 3)_{j + c_{(i+1) mod 3}}
# where indices are 1-based (or 0-based with appropriate shift)

# Let's use 0-based indexing for parts:
# lam^(i)[j] >= lam^((i+1)%3)[j + c_{(i+1)%3}]  for j >= 0

R = PolynomialRing(QQ, 'q')
q = R.gen()

def enum_CPs(c, max_entry, max_len=20):
    """Enumerate all CPs of profile c with max entry <= max_entry."""
    k = 3
    result = R(0)
    
    # Generate all 3-tuples of partitions
    # Each partition has parts in {0,...,max_entry}, weakly decreasing, length <= max_len
    def gen_partitions(max_val, max_len):
        if max_len == 0:
            yield ()
            return
        for v in range(max_val + 1):
            for rest in gen_partitions(v, max_len - 1):
                yield (v,) + rest
    
    # For efficiency, use smaller max_len
    ml = max_entry + max(c) + 3
    if ml > 8:
        ml = 8  # cap for speed
    
    parts_list = list(gen_partitions(max_entry, ml))
    print(f"  c={c}, max_entry={max_entry}: {len(parts_list)} partitions, searching {len(parts_list)**3} triples")
    
    count = 0
    for lam0 in parts_list:
        for lam1 in parts_list:
            for lam2 in parts_list:
                lams = [lam0, lam1, lam2]
                # Check interlacing
                valid = True
                for i in range(k):
                    ip1 = (i + 1) % k
                    cip1 = c[ip1]
                    for j in range(ml):
                        val_i = lams[i][j] if j < len(lams[i]) else 0
                        jc = j + cip1
                        val_ip1 = lams[ip1][jc] if jc < len(lams[ip1]) else 0
                        if val_i < val_ip1:
                            valid = False
                            break
                    if not valid:
                        break
                
                if valid:
                    size = sum(sum(l) for l in lams)
                    count += 1
                    result += q**size
    
    print(f"  Found {count} CPs")
    return result

# For d=2, compute F_{c,0}, F_{c,1}
for c in [(1,1,0), (2,0,0), (0,1,1)]:
    print(f"\nProfile {c}:")
    for n in range(3):
        Fcn = enum_CPs(c, n, max_len=6)
        print(f"  F_{{{c},{n}}} = {Fcn}")
