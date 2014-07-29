% Map_temp_undiff
% This just does temps (undifferentiated) w/ given alphas & betas

function [result] = Map_temp_undiff(alphas, betas, boardPath)
    min_param = .5;
    max_param = 5;
    param_step = .5;
    to_test = min_param : param_step : max_param;
    num_to_test = length(to_test);
    num_instances = 10000;
    num_plays = 50;

    fvals_temps_1 = zeros(num_to_test, 2);

    for i = 1 : num_to_test
        fvals_temps_1(i, :) = [to_test(i) ac_sep_twosteptask([alphas(1) alphas(2) betas(1) betas(2) to_test(i) to_test(i)], num_instances, num_plays, boardPath)];
    end

    % Save everything
    boardNum = boardPath((strfind(boardPath,'/')+6):end);
    
    result = fvals_temps_1;
end