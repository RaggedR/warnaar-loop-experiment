#!/usr/bin/env python3
"""Seed 8, Mission A remainder: extend Seed 5's Q1/Q2 (beta-locality/totality)
to higher (d,m,W) than their 15 cases (they went d<=8, m<=4, W<=13)."""
import sys
sys.path.insert(0, '.')
from seed8_L4_seed5_shim import test  # reuse test() from betaset via shim

if __name__ == "__main__":
    q1all = q2all = True
    for (d, c, m, W) in [(10, (4, 3, 3), 2, 11), (10, (4, 3, 3), 3, 12),
                         (10, (0, 5, 5), 3, 12), (10, (10, 0, 0), 3, 12),
                         (11, (4, 4, 3), 2, 11), (11, (4, 4, 3), 3, 12),
                         (13, (5, 4, 4), 2, 11), (13, (5, 4, 4), 3, 12),
                         (13, (13, 0, 0), 3, 12), (7, (7, 0, 0), 3, 12),
                         (8, (0, 1, 7), 3, 12), (5, (3, 1, 1), 4, 13),
                         (4, (2, 1, 1), 5, 14), (2, (1, 1, 0), 5, 14)]:
        a, b = test(d, c, m, W)
        q1all &= a; q2all &= b
    print(f"=== SEED8 Q1-EXT SUMMARY: Q1 {'ALL HOLD' if q1all else 'FAILS somewhere'}; "
          f"Q2 {'ALL HOLD' if q2all else 'FAILS somewhere'} ===")
