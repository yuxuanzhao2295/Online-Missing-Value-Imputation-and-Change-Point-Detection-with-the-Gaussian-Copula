% tuning 
kfmc_tuning_simonline = main_onlineKFMC_sim_online_tune(11:20, [200, 300, 400], [.1 .01 .001], 50, ...
    '/sim_online_masked_rep', '/sim_online_true_rep', '.csv', '.csv');
mean(kfmc_tuning_simonline(:,:,1:3), 3)
% best (200, .1)
    % 1.0943    1.1596    1.2534
    % 1.1079    1.1674    1.2705
    % 1.1187    1.1733    1.2723

grouse_tuning_simonline = main_GROUSE_sim_online_tune(11:20, [1 5 10], [1e-6 1e-4 1e-2], 100, ...
    '/sim_online_masked_rep', '/sim_online_true_rep', '.csv', '.csv');
mean(grouse_tuning_simonline(:,:,1:3), 3)
% best (1, 1e-6)
    % 1.2756    1.2825    1.3740
    % 1.7313    2.5930    1.6834
    % 3.1807    3.1807    3.1807