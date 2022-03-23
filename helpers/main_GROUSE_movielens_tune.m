function [info] = main_GROUSE_movielens_tune(rank_list, size_list, maxCycles)
lr = size(rank_list,1);
lb = size(size_list,1);
info = zeros(lr,lb, 3);
for i = 1:3
    for j = 1:3
        rank = rank_list(1,i);
        stepsize = size_list(1,j);
        [error] = GROUSE_movielens(rank, stepsize, maxCycles, true);
        info(i,j,:) = error;
    end
end
end