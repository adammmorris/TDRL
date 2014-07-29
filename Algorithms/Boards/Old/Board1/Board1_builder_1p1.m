% Develop transition matrix.
% transitions(state_i, action_j, board_k) is the state arrived at after
%   taking action_j at state_i in board_k.

numBoards = 1000;
numStates = 8;

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

% b = [0 ; 0 ; 0 ; 1 ; -1 ; 0 ; 0 ; 0];
% boards = repmat(b,1,1000);
% save('badgood/2s_boards.mat','boards')
% 
% b = [0 ; 0 ; 0 ; 1 ; -1 ; 2 ; -2 ; 0];
% boards = repmat(b,1,1000);
% save('badgood/2sp1_boards.mat','boards')
% 
% b = [0 ; 0 ; 0 ; 1 ; -1 ; 2 ; -2];
% for i = 1:10000
%     boards(:,i) = randsample(b,7);
% end
% boards(8,:) = zeros(1,10000);
% save('badgood/2sp2_boards.mat','boards')

% This is the one we're currently using.
% boards(state_i, board_k) = the reward given at state_i in board_k.

b = [1 ; -1 ; 2 ; -2];
boards = zeros(numStates,numBoards);
for i = 1:numBoards
    boards(4:7,i) = randsample(b,4);
end
save('2sp3_boards.mat','boards')