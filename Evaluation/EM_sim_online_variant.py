from em.online_expectation_maximization import OnlineExpectationMaximization
from em.batch_expectation_maximization import BatchExpectationMaximization
import numpy as np
import pandas as pd
from evaluation.helpers import *
import matplotlib.pyplot as plt
from scipy.stats import norm, expon
import itertools
import time

def generate_data(seed=1, NUM_SAMPLES = 2000, MASK_NUM = 2, write = False, path = None, p_type = 5):
    i = seed
    sigma1 = generate_sigma(3*i-2, dim = 3*p_type)
    sigma2 = generate_sigma(3*i-1, dim = 3*p_type)
    sigma3 = generate_sigma(3*i, dim = 3*p_type)
    
    mean = np.zeros(sigma1.shape[0])   
    np.random.seed(seed)    
    X1 = np.random.multivariate_normal(mean, sigma1, size=NUM_SAMPLES)
    X2 = np.random.multivariate_normal(mean, sigma2, size=NUM_SAMPLES)
    X3 = np.random.multivariate_normal(mean, sigma3, size=NUM_SAMPLES)
    
    X = np.vstack((X1, X2, X3))
    X[:,:p_type] = expon.ppf(norm.cdf(X[:,:p_type]), scale = 3)
    for j in range(p_type,p_type*3,1):
            # 6-10 columns are binary, 11-15 columns are ordinal with 5 levels
        X[:,j] = cont_to_ord(X[:,j], k=2*(j<p_type*2)+5*(j>=p_type*2), seed = i+j)
        
    X_masked, mask_indices = mask_types(X, MASK_NUM, seed=i)

    if write:
        name = f"{path}sim_online_rep{i}_maksed_masknum{MASK_NUM}_dim{p_type*3}_n{NUM_SAMPLES}.csv"
        pd.DataFrame(X_masked).to_csv(name, index=False)
        name = f"{path}sim_online_rep{i}_true_masknum{MASK_NUM}_dim{p_type*3}_n{NUM_SAMPLES}.csv"
        pd.DataFrame(X).to_csv(name, index=False)

    
    return X_masked, X



def EM_evaluate(WINDOW_SIZE = 200, decay_coef=0.5, batch_c=5, NUM_SAMPLES=2000, BATCH_SIZE=40, 
                MASK_NUM = 2, p_type =5,
                START=1, NUM_STEPS=10, online = True):
    NUM_BATCH = int(NUM_SAMPLES*3/BATCH_SIZE)
    smae_trials = np.zeros((NUM_STEPS, NUM_BATCH, 3))
    if online:
        test_stats = []
    times = np.zeros(NUM_STEPS)

    for i in range(START, NUM_STEPS+START):
        X_masked, X = generate_data(seed = i, NUM_SAMPLES=NUM_SAMPLES, MASK_NUM = MASK_NUM, p_type = p_type)
        
        # run
        start_time = time.time()
        
        if online:
            cont_indices = np.array([True] * p_type + [False] * p_type * 2)
            ord_indices = np.array([False] * p_type + [True] * p_type * 2)
            oem = OnlineExpectationMaximization(cont_indices, ord_indices, window_size=WINDOW_SIZE)
            X_imp, test_stat = oem.fit_one_pass(X_masked, BATCH_SIZE = BATCH_SIZE, max_workers = 4, sigma_diff_output=True)
            test_stats.append(test_stat)
        else:
            bem = BatchExpectationMaximization() # Switch to batch implementation for acceleration
            X_imp, _ = bem.impute_missing(X_masked, max_workers=4, batch_c=batch_c, max_iter=2*NUM_BATCH)
        
        end_time = time.time()
        times[i-START] = start_time - end_time

        # evaluation 
        j = 0
        Med = np.nanmedian(X_masked,0)
        while j<NUM_BATCH:
            start = j*BATCH_SIZE
            end = (j+1)*BATCH_SIZE
            # imputation error at each batch
            smae_trials[i-START,j,:] = get_smae(X_imp[start:end,:], X[start:end,:], X_masked[start:end,:], Med, True)
            j += 1
    
    mean_smae= np.mean(smae_trials, 0)
    
    res = [mean_smae, times]
    
    if online: 
        num_diff = test_stats[0].shape[0]
        stats = np.zeros((NUM_STEPS, num_diff, 3))
        cols = test_stats[0].columns
        for i in range(NUM_STEPS):
            stats[i,:,:] = np.array(test_stats[i])
        test_stats = pd.DataFrame(np.mean(stats, 0), columns = cols)
        res.append(test_stats)
    
    return res

    
