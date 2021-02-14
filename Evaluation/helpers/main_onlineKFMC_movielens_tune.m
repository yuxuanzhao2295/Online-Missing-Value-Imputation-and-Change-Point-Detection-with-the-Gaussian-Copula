function [info] = main_onlineKFMC_movielens_tune(rank_list, beta_list, num_iter, npass_total)
lr = size(rank_list,1);
lb = size(beta_list,1);
info = zeros(lr,lb, 3);
for i = 1:3
    for j = 1:3
        rank = rank_list(1,i);
        beta = beta_list(1,j);
        [error] = onlineKFMC_movielens(rank, beta, num_iter, npass_total, true);
        info(i,j,:) = error;
    end
end
end