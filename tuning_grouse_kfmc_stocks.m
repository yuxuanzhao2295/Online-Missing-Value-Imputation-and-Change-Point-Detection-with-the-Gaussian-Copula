[kfmc_pred_err_return, kfmc_pred_err_price] = main_onlieKFMC_predict_stocks([200 300 400], [.1 .01 .001], 400, 40, 25);
% MAE-validation, MAE-test, RMSE-validation, RMSE-test
% no difference for return
% best (200, 0.001)


[grouse_pred_err_return, grouse_pred_err_price] = main_GROUSE_predict_stocks([1 5 10], [1e-6 1e-4 1e-2], 400, 40, 100);
% best for return (1, 1e-6 or 1e-4)
% best for price (5, 1e-6)