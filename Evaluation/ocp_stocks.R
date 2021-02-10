# stock predict price
Xprice = read.csv("/Users/yuxuan/Box/imputation/python_files/stocks/pred_price_DJIA.csv")[,-1]

# stock predict log return
Xreturn = read.csv("/Users/yuxuan/Box/imputation/python_files/stocks/pred_log_return_DJIA.csv")[,-1]

res_tuning_price = tuning_ocp(list(Xprice[1:800,]), num = 9, verbose = TRUE, seed= 2)
res_tuning_return = tuning_ocp(list(Xreturn[1:800,]), num = 9, verbose = TRUE, seed= 3)

n = 850
sim_para_return = res_tuning_return$para_best
ocp_return =  onlineCPD(Xreturn[1:n,], missPts = 'mean',
                        hazard_func = function(x, lambda) {const_hazard(x, lambda = sim_para_return$lambda)},
                        init_params = list(sim_para_return$init_para), multivariate =  TRUE)

sim_para_price = res_tuning_price$para_best
ocp_price =  onlineCPD(Xprice[1:n,], missPts = 'mean',
                       hazard_func = function(x, lambda) {const_hazard(x, lambda = sim_para_price$lambda)},
                       init_params = list(sim_para_price$init_para), multivariate =  TRUE)
