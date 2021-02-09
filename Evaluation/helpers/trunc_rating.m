function [xk] = trunc_rating(x, max, min)
xk = round(x);
xk(xk>max) = max;
xk(xk<min) = min;
