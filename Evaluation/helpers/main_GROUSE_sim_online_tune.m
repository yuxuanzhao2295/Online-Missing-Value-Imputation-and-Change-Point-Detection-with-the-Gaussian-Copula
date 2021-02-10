function [info] = main_GROUSE_sim_online_tune(INDEX, rank_list, size_list, maxCycles)
lr = size(rank_list,1);
lb = size(size_list,1);
info = zeros(lr,lb, 4);
for i = 1:3
    for j = 1:3
        rank = rank_list(1,i);
        constant_step = size_list(1,j);
        [error, ~, t] = GROUSE_sim_online(INDEX, rank, constant_step, maxCycles);
        info(i,j,1:3) = mean(error, [1 2]);
        info(i,j,4) = mean(t);
    end
end
end