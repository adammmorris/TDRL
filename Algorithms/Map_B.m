% Map_B
% This just does betas w/ given alphas & temps

function [result] = Map_B(alphas, temps, boardPath, num_instances, num_plays, optNum, saveData)
    min_param = 0;
    max_param = .1;
    param_step = .1;
    to_test = min_param : param_step : max_param;
    num_to_test = length(to_test);

    fvals_betas_1 = zeros(num_to_test, num_to_test, 3);
    
    for i = 1 : num_to_test
        parfor j = 1 : num_to_test
            [means, ~, ~] = ac_sep_twosteptask_v2([alphas(1) alphas(2) to_test(i) to_test(j) temps(1) temps(2)], num_instances, num_plays, boardPath, 0, 0, [0 0 0 0 0 0]);
            fvals_betas_1(i, j, :) = [to_test(i) to_test(j) means];
        end
    end

    result = fvals_betas_1;
    
    % Save everything
    boardNum = boardPath((strfind(boardPath,'/')+6):end);
    
    ParseData(fvals_betas_1, 'beta', boardNum, optNum, saveData);
end