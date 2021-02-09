% this function is for stock experiments, where missing values are
% sequentially revealed
function [error] = onlineKFMC_predict(X, rank, beta, n_train, BATCH_SIZE, num_iter, minibatch_size)
X = table2array(X);
X = X';
p = size(X,1);
n = size(X,2);
ptrue = p/2;

warning off
ker.type='rbf';
ker.par=0;
ker.c=3;

options.online_maxiter=num_iter; 
options.eta=0.5; 
options.npass=1;

if nargin < 7
    minibatch_size = BATCH_SIZE;


rng(1);
options.D = randn(p,rank);

% initial estimate 
Xbatch = X(:, 1:n_train);
indicator = 1-isnan(Xbatch);
Xinit = init_for_online_KFMC(Xbatch);

%[~,Dlast,~,~,ker,~]=KFMC_online(Xinit,indicator,rank,0,beta,ker,options);
options.batch_size = BATCH_SIZE;
[~,Dlast,~,~,ker,~]=KFMC_minibatch(Xinit,indicator,rank,0,beta,ker,options);

NUM_BATCH = ceil((n-n_train)/BATCH_SIZE);
error = zeros(NUM_BATCH, 2);

for i = 1:NUM_BATCH
    start = (i-1) * BATCH_SIZE + 1 + n_train;
    if start > n
        break
    end
    last = min(i * BATCH_SIZE + n_train,n);
    %options.batch_size = min(minibatch_size, last - start + 1);
    %options.batch_size = 1;
    options.batch_size = last - start + 1;

    
    % predict
    Xbatch = zeros(p, last-start+1);
    Xbatch(1:ptrue,:) = X(1:ptrue,start:last);
    Xbatch((ptrue+1):p, :) = NaN;
    indicator = 1-isnan(Xbatch);
    Xinit = init_for_online_KFMC(Xbatch);    

   options.D = Dlast;
   %[Ximp,~,~,~,ker,~]=KFMC_online(Xinit,indicator,rank,0,beta,ker,options);
   [Ximp,~,~,~,ker,~]=KFMC_minibatch(Xinit,indicator,rank,0,beta,ker,options);
   %if any(isnan(Ximp))
    %    break
   %end
   
   % evaluate 
   [mae, rmse] = comp_error(Ximp((ptrue+1):p,:), X((ptrue+1):p,start:last));
   error(i,1) = mae;
   error(i,2) = rmse;
   
   % reveal 
   Xreveal = X(:,start:last);
   indicator = 1-isnan(Xreveal);
   Xinit = init_for_online_KFMC(Xreveal);
   %[~,Dlast,~,~,ker,~]=KFMC_online(Xinit,indicator,rank,0,beta,ker,options);
   [~,Dlast,~,~,ker,~]=KFMC_minibatch(Xinit,indicator,rank,0,beta,ker,options);
   
   %if any(isnan(Dlast))
    %    break
   %end
   
end

end














