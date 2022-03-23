function [mae, rmse] = comp_error(Ximp, Xtrue, Xobs)
if nargin==2
    training = [];
else
    training = find(~isnan(Xobs));
end
all = find(~isnan(Xtrue));
test = setdiff(all, training);
value = Xtrue(test);
imp = Ximp(test);
mae = mean(abs(value-imp));
rmse = mean((value-imp).^2).^(0.5);
end