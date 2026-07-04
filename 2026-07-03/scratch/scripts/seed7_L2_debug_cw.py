"""Debug the CW profile shifts for c = (3,2,2)."""
from itertools import combinations

def profile_shifts(c_tuple):
    k = len(c_tuple)
    I_c = [i for i in range(k) if c_tuple[i] > 0]
    results = []
    for size in range(1, len(I_c) + 1):
        for J in combinations(I_c, size):
            J_set = set(J)
            c_J = list(c_tuple)
            for i in range(k):
                i_prev = (i - 1) % k
                if i in J_set and i_prev not in J_set: c_J[i] -= 1
                elif i not in J_set and i_prev in J_set: c_J[i] += 1
            c_J = tuple(c_J)
            if any(x < 0 for x in c_J):
                results.append((set(J), c_J, "INVALID"))
            else:
                results.append((set(J), c_J, "OK"))
    return results

# Trace the recursion tree for (3,2,2)
def trace(c, depth=0, seen=None):
    if seen is None: seen = set()
    c = tuple(c)
    prefix = "  " * depth
    if c in seen:
        print(f"{prefix}{c} <-- CYCLE!")
        return
    seen.add(c)

    if sum(c) == 0:
        print(f"{prefix}{c} [BASE CASE]")
        return

    shifts = profile_shifts(c)
    print(f"{prefix}{c}")
    for J, cJ, status in shifts:
        sign = (-1)**(len(J)-1)
        if status == "INVALID":
            print(f"{prefix}  J={J}: c(J)={cJ} INVALID")
        else:
            print(f"{prefix}  J={J}: c(J)={cJ} sign={'+' if sign > 0 else '-'}")
            if sum(cJ) == sum(c):  # d is preserved
                trace(cJ, depth+2, set(seen))
            else:
                print(f"{prefix}    d changed from {sum(c)} to {sum(cJ)}! BUG")

print("Tracing profile shifts for c = (3,2,2):")
print()
# Just show first two levels
shifts = profile_shifts((3,2,2))
for J, cJ, status in shifts:
    sign = (-1)**(len(J)-1)
    if status != "INVALID":
        print(f"J={J}: c(J)={cJ} sign={'+' if sign > 0 else '-'}")
        shifts2 = profile_shifts(cJ)
        for J2, cJ2, status2 in shifts2:
            if status2 != "INVALID":
                sign2 = (-1)**(len(J2)-1)
                print(f"  J={J2}: c(J)={cJ2} sign={'+' if sign2 > 0 else '-'}")
