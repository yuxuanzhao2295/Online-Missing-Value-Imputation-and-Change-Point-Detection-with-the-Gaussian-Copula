function [Ximp] = init_for_online_KFMC(X)
p = size(X,1);
Ximp = X;
for j = 1:p
    loc = isnan(X(j,:));
    if sum(loc) ==0
        continue
    end
    if sum(~loc)>0
        Ximp(j,loc) = mean(X(j,~loc));
    else
        Ximp(j,loc) = 0;
    end
end
end