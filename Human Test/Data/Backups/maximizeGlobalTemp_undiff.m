% This is going to maximize temperature globally (while maximizing the
%   learning rates individually within)
function [results, results_temp] = maximizeGlobalTemp_undiff(id, A1, S2, A2, Re, start)
tempRange = .1:.1:2;
subjMarkers = getSubjMarkers(id);
results = zeros(length(subjMarkers), 4);
results_temp = zeros(length(subjMarkers), 4, length(tempRange));
bestLik = realmax;

for i = 1:length(tempRange)
    results_temp(:, :, i) = maximizeAB_undiff(id, A1, S2, A2, Re, tempRange(i), start);
    
    % Is this the best one so far?
    lik = sum(results_temp(:,:,i));
    lik = lik(4);
    if lik < bestLik
        results = results_temp(:,:,i);
        bestLik = lik;
    end
end
end