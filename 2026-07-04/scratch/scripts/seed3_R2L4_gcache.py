"""Cache g (d=7, NMAX=8, PREC=200) from seed3_R2L4_engine to pickle."""
import pickle, sys
import seed3_R2L4_engine as E

if __name__ == "__main__":
    d, NMAX = 7, 8
    g = E.solve_g(d, NMAX)
    with open("seed3_R2L4_g_d7.pkl", "wb") as f:
        pickle.dump({"d": d, "NMAX": NMAX, "PREC": E.PREC, "g": g}, f)
    print("cached", flush=True)
