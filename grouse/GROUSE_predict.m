function [error, residual] = GROUSE_predict(X, maxrank, step_size, n_train, BATCH_SIZE, maxcycle)
X = table2array(X);
X = X';
p = size(X,1);
ptrue = p/2;
n = size(X,2);


maxCycles = maxcycle;
NUM_BATCH = ceil((n-n_train)/BATCH_SIZE);
error = zeros(NUM_BATCH, 2);
residual = zeros(NUM_BATCH, 1);

rng(1);
Ulast = orth(randn(p,maxrank));

% initial estimate 
Xbatch = X(:, 1:n_train);
[pb, m] = size(Xbatch);
[row, col] = find(~isnan(Xbatch));
v = Xbatch(~isnan(Xbatch));
[Usg, ~, ~, ~] = grouse(row,col,v,pb,m,maxrank,step_size,maxCycles, Ulast, true);

for i = 1:NUM_BATCH
    start = (i-1) * BATCH_SIZE + 1 + n_train;
    if start > n
        break
    end
    last = min(i * BATCH_SIZE + n_train,n);
      
    % predict
    Xbatch = zeros(p, last-start+1);
    Xbatch(1:ptrue,:) = X(1:ptrue,start:last);
    Xbatch((ptrue+1):p, :) = NaN;
    
    [pb,m] = size(Xbatch);
    [row, col] = find(~isnan(Xbatch));
    v = Xbatch(~isnan(Xbatch));
    Ulast = Usg; % update latent space parameters from last fit
    [Usg, Vsg, ~, ~] = grouse(row,col,v,pb,m,maxrank,step_size,maxCycles, Ulast, true);
    Ximp = Usg * Vsg';
    
    % reveal
    Xreveal = X(:,start:last);
    [pb, m] = size(Xreveal);
    [row, col] = find(~isnan(Xreveal));
    v = Xreveal(~isnan(Xreveal));
    [Usg, ~, ~, r] = grouse(row,col,v,pb,m,maxrank,step_size,maxCycles, Ulast, true);
    residual(i,1) = mean(r);

    
    % evaluate 
   [mae, rmse] = comp_error(Ximp((ptrue+1):p,:), X((ptrue+1):p,start:last));
   error(i,1) = mae;
   error(i,2) = rmse;
end
end