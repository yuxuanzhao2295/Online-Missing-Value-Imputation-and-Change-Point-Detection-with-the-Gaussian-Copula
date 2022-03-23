from gcimpute.helper_data import generate_sigma, generate_mixed_from_gc
from gcimpute.helper_evaluation import get_smae, get_scaled_error
from gcimpute.helper_mask import mask_types, mask_MCAR
import numpy as np
import pandas as pd
import time
from tqdm import tqdm
from collections import defaultdict
import sys
import argparse

def write_sim_offline(START=1, NUM_RUNS=20, NUM_SAMPLES=2000, MASK_NUM=2, var_types=None):
	if var_types is None:
		var_types = {'cont':list(range(5)), 'ord':list(range(5, 10)), 'bin':list(range(10, 15))}

	for seed in range(START, NUM_RUNS+START):
		X = generate_mixed_from_gc(n=NUM_SAMPLES, seed=seed, var_types=var_types, cutoff_by='quantile', qmin=0.4, qmax=0.6)
		X_masked = mask_types(X, MASK_NUM, seed=seed, var_types=var_types)
		pd.DataFrame(X).to_csv('SimData/sim_offline_true_rep'+str(seed)+'.csv', index=False)
		pd.DataFrame(X_masked).to_csv('SimData/sim_offline_masked_rep'+str(seed)+'.csv', index=False)

	return 

def write_sim_online(START=1, NUM_RUNS=20, NUM_SAMPLES=2000, MASK_NUM=2, var_types=None):
	if var_types is None:
		var_types = {'cont':list(range(5)), 'ord':list(range(5, 10)), 'bin':list(range(10, 15))}

	for seed in range(START, NUM_RUNS+START):
		sigma = [generate_sigma(seed+i, p=sum([len(value) for value in var_types.values()])) for i in range(3)]
		X = generate_mixed_from_gc(sigma=sigma, n=NUM_SAMPLES, seed=seed, var_types=var_types, cutoff_by='quantile', qmin=0.4, qmax=0.6)
		X_masked = mask_types(X, MASK_NUM, seed=seed*2, var_types=var_types)

		pd.DataFrame(X).to_csv('SimData/sim_online_true_rep'+str(seed)+'.csv', index=False)
		pd.DataFrame(X_masked).to_csv('SimData/sim_online_masked_rep'+str(seed)+'.csv', index=False)

	return 


def write_movielens(NUM_STEPS=10, MASK_FRACTION=0.1):
	df = pd.read_csv("RealData/data_movielens1m_1000rating.csv").to_numpy()
	# 10 percent for validation, only used when tuning parameter is needed
	X_traintest = mask_MCAR(df, 0.1, seed=1) 
	pd.DataFrame(X_traintest).to_csv("RealData/data_movielens1m_traintest.csv", index=False)
	for seed in range(1, NUM_STEPS + 1):
		# another 10% for test
		X_masked = mask_MCAR(X_traintest, MASK_FRACTION, seed=seed) 
		pd.DataFrame(X_masked).to_csv("RealData/data_movielens1m_masked_"+str(seed)+".csv", index=False)


if __name__ == "__main__":
	write_sim_offline()
	write_sim_online()
	write_movielens()