%info_tuning_kfmc_movie = main_onlineKFMC_movielens_tune([200 300 400], [.1 .01 .001], 50, 20);
% best (200, 0.1) 0.623 MAE 0.899 RMSE 139 time 

run_kfmc_movie = onlineKFMC_movielens(200, 0.1, 50, 20);
% mean  0.6314    0.9049  176.0568
% std 0.0049    0.0063   21.3736


%tuning_grouse_movie = main_GROUSE_movielens_tune([1 5 10], [.1 1 10], 200);
% best (5, 1)
run_grouse_movie = GROUSE_movielens(5, 1, 200);
% mean   0.6343    0.9335   26.6085
% std  0.6343    0.9335   26.6085
