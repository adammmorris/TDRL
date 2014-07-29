% This will test different numBoards to see the std devs they give
% Finding the variability of Fval

to_test = [10000 12500 15000];
num_each = 50;

std_devs = zeros(length(to_test), 1);
x = [.1 .1 .1 .1 .6 .6];

for i = 1 : length(to_test)
    results = zeros(num_each, 1);
    parfor j = 1 : num_each
        results(j) = ac_sep_1p7(x, to_test(i));
    end
    std_devs(i) = std(results);
end

% This will test the std. dev. of the difference between Fvals (across
%   changes of alphaR)
% What we want is: (|Avg. Difference| - 2 std. devs) > (Fval +/- 2 std. devs)

%param_step = .1;
%fvals = zeros(length(param_step : param_step : 1), 1);
%i = 1;

%for cur_alpha = param_step : param_step : 1
%    fvals(i) = ac_sep_1p6([cur_alpha .5], 10000);
%    i = i + 1;
%end

%differences = fvals(2:end) - fvals(1:(end-1));