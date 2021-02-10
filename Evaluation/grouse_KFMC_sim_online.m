%kfmc_tuning_simonline = main_onlineKFMC_sim_online_tune(11:20, [200, 300, 400], [.1 .01 .001], 50);
% mean(kfmc_tuning_simonline(:,:,1:3), 3)
% best (200, .1)
[kfmc_run_sinmonline, kfmc_time_simonline] = onlineKFMC_sim_online(1:10, 200, 0.1, 50);
% mean 9s std 3s
kfmc_run_simonline_mean = squeeze(mean(kfmc_run_sinmonline, 1));
%plot(1:150, kfmc_run_simonline_mean(:,1))
%plot(1:150, kfmc_run_simonline_mean(:,2))
%plot(1:150, kfmc_run_simonline_mean(:,3))
writematrix(kfmc_run_simonline_mean,'/Results/simonline_kfmc_smaes.csv') 


% grouse_tuning_simonline = main_GROUSE_sim_online_tune(11:20, [1 5 10], [1e-6 1e-4 1e-2], 100);
% % mean(grouse_tuning_simonline(:,:,1:3), 3)
% best (1, 1e-6)
[grouse_run_simonline, grouse_r_simonline, grouse_time_simonline] = GROUSE_sim_online(1:10, 1, 1e-6, 100);
% across mean 1.3759
% mean 12s std 1s
grouse_run_simonline_mean = squeeze(mean(grouse_run_simonline, 1));
%plot(1:150, grouse_run_simonline_mean(:,1))
%plot(1:150, mean(grouse_r_simonline,1))
x = mean(grouse_r_simonline,1);
info = [grouse_run_simonline_mean x(:)];
writematrix(info,'/Results/simonline_grouse_smaes.csv') 
