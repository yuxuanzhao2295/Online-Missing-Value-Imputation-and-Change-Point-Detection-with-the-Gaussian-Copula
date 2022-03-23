function [Ximp, time] = onlineKFMC_call(X, rank, beta, batch_size, num_iter, npass_total)
warning off
ker.type='rbf';
ker.par=0;
ker.c=3;

options.batch_size = batch_size;
options.online_maxiter=num_iter; 
options.eta=0.5; 
options.npass=npass_total;


% initial estimate 
X = table2array(X);
X = X';
indicator = 1-isnan(X);
Xinit = init_for_online_KFMC(X);  


tic
%[Ximp,~,~,~,~,~]=KFMC_online(Xinit,indicator,rank,0,beta,ker,options);
[Ximp,~,~,~,~,~]=KFMC_minibatch(Xinit,indicator,rank,0,beta,ker,options);
time = toc;

end













