% This is going to maximize the two learning rates individually, using a
%   given global temp
function [results] = maximizeAB_undiff(id, A1, S2, A2, Re, globalTemp, start)

subjMarkers = getSubjMarkers(id);

% Trying to maximize alpha, beta, & temp
results = zeros(length(subjMarkers), 4);

% Set up patternsearch
options = psoptimset('CompleteSearch','on','SearchMethod',{@searchlhs},'UseParallel','Never', 'MeshExpansion', 2, 'MeshContraction', .5);

parfor thisSubject = 1:length(subjMarkers)
    % If we're not at the end..
    if thisSubject < length(subjMarkers)
        thisIndex = subjMarkers(thisSubject):(subjMarkers(thisSubject + 1) - 1);
    else   
        thisIndex = subjMarkers(thisSubject):length(id);
    end
    
    %[max_params, lik, ~] = fmincon(@(params) getLikelihood(params,A1(thisIndex), S2(thisIndex), A2(thisIndex), Re(thisIndex)),[0 0 5],[],[],[],[],[0 0 .1],[1 1 5]);
    [max_params, lik, ~] = patternsearch(@(params) getLikelihood_undiff(params, A1(thisIndex), S2(thisIndex), A2(thisIndex), Re(thisIndex), globalTemp),start,[],[],[],[],[.01 .01],[1 1],options);
    results(thisSubject, :) = cat(2, max_params, globalTemp, lik);
end

end