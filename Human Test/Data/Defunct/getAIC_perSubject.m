% Calculate AIC for each subject
% AIC for a given model = 2*(#params) + 2*(neg LL)

% negLLs should be a n x k matrix where n is the # of subjects and k is the # of models
% numParams should be a k x 1 matrix where k is the # of models
% AICs is going to be an n x k
function [AICs] = getAIC_perSubject(negLLs, numParams)
numSubjects = size(negLLs,1);
numModels = size(negLLs,2);
AICs = zeros(numSubjects,numModels);

for thisSubj = 1:numSubjects
    for thisModel = 1:numModels
        AICs(thisSubj,thisModel) = 2*negLLs(thisSubj,thisModel) + 2*numParams(thisModel);
    end
end
end