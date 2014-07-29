% Gets likelihood for all subjects (for global optimization)
% x should contain [alphaR alphaP betaR betaP temp]
function [likelihood, numSlips] = getLikelihood_all_diff(x, A1, S2, A2, Re, Tosslist, subjMarkers, separateTemp)
likelihoods = zeros(length(subjMarkers),1);
numSlips = zeros(length(subjMarkers),1);
for thisSubject = 1:length(subjMarkers)
    % Do we want to use this subject?
    if sum(Tosslist == thisSubject) == 0
        % Figure out the proper index
        if thisSubject < length(subjMarkers)
            thisIndex = subjMarkers(thisSubject):(subjMarkers(thisSubject + 1) - 1);
        else   
            thisIndex = subjMarkers(thisSubject):length(subjMarkers);
        end

        [likelihoods(thisSubject), numSlips(thisSubject)] = getLikelihood_diff(x, A1(thisIndex), S2(thisIndex), A2(thisIndex), Re(thisIndex), separateTemp);
    end
end
likelihood = sum(likelihoods);
end