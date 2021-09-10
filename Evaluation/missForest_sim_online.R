relative_path = ''
path = paste(relative_path, 'Online-Missing-Value-Imputation-Dependence-Change-Detection-for-Mixed-Data/Evaluation', sep =  "")
setwd(path)

library(missForest)
data_true = list()
data_mask = list()
for (i in 1:10){
  d1 = read.csv(paste('SimData/sim_online_true_rep', i, '.csv', sep =''))
  d2 = read.csv(paste('SimData/sim_online_masked_rep', i, '.csv', sep =''))
  for (j in 6:15){
    d1[,j] = as.factor(d1[,j])
    d2[,j] = as.factor(d2[,j])
  } 
  data_true[[i]] = d1
  data_mask[[i]] = d2
}

est_forest = list()
for (i in 1:10){
  est_forest[[i]] = missForest(xmis = data_mask[[i]], verbose = FALSE)
}

smae_forest = array(0, dim = c(10, 150, 3))
for (i in 1:10) smae_forest[i,,] = smae_batch(est_forest[[i]]$ximp, data_true[[i]], data_mask[[i]], 40)
mean_smae_forest = apply(smae_forest, c(2,3), mean)
write.csv(mean_smae_forest, file = 'Results/simonline_missForest_smaes.csv')

smae_batch = function(Ximp, Xtrue, Xobs, batch){
  n = dim(Ximp)[1]
  p = dim(Ximp)[2]
  Ximp = as.numeric(as.matrix(Ximp))
  dim(Ximp) = c(n,p)
  Xtrue = as.numeric(as.matrix(Xtrue))
  dim(Xtrue) = c(n,p)
  Xobs = as.numeric(as.matrix(Xobs))
  dim(Xobs) = c(n,p)
  num_batch = ceiling(n / batch)
  med = apply(Xobs, 2, median, na.rm = TRUE)
  smae = array(0, dim = c(num_batch, 3))
  for (j in 1:num_batch){
    start = (j-1)*batch + 1
    end = min(j * batch, n)
    e = get_smae(Ximp[start:end, ], Xtrue[start:end, ], Xobs[start:end, ], med)
    smae[j, ] = e
  }
  smae
}

get_smae = function(Ximp, Xtrue, Xobs, med){
  p = dim(Xobs)[2]
  error = array(0, dim = c(p,2))
  for (i in 1:p){
    loc_missing = is.na(Xobs[,i])
    test = (!is.na(Xtrue[,i])) & loc_missing
    if (sum(test) == 0) next
    xtrue_col = Xtrue[test, i]
    ximp_col = Ximp[test, i]
    m = med[i]
    diff = sum(abs(ximp_col - xtrue_col))
    med_diff = sum(abs(m - xtrue_col))
    error[i,1] = diff
    error[i,2] = med_diff
  }
  s_error = numeric(3)
  for (j in 1:3){
    start = (j-1) * 5 + 1
    end = j*5
    s_error[j] = sum(error[start:end, 1]) / sum(error[start:end, 2])
  }
  s_error
}


