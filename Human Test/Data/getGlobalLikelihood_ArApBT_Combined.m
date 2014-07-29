%% getGlobalLikelihood_ArApBT_combined
% Gets the global likelihood for the model with a combined learner &
%   differentiated alphas

function [likelihood] = getGlobalLikelihood_ArApBT_Combined(x, id, A1, S2, A2, Re, Tosslist)
subjMarkers = getSubjMarkers(id);
likelihoods = zeros(length(subjMarkers),1);

parfor thisSubject = 1:length(subjMarkers)
    % Do we want to use this subject?
    if sum(Tosslist == thisSubject) == 0
        % Figure out the proper index
        if thisSubject < length(subjMarkers)
            thisIndex = subjMarkers(thisSubject):(subjMarkers(thisSubject + 1) - 1);
        else   
            thisIndex = subjMarkers(thisSubject):length(subjMarkers);
        end

        likelihoods(thisSubject) = getIndivLikelihood_ArApBT_Combined(x, A1(thisIndex), S2(thisIndex), A2(thisIndex), Re(thisIndex));
    end
end

likelihood = sum(likelihoods);
end