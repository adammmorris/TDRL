function [finalScores] = getFinalScores(scores, subjMarkers)
numSubjects = length(subjMarkers);
finalScores = zeros(numSubjects,1);
for i = 1:(numSubjects - 1)
    finalScores(i) = scores(subjMarkers(i+1)-1);
%     if thisSubj < numSubjects
%         index = subjMarkers(thisSubj):(subjMarkers(thisSubj + 1) - 1);
%     else
%         index = subjMarkers(thisSubj):length(id);
%     end
%     
%     finalScores(i) = scores(roundNum(index)==150);
end
finalScores(numSubjects) = scores(end);
end