from em.online_expectation_maximization import OnlineExpectationMaximization
from em.batch_expectation_maximization import BatchExpectationMaximization
import numpy as np
import pandas as pd
from evaluation.helpers import *
import matplotlib.pyplot as plt
from scipy.stats import norm, expon
import itertools
import time

def generate_data(seed=1, NUM_SAMPLES = 2000, MASK_NUM = 2, write = False, path = None):
    i = seed
    sigma1 = generate_sigma(3*i-2)
    sigma2 = generate_sigma(3*i-1)
    sigma3 = generate_sigma(3*i)
    
    mean = np.zeros(sigma1.shape[0])   
    np.random.seed(seed)    
    X1 = np.random.multivariate_normal(mean, sigma1, size=NUM_SAMPLES)
    X2 = np.random.multivariate_normal(mean, sigma2, size=NUM_SAMPLES)
    X3 = np.random.multivariate_normal(mean, sigma3, size=NUM_SAMPLES)
    
    X = np.vstack((X1, X2, X3))
    X[:,:5] = expon.ppf(norm.cdf(X[:,:5]), scale = 3)
    for j in range(5,15,1):
            # 6-10 columns are binary, 11-15 columns are ordinal with 5 levels
        X[:,j] = cont_to_ord(X[:,j], k=2*(j<10)+5*(j>=10), seed = i+j)
        
    X_masked, mask_indices = mask_types(X, MASK_NUM, seed=i)

    if write:
        pd.DataFrame(X).to_csv(path+'sim_online_true_rep'+str(i)+'.csv', index=False)
        pd.DataFrame(X_masked).to_csv(path+'sim_online_masked_rep'+str(i)+'.csv', index=False)

    
    return X_masked, X

def data_writing(path=None, START=1, NUM_RUNS=20):
    for i in range(START, NUM_RUNS+START):
        _, _ = generate_data(seed = i, write = True, path = path)


def EM_evaluate(WINDOW_SIZE = 200, decay_coef=0.5, batch_c=5, NUM_SAMPLES=2000, BATCH_SIZE=40, START=1, NUM_STEPS=10, online = True):
    NUM_BATCH = int(NUM_SAMPLES*3/BATCH_SIZE)
    smae_trials = np.zeros((NUM_STEPS, NUM_BATCH, 3))
    if online:
        test_stats = []
    times = np.zeros(NUM_STEPS)

    for i in range(START, NUM_STEPS+START):
        X_masked, X = generate_data(seed = i, NUM_SAMPLES=NUM_SAMPLES)
        
        # run
        start_time = time.time()
        
        if online:
            cont_indices = np.array([True] * 5 + [False] * 10)
            ord_indices = np.array([False] * 5 + [True] * 10)
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

def monte_carlo_test(START=1, NUM_STEPS=10, NUM_SAMPLES=2000, nsamples = 200, WINDOW_SIZE = 200, BATCH_SIZE=40, decay_coef=0.5, verbose = True, type = ['F', 'S', 'N'], path = None):
    NUM_BATCH = int(NUM_SAMPLES*3/BATCH_SIZE)
    res_pvals = {t:np.zeros((NUM_BATCH,NUM_STEPS)) for t in type}
    res_stats = {t:np.zeros((NUM_BATCH,NUM_STEPS)) for t in type}
    for i in range(START, NUM_STEPS+START):
        X_masked, X = generate_data(seed = i, NUM_SAMPLES = NUM_SAMPLES)
        cont_indices = np.array([True] * 5 + [False] * 10)
        ord_indices = np.array([False] * 5 + [True] * 10)
        oem = OnlineExpectationMaximization(cont_indices, ord_indices, window_size=WINDOW_SIZE)
        pval, test_stat = oem.test_one_pass(X_masked, BATCH_SIZE = BATCH_SIZE, 
                                            nsample = nsamples, decay_coef=decay_coef, verbose = verbose, type =type)
        pval.to_csv(paht + "sim_CP_pvalues_rep_"+str(i)+"_"+ str(nsamples)+".csv")
        test_stat.to_csv(path + "sim_CP_statistics_rep_"+str(i)+"_"+ str(nsamples)+".csv")
        for t in type:
            res_pvals[t][:,i-START] = np.array(pval[t])  
            res_stats[t][:,i-START] = np.array(test_stat[t])
        print('finish iteration '+str(i))
    return res_pvals, res_stats
    

def main_run(WINDOW_SIZE = 200, NUM_SAMPLES=2000,batch_c=5, decay_coef=0.5, BATCH_SIZE=40, START=1, NUM_STEPS=10):
    mean_smae_online, time_online, test_stat = EM_evaluate(WINDOW_SIZE = WINDOW_SIZE, decay_coef=decay_coef, BATCH_SIZE=BATCH_SIZE, START=START, NUM_STEPS=NUM_STEPS, online = True)
    mean_smae_offline, time_offline = EM_evaluate(batch_c=batch_c, BATCH_SIZE=BATCH_SIZE, START=START, NUM_STEPS=NUM_STEPS, online = False)
    return mean_smae_online, mean_smae_offline, test_stat, time_online, time_offline

def main_online_tune(window_list, coef_list, BATCH_SIZE=40, START=11, NUM_STEPS=10):
    res = {}
    for window,coef in itertools.product(window_list,coef_list):
        r = EM_evaluate(window, coef, START = START)
        r = r[0]
        res[(window,coef)] = np.mean(r)
    res = pd.Series(res)
    print(res)
    
def plot_res(mean_smae_offline, mean_smae_online):
    fig = plt.figure()
    ax1 = fig.add_subplot(2, 2, 1)
    ax2 = fig.add_subplot(2, 2, 2)
    ax3 = fig.add_subplot(2, 2, 3)
    axes = [ax1, ax2, ax3]
    titles = ['cont', 'bin', 'ord']
    for i in range(3):
        ax = axes[i]
        ax.plot(mean_smae_offline[:,i], 'k', label = "offline")
        ax.plot(mean_smae_online[:,i], 'g', label = "online")
        ax.legend(loc = 'best')
        ax.set_title(titles[i])
        
def store_res(mean_smae_online, mean_smae_offline, test_stat, path = "/Results/"):
    df = np.concatenate([mean_smae_online, mean_smae_offline], axis=1)
    df = pd.DataFrame(df, columns = ['online cont', 'online bin', 'online ord', 'offline cont', 'offline bin', 'offline ord'])
    df = pd.concat([df, test_stat], axis=1)
    df.to_csv(path + "simonline_EMmethods_smaes.csv", index=False)
    

if __name__ == "__main__":
    #main_online_tune([50, 100, 200], [0.5]) # best window size 200
    #mean_smae_online, mean_smae_offline, test_stat, time_online, time_offline = main_run(WINDOW_SIZE = 200)
    # mean online 26s, offline 21s
    # monte carlo test
    #res_pvals, res_stats = monte_carlo_test(1,10,nsamples=499)

    
