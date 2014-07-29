% This script builds Board7
% Board7 is double-tier (w/ only punishments on upper tier), punishments are NOT doubled, equal amounts of
%   rewards & punishments

% BOARD PARAMETERS

numStates = 22; % # of states
numMoves = 2; % # of decision points for the agent
numActions = 4; % # of options at each decision point
numBoards = 20000;  % # of separate boards to be instantiated

% Different types of randomization for the lower tier (upper is always
%   hard)
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
t(1,:) = [2 3 4 5];
t(2,:) = [6 7 8 9];
t(3,:) = [10 11 12 13];
t(4,:) = [14 15 16 17];
t(5,:) = [18 19 20 21];
for i = 6:21
    t(i,:) = [22 22 22 22];
end
t(22,:) = [1 1 1 1]; % terminal state

transitions = zeros(numStates, numActions, numBoards);

for i = 1:numBoards
    transitions(:,:,i) = t;
end

% BOARD MATRIX
% i.e. where the rewards are

rewards_upper = [-10 -5 -15 0]';
rewards_lower = [-25 25 -10 10 -50 50 -10 10 -32 32 0 0 -5 5 -10 10]';
boards = zeros(numStates,numBoards);

for i = 1:numBoards
    % For lower tier..
    if randomized == 1
        % Soft randomization

        % Randomize within each tree
        trees = zeros(4, 4);
        trees(1, :) = randsample(rewards_lower(1:4), 4, false);
        trees(2, :) = randsample(rewards_lower(5:8), 4, false);
        trees(3, :) = randsample(rewards_lower(9:12), 4, false);
        trees(4, :) = randsample(rewards_lower(13:16), 4, false);
        
        % Randomize between trees
        tree_order = randperm(4);
        boards(6:9,i) = trees(tree_order(1), :);
        boards(10:13,i) = trees(tree_order(2), :);
        boards(14:17,i) = trees(tree_order(3), :);
        boards(18:21,i) = trees(tree_order(4), :);
        
    elseif randomized == 2
        % hard randomization
        boards(6:21,i) = randsample(rewards_lower, length(rewards_lower));
    else
        % no randomization
        boards(6:21,i) = rewards_lower;
    end
    
    % For upper tier, always hard randomize
    boards(2:5,i) = randsample(rewards_upper, length(rewards_upper));
end

[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
save(strcat(currentPath, '/Board7_soft.mat'), 'boards', 'transitions', 'numStates', 'numMoves', 'numActions', 'numBoards')