function [info] = main_GROUSE_sim_offline(INDEX, rank_list, size_list, maxCycles)
lb = size(size_list,1);
lr = size(rank_list,1);
info = zeros(lr,lb, 10, 4);
for i = 1:3
    for j = 1:3
        rank = rank_list(1,i);
        stepsize = size_list(1,j);
        [error] = GROUSE_sim_offline(INDEX, rank, stepsize, maxCycles);
        info(i,j,:,:) = error;
    end
end
end