% Map
% This basically just searches over a space of parameters w/o analyzing the
%   results (or seeking a maximum or anything like that)

% Things to check before running:
% IF I UPDATE AC_SEP VERSION, CHANGE IT HERE!

min_param = 0;
max_param = 1;
param_step = .1;
to_test = min_param : param_step : max_param;
num_to_test = length(to_test);
num_instances = 10000;

fvals_alphas_1 = zeros(num_to_test, num_to_test, 3); % for betas = .1, temp = .6
fvals_betas_1 = zeros(num_to_test, num_to_test, 3); % for alphas = .1, temp = .6

for i = 1 : num_to_test
    parfor j = 1 : num_to_test
        fvals_alphas_1(i, j, :) = [to_test(i) to_test(j) ac_sep_1p7([to_test(i) to_test(j) .1 .1 .6 .6], num_instances)];
    end
end

for i = 1 : num_to_test
    parfor j = 1 : num_to_test
        fvals_betas_1(i, j, :) = [to_test(i) to_test(j) ac_sep_1p7([.1 .1 to_test(i) to_test(j) .6 .6], num_instances)];
    end
end

% find best alpha
[~, i_x] = max(fvals_alphas_1(:,:,3)); [~, i_y] = max(max(fvals_alphas_1(:,:,3)));
i_x = i_x(i_y);
best_alphaR = fvals_alphas_1(i_x, i_y, 1);
best_alphaP = fvals_alphas_1(i_x, i_y, 2);

% find best beta
[~, i_x] = max(fvals_betas_1(:,:,3)); [~, i_y] = max(max(fvals_betas_1(:,:,3)));
i_x = i_x(i_y);
best_betaR = fvals_betas_1(i_x, i_y, 1);
best_betaP = fvals_betas_1(i_x, i_y, 2);

fvals_alphas_2 = zeros(num_to_test, num_to_test, 3); % for betas = best, temp = .6
fvals_betas_2 = zeros(num_to_test, num_to_test, 3); % for alphas = best, temp = .6

for i = 1 : num_to_test
    parfor j = 1 : num_to_test
        fvals_alphas_2(i, j, :) = [to_test(i) to_test(j) ac_sep_1p7([to_test(i) to_test(j) best_betaR best_betaP .6 .6], num_instances)];
    end
end

for i = 1 : num_to_test
    parfor j = 1 : num_to_test
        fvals_betas_2(i, j, :) = [to_test(i) to_test(j) ac_sep_1p7([best_alphaR best_alphaP to_test(i) to_test(j) .6 .6], num_instances)];
    end
end