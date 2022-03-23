from gcimpute.gaussian_copula import GaussianCopula
from gcimpute.helper_data import generate_sigma, generate_mixed_from_gc
from gcimpute.helper_evaluation import get_smae, get_smae_batch
from gcimpute.helper_mask import mask_types
import numpy as np
import pandas as pd
import time
from tqdm import tqdm
from collections import defaultdict
import sys
import argparse
import pickle


def run_onerep(seed, batch_size=40, batch_c=5, online=False, max_workers=4):
	X = pd.read_csv(f'SimData/sim_online_true_rep{seed}.csv').to_numpy()
	X_masked = pd.read_csv(f'SimData/sim_online_masked_rep{seed}.csv').to_numpy()
	# model fitting
	
	p = X.shape[1]
	start_time = time.time()
	if online:
		gc = GaussianCopula(training_mode='minibatch-online', 
						    const_stepsize=0.5, 
						    batch_size=batch_size, 
						    random_state=seed, 
						    n_jobs=max_workers,
						    window_size=200,
						    realtime_marginal=False
						    )
	else:
		stepsize_func=lambda k, c=batch_c:c/(k+c)
		gc = GaussianCopula(training_mode='minibatch-offline', 
						    stepsize_func=stepsize_func, 
						    const_stepsize=None, 
						    batch_size=batch_size, 
						    random_state=seed, 
						    n_jobs=max_workers,
						    num_pass=2
						    )

	X_imp = gc.fit_transform(X_masked)
	end_time = time.time()
	# save results 
	var_types = {'cont':list(range(5)), 'ord':list(range(5, 10)), 'bin':list(range(10, 15))}
	smae = get_smae_batch(X_imp, X, X_masked, batch_size=batch_size, per_type=True, var_types=var_types)
	df = pd.DataFrame(smae)
	if online:
		df['corr_diff'] = pd.Series([0] + gc.corr_diff['F'])
	return df
	
def main(NUM_STEPS=10, **kwargs):
	smaes = []

	for i in tqdm(range(1, NUM_STEPS + 1)):
		output = run_onerep(seed=i, **kwargs)
		smaes.append(output)

	smaes_mean = sum(smaes)/NUM_STEPS
	return smaes_mean

if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument('-r', '--rep', default=10, type=int, help='number of repetitions to run')
	parser.add_argument('-w', '--workers', default=1, type=int, help='number of parallel workers to use')
	args = parser.parse_args()

	res = {}
	res['online_EM'] = main(NUM_STEPS=args.rep, max_workers=args.workers, batch_c=0, online=True)
	res['offline_EM'] = main(NUM_STEPS=args.rep, max_workers=args.workers, batch_c=5, online=False)
	with open('Results/res_sim_online_EM.pickle', 'wb') as f:
		pickle.dump(res, f)

