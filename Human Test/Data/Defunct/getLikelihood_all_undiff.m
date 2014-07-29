% Gets likelihood for all subjects (for global optimization)
function [likelihood] = getLikelihood_all_undiff(x, A1, S2, A2, Re, subjMarkers)
likelihood = 0;
for thisSubject = 1:length(subjMarkers)
    if thisSubject < length(subjMarkers)
        thisIndex = subjMarkers(thisSubject):(subjMarkers(thisSubject + 1) - 1);
    else % just in case we're literally at the last line or something
        thisIndex = subjMarkers(thisSubject):length(subjMarkers);
    end
    
    likelihood = likelihood + getLikelihood_undiff(x, A1(thisIndex), S2(thisIndex), A2(thisIndex), Re(thisIndex));
end
end