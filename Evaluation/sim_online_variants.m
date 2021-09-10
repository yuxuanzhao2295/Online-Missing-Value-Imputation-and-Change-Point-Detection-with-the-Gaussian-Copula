[kfmc_run_sinmonline, ~] = onlineKFMC_sim_online(1:10, 200, 0.1, 50, ...
    '/sim_online_rep', '/sim_online_true_rep', '_mnar.csv');
kfmc_mnar = squeeze(mean(kfmc_run_sinmonline, 1));


[grouse_run_simonline, ~, ~] = GROUSE_sim_online(1:10, 1, 1e-6, 100, ...
    '/sim_online_rep', '/sim_online_true_rep', '_mnar.csv');
grouse_mnar = squeeze(mean(grouse_run_simonline, 1));