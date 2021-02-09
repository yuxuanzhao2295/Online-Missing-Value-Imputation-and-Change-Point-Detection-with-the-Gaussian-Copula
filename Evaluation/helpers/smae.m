function [error] = smae(Ximp, Xtrue, Xobs, med, type)
[~,p] = size(Ximp);
error = zeros(p,2);
if nargin == 3 
	med = nanmedian(Xobs);
end

for j = 1:p
    loc = find(isnan(Xobs(:,j)) & ~isnan(Xtrue(:,j)));
    if isempty(loc)
    	error(j,:) = nan;
    else
    	error(j,1) = sum(abs(Ximp(loc,j) - Xtrue(loc,j)));
        error(j,2) = sum(abs(med(j) - Xtrue(loc,j)));
    end
end

if nargin == 5
	err = zeros(3,1);
    for i = 1:3
        start = 5 * (i-1) + 1;
        last = 5 * i;
        err(i) = nansum(error(start:last,1))/nansum(error(start:last,2));
    end
    error = err;
else
	error = error(:,1)./error(:,2);
end