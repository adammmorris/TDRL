% This maximize alpha, betaR, betaP, temp
function [results] = maximizeABT_aUndiff_bDiff_indiv(id, A1, S2, A2, Re, tosslist, start, separateTemp)

if (separateTemp == 0 && length(start) ~= 4) || (separateTemp == 1 && length(start) ~= 3)
    error('start has wrong # of values');
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
        
        if separateTemp == 0
            [max_params, lik, ~] = patternsearch(@(params) getLikelihood_aUndiff_bDiff(params,A1(thisIndex), S2(thisIndex), A2(thisIndex), Re(thisIndex), separateTemp), start,[],[],[],[],[0 0 0 .1],[1 1 1 2],options);
        elseif separateTemp == 1
            [max_params, lik, ~] = patternsearch(@(params) getLikelihood_aUndiff_bDiff(params,A1(thisIndex), S2(thisIndex), A2(thisIndex), Re(thisIndex), separateTemp), start,[],[],[],[],[0 0 0],[1 1 2],options);
        end
        results(thisSubject, :) = cat(2, subjMarkers(thisSubject), max_params', lik);
    end
end

% Get rid of tossed ppl
results = removerows(results, 'ind', find(results(:,1) == 0));

end