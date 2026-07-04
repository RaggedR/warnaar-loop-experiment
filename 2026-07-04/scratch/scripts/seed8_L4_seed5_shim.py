# shim: import test() from seed5_R2L4_betaset.py without running its __main__
import importlib.util
spec = importlib.util.spec_from_file_location("betaset",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L4_betaset.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)   # __name__ != "__main__" so case list won't run
test = mod.test
