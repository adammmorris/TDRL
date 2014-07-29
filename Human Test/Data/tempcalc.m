function [result] = tempcalc(x, temp)
result = (exp(temp .* x(1)) ./ sum(exp(temp .* x)));
end