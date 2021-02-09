import numpy as np
from em.expectation_maximization import ExpectationMaximization
from em.batch_expectation_maximization import BatchExpectationMaximization
from em.online_expectation_maximization import OnlineExpectationMaximization
from scipy.stats import random_correlation, norm, expon
from evaluation.helpers import *
import pandas as pd
import time

def read_data(path = None, write = False):
    df = pd.read_csv(path + "data_movielens1m_1000rating.csv").to_numpy()
    #pd.DataFrame(df).to_csv("/data_movielens1m_1000rating.csv", index = False)
    X_masked, validation_indices, _ = mask(df, 0.1, seed=1) # 10 percent for validation, only used when tuning parameter is needed
    if write:
        pd.DataFrame(X_masked).to_csv(path + "data_movielens1m_traintest.csv", index = False)
    return X_masked, validation_indices

def data_writing(NUM_STEPS=10, MASK_FRACTION=0.1, path = None):
    X_traintest, validation_indices = read_data()
    seed_last = 0
    for i in range(1, NUM_STEPS + 1):
        X_masked, mask_indices, seed_last = mask(X_traintest, MASK_FRACTION, seed=seed_last+1) # another 10% for test
        pd.DataFrame(X_masked).to_csv(path + "data_movielens1m_masked_"+str(i)+".csv", index=False)
    

def main(MASK_FRACTION = 0.1, WINDOW_SIZE=200, batch_c = 5, MAX_ITER = 100, BATCH_SIZE = 121, NUM_STEPS = 10, path = None, write = False):
    X_traintest, validation_indices = read_data()
    X = X_traintest
    seed_last = 0
    mae = np.zeros((NUM_STEPS, 6))
    rmse = np.zeros((NUM_STEPS, 6))
    times = np.zeros((NUM_STEPS, 6))

    for i in range(1, NUM_STEPS + 1):
        X_masked, mask_indices, seed_last = mask(X_traintest, MASK_FRACTION, seed=seed_last+1) # another 10% for test
        if write:
            pd.DataFrame(X_masked).to_csv(path + "data_movielens1m_masked_"+str(i)+".csv", index=False)

        # STANDARD EM: one core 
        em = ExpectationMaximization()
        start_time = time.time()
        X_imp, sigma_imp = em.impute_missing(X_masked, max_workers=1)
        times[i-1,0] = time.time() - start_time
        rmse[i-1,0] = get_rmse(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])
        mae[i-1,0] = get_mae(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])
        
        # STANDARD EM: four cores
        em = ExpectationMaximization()
        start_time = time.time()
        X_imp, sigma_imp = em.impute_missing(X_masked, max_workers=4)
        times[i-1,1]= time.time() - start_time
        rmse[i-1,1]= get_rmse(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])
        mae[i-1,1] = get_mae(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])

        # OFFLINE MINIBATCH EM: one core
        bem = BatchExpectationMaximization()
        start_time = time.time()
        X_imp, sigma_imp = bem.impute_missing(np.copy(X_masked), max_iter=MAX_ITER, batch_size=BATCH_SIZE, batch_c =batch_c, max_workers=1)
        times[i-1,2] = time.time() - start_time
        rmse[i-1,2] = get_rmse(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])
        mae[i-1,2] = get_mae(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])
        
        # OFFLINE MINIBATCH EM: four cores
        bem = BatchExpectationMaximization()
        start_time = time.time()
        X_imp, sigma_imp = bem.impute_missing(np.copy(X_masked), max_iter=MAX_ITER, batch_size=BATCH_SIZE, batch_c =batch_c, max_workers=4)
        times[i-1,3]= time.time() - start_time
        rmse[i-1,3]= get_rmse(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])
        mae[i-1,3] = get_mae(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])

        n, p = X_masked.shape
        cont_indices = [False] * p
        ord_indices = [True] * p
        # ONLINE EM: one core

        oem = OnlineExpectationMaximization(cont_indices, ord_indices, window_size=WINDOW_SIZE)
        start_time = time.time()
        X_imp = oem.fit_multiple_pass(X_masked, BATCH_SIZE = BATCH_SIZE, batch_c = batch_c,  max_workers = 1)
        times[i-1,4]= time.time() - start_time
        rmse[i-1,4]= get_rmse(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])
        mae[i-1,4] = get_mae(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])

        # ONLINE EM: four cores
        oem = OnlineExpectationMaximization(cont_indices, ord_indices, window_size=WINDOW_SIZE)
        start_time = time.time()
        X_imp = oem.fit_multiple_pass(X_masked, BATCH_SIZE = BATCH_SIZE, batch_c = batch_c,  max_workers = 4)
        times[i-1,5]= time.time() - start_time
        rmse[i-1,5]= get_rmse(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])
        mae[i-1,5] = get_mae(X_imp[mask_indices[:,0], mask_indices[:,1]], X[mask_indices[:,0], mask_indices[:,1]])
        print('finish iteration '+str(i))
    
    return times, rmse, mae


if __name__ == "__main__":
    times, rmse, mae = main()
    print("run time: ")
    print(np.mean(times,0))
    print(np.std(times,0))
    #
    print("rmse: ")
    print(np.mean(rmse,0))
    print(np.std(rmse,0))
    #
    print("mae: ")
    print(np.mean(mae,0))
    print(np.std(mae,0))