from em.online_expectation_maximization import OnlineExpectationMaximization
import numpy as np
from evaluation.helpers import *
import matplotlib.pyplot as plt
import time
from scipy.stats import random_correlation, norm, expon
import pandas as pd
import itertools
from collections import defaultdict

def onlineEM_predict(X, window_size=100, decay_coef=0.5, n_train = 400, BATCH_SIZE = 40, nsample=200, seed = 1, CP = False, type = ['F','S','N'], name = None):
    n,p = X.shape
    ptrue = p//2
    
    error_trials = []
    
    # only continuous variables
    cont_indices = np.array([True] * p)
    ord_indices = np.array([False] * p)

    # online 
    oem = OnlineExpectationMaximization(cont_indices, ord_indices, window_size=window_size)
    oem.partial_fit_and_predict(X[:n_train,:], decay_coef=decay_coef)
        
    sigma_diff = defaultdict(list)
    sigma_old = oem.get_sigma()
    
    if CP:
        pvalues = {t:[] for t in type}
        test_stats = {t:[] for t in type}
    
    j = 0
    while True:
        start = j * BATCH_SIZE + n_train 
        end = np.min(((j+1) * BATCH_SIZE + n_train,n))
        if start >= n: 
            break

        # prediction
        X_batch = np.zeros((end-start, p))
        X_batch[:,:ptrue] = X[start:end,:ptrue] # observe yeterday's data
        X_batch[:,ptrue:] = np.nan # mask today's data
        X_imp = oem.partial_fit_and_predict(X_batch, decay_coef=decay_coef, sigma_update = False, marginal_update = False)
        # Evaluate 
        error_trials.append(
            [get_mae(X_imp[:,ptrue:], X[start:end, ptrue:]),
            get_rmse(X_imp[:,ptrue:], X[start:end, ptrue:])])
        #print(error_trials[-1])
        
        # reveal information
        X_batch_reveal = np.copy(X[start:end,:])
        oem._init_sigma(sigma_old) # only update model parameters on full observation
        if CP:
            _, pval_iter, s_iter = oem.change_point_test(X_batch_reveal, decay_coef=decay_coef, nsample=nsample)
            for t in type:
                pvalues[t].append(pval_iter[t])
                test_stats[t].append(s_iter[t])
        else:
            oem.partial_fit_and_predict(X_batch_reveal, decay_coef=decay_coef)
        
        sigma_new = oem.get_sigma()
        d = oem.get_matrix_diff(sigma_old, sigma_new)
        for t in ['F', 'S', 'N']:
            sigma_diff[t].append(d[t])
        sigma_old = sigma_new
        
        j += 1

    error_trials = pd.DataFrame(np.concatenate([np.array(error_trials), np.array(pd.DataFrame(sigma_diff))], axis=1), 
                                columns = ['MAE', "RMSE", 'F', 'S', 'N'])
    if CP:
        pd.DataFrame(pvalues).to_csv('Results/EM_CP_pval_'+name+'.csv')
        pd.DataFrame(test_stats).to_csv('Results/EM_CP_test_stats_'+name+'.csv')
    return error_trials


def get_error(error, loc = 10):
    error_validation = error.iloc[:loc,:].mean(axis=0)
    error_validation = error_validation.rename(index={n:'Validation '+n for n in error_validation.index})
    error_test = error.iloc[loc:,:].mean(axis=0)
    error_test = error_test.rename(index={n:'Test '+n for n in error_test.index})
    return pd.concat([error_validation, error_test], axis=0)

def print_summary(res):
    e = pd.concat([res[key].rename(key) for key in res], axis=1)
    print(e.min(axis=1), e.idxmin(axis=1))
        
  
def main(X, window_size_list, size_list):
    res = {}
    for window,size in itertools.product(window_size_list,size_list):
        res[(window,size)] = get_error(onlineEM_predict(X, window, size))
        print('finish ' + str(window) + ' ' + str(size))
    return res

def main_tuning(path = 'RealData/', window_list = [50, 100, 200]):
    log_return = np.array(pd.read_csv(path + 'pred_log_return_DJIA.csv'))[:,1:]
    res_pred_log_return = main(log_return, window_list, [0.5])
    price = np.array(pd.read_csv(path + 'pred_price_DJIA.csv'))[:,1:]
    res_pred_price = main(price, window_list, [0.5])
    print_summary(res_pred_log_return) # best window 200
    print_summary(res_pred_price) # best window 50
    return res_pred_log_return, res_pred_price

def main_run(CP = False, path = 'RealData/'):
    log_return = np.array(pd.read_csv(path + 'pred_log_return_DJIA.csv'))[:,1:]
    price = np.array(pd.read_csv(path + 'pred_price_DJIA.csv'))[:,1:]
    # log return
    start_time = time.time()
    if CP:
        err_log_return = onlineEM_predict(log_return, 200, CP=CP, name = "Return")
    else:
        err_log_return = onlineEM_predict(log_return, 200)
    end_time = time.time()
    time_log_return = end_time - start_time
    res_log_return = [err_log_return, time_log_return]
    # price 
    start_time = time.time()
    if CP:
        err_price = onlineEM_predict(price, 50, CP=CP, name = "price")
    else:
        err_price = onlineEM_predict(price, 50)
    end_time = time.time()
    time_price = end_time - start_time 
    res_price = [err_price, time_price]
    return res_log_return, res_price

    
def store_res(res_pred_log_return, res_pred_price, path = 'Results/'):
    df = np.concatenate([res_pred_log_return[0], res_pred_price[0]], axis=1)
    df = pd.DataFrame(df, columns = ['return MAE', 'return RMSE', 'return F', 'retrun S', 'return N',
                                     'price MAE', 'price RMSE', 'price F', 'price S', 'price N'])
    df.to_csv(path + "err_EMmethods_stocks.csv", index=False)
    
if __name__ == "__main__":
    # For tuning 
    # res_log_return, res_price = main_tuning()
    # without MC test
    res_pred_log_return, res_pred_price = main_run()
    # with MC test
    #res_pred_log_return, res_pred_price = main_run(True)
    # store result
    store_res(res_pred_log_return, res_pred_price)
    
