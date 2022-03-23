[kfmc_run, ~] = onlineKFMC_sim_online(1:10, 200, 0.1, 50, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum2_dim15_n1000.csv', '_true_masknum2_dim15_n1000.csv');
kfmc_n1000 = squeeze(mean(kfmc_run, 1));


[grouse_run, ~, ~] = GROUSE_sim_online(1:10, 1, 1e-6, 100, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum2_dim15_n1000.csv', '_true_masknum2_dim15_n1000.csv');
grouse_n1000 = squeeze(mean(grouse_run, 1));

[kfmc_run, ~] = onlineKFMC_sim_online(1:10, 200, 0.1, 50, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum2_dim15_n3000.csv', '_true_masknum2_dim15_n3000.csv');
kfmc_n3000 = squeeze(mean(kfmc_run, 1));


[grouse_run, ~, ~] = GROUSE_sim_online(1:10, 1, 1e-6, 100, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum2_dim15_n3000.csv', '_true_masknum2_dim15_n3000.csv');
grouse_n3000 = squeeze(mean(grouse_run, 1));

%%%%%%%%%%%

[kfmc_run, ~] = onlineKFMC_sim_online(1:10, 200, 0.1, 50, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum1_dim15_n2000.csv', '_true_masknum1_dim15_n2000.csv');
kfmc_mask1 = squeeze(nanmean(kfmc_run, 1));


[grouse_run, ~, ~] = GROUSE_sim_online(1:10, 1, 1e-6, 100, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum1_dim15_n2000.csv', '_true_masknum1_dim15_n2000.csv');
grouse_mask1 = squeeze(mean(grouse_run, 1));

[kfmc_run, ~] = onlineKFMC_sim_online(1:10, 200, 0.1, 50, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum3_dim15_n2000.csv', '_true_masknum3_dim15_n2000.csv');
kfmc_mask3 = squeeze(mean(kfmc_run, 1));


[grouse_run, ~, ~] = GROUSE_sim_online(1:10, 1, 1e-6, 100, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum3_dim15_n2000.csv', '_true_masknum3_dim15_n2000.csv');
grouse_mask3 = squeeze(mean(grouse_run, 1));

%%%%%%%%%%%

[kfmc_run, ~] = onlineKFMC_sim_online(1:10, 200, 0.1, 50, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum4_dim30_n2000.csv', '_true_masknum4_dim30_n2000.csv');
kfmc_p30 = squeeze(mean(kfmc_run, 1));


[grouse_run, ~, ~] = GROUSE_sim_online(1:10, 1, 1e-6, 100, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum4_dim30_n2000.csv', '_true_masknum4_dim30_n2000.csv');
grouse_p30 = squeeze(mean(grouse_run, 1));

[kfmc_run, ~] = onlineKFMC_sim_online(1:10, 200, 0.1, 50, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum6_dim45_n2000.csv', '_true_masknum6_dim45_n2000.csv');
kfmc_p45 = squeeze(mean(kfmc_run, 1));


[grouse_run, ~, ~] = GROUSE_sim_online(1:10, 1, 1e-6, 100, ...
    '/sim_online_rep', '/sim_online_rep', '_maksed_masknum6_dim45_n2000.csv', '_true_masknum6_dim45_n2000.csv');
grouse_p45 = squeeze(mean(grouse_run, 1));