% Who should we toss?
function [tosslist, remainder] = toss(params, id, numTrialsCompleted)
tosslist = [];
subjMarkers = getSubjMarkers(id);
for i = 1:length(subjMarkers)
    % Check filter criteria
    if params(i,2) < prctile(params(:,2),20) || params(i,3) < prctile(params(:,3),20) || numTrialsCompleted(i) < 100
        tosslist(end+1) = i;
    end
end
remainder = removerows(params, 'ind', [tosslist]);
end