function [error_return, error_price, time_return, time_price] = onlineKFMC_predict_stock(rank, beta, n_train, BATCH_SIZE, num_iter, allerror)
X_return = readtable('/RealData/pred_log_return_DJIA.csv', 'HeaderLines',1);
X_price = readtable('/RealData/pred_price_DJIA.csv', 'HeaderLines',1);
% log return
tic
error_return = onlineKFMC_predict(X_return, rank, beta, n_train, BATCH_SIZE, num_iter);
time_return = toc;
% price
tic
error_price = onlineKFMC_predict(X_price, rank, beta, n_train, BATCH_SIZE, num_iter);
time_price = toc;

if nargin ==5
    error_return = get_error(error_return);
    error_price = get_error(error_price);
end
