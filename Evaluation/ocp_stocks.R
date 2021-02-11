# fill up path and set working directory
#setwd("path/Online-Missing-Value-Imputation-Dependence-Change-Detection-for-Mixed-Data/Evaluation")
source('helpers/ocp_helper.R')

# stock predict price
Xprice = read.csv(paste(getwd(), '/RealData/pred_price_DJIA.csv',sep = ''))[,-1]

# stock predict log return
Xreturn = read.csv(paste(getwd(), "/RealData/pred_log_return_DJIA.csv", sep=""))[,-1]

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

print(ocp_return$changepoint_lists$maxCPs)
print(ocp_price$changepoint_lists$maxCPs)
