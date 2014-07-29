%% getGlobalParams_TDRL
% This function finds the optimal global parameters using the specified
%   model
% Uses patternsearch

%% Inputs:
% model should be a handle to a function that:
%   takes an entire id,a1,s2,a2,re,tosslist as input
%   and outputs the global negLL
% starts should be a k x numParams matrix, where k is the number of
%   different starts we want to do (and then take the best of)
% A and b are the linear constraint vectors
% bounds should be a 2 x numParams matrix, where the first row has the
%   lower limit & the second row has the upper limit

%% Outputs:
% optimalParams is a numSubjects x (numParams+1) matrix
% Last column is negLL

function [optimalParams] = getGlobalParams_TDRL(model,id,a1,s2,a2,re,starts,A,b,bounds,tosslist)

% Get the parameter info
if (size(starts,2) ~= size(bounds,2))
    error('starts and bounds must have the same amount of columns');
end
numParams = size(starts,2);
numStarts = size(starts,1);

% Set patternsearch options
options = psoptimset('CompleteSearch','on','SearchMethod',{@searchlhs},'UseParallel','Always');    

% Set up results matrix
optimalParams = zeros(1,numParams+1); % last column will be negLL

% Temporary variables
max_params = zeros(numParams,numStarts);
lik = zeros(numStarts,1);

%% Loop through starts
for thisStart = 1:numStarts
    % Do patternsearch
    [max_params(:,thisStart),lik(thisStart),~] = patternsearch(@(params) model(params,id,a1,s2,a2,re,tosslist),starts(thisStart,:),A,b,[],[],bounds(1,:),bounds(2,:),options);
end

% Take best results
[~,bestStart] = min(lik); % minimum likelihood
optimalParams(1,:) = [max_params(:,bestStart)' lik(bestStart)];

end