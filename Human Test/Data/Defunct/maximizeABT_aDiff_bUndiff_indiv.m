% This maximize alphaR, alphaP, beta, temp
function [results] = maximizeABT_aDiff_bUndiff_indiv(id, A1, S2, A2, Re, tosslist, start, separateTemp)

if length(start) ~= 4
    error('start must have 4 params');
end

% This array is going to be populated with all the points at which a new
%   subject begins
subjMarkers = getSubjMarkers(id);
numSubjects = length(subjMarkers);

% Trying to maximize the 5 params, plus subject id at the beginning &
%   likelihood at the end
results = zeros(numSubjects, length(start) + 2);

options = psoptimset('CompleteSearch','on','SearchMethod',{@searchlhs},'UseParallel','Never', 'MeshExpansion', 2, 'MeshContraction', .5);    

for thisSubject = 1:numSubjects
    % Do we want to use this person?
    if sum(tosslist == thisSubject) == 0
        % If we're not at the end..
        if thisSubject < length(subjMarkers)
            thisIndex = subjMarkers(thisSubject):(subjMarkers(thisSubject + 1) - 1);
        else
            thisIndex = subjMarkers(thisSubject):length(id);
        end
        
        %[max_params, lik, ~] = fmincon(@(params) getLikelihood(params,A1(thisIndex), S2(thisIndex), A2(thisIndex), Re(thisIndex)),[0 0 5],[],[],[],[],[0 0 .1],[1 1 5]);
        [max_params, lik, ~] = patternsearch(@(params) getLikelihood_aDiff_bUndiff(params,A1(thisIndex), S2(thisIndex), A2(thisIndex), Re(thisIndex)), start,[],[],[],[],[0 0 0 .1],[1 1 1 2],options);
        results(thisSubject, :) = cat(2, subjMarkers(thisSubject), max_params', lik);
    end
end

% Get rid of tossed ppl
results = removerows(results, 'ind', find(results(:,1) == 0));

end