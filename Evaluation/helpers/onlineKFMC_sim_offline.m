function [info] = onlineKFMC_sim_offline(INDEX, rank, beta, num_iter, npass_total)
info = zeros(10,4);
batch_size = 40;
for i = 1:10
    index = INDEX(i);
	X = readtable(['/SimData/sim_offline_masked_rep',num2str(index),'.csv'], 'HeaderLines',1);
    Xtrue = readtable(['/SimData/sim_offline_true_rep',num2str(index),'.csv'], 'HeaderLines',1);
    
    
    [Ximp, time] = onlineKFMC_call(X, rank, beta, batch_size, num_iter, npass_total);
    X = table2array(X);
    Xtrue = table2array(Xtrue);
    info(i,4) = time;

    for j = 6:10
    	Ximp(j,:) = trunc_rating(Ximp(j,:), 1, 0);
    end
    for j = 11:15
    	Ximp(j,:) = trunc_rating(Ximp(j,:), 4, 0);
    end

    e = smae(Ximp', Xtrue, X);
    for j = 1:3
    	start = 5 * (j-1) + 1;
        last = 5 * j;
        info(i,j) = mean(e(start:last));
    end

end