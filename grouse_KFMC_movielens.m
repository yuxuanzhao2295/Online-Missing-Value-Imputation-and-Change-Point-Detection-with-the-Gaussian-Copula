% fill out the path and add all subfolders to path for simplicity
%path = '/path/Online-Missing-Value-Imputation-Dependence-Change-Detection-for-Mixed-Data'
%addpath(genpath(path));



run_kfmc_movie = onlineKFMC_movielens(300, 0.1, 50, 20);
mean(run_kfmc_movie)
% 0.6394    0.9189  168.8200
std(run_kfmc_movie)
% 0.0098    0.0121    7.5647



run_grouse_movie = GROUSE_movielens(5, 1, 200);
mean(run_grouse_movie)
% 0.6375    0.9365   24.9288
std(run_grouse_movie)
% 0.0061    0.0059    0.1216
