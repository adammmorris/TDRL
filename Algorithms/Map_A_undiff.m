% Map_temp_undiff
% This just does alphas (undifferentiated) w/ given temps & betas

function [result] = Map_A_undiff(betas, temps, boardPath, num_instances, num_plays)
    min_param = 0;
    max_param = 1;
    param_step = .1;
    to_test = min_param : param_step : max_param;
    num_to_test = length(to_test);

    fvals_alphas_1 = zeros(num_to_test, 2);

    parfor i = 1 : num_to_test
        fvals_alphas_1(i, :) = [to_test(i) ac_sep_twosteptask([to_test(i) to_test(i) betas(1) betas(2) temps(1) temps(2)], num_instances, num_plays, boardPath)];
    end
    
    result = fvals_alphas_1;
end