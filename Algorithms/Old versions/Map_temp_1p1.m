% Map
% This basically just searches over a space of parameters w/o analyzing the
%   results (or seeking a maximum or anything like that)

min_temp = .1;
max_temp = 1.5;
param_step = .1;
to_test_temp = min_temp : param_step : max_temp;
num_to_test_temp = length(to_test_temp);

% Run over alphas = betas = .1 and .2

fvals_1 = zeros(num_to_test_temp, 2);
fvals_2 = zeros(num_to_test_temp, 2);

parfor i = 1 : num_to_test_temp
    fvals_1(i, :) = [to_test_temp(i) ac_sep_1p7([.1 .1 .1 .1 to_test_temp(i) to_test_temp(i)], 10000)];
    fvals_2(i, :) = [to_test_temp(i) ac_sep_1p7([.2 .2 .2 .2 to_test_temp(i) to_test_temp(i)], 10000)];
end