% fill out the path and add all subfolders to path for simplicity
%path = '/path/Online-Missing-Value-Imputation-Dependence-Change-Detection-for-Mixed-Data'
%addpath(genpath(path));


% tuning
% [kfmc_pred_err_return, kfmc_pred_err_price] = main_onlieKFMC_predict_stocks([200 300 400], [.1 .01 .001], 400, 40, 25);
% best: (price, mae, rank 300, beta 0.1; rmse, same) (return, all the same )

% run with best parameters
[kfmc_err_return, kfmc_err_price, ~, ~] = onlineKFMC_predict_stock(200, 0.1, 400, 40, 25, true);
% write data:
% writematrix([kfmc_err_return, kfmc_err_price],strcat(path, '/Evaluation/Results/stocks_kfmc_err.csv')) 


% tuning
[grouse_pred_err_return, grouse_pred_err_price] = main_GROUSE_predict_stocks([1 5 10], [1e-6 1e-4 1e-2], 400, 40, 100);
% best (1, 1e-6) return (10, 1e-6) price

% run with best parameters
[grouse_err_return, grouse_err_price, grouse_r_return, grouse_r_price, ~, ~] = GROUSE_predict_stock(1, 1e-6, 400, 40, 100, 10, 1e-6);
%writematrix([grouse_err_return, grouse_err_price, grouse_r_return, grouse_r_price],strcat(path, '/Evaluation/Results/stocks_grouse_err.csv')) 

