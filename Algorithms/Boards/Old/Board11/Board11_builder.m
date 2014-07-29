% This script builds Board11
% Board11 is 4-level, values on levels 2-4, fully randomized (but segregated
%   by level)
% But also has 'switches' implemented

% BOARD PARAMETERS

numMoves = 3; % # of decision points for the agent
numLevels = numMoves + 1; % # of levels - this is not including end state
numActions = 4; % # of options at each decision point

% Calculate # of states
numStates = 0;
for i = 1:numLevels
    numStates = numStates + numActions ^ (i-1);
end
numStates = numStates + 1; % add end state

numBoards = 10000;  % # of separate boards to be instantiated
numSwitches = 10; % # each board has a certain # of switches - separate sub-boards through which the agent will cycle

% Different types of randomization
% randomized = 0 -> no randomization
% randomized = 1 -> "soft" randomization
%   this means to keep each tree separate, and randomize intra-tree and
%   inter-tree without mixing
% randomized = 2 -> "hard" randomization
%   this means to completely randomize where the rewards are
randomized = 2;

% TRANSITION MATRIX

% Develop transition matrix.
% transitions(state_i, action_j, board_k) is the state arrived at after
%   taking action_j at state_i in board_k.

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

% rewards is a cell array, where rewards{i} is the set of rewards for the ith level (starting
%   at level 1)
rewards = cell(numLevels,1);

for i = 1 : numLevels
    rewards{i} = zeros(numActions ^ (i-1), 1);
end

% I'm making this a numStates x numBoards x numSwitches
boards = zeros(numStates,numBoards,numSwitches);

for i = 1:numBoards
    for j = 1:numSwitches
        if randomized == 1
            % Soft randomization
            
            % For level 2, I want half punishments & half zeros
            boards(2:3, i) = randsample(-15:-5, 2, true);
            boards(4:5, i) = [0 0];
            boards(2:5,i) = randsample(boards(2:5,i), length(boards(2:5,i)));
            
            % For level 3, I want 4 trees with half rewards, half
            %   punishments
            trees = zeros(numActions, numActions);
            
            for k = 1:4
                trees(k, 1:2) = randsample(10:25, 2, true);
                trees(k, 3:4) = randsample(-25:-10, 2, true);
                trees(k, :) = randsample(trees(k, :), length(trees(k, :))); % Permute them
            end
            
            % Randomize between trees
            tree_order = randperm(numActions);
            for q = 1 : numActions
                boards(((numActions+2) + numActions*(q-1)):((numActions+2) + numActions*(q-1) + (numActions-1)), i) = trees(tree_order(q), :);
            end
            
        elseif randomized == 2
            % hard randomization, segregated by level
            boards(2:5, i, j) = randsample(-15:15, numActions, true);
            boards(6:21, i, j) = randsample(-30:30, numActions ^ 2, true);
            boards(22:85, i, j) = randsample(-60:60, numActions ^ 3, true);
        else
            % no randomization
            boards(6:21,i) = rewards;
        end
    end
end

% RISK MATRIX
% Give each state a % chance of 'flipping' its reward (i.e. multiplying it
%   by -1)
%risk = zeros(numStates, numBoards);
%for i = 1:numBoards
    % only give this to level 3, and only give it to rewards
%    risk(boards(22:85,i) > 0, i) = randsample(50, sum(boards(22:85,i) > 0), true);
%end

[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
save(strcat(currentPath, '/Board11.mat'), 'boards', 'transitions', 'numStates', 'numMoves', 'numActions', 'numBoards', 'numSwitches')