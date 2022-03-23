% fill out the path and add all subfolders to path for simplicity
%path = '/path/Online-Missing-Value-Imputation-Dependence-Change-Detection-for-Mixed-Data'
%addpath(genpath(path));

% run with best parameters:
[kfmc_run_sinmonline, kfmc_time_simonline] = onlineKFMC_sim_online(1:10, 200, 0.1, 50, ...
    '/sim_online_masked_rep', '/sim_online_true_rep', '.csv', '.csv');
kfmc_run_simonline_mean = squeeze(mean(kfmc_run_sinmonline, 1));
% write data:
writematrix(kfmc_run_simonline_mean,'Results/simonline_kfmc_smaes.csv');


% run with best parameters:
[grouse_run_simonline, grouse_r_simonline, grouse_time_simonline] = GROUSE_sim_online(1:10, 1, 1e-6, 100, ...
    '/sim_online_masked_rep', '/sim_online_true_rep', '.csv', '.csv');
grouse_run_simonline_mean = squeeze(mean(grouse_run_simonline, 1));
% write data:
x = mean(grouse_r_simonline,1);
info = [grouse_run_simonline_mean x(:)];
writematrix(info, 'Results/simonline_grouse_smaes.csv');


