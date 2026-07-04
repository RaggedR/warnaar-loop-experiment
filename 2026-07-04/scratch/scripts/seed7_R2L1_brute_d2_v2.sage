# Redo brute force for d=2, profile (1,1,0), max=1, with larger max_len
R = PolynomialRing(QQ, 'q')
q = R.gen()

def enum_CPs(c, max_entry, max_len):
    """Count CPs of profile c with max entry <= max_entry, parts length <= max_len."""
    k = 3
    result = R(0)
    
    def gen_partitions(max_val, length):
        if length == 0:
            yield ()
            return
        for v in range(max_val + 1):
            for rest in gen_partitions(v, length - 1):
                yield (v,) + rest
    
    parts_list = list(gen_partitions(max_entry, max_len))
    count = 0
    
    for lam0 in parts_list:
        for lam1 in parts_list:
            for lam2 in parts_list:
                lams = [lam0, lam1, lam2]
                valid = True
                for i in range(k):
                    ip1 = (i + 1) % k
                    cip1 = c[ip1]
                    for j in range(max_len):
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
    
    return result, count

c = (1, 1, 0)
for ml in [6, 8, 10, 12]:
    F_bounded, cnt = enum_CPs(c, 1, ml)
    print(f"max_len={ml}: {cnt} CPs, F^bounded_1 = {F_bounded}")
