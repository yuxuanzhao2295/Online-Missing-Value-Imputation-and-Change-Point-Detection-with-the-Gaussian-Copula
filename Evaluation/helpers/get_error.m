function [error] = get_error(e)
p = size(e,1);
val = e(1:10,:);
test = e(11:p,:);
error = [mean(val,1) mean(test,1)];
