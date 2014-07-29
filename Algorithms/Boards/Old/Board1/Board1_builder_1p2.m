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

t = ones(numStates,2);
t(1,:) = [2 3];
t(2,:) = [4 5];
t(3,:) = [6 7];
t(4,:) = [8 8];
t(5,:) = [8 8];
t(6,:) = [8 8];
t(7,:) = [8 8];
t(8,:) = [1 1]; % terminal state

transitions = zeros(numStates,2,numBoards);

for i = 1:numBoards
    transitions(:,:,i) = t;
end

save('2s_transitions.mat','transitions')

% Develop board matrices.

% This board will be called Board1
b = [1 ; -1 ; 2 ; -2];
boards = zeros(numStates,numBoards);
for i = 1:numBoards
    boards(4:7,i) = randsample(b,4);
end
save('2sp3_boards.mat','boards', 'numStates', 'numMoves', 'numActions', 'numBoards')