% run with best parameter:
info_run_kfmc_simoffline = onlineKFMC_sim_offline(1:10, 300, 0.1, 50, 10);
mean(info_run_kfmc_simoffline)
std(info_run_kfmc_simoffline)
% mean 0.8982    1.2919    0.6312   37.0664
% std 0.0218    0.2011    0.0368    7.6404


% run with best parameter:
info_run_grouse_simoffline = GROUSE_sim_offline(1:10, 1, 1, 100);
mean(info_run_grouse_simoffline)
std(info_run_grouse_simoffline)
% mean 1.1530    1.3147    1.0226    2.1043
% std 0.0615    0.1942    0.0725    0.0327