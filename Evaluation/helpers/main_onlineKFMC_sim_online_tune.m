function [info] = main_onlineKFMC_sim_online_tune(INDEX, rank_list, beta_list, num_iter, npass_total)
lr = size(rank_list,1);
lb = size(beta_list,1);
info = zeros(lr,lb, 4);
for i = 1:3
    for j = 1:3
        rank = rank_list(1,i);
        beta = beta_list(1,j);
        [error, t] = onlineKFMC_sim_online(INDEX, rank, beta, num_iter, npass_total);
        info(i,j,1:3) = mean(error, [1 2]);
        info(i,j,4) = mean(t);
    end
end
end