% Map_AB
% This just does alphas (differentiated) w/ given betas & temps

function [result] = Map_A(betas, temps, boardPath, num_instances, num_plays, optNum_alpha, saveData)
    min_param = 0;
    max_param = 1;
    param_step = .1;
    to_test = min_param : param_step : max_param;
    num_to_test = length(to_test);

    fvals_alphas = zeros(num_to_test, num_to_test, 3);
    
    for i = 1 : num_to_test
        parfor j = 1 : num_to_test
            fvals_alphas(i, j, :) = [to_test(i) to_test(j) ac_sep_twosteptask_v2([to_test(i) to_test(j) betas(1) betas(2) temps(1) temps(2)], num_instances, num_plays, boardPath, 0, 0, [0 0 0 0 0 0])];
        end
    end
    
    result = fvals_alphas;
    
    % Save everything
    boardNum = boardPath((strfind(boardPath,'/')+6):end);
    
    ParseData(fvals_alphas, 'alpha', boardNum, optNum_alpha, saveData);
end