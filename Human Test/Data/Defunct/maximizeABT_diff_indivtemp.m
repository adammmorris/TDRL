% This does a global maximization on alphas & betas and an individual
% maximization on temp, using a differentiated model
% start should be [alphaR alphaP betaR betaP]

function [results, subjMarkers] = maximizeABT_diff_indivtemp(id, A1, S2, A2, Re, Tosslist, start)

% This array is going to be populated with all the points at which a new
%   subject begins
subjMarkers = getSubjMarkers(id);

% Trying to maximize alphaR, alphaP, betaR, & betaP globally
% 5th column is for likelihood
results = zeros(1, 5);

options = psoptimset('CompleteSearch','on','SearchMethod',{@searchlhs},'UseParallel','Never', 'MeshExpansion', 2, 'MeshContraction', .5);
[max_params, lik, ~] = patternsearch(@(params) getLikelihood_all_diff_indivtemp(params, A1, S2, A2, Re, Tosslist, subjMarkers),start,[],[],[],[],[0 0 0 0],[1 1 1 1],options);
results(1,:) = cat(2, max_params, lik);

end