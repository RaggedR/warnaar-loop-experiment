"""
Agent A: Correct Q_2 computation with proper precision.
The issue: g_2 needs enumeration up to max_s ~ PREC/(2*3) to get correct coefficients.
For PREC=30, we need max_s >= 5; for PREC=50 we need max_s >= 8.
But the negative tail in Q_2 at high degrees means our g_2 is truncated too early.

The fix: use lower PREC but sufficient max_s.
"""
from sage.all import *

PREC = 30
PR = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = PR.gen()

# d=7, c=(3,2,2)
c = (3, 2, 2)
d = 7

# g_1 
g1 = PR(0)
for s0 in range(PREC):
    for s1 in range(min(s0+c[1]+1, PREC)):
        for s2 in range(min(s1+c[2]+1, PREC)):
            if s0 <= s2+c[0] and max(s0,s1,s2)>=1:
                total = s0+s1+s2
                if total < PREC: g1 += q**total

# g_2: need sufficient enumeration depth
# For each pair (a0,a1,a2,b0,b1,b2), total = a0+a1+a2+b0+b1+b2.
# We need total < PREC. Since we have 6 variables, each can be at most PREC/2.
# But the interlacing constraints limit the range significantly.
# For max_s = PREC//2 = 15, total can reach 6*15 = 90 >> 30. So max_s=15 is overkill.
# The constraint is that total < PREC, and we need to enumerate ALL
# configurations with total < PREC. Let max_s = PREC to be safe.

g2 = PR(0)
max_s = PREC  # each variable can be at most PREC
for a0 in range(max_s):
    for a1 in range(min(a0+c[1]+1, max_s)):
        for a2 in range(min(a1+c[2]+1, max_s)):
            if a0 > a2+c[0]: continue
            for b0 in range(min(a0+1, max_s)):
                for b1 in range(min(b0+c[1]+1, a1+1, max_s)):
                    for b2 in range(min(b1+c[2]+1, a2+1, max_s)):
                        if b0 > b2+c[0]: continue
                        if max(b0,b1,b2)>=1:
                            total = a0+a1+a2+b0+b1+b2
                            if total < PREC: g2 += q**total

Q2 = (1-q)*(1-q**2)*g2 - (1-q**2)*q*g1 + q**3
coeffs_Q2 = [Q2[i] for i in range(PREC)]
print(f"d=7, c=(3,2,2):")
print(f"Q_2 coeffs: {coeffs_Q2}")
print(f"Q_2(1) = {sum(coeffs_Q2)} (expected {11**2})")
neg = [i for i in range(PREC) if coeffs_Q2[i] < 0]
print(f"Negative: {neg if neg else 'NONE'}")

# Also check d=4
c4 = (2,1,1)
g1_4 = PR(0)
for s0 in range(PREC):
    for s1 in range(min(s0+c4[1]+1, PREC)):
        for s2 in range(min(s1+c4[2]+1, PREC)):
            if s0 <= s2+c4[0] and max(s0,s1,s2)>=1:
                total = s0+s1+s2
                if total < PREC: g1_4 += q**total

g2_4 = PR(0)
for a0 in range(PREC):
    for a1 in range(min(a0+c4[1]+1, PREC)):
        for a2 in range(min(a1+c4[2]+1, PREC)):
            if a0 > a2+c4[0]: continue
            for b0 in range(min(a0+1, PREC)):
                for b1 in range(min(b0+c4[1]+1, a1+1, PREC)):
                    for b2 in range(min(b1+c4[2]+1, a2+1, PREC)):
                        if b0 > b2+c4[0]: continue
                        if max(b0,b1,b2)>=1:
                            total = a0+a1+a2+b0+b1+b2
                            if total < PREC: g2_4 += q**total

Q2_4 = (1-q)*(1-q**2)*g2_4 - (1-q**2)*q*g1_4 + q**3
coeffs_Q2_4 = [Q2_4[i] for i in range(PREC)]
print(f"\nd=4, c=(2,1,1):")
print(f"Q_2 coeffs: {coeffs_Q2_4}")
print(f"Q_2(1) = {sum(coeffs_Q2_4)} (expected {4**2})")
neg4 = [i for i in range(PREC) if coeffs_Q2_4[i] < 0]
print(f"Negative: {neg4 if neg4 else 'NONE'}")

