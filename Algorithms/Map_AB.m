% Map_AB
% This just does alphas w/ given betas & temps, and betas w/ optimal alphas & given temps

function [res1, res2] = Map_AB(betas, temps, boardPath, optNum_alpha, optNum_beta, saveData)
    min_param = 0;
    max_param = 1;
    param_step = .1;
    to_test = min_param : param_step : max_param;
    num_to_test = length(to_test);
    num_instances = 10000;
    num_plays = 50;

    fvals_alphas_1 = zeros(num_to_test, num_to_test, 3);
    fvals_betas_1 = zeros(num_to_test, num_to_test, 3);
    
    for i = 1 : num_to_test
        parfor j = 1 : num_to_test
            fvals_alphas_1(i, j, :) = [to_test(i) to_test(j) ac_sep_1p11([to_test(i) to_test(j) betas(1) betas(2) temps(1) temps(2)], num_instances, num_plays, boardPath)];
        end
    end
    
    [~, i_x] = max(fvals_alphas_1(:,:,3)); [~, i_y] = max(max(fvals_alphas_1(:,:,3)));
    i_x = i_x(i_y);
    best_alphaR = fvals_alphas_1(i_x, i_y, 1);
    best_alphaP = fvals_alphas_1(i_x, i_y, 2);
    
    for i = 1 : num_to_test
        parfor j = 1 : num_to_test
            fvals_betas_1(i, j, :) = [to_test(i) to_test(j) ac_sep_1p11([best_alphaR best_alphaP to_test(i) to_test(j) temps(1) temps(2)], num_instances, num_plays, boardPath)];
        end
    end

    res1 = fvals_alphas_1;
    res2 = fvals_betas_1;
    
    % Save everything
    boardNum = boardPath((strfind(boardPath,'/')+6):end);
    
    ParseData(fvals_alphas_1, 'alpha', boardNum, optNum_alpha, saveData);
    ParseData(fvals_betas_1, 'beta', boardNum, optNum_beta, saveData);
end