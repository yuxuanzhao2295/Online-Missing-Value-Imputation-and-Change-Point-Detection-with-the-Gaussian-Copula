% fill out the path and add all subfolders to path for simplicity
%path = '/path/Online-Missing-Value-Imputation-Dependence-Change-Detection-for-Mixed-Data'
%addpath(genpath(path));

% tuning 
% kfmc_tuning_simonline = main_onlineKFMC_sim_online_tune(11:20, [200, 300, 400], [.1 .01 .001], 50);
% mean(kfmc_tuning_simonline(:,:,1:3), 3)
% best (200, .1)

% run with best parameters:
[kfmc_run_sinmonline, kfmc_time_simonline] = onlineKFMC_sim_online(1:10, 200, 0.1, 50, ...
    '/sim_online_masked_rep', '/sim_online_true_rep', '.csv');
kfmc_run_simonline_mean = squeeze(mean(kfmc_run_sinmonline, 1));
% write data:
% writematrix(kfmc_run_simonline_mean,strcat(path, '/Evaluation/Results/simonline_kfmc_smaes.csv')) 

% tuning
%grouse_tuning_simonline = main_GROUSE_sim_online_tune(11:20, [1 5 10], [1e-6 1e-4 1e-2], 100);
% % mean(grouse_tuning_simonline(:,:,1:3), 3)
% best (1, 1e-6)

% run with best parameters:
[grouse_run_simonline, grouse_r_simonline, grouse_time_simonline] = GROUSE_sim_online(1:10, 1, 1e-6, 100, ...
    '/sim_online_masked_rep', '/sim_online_true_rep', '.csv');
grouse_run_simonline_mean = squeeze(mean(grouse_run_simonline, 1));
% write data:
%x = mean(grouse_r_simonline,1);
%info = [grouse_run_simonline_mean x(:)];
%writematrix(info,strcat(path, '/Evaluation/Results/simonline_grouse_smaes.csv')) 


