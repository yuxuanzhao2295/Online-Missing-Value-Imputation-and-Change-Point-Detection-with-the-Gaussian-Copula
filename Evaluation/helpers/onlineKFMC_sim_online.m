function [info, times] = onlineKFMC_sim_online(INDEX, rank, beta, num_iter, ...
    prefix_mask, prefix_true, suffix_mask, suffix_true)

 Xtrue = readtable([prefix_true,num2str(1),suffix_true], 'HeaderLines',1);
 [n,p]=size(Xtrue);
p_type = p/3;

times = zeros(10, 1);
batch_size = 40;
num_batch = n/batch_size;
info = zeros(10, num_batch, 3);


npass_total = 1;
for i = 1:10
    index = INDEX(i);
	X = readtable([prefix_mask,num2str(index),suffix_mask], 'HeaderLines',1);
    Xtrue = readtable([prefix_true,num2str(index),suffix_true], 'HeaderLines',1);
   
    
    [Ximp, time] = onlineKFMC_call(X, rank, beta, batch_size, num_iter, npass_total);
    X = table2array(X);
    med = nanmedian(X);
    Xtrue = table2array(Xtrue);
    times(i,1) = time;

    for j = (p_type+1):(2*p_type)
    	Ximp(j,:) = trunc_rating(Ximp(j,:), 1, 0);
    end
    for j = (2*p_type+1):(3*p_type)
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