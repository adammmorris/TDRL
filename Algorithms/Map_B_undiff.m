% Map_temp_undiff
% This just does betas (undifferentiated) w/ given alphas & temps

function [result] = Map_B_undiff(alphas, temps, boardPath, num_instances, num_plays)
    min_param = 0;
    max_param = 1;
    param_step = .2;
    to_test = min_param : param_step : max_param;
    num_to_test = length(to_test);

    fvals_betas_1 = zeros(num_to_test, 2);

    parfor i = 1 : num_to_test
        fvals_betas_1(i, :) = [to_test(i) ac_sep_twosteptask([alphas(1) alphas(2) to_test(i) to_test(i)  temps(1) temps(2)], num_instances, num_plays, boardPath, 0, 0, [0 0 0 0 0 0])];
    end
    
    result = fvals_betas_1;
end