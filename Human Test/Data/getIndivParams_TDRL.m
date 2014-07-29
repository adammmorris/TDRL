%% getIndivParams (in loss aversion project)
% This function finds the optimal individual parameters using the specified
%   model
% Uses patternsearch

%% Inputs:
% model should be a handle to a function that:
%   takes a single subject's info as input
%   and outputs the negLL
%   more specifically, it should be
%   model(x,actions,states,rewards,round#,combined)
% starts should be a k x numParams matrix, where k is the number of
%   different starts we want to do (and then take the best of)
% A and b are the linear constraint vectors
% bounds should be a 2 x numParams matrix, where the first row has the
%   lower limit & the second row has the upper limit

%% Outputs:
% optimalParams is a numSubjects x (numParams+2) matrix
% First column is id, last is negLL

function [optimalParams] = getIndivParams_TDRL(model,id,actions,states,rewards,round1,comb,starts,A,b,bounds,tosslist)
% Get the list of subjects
subjMarkers = getSubjMarkers(id);
numSubjects = length(subjMarkers);

% Get the parameter info
if (size(starts,2) ~= size(bounds,2))
    error('starts and bounds must have the same amount of columns');
end
numParams = size(starts,2);
numStarts = size(starts,1);

% Set patternsearch options
options = psoptimset('CompleteSearch','on','SearchMethod',{@searchlhs},'UseParallel','Always');    

% Set up results matrix
optimalParams = zeros(numSubjects,numParams+2); % first column will be id, last will be negLL

% Temporary variables
max_params = zeros(numParams,numStarts,numSubjects);
lik = zeros(numStarts,numSubjects);

%% Loop through starts
for thisStart = 1:numStarts
    % Loop through subjects
    parfor thisSubj = 1:numSubjects
        % Do we want to use this person?
        if ~any(tosslist == thisSubj)
            % Get the appropriate index
            if thisSubj < length(subjMarkers)
                index = subjMarkers(thisSubj):(subjMarkers(thisSubj + 1) - 1);
            else
                index = subjMarkers(thisSubj):length(id);
            end
            
            % Do patternsearch
            [max_params(:,thisStart,thisSubj),lik(thisStart,thisSubj),~] = patternsearch(@(params) model(params,actions(index),states(index),rewards(index),round1(index),comb),starts(thisStart,:),A,b,[],[],bounds(1,:),bounds(2,:),options);
        end
    end
end

% Take best results
for thisSubj = 1:numSubjects
    [~,bestStart] = min(lik(:,thisSubj)); % minimum likelihood
    optimalParams(thisSubj,:) = [thisSubj max_params(:,bestStart,thisSubj)' lik(bestStart,thisSubj)];
end

% Get rid of tossed rows
optimalParams = removerows(optimalParams,'ind',tosslist);
end