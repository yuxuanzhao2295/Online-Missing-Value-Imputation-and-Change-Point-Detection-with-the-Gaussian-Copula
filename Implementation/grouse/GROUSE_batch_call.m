% the gourse function with parameter updated at every batch, allow multiple
% passses over a single batch
function [Ximp, residuals, time] = GROUSE_batch_call(X, BATCH_SIZE, maxrank, constant_step, maxCycles)
X = table2array(X);
X = X';
P = size(X,1);
n = size(X,2);

n_train = 0;

NUM_BATCH = ceil((n-n_train)/BATCH_SIZE);

Ximp = zeros(P,n);
residuals = zeros(NUM_BATCH, 1);



rng(1);
Usg = orth(randn(P,maxrank));

tic
for i = 1:NUM_BATCH
    start = (i-1) * BATCH_SIZE + 1 + n_train;
    if start > n
        break
    end
    last = min(i * BATCH_SIZE + n_train,n);
   
     % predict
    Xbatch = X(:,start:last);
    [p,m] = size(Xbatch);
    [row, col] = find(~isnan(Xbatch));
    v = Xbatch(~isnan(Xbatch));
   
    Ulast = Usg;
    [Usg, Vsg, ~, r] = grouse(row,col,v,p,m,maxrank,constant_step,maxCycles, Ulast, true);
    Ximp(:,start:last) = Usg * Vsg';
    residuals(i,1) = mean(r);
end
time = toc;
end

