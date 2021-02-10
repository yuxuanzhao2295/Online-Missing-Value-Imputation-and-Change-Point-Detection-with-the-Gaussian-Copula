function [info, residuals, times] = GROUSE_sim_online(INDEX, maxrank, constant_step, maxCycles)
info = zeros(10, 150, 3);
times = zeros(10, 1);
residuals = zeros(10, 150);
n = 2000;
batch_size = 40;
num_batch = 150;
for i = 1:10
    index = INDEX(i);
	X = readtable(['/SimData/sim_online_masked_rep',num2str(index),'.csv'], 'HeaderLines',1);
    Xtrue = readtable(['/SimData/sim_online_true_rep',num2str(index),'.csv'], 'HeaderLines',1);
   
    
    [Ximp, r, time] = GROUSE_batch_call(X, 40, maxrank, constant_step, maxCycles);
    X = table2array(X);
    med = nanmedian(X);
    Xtrue = table2array(Xtrue);
    times(i,1) = time;
    residuals(i,:) = r;

    for j = 6:10
    	Ximp(j,:) = trunc_rating(Ximp(j,:), 1, 0);
    end
    for j = 11:15
    	Ximp(j,:) = trunc_rating(Ximp(j,:), 4, 0);
    end

    for l = 1:num_batch
        start = (l-1)*batch_size + 1;
        last = l * batch_size;
        ximp = Ximp(:,start:last);
        xtrue = Xtrue(start:last, :);
        xobs = X(start:last, :);
        info(i,l,:) = smae(ximp', xtrue, xobs, med, true); 
    end

end