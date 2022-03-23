% fill out the path and add all subfolders to path for simplicity
%path = '/path/Online-Missing-Value-Imputation-Dependence-Change-Detection-for-Mixed-Data'
%addpath(genpath(path));



% run with best parameters
[kfmc_err_return, kfmc_err_price, ~, ~] = onlineKFMC_predict_stock(200, 0.001, 400, 40, 25, true);
% write data:
writematrix([kfmc_err_return, kfmc_err_price], 'Results/stocks_kfmc_err.csv')


% tuning

% best (1, 1e-6) return (5, 1e-6) price

% run with best parameters
[grouse_err_return, grouse_err_price, grouse_r_return, grouse_r_price, ~, ~] = GROUSE_predict_stock(1, 1e-6, 400, 40, 100, 5, 1e-6);
writematrix([grouse_err_return, grouse_err_price, grouse_r_return, grouse_r_price], 'Results/stocks_grouse_err.csv') 

