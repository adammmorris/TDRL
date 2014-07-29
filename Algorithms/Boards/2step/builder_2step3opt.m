%% builder_2step3opt
% This script builds a 2-step task with 3 options, with deterministic transitions &
% drifting rewards

% BOARD PARAMETERS

numMoves = 2; % # of decision points for the agent
numLevels = numMoves + 1; % # of levels - this is not including end state
numActions = 3; % # of options at each decision point

% Calculate # of states
numStates = 0;
for i = 1:numLevels
    numStates = numStates + numActions ^ (i-1);
end
numStates = numStates + 1; % add end state

numBoards = 1000;  % # of separate boards to be instantiated
numRounds = 250;

% TRANSITION MATRIX

% Develop transition matrix.
% transitions(state_i, action_j, board_k) is the state arrived at after
%   taking action_j at state_i in board_k

t = ones(numStates, numActions);

so_far = 0; % this will keep track of the # of states we've gone through so far
for level = 1 : numLevels
    levelStates = numActions ^ (level - 1); % # of states in this level
    for i = 1:levelStates
        for j = 1:numActions
            % If we're on the last move..
            if level == numLevels 
                t(i+so_far, j) = numStates; % Set to end state
            else % Otherwise..
                t(i+so_far, j) = (so_far + levelStates + 1) + (i-1)*(numActions) + (j-1);
            end
        end
    end
    
    so_far = so_far + levelStates;
end

%t(numStates,:) = ones; automatically set to ones

transitions = zeros(numStates, numActions, numBoards);

for i = 1:numBoards
    transitions(:,:,i) = t;
end

% BOARD MATRIX
% i.e. where the rewards are

% I'm making this a numStates x numBoards x numSwitches
boards = zeros(numStates,numRounds,numBoards);
rewardRange = 5;
rewardStates = 5:13;

% drift
for thisBoard = 1:numBoards
    % Implement random drifting
    directions = ones(numStates,1); % +1 or -1 for up or down
    increment = 1;
    weights = [.25 .25 .5]; % probs of (-increment, 0, increment)
    
    % Initialize random directions for drifting
    for i=1:numStates
        if rand() < .5
            directions(i) = directions(i) * -1;
        end
    end
    
    % initialize random first round rewards
    boards(rewardStates,1,thisBoard) = randsample(-rewardRange:rewardRange, length(rewardStates), true);
    
    % go through each round
    for thisRound = 1:(numRounds-1)
        % Loop through each rewardable state
        for curState = rewardStates
            % Was the last one at an extreme?
            if boards(curState,thisRound,thisBoard) >= rewardRange
                directions(curState) = -1;
            elseif boards(curState,thisRound,thisBoard) <= -rewardRange
                directions(curState) = 1;
            end
            
            % Get shift according to weights & then multiply it by
            %   curDirection
            shift = randsample([-increment 0 increment], 1, true, weights) * directions(curState);
            
            % Do it!
            boards(curState,thisRound+1,thisBoard) = boards(curState,thisRound,thisBoard) + shift;
        end
    end
end

[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
save(strcat(currentPath, '/2step3opt.mat'), 'boards', 'transitions', 'numStates', 'numMoves', 'numActions', 'numBoards');