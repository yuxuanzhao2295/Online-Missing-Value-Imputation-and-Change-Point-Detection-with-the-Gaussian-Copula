function [error_return, error_price, residual_return, residual_stock, time_return, time_price] = GROUSE_predict_stock(maxrank, step_size, n_train, BATCH_SIZE, maxcycle, rank_price, stepsize_price)
X_return = readtable('/RealData/pred_log_return_DJIA.csv','TreatAsEmpty',{'NA'});
X_return = X_return(:, 1:60);
X_price = readtable('/RealData/pred_price_DJIA.csv', 'TreatAsEmpty',{'NA'});
X_price = X_price(:, 1:60);
% return 
tic
[error_return, residual_return] = GROUSE_predict(X_return, maxrank, step_size, n_train, BATCH_SIZE, maxcycle);
time_return = toc;
% price
if nargin > 5
    maxrank = rank_price;
    step_size = stepsize_price;
end
tic
[error_price, residual_stock] = GROUSE_predict(X_price, maxrank, step_size, n_train, BATCH_SIZE, maxcycle);
time_price = toc;

if nargin == 5
    error_return = get_error(error_return);
    error_price = get_error(error_price);
end
end
