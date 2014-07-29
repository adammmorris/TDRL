% This script builds Board8
% Board8 is single-tier, punishments are NOT doubled, equal amounts of
%   rewards & punishments - but there's multiple branches of all
%   punishments

% BOARD PARAMETERS

numMoves = 2; % # of decision points for the agent
numLevels = numMoves + 1; % # of levels
numActions = 8; % # of options at each decision point

% Calculate # of states
numStates = 0;  
for i = 1:numLevels
    numStates = numStates + numActions ^ (i-1);
end
numStates = numStates + 1; % add end state

numBoards = 10000;  % # of separate boards to be instantiated

% Different types of randomization
% randomized = 0 -> no randomization
% randomized = 1 -> "soft" randomization
%   this means to keep each tree separate, and randomize intra-tree and
%   inter-tree without mixing
% randomized = 2 -> "hard" randomization
%   this means to completely randomize where the rewards are
randomized = 1;

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

boards = zeros(numStates,numBoards);

for i = 1:numBoards
    if randomized == 1
        % Soft randomization

        % For this board, I want 4 trees with only punishments + zeros (to create evil branches), 2
        %   trees with only low rewards (to balance punishments), 2 trees with half large rewards &
        %   half punishments (to preserve necessary cliffs)
        % And only on level 3
        trees = zeros(numActions, numActions);
        
        % First 4 trees
        for k = 1:4
            trees(k, 1:4) = randsample(-25:-1, 4, true);
            trees(k, 5:8) = [0 0 0 0];
            trees(k, :) = randsample(trees(k, :), length(trees(k, :))); % Permute them
        end
        
        % Next 2 trees
        for k = 5:6
            trees(k, 1:8) = randsample(1:25, 8, true);
            trees(k, :) = randsample(trees(k, :), length(trees(k, :))); % Permute them
        end
        
        % Final 2 trees
        for k = 7:8
            trees(k, 1:4) = randsample(25:50, 4, true);
            trees(k, 5:8) = randsample(-50:-25, 4, true);
            trees(k, :) = randsample(trees(k, :), length(trees(k, :))); % Permute them
        end
        
        % Randomize between trees
        tree_order = randperm(numActions);
        for q = 1 : 8
            boards((10 + 8*(q-1)):(10 + 8*(q-1)+7), i) = trees(tree_order(q), :);
        end
        
    elseif randomized == 2
        % hard randomization
        boards(6:21,i) = randsample(rewards, length(rewards));
    else
        % no randomization
        boards(6:21,i) = rewards;
    end
end

[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
save(strcat(currentPath, '/Board8_soft.mat'), 'boards', 'transitions', 'numStates', 'numMoves', 'numActions', 'numBoards')