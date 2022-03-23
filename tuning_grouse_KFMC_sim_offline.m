info_tuning_kfmc_simoffline = main_onlineKFMC_sim_offline(11:20, [200 300 400], [.1 .01 .001], 50, 10);
mean(info_tuning_kfmc_simoffline(:,:,:,1:3), [3 4])
%0.9533    0.9628    1.0245
%0.9520    0.9802    1.0413
%0.9524    0.9923    1.0565
%best (300, .1);

info_tuning_grouse_simoffline = main_GROUSE_sim_offline(11:20, [1 5 10], [.1 1 10], 100);
mean(info_tuning_grouse_simoffline(:,:,:,1:3), [3 4])
%1.1851    1.1854    1.1862
%2.1237    1.7003    1.7008
%3.2740    3.3099    3.0636
%best (1, .1);