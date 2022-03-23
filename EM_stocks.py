from gcimpute.gaussian_copula import GaussianCopula
from gcimpute.helper_evaluation import get_error_batch
import numpy as np
import matplotlib.pyplot as plt
import time
import pandas as pd
import pickle
import argparse

def onlineEM_predict(X, Xtrue, window_size=100, decay_coef=0.5, n_train = 400, BATCH_SIZE = 40, seed=131, max_workers=4, realtime_marginal=False):
    gc = GaussianCopula(training_mode='minibatch-online', 
                        const_stepsize=decay_coef, 
                        realtime_marginal=realtime_marginal,
                        batch_size=BATCH_SIZE,
                        random_state=seed, 
                        n_jobs=max_workers)

    X_imp = gc.fit_transform(X=X, X_true=Xtrue, n_train=n_train)
    corr_change = np.array(gc.corr_diff['F'])
    error = get_error_batch(X_imp[n_train:], Xtrue[n_train:], X[n_train:], batch_size = BATCH_SIZE, error_type = 'RMSE')

    return {'corr_change':corr_change, 'RMSE':np.array(error)}


def main(data, **kwargs):
    if data == 'price':
        path = 'RealData/pred_price_DJIA.csv'
    elif data == 'log_return':
        path = 'RealData/pred_log_return_DJIA.csv'
    else:
        raise

    Xtrue = pd.read_csv(path).to_numpy()
    X = Xtrue.copy()
    X[:,-30:]=np.nan

    out = onlineEM_predict(X=X, Xtrue=Xtrue, **kwargs)
    return out

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-r', '--realtime', default=0, type=int, help='whether to use realtime marginal')
    parser.add_argument('-w', '--workers', default=4, type=int, help='number of parallel workers to use')
    args = parser.parse_args()

    window_grid = [50, 100, 150, 200]

    res_all = {}
    for window in window_grid:
        res = {}
        res['price'] = main(data='price', window_size=window, max_workers=args.workers, realtime_marginal=args.realtime>0)
        res['log_return'] = main(data='log_return', window_size=window, max_workers=args.workers, realtime_marginal=args.realtime>0)
        res_all[window] = res

    path = 'Results/res_stocks_EM'
    if args.realtime>0:
        path += '_realtime'
    path += '.pickle'
    with open(path, 'wb') as f:
        pickle.dump(res_all, f)