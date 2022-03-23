from gcimpute.gaussian_copula import GaussianCopula
from gcimpute.helper_data import generate_sigma, generate_mixed_from_gc
from gcimpute.helper_evaluation import get_smae, get_scaled_error
from gcimpute.helper_mask import mask_types
import numpy as np
import pandas as pd
import time
from tqdm import tqdm
from collections import defaultdict
import sys
import argparse


def run_onerep(seed, batch_size=40, batch_c=0, online=False, max_workers=4):
	X = pd.read_csv(f'SimData/sim_offline_true_rep{seed}.csv').to_numpy()
	X_masked = pd.read_csv(f'SimData/sim_offline_masked_rep{seed}.csv').to_numpy()
	# model fitting
	
	p = X.shape[1]
	start_time = time.time()
	if online:
		training_mode = 'minibatch-online'
		stepsize_func=lambda k, c=batch_c:c/(k+c)
		gc = GaussianCopula(training_mode=training_mode, 
						    stepsize_func=stepsize_func, 
						    const_stepsize=None, 
						    batch_size=batch_size, 
						    random_state=seed, 
						    n_jobs=max_workers,
						    window_size=200,
						    realtime_marginal=False
						    )
	else:
		if batch_c>0:
			training_mode = 'minibatch-offline'
			stepsize_func=lambda k, c=batch_c:c/(k+c)
		else:
			training_mode = 'standard'
			stepsize_func = None
		gc = GaussianCopula(training_mode=training_mode, 
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
	smae = get_smae(X_imp, X, X_masked)
	output = {'runtime':end_time - start_time, 'smae':smae}
	return output
	
def main(f, NUM_STEPS=10, batch_size=40, batch_c=0, online=False, max_workers=4):
	if online:
		print(f'Online EM Results using {max_workers} workers: ', file=f)
	elif batch_c>0:
		print(f'Minibatch EM Results using {max_workers} workers: ', file=f)
	else:
		print(f'Offline EM Results using {max_workers} workers: ', file=f)

	output_all = defaultdict(list)

	for i in tqdm(range(1, NUM_STEPS + 1)):
		output = run_onerep(seed=i, batch_size=batch_size, batch_c=batch_c, online=online, max_workers=max_workers)
		for name, value in output.items():
			output_all[name].append(value)

	# restults
	for name,value in output_all.items():
		output_all[name] = np.array(value)

	text = f"Runtime in seconds: mean {output_all['runtime'].mean():.2f}, std {output_all['runtime'].std():.2f}"
	print(text, file=f)

	mean_smaes = np.mean(output_all['smae'],axis=0)
	std_smaes = np.std(output_all['smae'],axis=0)

	var_types = {'cont':list(range(5)), 'ord':list(range(5, 10)), 'bin':list(range(10, 15))}

	for name,value in var_types.items():
		text = f'{name} imputation SMAE: mean {mean_smaes[value].mean():.3f}, std {mean_smaes[value].std():.3f}'
		print(text, file=f)



if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument('-r', '--rep', default=10, type=int, help='number of repetitions to run')
	parser.add_argument('-w', '--workers', default=1, type=int, help='number of parallel workers to use')
	args = parser.parse_args()

	#with open('output_sim_offline.txt', 'wt') as f:
	with open('Results/output_sim_offline.txt', 'at') as f:
		main(f=f, NUM_STEPS=args.rep, max_workers=args.workers, batch_c=0, online=False)
		main(f=f, NUM_STEPS=args.rep, max_workers=args.workers, batch_c=5, online=False)
		main(f=f, NUM_STEPS=args.rep, max_workers=args.workers, batch_c=5, online=True)





