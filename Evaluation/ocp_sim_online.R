source('Evaluation/helpers/ocp_helper.R')

for (i in 11:20){
  X_list[[i-10]] = as.matrix(
    read.csv(paste('/SimData/sim_online_true_rep', i, '.csv',sep = '')))
}
res_tuning = tuning_ocp(X_list, num = 9, verbose = TRUE, seed= 1)

sim_para = res_tuning$para_best
sim_res_ocp = list(10)
for (i in 1:10){
  X = as.matrix(read.csv(paste('/SimData/sim_online_masked_rep', i, '.csv',sep = '')))
  sim_res_ocp[[i]] = onlineCPD(X, missPts = 'mean',
                          hazard_func = function(x, lambda) {const_hazard(x, lambda = sim_para$lambda)},
                          init_params = list(sim_para$init_para), multivariate =  TRUE)
  print(paste('Finish iteration ', i))
}

for(i in 1:10) print(sim_res_ocp[[i]]$changepoint_lists$maxCPs)
# 9 of 10 iterations only find CP at the first batch, 1 iteration finds CP at the last batch


