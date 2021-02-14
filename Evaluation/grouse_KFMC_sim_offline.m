% fill out the path and add all subfolders to path for simplicity
%path = '/path/Online-Missing-Value-Imputation-Dependence-Change-Detection-for-Mixed-Data'
%addpath(genpath(path));

% tuning:
% info_tuning_kfmc_simoffline = main_onlineKFMC_sim_offline(11:20, [200 300 400], [.1 .01 .001], 50, 10);
% mean(info_tuning_kfmc_simoffline(:,:,:,1:3), [3 4]); best (400, .1);
% run with best parameter:
info_run_kfmc_simoffline = onlineKFMC_sim_offline(1:10, 400, 0.1, 50, 10);
% mean 0.9164    0.6949    0.9000   33.6955
% std 0.0332    0.0807    0.0177    1.6853

% tuning:
%info_tuning_grouse_simoffline = main_GROUSE_sim_offline(11:20, [1 5 10], [.1 1 10], 100);
% mean(info_tuning_grouse_simoffline(:,:,:,1:3), [3 4]);  best (1, .1) or (1, 1);
% run with best parameter:
info_run_grouse_simoffline = GROUSE_sim_offline(1:10, 1, 1, 100);
% mean 1.1558    1.1381    1.5507    2.1628
% std 0.0264    0.1695    0.0729    0.0868