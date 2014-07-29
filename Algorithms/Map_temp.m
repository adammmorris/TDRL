% Map_temp
% This just does temps w/ given alphas & betas

function [result] = Map_temp(alphas, betas, boardPath, optNum, saveData)
    min_param = 2;
    max_param = 5;
    param_step = .5;
    to_test = min_param : param_step : max_param;
    num_to_test = length(to_test);
    num_instances = 10000;
    num_plays = 100;

    fvals_temps_1 = zeros(num_to_test, num_to_test, 3);

    for i = 1 : num_to_test
        parfor j = 1 : num_to_test
            fvals_temps_1(i, j, :) = [to_test(i) to_test(j) ac_sep_1p11([alphas(1) alphas(2) betas(1) betas(2) to_test(i) to_test(j)], num_instances, num_plays, boardPath)];
        end
    end

    % Save everything
    boardNum = boardPath((strfind(boardPath,'/')+6):end);
    
    result = fvals_temps_1;
    ParseData(fvals_temps_1, 'temp', boardNum, optNum, saveData);
end