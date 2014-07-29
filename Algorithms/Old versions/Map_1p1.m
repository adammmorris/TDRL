% Map
% This basically just searches over a space of parameters w/o analyzing the
%   results (or seeking a maximum or anything like that)

min_beta = 0;
max_beta = 1;
param_step = .1;
to_test_betaR = min_beta : param_step : max_beta;
to_test_betaP = min_beta : param_step : max_beta;
num_to_test_betaR = length(to_test_betaR);
num_to_test_betaP = length(to_test_betaP);

% Run over temp = .6

fvals_betas_1 = zeros(num_to_test_betaR, num_to_test_betaP, 3);

for i = 1 : num_to_test_betaR
    parfor j = 1 : num_to_test_betaP
        fvals_betas_1(i, j, :) = [to_test_betaR(i) to_test_betaP(j) ac_sep_1p6([.8 .05 to_test_betaR(i) to_test_betaP(j) .6 .6], 10000)];
    end
end

% Run over temp = .3

fvals_betas_2 = zeros(num_to_test_betaR, num_to_test_betaP, 3);

for i = 1 : num_to_test_betaR
    parfor j = 1 : num_to_test_betaP
        fvals_betas_2(i, j, :) = [to_test_betaR(i) to_test_betaP(j) ac_sep_1p6([.5 .1 to_test_betaR(i) to_test_betaP(j) .3 .3], 10000)];
    end
end