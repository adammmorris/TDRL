function [results] = getBestOptimization(funcHandle, id, A1, S2, A2, Re, tosslist, numStart, separateTemp)
% Optimize with different starts
resultLists = cell(3,1);
resultLists{1} = funcHandle(id,A1,S2,A2,Re,tosslist,zeros(numStart,1),separateTemp);
resultLists{2} = funcHandle(id,A1,S2,A2,Re,tosslist,.5.*ones(numStart,1),separateTemp);
resultLists{3} = funcHandle(id,A1,S2,A2,Re,tosslist,ones(numStart,1),separateTemp);

numSubjects = size(resultLists{1},1);
numCols = size(resultLists{1},2);

likelihoods = [resultLists{1}(:,end) resultLists{2}(:,end) resultLists{3}(:,end)]; % We want the last column - the likelihood

results = zeros(numSubjects, numCols);

% Choose best likelihood from each
for thisSubj = 1:numSubjects
    [~,ind] = min(likelihoods(thisSubj,:)); % Get lowest likelihood
    results(thisSubj,:) = resultLists{ind}(thisSubj,:);
end
end