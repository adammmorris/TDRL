% Gets likelihood for all subjects (for global optimization)
% This one maximizes temp individually
% x parameter should contain [alphaR alphaP betaR betaP]

function [likelihood] = getLikelihood_all_diff_indivtemp(x, A1, S2, A2, Re, Tosslist, subjMarkers)
likelihood = 0;
for thisSubject = 1:length(subjMarkers)
    % Do we want to use this subject?
    if sum(Tosslist == thisSubject) == 0
        % Figure out the proper index
        if thisSubject < length(subjMarkers)
            thisIndex = subjMarkers(thisSubject):(subjMarkers(thisSubject + 1) - 1);
        else   
            thisIndex = subjMarkers(thisSubject):length(subjMarkers);
        end

        % Get optimal temp for this subject
        options = psoptimset('CompleteSearch','on','SearchMethod',{@searchlhs},'UseParallel','Never', 'MeshExpansion', 2, 'MeshContraction', .5);
        [max_params, lik, ~] = patternsearch(@(temp) getLikelihood_diff([x temp], A1(thisIndex), S2(thisIndex), A2(thisIndex), Re(thisIndex)),[1 1],[],[],[],[],[.1],[2],options);

        x(5) = max_params(1); % Set that optimal temp
        likelihood = likelihood + getLikelihood_diff(x, A1(thisIndex), S2(thisIndex), A2(thisIndex), Re(thisIndex));
    end
end
end