def main_run(WINDOW_SIZE = 200, NUM_SAMPLES=2000,batch_c=5, decay_coef=0.5, BATCH_SIZE=40, START=1, NUM_STEPS=10):
    res = EM_evaluate(WINDOW_SIZE = WINDOW_SIZE, decay_coef=decay_coef, BATCH_SIZE=BATCH_SIZE,
                                                           START=START, NUM_STEPS=NUM_STEPS, online = True)

    return res

def main_run_change_missing(WINDOW_SIZE = 200, NUM_SAMPLES=2000,batch_c=5, decay_coef=0.5, BATCH_SIZE=40, START=1, NUM_STEPS=10):
    res_mask1 = EM_evaluate(WINDOW_SIZE = WINDOW_SIZE, decay_coef=decay_coef, BATCH_SIZE=BATCH_SIZE,
                                                           MASK_NUM = 1,
                                                           START=START, NUM_STEPS=NUM_STEPS, online = True)
    res_mask3 = EM_evaluate(WINDOW_SIZE = WINDOW_SIZE, decay_coef=decay_coef, BATCH_SIZE=BATCH_SIZE, 
                                                           MASK_NUM = 3,
                                                           START=START, NUM_STEPS=NUM_STEPS, online = True)
    return res_mask1, res_mask3

def main_run_change_n(WINDOW_SIZE = 200, batch_c=5, decay_coef=0.5, BATCH_SIZE=40, START=1, NUM_STEPS=10):
    res_n1000 = EM_evaluate(WINDOW_SIZE = WINDOW_SIZE, decay_coef=decay_coef, BATCH_SIZE=BATCH_SIZE,
                            NUM_SAMPLES = 1000,
                            START=START, NUM_STEPS=NUM_STEPS, online = True)
    res_n3000 = EM_evaluate(WINDOW_SIZE = WINDOW_SIZE, decay_coef=decay_coef, BATCH_SIZE=BATCH_SIZE, 
                            NUM_SAMPLES = 3000,
                            START=START, NUM_STEPS=NUM_STEPS, online = True)
    return res_n1000, res_n3000

def main_run_change_p(WINDOW_SIZE = 200, NUM_SAMPLES=2000,batch_c=5, decay_coef=0.5, BATCH_SIZE=40, START=1, NUM_STEPS=10):
    res_p30 = EM_evaluate(WINDOW_SIZE = WINDOW_SIZE, decay_coef=decay_coef, BATCH_SIZE=BATCH_SIZE,
                          p_type = 10, MASK_NUM = 4,
                          START=START, NUM_STEPS=NUM_STEPS, online = True)
    res_p45 = EM_evaluate(WINDOW_SIZE = WINDOW_SIZE, decay_coef=decay_coef, BATCH_SIZE=BATCH_SIZE, 
                          p_type = 15, MASK_NUM = 6,
                          START=START, NUM_STEPS=NUM_STEPS, online = True)
    return res_p30, res_p45


        
    

if __name__ == "__main__":
    #main_online_tune([50, 100, 200], [0.5]) # best window size 200
    #mean_smae_online, mean_smae_offline, test_stat, time_online, time_offline = main_run(WINDOW_SIZE = 200)
    # mean online 26s, offline 21s
    res_default = main_run()
    res_n1000, res_n3000 = main_run_change_n()
    res_p30, res_p45 = main_run_change_p()

    
