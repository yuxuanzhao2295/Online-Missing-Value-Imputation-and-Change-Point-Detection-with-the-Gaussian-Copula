function K=kernel(X,Y,ker)
nx=size(X,2);
ny=size(Y,2);
if strcmp(ker.type,'rbf')
    xx=sum(X.*X,1);
    yy=sum(Y.*Y,1);
    D=repmat(xx',1,ny) + repmat(yy,nx,1) - 2*X'*Y;
    K=exp(-D/2/ker.par); 
end
if strcmp(ker.type,'poly')
    K=(X'*Y+ker.par(1)).^ker.par(2);
end
end