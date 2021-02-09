function [Ximp, time] = GROUSE_call(X, maxrank, step_size, maxCycles, constant_step)
X = table2array(X);
X = X';
[p, n] = size(X);
[row, col] = find(~isnan(X));
v = X(~isnan(X));

if nargin<5
	tic
	[Usg, Vsg, ~] = grouse(row,col,v,p,n,maxrank,step_size,maxCycles);
	Ximp = Usg * Vsg';
	time = toc;
else
	rng(1);
    Uinit = orth(randn(p,maxrank)); 
    tic
    % constant step size
	[Usg, Vsg, ~] = grouse(row,col,v,p,n,maxrank,constant_step,maxCycles, Uinit, true);
	Ximp = Usg * Vsg';
	time = toc;
end

end
