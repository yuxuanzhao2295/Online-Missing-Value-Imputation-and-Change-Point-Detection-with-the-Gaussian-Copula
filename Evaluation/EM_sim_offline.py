import numpy as np
from em.expectation_maximization import ExpectationMaximization
from em.batch_expectation_maximization import BatchExpectationMaximization
from em.online_expectation_maximization import OnlineExpectationMaximization
from scipy.stats import norm, expon
from evaluation.helpers import *
import pandas as pd
import time
import os
import sys

def generate_data(seed=1, NUM_SAMPLES = 2000, MASK_NUM = 2, write = False):
    i = seed
    sigma = generate_sigma(i)
    mean = np.zeros(sigma.shape[0])   
    np.random.seed(seed)    
    X = np.random.multivariate_normal(mean, sigma, size=NUM_SAMPLES)
   
    X[:,:5] = expon.ppf(norm.cdf(X[:,:5]), scale = 3)
    for j in range(5,15,1):
            # 6-10 columns are binary, 11-15 columns are ordinal with 5 levels
        X[:,j] = cont_to_ord(X[:,j], k=2*(j<10)+5*(j>=10), seed = i+j)
        
    X_masked, mask_indices = mask_types(X, MASK_NUM, seed=i)

    if write:
        path = os.getcwd() + '/SimData/'
        pd.DataFrame(X).to_csv(path+'sim_offline_true_rep'+str(i)+'.csv', index=False)
        pd.DataFrame(X_masked).to_csv(path+'sim_offline_masked_rep'+str(i)+'.csv', index=False)

    
    return X_masked, X, sigma

def data_writing(START=1, NUM_RUNS=20):
    for i in range(START, NUM_RUNS+START):
        _, _, _ = generate_data(seed = i, write = True)
        
def get_error(smae):
    return np.array([np.mean(smae[:5]), np.mean(smae[5:10]), np.mean(smae[10:])])

def main(WINDOW_SIZE=200, NUM_SAMPLES=2000,batch_c=5, decay_coef=0.5, BATCH_SIZE=40, START=1, NUM_STEPS=10, write = False):
    scaled_error =  np.zeros((NUM_STEPS, 6))
    smaes =  np.zeros((NUM_STEPS, 3, 6))
    runtimes =  np.zeros((NUM_STEPS, 6))
    
    for i in range(START, NUM_STEPS + START):
        print("starting epoch: " + str(i))
        print("\n")
        X_masked, X, sigma = generate_data(seed = i, NUM_SAMPLES=NUM_SAMPLES, write = write)
        n,p = X.shape
        
        

        # STANDARD EM: one core
        em = ExpectationMaximization()
        start_time = time.time()
        X_imp, sigma_imp = em.impute_missing(X_masked, max_workers=1)
        end_time = time.time()
        runtimes[i-1,0] = end_time - start_time
        scaled_error[i-1,0] = get_scaled_error(sigma_imp, sigma)
        smae = get_smae(X_imp, X, X_masked)
        smaes[i-1,0,0] = np.mean(smae[:5])
        smaes[i-1,1,0] = np.mean(smae[5:10])
        smaes[i-1,2,0] = np.mean(smae[10:])

        # STANDARD EM: four cores
        em = ExpectationMaximization()
        start_time = time.time()
        X_imp, sigma_imp = em.impute_missing(X_masked, max_workers=4)
        end_time = time.time()
        runtimes[i-1,1] = end_time - start_time
        scaled_error[i-1,1] = get_scaled_error(sigma_imp, sigma)
        smae = get_smae(X_imp, X, X_masked)
        smaes[i-1,0,1] = np.mean(smae[:5])
        smaes[i-1,1,1] = np.mean(smae[5:10])
        smaes[i-1,2,1] = np.mean(smae[10:])

        # MINIBATCH EM: one core
        bem = BatchExpectationMaximization()
        start_time = time.time()
        X_imp, sigma_imp = bem.impute_missing(X_masked, batch_size=BATCH_SIZE, batch_c = batch_c, max_workers=1)
        end_time = time.time()
        runtimes[i-1,2] = end_time - start_time
        scaled_error[i-1,2] = get_scaled_error(sigma_imp, sigma)
        smae = get_smae(X_imp, X, X_masked)
        smaes[i-1,0,2] = np.mean(smae[:5])
        smaes[i-1,1,2] = np.mean(smae[5:10])
        smaes[i-1,2,2] = np.mean(smae[10:])

        # MINIBATCH EM: four cores
        bem = BatchExpectationMaximization()
        start_time = time.time()
        X_imp, sigma_imp = bem.impute_missing(X_masked,  batch_size=BATCH_SIZE, batch_c = batch_c, max_workers=4)
        end_time = time.time()
        runtimes[i-1,3] = end_time - start_time
        scaled_error[i-1,3] = get_scaled_error(sigma_imp, sigma)
        smae = get_smae(X_imp, X, X_masked)
        smaes[i-1,0,3] = np.mean(smae[:5])
        smaes[i-1,1,3] = np.mean(smae[5:10])
        smaes[i-1,2,3] = np.mean(smae[10:])
        
        cont_indices = np.array([True] * 5 + [False] * 10)
        ord_indices = np.array([False] * 5 + [True] * 10)
        # ONLINE EM: one core
        oem = OnlineExpectationMaximization(cont_indices, ord_indices, window_size=WINDOW_SIZE)
        start_time = time.time()
        X_imp = oem.fit_multiple_pass(X_masked, BATCH_SIZE = BATCH_SIZE, batch_c = batch_c, max_workers = 1)
        end_time = time.time()
        smae = get_smae(X_imp, X, X_masked)
        runtimes[i-1,4] = end_time - start_time
        scaled_error[i-1,4] = get_scaled_error(oem.get_sigma(), sigma)
        smaes[i-1,0,4] = np.mean(smae[:5])
        smaes[i-1,1,4] = np.mean(smae[5:10])
        smaes[i-1,2,4] = np.mean(smae[10:])
        

        # ONLINE EM: four cores
        oem = OnlineExpectationMaximization(cont_indices, ord_indices, window_size=WINDOW_SIZE)
        start_time = time.time()
        X_imp = oem.fit_multiple_pass(X_masked, BATCH_SIZE = BATCH_SIZE, batch_c = batch_c,  max_workers = 4)
        end_time = time.time()
        smae = get_smae(X_imp, X, X_masked)
        runtimes[i-1,5] = end_time - start_time
        scaled_error[i-1,5] = get_scaled_error(oem.get_sigma(), sigma)
        smaes[i-1,0,5] = np.mean(smae[:5])
        smaes[i-1,1,5] = np.mean(smae[5:10])
        smaes[i-1,2,5] = np.mean(smae[10:])
        
    print_summary(runtimes, smaes, scaled_error)
    return runtimes, smaes, scaled_error

def print_summary(times, smaes, corr_error):
    print("runtime: ")
    print(np.mean(times,0))
    print(np.std(times,0))
    #
    print("smae: ")
    print(np.mean(smaes,0))
    print(np.std(smaes,0))
    #
    print("correlation error: ")
    print(np.mean(corr_error,0))
    print(np.std(corr_error,0))

if __name__ == "__main__":
    # fill out the path 
    # path = "path/Online-Missing-Value-Imputation-Dependence-Change-Detection-for-Mixed-Data/Implementation/EM_Methods"
    # sys.path.append(path)
    # write data
    #data_writing()
    runtimes, smaes, scaled_error = main()

