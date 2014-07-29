% Procedure for model selection using individual MLE parameter estimates

% params is a cell of length numModels, where params{i} is a numSubjects x
%   numParams for model i
% negLLs is a numSubjects x numModels matrix
% The models must be in the same order, because:
% preferredModel tells us which (in order) of those models is the preferred
%   one
% negLLs_chance is a numSubjects x 1 matrix

function [pseudoR2s, paramPercentiles, comparisonToChance, globalLRtests, indivLRtests, AICs, AICs_perSubject, BMS_withAICs] = compareModels(params, negLLs, preferredModel, negLLs_chance)

% Get # of subjects, models, & parameters per model
numModels = length(params);
if size(negLLs,2) ~= numModels
    error('negLLs must have length(params) columns');
end

numSubjects = size(negLLs,1);
numParams = zeros(1,numModels);
for thisModel = 1:numModels
    numParams(thisModel) = size(params{thisModel},2);
    if size(params{thisModel},1) ~= numSubjects
        error('Each parameter matrix must have size(negLLs,1) rows');
    end
end

% Get global chance neg LL
negLL_chance_global = sum(negLLs_chance);

% Calculate the pseudo-R^s for each subject
pseudoR2s = 1 - (negLLs ./ repmat(negLLs_chance,1,numModels)); % McFadden
% pseudoR2s = 1 - (exp(-1 * negLLs) ./ repmat(exp(-1 * negLLs_chance),1,numModels)) .^ (repmat(numTrialsCompleted,1,numModels) / 2); % Cox & Snell

% For each model, calculate the 25th, 50th, and 75th percentiles of each
%   parameter, of the LLs (not the neg LLs)
paramPercentiles = cell(numModels, 1);
for thisModel = 1:numModels
    paramPercentiles{thisModel} = zeros(3, numParams(thisModel)+2);
    for thisParam = 1:numParams(thisModel)
        paramPercentiles{thisModel}(:,thisParam) = prctile(params{thisModel}(:,thisParam),[25 50 75])';
    end
    paramPercentiles{thisModel}(:,end-1) = prctile(-1 .* negLLs(:,thisModel),[25 50 75])';
    paramPercentiles{thisModel}(:,end) = prctile(pseudoR2s(:,thisModel),[25 50 75])';
end

% Get population-level negLLs
negLLs_global = sum(negLLs);

% Compare our preferred model to chance using individual likelihood ratio
% tests
% H0 is the simpler model (chance), Ha is our preferred model
% Uses a 1-tailed test
%comparisonToChance = zeros(3,1); % top row is the test statistic, second row is the df, bottom row is the p-value
%comparisonToChance(1) = 2 * (negLL_chance_global - negLLs_global(preferredModel));
%comparisonToChance(2) = numParams(preferredModel)*numSubjects; % # of added params
%comparisonToChance(3) = 1-chi2cdf(comparisonToChance(1), comparisonToChance(2));

comparisonToChance = zeros(numSubjects,1); % outputs p values

for thisSubj = 1:numSubjects
    x = 2*(negLLs_chance(thisSubj) - negLLs(thisSubj,preferredModel));
    v = numParams(preferredModel);
    comparisonToChance(thisSubj,1) = 1-chi2cdf(x,v);
end

% Compare our preferred model to other models using global likelihood ratio
%   tests
% All 1-tailed
globalLRtests = zeros(3,numModels); % top row is the test statistic, second is the df, bottom is the p-value

globalLRtests(1,:) = 2*(negLLs_global - negLLs_global(preferredModel));
globalLRtests(2,:) = numParams(preferredModel)*numSubjects - numParams.*numSubjects;
globalLRtests(3,:) = 1-chi2cdf(globalLRtests(1,:), globalLRtests(2,:));

% Do likelihood ratio tests for each subject comparing each model to our
%   preferred model
% Outputs p values
indivLRtests = zeros(numSubjects,numModels); % p values

for thisSubj = 1:numSubjects
    x = 2*(negLLs(thisSubj,:) - negLLs(thisSubj,preferredModel));
    v = numParams(preferredModel) - numParams;
    indivLRtests(thisSubj,:) = 1-chi2cdf(x,v);
end

% Get global AICs
AICs = 2*(numParams)*numSubjects + 2*(negLLs_global);

% Do Bayesian model selection, using AIC as the log model evidence
AICs_perSubject = repmat(2*(numParams),numSubjects,1) + 2*negLLs;

BMS_withAICs = cell(3,1); % first is model probabilities, second is expected posterior, third is exceedance probabilities
[BMS_withAICs{1}, BMS_withAICs{2}, BMS_withAICs{3}] = spm_BMS(-1 .* AICs_perSubject);

% Display tables

% Table #1: parameter percentiles for preferred model
format;
str = '    Param1';
for i = 2:numParams(preferredModel)
    str = [str '    Param' num2str(i)];
end
str = [str '    LLs'];
str = [str '    pseudo-R^2s'];
disp(str)
disp(paramPercentiles{preferredModel});

disp(''); % newline

% Table #2: for each model..
format short g;
disp('       negLL       globalLR       indivLR       AICs      ModelProbs     ExceedanceProbs');
disp([negLLs_global' globalLRtests(3,:)' sum(indivLRtests < .05)' AICs' BMS_withAICs{1}' BMS_withAICs{3}']);
end