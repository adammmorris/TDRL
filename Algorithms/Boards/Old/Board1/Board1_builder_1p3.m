% This script builds Board1

% BOARD PARAMETERS

numStates = 8; % # of states
numMoves = 2; % # of decision points for the agent
numActions = 2; % # of options at each decision point
numBoards = 10000;  % # of separate boards to be instantiated

% TRANSITION MATRIX

% Develop transition matrix.
% transitions(state_i, action_j, board_k) is the state arrived at after
%   taking action_j at state_i in board_k.

t = ones(numStates, numActions);
t(1,:) = [2 3];
t(2,:) = [4 5];
t(3,:) = [6 7];
t(4,:) = [8 8];
t(5,:) = [8 8];
t(6,:) = [8 8];
t(7,:) = [8 8];
t(8,:) = [1 1]; % terminal state

transitions = zeros(numStates, numActions, numBoards);

for i = 1:numBoards
    transitions(:,:,i) = t;
end

% BOARD MATRIX
% i.e. where the rewards are

rewards = [1 ; -1 ; 2 ; -2];
boards = zeros(numStates,numBoards);

for i = 1:numBoards
    boards(4:7,i) = randsample(rewards,4);
end

[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
save(strcat(currentPath, '/Board1.mat'), 'boards', 'transitions', 'numStates', 'numMoves', 'numActions', 'numBoards')