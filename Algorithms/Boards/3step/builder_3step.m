%% builder_3step
% This script builds a 3-step task with 2 options at each step
% It has deterministic transitions & drifting rewards
% The states on the bottom level have a large reward range, the states on
% the middle level have a small reward range, and the states on the top
%   level have no rewards

% BOARD PARAMETERS

numMoves = 3; % # of decision points for the agent
numLevels = numMoves + 1; % # of levels - this is not including end state
numActions = 2; % # of options at each decision point

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
rewardRange_middle = 5;
rewardRange_bottom = 10;

rewardStates_middle = 4:7;
rewardStates_bottom = 8:15;

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
    boards(rewardStates_middle,1,thisBoard) = randsample(-rewardRange_middle:rewardRange_middle, length(rewardStates_middle), true);
    boards(rewardStates_bottom,1,thisBoard) = randsample(-rewardRange_bottom:rewardRange_bottom, length(rewardStates_bottom), true);
    
    % go through each round
    for thisRound = 1:(numRounds-1)
        % Loop through middle reward states
        for curState = rewardStates_middle
            % Was the last one at an extreme?
            if boards(curState,thisRound,thisBoard) >= rewardRange_middle
                directions(curState) = -1;
            elseif boards(curState,thisRound,thisBoard) <= -rewardRange_middle
                directions(curState) = 1;
            end
            
            % Get shift according to weights & then multiply it by
            %   curDirection
            shift = randsample([-increment 0 increment], 1, true, weights) * directions(curState);
            
            % Do it!
            boards(curState,thisRound+1,thisBoard) = boards(curState,thisRound,thisBoard) + shift;
        end
        
        % Loop through bottom reward states
        for curState = rewardStates_bottom
            % Was the last one at an extreme?
            if boards(curState,thisRound,thisBoard) >= rewardRange_bottom
                directions(curState) = -1;
            elseif boards(curState,thisRound,thisBoard) <= -rewardRange_bottom
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
save(strcat(currentPath, '/3step.mat'), 'boards', 'transitions', 'numStates', 'numMoves', 'numActions', 'numBoards');