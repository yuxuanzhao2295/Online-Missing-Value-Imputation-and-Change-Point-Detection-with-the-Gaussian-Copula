# random search for onlineCPD hyperparameters

runif_range = function(n, r, exp_grid = FALSE, seed =1){
  lower = r[1]
  upper = r[2]
  set.seed(seed)
  if (exp_grid){
    exp(runif(n, log(lower), log(upper)))
  }else{
    runif(n, lower, upper)
  }
}

rand_ocp_para = function(para_range, seed=1, num=9){
  samples = list(num)
  l = runif_range(num, para_range$lambda)
  alpha = runif_range(num, para_range$alpha, TRUE)
  beta = runif_range(num, para_range$beta, TRUE)
  kappa = runif_range(num, para_range$kappa, TRUE)
  for (i in 1:num){
    samples[[i]] = list(lambda = l[i],
                        init_para = list(m=0, k=kappa[i], a = alpha[i], b = beta[i]))
  }
  samples
}

pred_error_ocp = function(X, para, verbose = FALSE){
  require(ocp)
  lambda_init = para$lambda
  init_params = para$init_para
  obj = onlineCPD(X, missPts = 'mean',
                  hazard_func = function(x, lambda) {const_hazard(x, lambda = lambda_init)},
                  init_params = list(init_params), multivariate =  TRUE,
                  printupdates = verbose
                  )
  Ximp = array(0, dim = dim(X))
  for (i in 1:dim(X)[1]) Ximp[i,] = obj$currmu[[i]]
  loc = !is.na(X)
  diff = X[loc] - Ximp[loc]
  mean(abs(diff))
}


tuning_ocp = function(X_list, num = 9, verbose = FALSE, seed= 1){
  para_range = list(lambda =  c(50, 200),
                    alpha = c(0.01, 1),
                    beta = c(1e-4, 1e-2),
                    kappa = c(0.01, 1))

  set.seed(seed)
  para_list = rand_ocp_para(para_range, seed = seed, num = num)
  lx = length(X_list)
  err = array(0, dim = c(num, lx))
  for (j in 1:lx){
    for (i in 1:num){
      err[i,j] = pred_error_ocp(X_list[[j]], para_list[[i]])
      print(paste('finish iteration ', i))
      }
  }
  errmean = apply(err, 2, mean)
  res = list(para_best = para_list[[which.min(errmean)]], err = err, para_list = para_list)
  res
}
