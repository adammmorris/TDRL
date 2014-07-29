% This does a global maximization on alphas, betas, and temps, using a
%   differentiated model.
% if separateTemp is 0: alphaR alphaP betaR betaP temp
% if separateTemp is 1: alphaR alphaP betaR*tempR betaP*tempP

function [results, subjMarkers] = maximizeABT_diff(id, A1, S2, A2, Re, Tosslist, start, separateTemp)

if (separateTemp == 0 && length(start) ~= 5) || (separateTemp == 1 && length(start) ~= 4)
    error('start has wrong # of values');
end

% This array is going to be populated with all the points at which a new
%   subject begins
subjMarkers = getSubjMarkers(id);

if separateTemp == 0
    % Trying to maximize alphaR, alphaP, betaR, betaP & temp globally
    % 6th column is for likelihood
    results = zeros(1, 6);

    options = psoptimset('CompleteSearch','on','SearchMethod',{@searchlhs},'UseParallel','Never', 'MeshExpansion', 2, 'MeshContraction', .5);
    [max_params, lik, ~] = patternsearch(@(params) getLikelihood_all_diff(params, A1, S2, A2, Re, Tosslist, subjMarkers, separateTemp),start,[],[],[],[],[0 0 0 0 .1],[1 1 1 1 2],options);
    results(1,:) = cat(2, max_params, lik);
elseif separateTemp == 1
    % Trying to maximize alphaR, alphaP, betaR*tempR, betaP*tempP
    results = zeros(1,5);
    options = psoptimset('CompleteSearch','on','SearchMethod',{@searchlhs},'UseParallel','Never', 'MeshExpansion', 2, 'MeshContraction', .5);
    [max_params, lik, ~] = patternsearch(@(params) getLikelihood_all_diff(params, A1, S2, A2, Re, Tosslist, subjMarkers, separateTemp),start,[],[],[],[],[0 0 0 0],[1 1 2 2],options);
    results(1,:) = cat(2, max_params, lik);
end

end