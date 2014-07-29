% Map_B
% This just does betas w/ given alphas & temps

function [result] = Map_BtimesTemp(alphas, boardPath, num_instances, num_plays, optNum, saveData)
    min_beta = 0;
    max_beta = 1;
    beta_step = .1;
    min_temp = .1;
    max_temp = 2.3;
    temp_step = .2;
    to_test_beta = min_beta : beta_step : max_beta;
    to_test_temp = min_temp : temp_step : max_temp;
    num_to_test = length(to_test_beta);

    fvals_1 = zeros(num_to_test, num_to_test, 3);
    
    for i = 1 : num_to_test
        parfor j = 1 : num_to_test
            [means, ~, ~] = ac_sep_twosteptask_v2([alphas(1) alphas(2) to_test_beta(i) to_test_beta(j) to_test_temp(i) to_test_temp(j)], num_instances, num_plays, boardPath, 0, 0, [0 0 0 0 0 0]);
            fvals_1(i, j, :) = [(to_test_beta(i)*to_test_temp(i)) (to_test_beta(j) * to_test_temp(j)) means];
        end
    end

    result = fvals_1;
    
    % Save everything
    %boardNum = boardPath((strfind(boardPath,'/')+6):end);
    
    %ParseData(fvals_1, '(beta*temp)', boardNum, optNum, saveData);
end