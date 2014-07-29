% This script builds Board13 - another board for humans
% This board is a replication of Fiery's 2-step task (in order to help with
%   analysis of that data)
% Basically it's just a two-level board with stochastic transitions and
%   his rewards at the bottom

% BOARD PARAMETERS

numMoves = 2; % # of decision points for the agent
numLevels = numMoves + 1; % # of levels - this is not including end state
numActions = 2; % # of options at each decision point

% Calculate # of states
numStates = 0;
for i = 1:numLevels
    numStates = numStates + numActions ^ (i-1);
end
numStates = numStates + 1; % add end state

numBoards = 1000;  % # of separate boards to be instantiated
numSwitches = 1; % # each board has a certain # of switches - separate sub-boards through which the agent will cycle

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
            rewardRange = 5;
            possible_rewards = -rewardRange:rewardRange;
            %possible_rewards(rewardRange + 1) = []; % remove 0
            boards(4:7, i, j) = randsample(possible_rewards, 4, true);
        else
            % no randomization
            boards(6:21,i) = rewards;
        end
    end
end

winsArray = zeros(4, 149);
winsArray(1, 1) = 4;
winsArray(1, 2) = 3;
winsArray(1, 3) = 4;
winsArray(1, 4) = 2;
winsArray(1, 5) = 3;
winsArray(1, 6) = 3;
winsArray(1, 7) = 4;
winsArray(1, 8) = 3;
winsArray(1, 9) = 1;
winsArray(1, 10) = 1;
winsArray(1, 11) = -1;
winsArray(1, 12) = -2;
winsArray(1, 13) = -2;
winsArray(1, 14) = -3;
winsArray(1, 15) = -2;
winsArray(1, 16) = -4;
winsArray(1, 17) = -3;
winsArray(1, 18) = -3;
winsArray(1, 19) = -2;
winsArray(1, 20) = -2;
winsArray(1, 21) = -3;
winsArray(1, 22) = -3;
winsArray(1, 23) = -4;
winsArray(1, 24) = -2;
winsArray(1, 25) = 1;
winsArray(1, 26) = 1;
winsArray(1, 27) = -1;
winsArray(1, 28) = 0;
winsArray(1, 29) = 0;
winsArray(1, 30) = 1;
winsArray(1, 31) = 2;
winsArray(1, 32) = 2;
winsArray(1, 33) = 0;
winsArray(1, 34) = 0;
winsArray(1, 35) = -1;
winsArray(1, 36) = 1;
winsArray(1, 37) = 1;
winsArray(1, 38) = 3;
winsArray(1, 39) = 2;
winsArray(1, 40) = 0;
winsArray(1, 41) = 0;
winsArray(1, 42) = -1;
winsArray(1, 43) = -1;
winsArray(1, 44) = 0;
winsArray(1, 45) = 2;
winsArray(1, 46) = 3;
winsArray(1, 47) = 4;
winsArray(1, 48) = 3;
winsArray(1, 49) = 1;
winsArray(1, 50) = 1;
winsArray(1, 51) = 1;
winsArray(1, 52) = 0;
winsArray(1, 53) = 3;
winsArray(1, 54) = 2;
winsArray(1, 55) = 3;
winsArray(1, 56) = 2;
winsArray(1, 57) = 3;
winsArray(1, 58) = 4;
winsArray(1, 59) = 5;
winsArray(1, 60) = 4;
winsArray(1, 61) = 0;
winsArray(1, 62) = 0;
winsArray(1, 63) = -1;
winsArray(1, 64) = -2;
winsArray(1, 65) = -2;
winsArray(1, 66) = -1;
winsArray(1, 67) = 0;
winsArray(1, 68) = 1;
winsArray(1, 69) = 3;
winsArray(1, 70) = 5;
winsArray(1, 71) = 4;
winsArray(1, 72) = 4;
winsArray(1, 73) = 5;
winsArray(1, 74) = 3;
winsArray(1, 75) = 3;
winsArray(1, 76) = 2;
winsArray(1, 77) = 2;
winsArray(1, 78) = 0;
winsArray(1, 79) = 1;
winsArray(1, 80) = 1;
winsArray(1, 81) = 0;
winsArray(1, 82) = -1;
winsArray(1, 83) = 0;
winsArray(1, 84) = 0;
winsArray(1, 85) = -1;
winsArray(1, 86) = -1;
winsArray(1, 87) = -3;
winsArray(1, 88) = -3;
winsArray(1, 89) = -1;
winsArray(1, 90) = -1;
winsArray(1, 91) = 1;
winsArray(1, 92) = 3;
winsArray(1, 93) = 4;
winsArray(1, 94) = 5;
winsArray(1, 95) = 4;
winsArray(1, 96) = 5;
winsArray(1, 97) = 3;
winsArray(1, 98) = 4;
winsArray(1, 99) = 4;
winsArray(1, 100) = 3;
winsArray(1, 101) = 3;
winsArray(1, 102) = 1;
winsArray(1, 103) = 0;
winsArray(1, 104) = 0;
winsArray(1, 105) = 1;
winsArray(1, 106) = 0;
winsArray(1, 107) = -1;
winsArray(1, 108) = 0;
winsArray(1, 109) = 0;
winsArray(1, 110) = -1;
winsArray(1, 111) = -1;
winsArray(1, 112) = -2;
winsArray(1, 113) = -3;
winsArray(1, 114) = -2;
winsArray(1, 115) = 0;
winsArray(1, 116) = 2;
winsArray(1, 117) = 2;
winsArray(1, 118) = 0;
winsArray(1, 119) = -1;
winsArray(1, 120) = -3;
winsArray(1, 121) = -4;
winsArray(1, 122) = -3;
winsArray(1, 123) = -3;
winsArray(1, 124) = -4;
winsArray(1, 125) = -3;
winsArray(1, 126) = -4;
winsArray(1, 127) = -2;
winsArray(1, 128) = -1;
winsArray(1, 129) = -2;
winsArray(1, 130) = -1;
winsArray(1, 131) = 0;
winsArray(1, 132) = 0;
winsArray(1, 133) = 0;
winsArray(1, 134) = 0;
winsArray(1, 135) = 3;
winsArray(1, 136) = 3;
winsArray(1, 137) = 2;
winsArray(1, 138) = 1;
winsArray(1, 139) = 0;
winsArray(1, 140) = -2;
winsArray(1, 141) = -2;
winsArray(1, 142) = -3;
winsArray(1, 143) = -2;
winsArray(1, 144) = -1;
winsArray(1, 145) = -1;
winsArray(1, 146) = 0;
winsArray(1, 147) = 0;
winsArray(1, 148) = -1;
winsArray(1, 149) = -1;
winsArray(2, 1) = 1;
winsArray(2, 2) = 1;
winsArray(2, 3) = 0;
winsArray(2, 4) = 1;
winsArray(2, 5) = 2;
winsArray(2, 6) = 3;
winsArray(2, 7) = 4;
winsArray(2, 8) = 4;
winsArray(2, 9) = 3;
winsArray(2, 10) = 5;
winsArray(2, 11) = 4;
winsArray(2, 12) = 4;
winsArray(2, 13) = 3;
winsArray(2, 14) = 2;
winsArray(2, 15) = -1;
winsArray(2, 16) = -1;
winsArray(2, 17) = -2;
winsArray(2, 18) = -2;
winsArray(2, 19) = -2;
winsArray(2, 20) = 0;
winsArray(2, 21) = 0;
winsArray(2, 22) = 1;
winsArray(2, 23) = 2;
winsArray(2, 24) = 3;
winsArray(2, 25) = -3;
winsArray(2, 26) = -2;
winsArray(2, 27) = -4;
winsArray(2, 28) = -5;
winsArray(2, 29) = -3;
winsArray(2, 30) = -2;
winsArray(2, 31) = -1;
winsArray(2, 32) = -1;
winsArray(2, 33) = 0;
winsArray(2, 34) = -2;
winsArray(2, 35) = -1;
winsArray(2, 36) = 2;
winsArray(2, 37) = 3;
winsArray(2, 38) = 5;
winsArray(2, 39) = 4;
winsArray(2, 40) = 4;
winsArray(2, 41) = 4;
winsArray(2, 42) = 3;
winsArray(2, 43) = 2;
winsArray(2, 44) = 3;
winsArray(2, 45) = 3;
winsArray(2, 46) = 0;
winsArray(2, 47) = 0;
winsArray(2, 48) = 2;
winsArray(2, 49) = 3;
winsArray(2, 50) = 2;
winsArray(2, 51) = 2;
winsArray(2, 52) = 3;
winsArray(2, 53) = 3;
winsArray(2, 54) = 1;
winsArray(2, 55) = 1;
winsArray(2, 56) = 2;
winsArray(2, 57) = 2;
winsArray(2, 58) = 0;
winsArray(2, 59) = 1;
winsArray(2, 60) = 1;
winsArray(2, 61) = 0;
winsArray(2, 62) = 0;
winsArray(2, 63) = -1;
winsArray(2, 64) = -2;
winsArray(2, 65) = -3;
winsArray(2, 66) = -3;
winsArray(2, 67) = -4;
winsArray(2, 68) = -3;
winsArray(2, 69) = -3;
winsArray(2, 70) = 0;
winsArray(2, 71) = 0;
winsArray(2, 72) = 1;
winsArray(2, 73) = 0;
winsArray(2, 74) = 2;
winsArray(2, 75) = 2;
winsArray(2, 76) = 4;
winsArray(2, 77) = 3;
winsArray(2, 78) = 4;
winsArray(2, 79) = 2;
winsArray(2, 80) = 2;
winsArray(2, 81) = 0;
winsArray(2, 82) = 0;
winsArray(2, 83) = -3;
winsArray(2, 84) = -4;
winsArray(2, 85) = -4;
winsArray(2, 86) = -3;
winsArray(2, 87) = -3;
winsArray(2, 88) = -3;
winsArray(2, 89) = -1;
winsArray(2, 90) = 2;
winsArray(2, 91) = 4;
winsArray(2, 92) = 5;
winsArray(2, 93) = 4;
winsArray(2, 94) = 3;
winsArray(2, 95) = 2;
winsArray(2, 96) = 0;
winsArray(2, 97) = -1;
winsArray(2, 98) = -1;
winsArray(2, 99) = -1;
winsArray(2, 100) = 1;
winsArray(2, 101) = 3;
winsArray(2, 102) = 3;
winsArray(2, 103) = 4;
winsArray(2, 104) = 3;
winsArray(2, 105) = 1;
winsArray(2, 106) = 0;
winsArray(2, 107) = -2;
winsArray(2, 108) = 0;
winsArray(2, 109) = 0;
winsArray(2, 110) = 0;
winsArray(2, 111) = 0;
winsArray(2, 112) = -1;
winsArray(2, 113) = -1;
winsArray(2, 114) = -2;
winsArray(2, 115) = 0;
winsArray(2, 116) = 2;
winsArray(2, 117) = 2;
winsArray(2, 118) = 3;
winsArray(2, 119) = 3;
winsArray(2, 120) = 2;
winsArray(2, 121) = 4;
winsArray(2, 122) = 2;
winsArray(2, 123) = 2;
winsArray(2, 124) = 1;
winsArray(2, 125) = 2;
winsArray(2, 126) = 4;
winsArray(2, 127) = 3;
winsArray(2, 128) = 2;
winsArray(2, 129) = 0;
winsArray(2, 130) = -1;
winsArray(2, 131) = 0;
winsArray(2, 132) = 0;
winsArray(2, 133) = 0;
winsArray(2, 134) = 0;
winsArray(2, 135) = 3;
winsArray(2, 136) = 2;
winsArray(2, 137) = 4;
winsArray(2, 138) = 5;
winsArray(2, 139) = 4;
winsArray(2, 140) = 3;
winsArray(2, 141) = 3;
winsArray(2, 142) = 4;
winsArray(2, 143) = 3;
winsArray(2, 144) = 2;
winsArray(2, 145) = 2;
winsArray(2, 146) = 0;
winsArray(2, 147) = 3;
winsArray(2, 148) = 3;
winsArray(2, 149) = 3;
winsArray(3, 1) = -2;
winsArray(3, 2) = -3;
winsArray(3, 3) = -2;
winsArray(3, 4) = -1;
winsArray(3, 5) = -3;
winsArray(3, 6) = -2;
winsArray(3, 7) = -3;
winsArray(3, 8) = -3;
winsArray(3, 9) = -4;
winsArray(3, 10) = -3;
winsArray(3, 11) = -3;
winsArray(3, 12) = -2;
winsArray(3, 13) = 0;
winsArray(3, 14) = 1;
winsArray(3, 15) = 2;
winsArray(3, 16) = 2;
winsArray(3, 17) = 3;
winsArray(3, 18) = 4;
winsArray(3, 19) = 4;
winsArray(3, 20) = 2;
winsArray(3, 21) = 2;
winsArray(3, 22) = 0;
winsArray(3, 23) = -1;
winsArray(3, 24) = -1;
winsArray(3, 25) = -1;
winsArray(3, 26) = 0;
winsArray(3, 27) = 0;
winsArray(3, 28) = 1;
winsArray(3, 29) = 1;
winsArray(3, 30) = 1;
winsArray(3, 31) = 2;
winsArray(3, 32) = 2;
winsArray(3, 33) = 4;
winsArray(3, 34) = 2;
winsArray(3, 35) = 1;
winsArray(3, 36) = -1;
winsArray(3, 37) = -1;
winsArray(3, 38) = -2;
winsArray(3, 39) = -3;
winsArray(3, 40) = -1;
winsArray(3, 41) = -1;
winsArray(3, 42) = 0;
winsArray(3, 43) = -2;
winsArray(3, 44) = -3;
winsArray(3, 45) = -2;
winsArray(3, 46) = -1;
winsArray(3, 47) = -1;
winsArray(3, 48) = 1;
winsArray(3, 49) = 1;
winsArray(3, 50) = 2;
winsArray(3, 51) = 3;
winsArray(3, 52) = 2;
winsArray(3, 53) = 2;
winsArray(3, 54) = 0;
winsArray(3, 55) = 0;
winsArray(3, 56) = -1;
winsArray(3, 57) = -1;
winsArray(3, 58) = 0;
winsArray(3, 59) = 0;
winsArray(3, 60) = -1;
winsArray(3, 61) = 0;
winsArray(3, 62) = 0;
winsArray(3, 63) = 1;
winsArray(3, 64) = 2;
winsArray(3, 65) = 3;
winsArray(3, 66) = 4;
winsArray(3, 67) = 3;
winsArray(3, 68) = 4;
winsArray(3, 69) = 3;
winsArray(3, 70) = 1;
winsArray(3, 71) = 1;
winsArray(3, 72) = 0;
winsArray(3, 73) = -2;
winsArray(3, 74) = -3;
winsArray(3, 75) = -2;
winsArray(3, 76) = -1;
winsArray(3, 77) = -1;
winsArray(3, 78) = -2;
winsArray(3, 79) = 0;
winsArray(3, 80) = 0;
winsArray(3, 81) = 2;
winsArray(3, 82) = 2;
winsArray(3, 83) = 4;
winsArray(3, 84) = 3;
winsArray(3, 85) = 3;
winsArray(3, 86) = 5;
winsArray(3, 87) = 4;
winsArray(3, 88) = 4;
winsArray(3, 89) = 2;
winsArray(3, 90) = 2;
winsArray(3, 91) = 0;
winsArray(3, 92) = -2;
winsArray(3, 93) = -2;
winsArray(3, 94) = -2;
winsArray(3, 95) = -2;
winsArray(3, 96) = 0;
winsArray(3, 97) = 0;
winsArray(3, 98) = 0;
winsArray(3, 99) = -1;
winsArray(3, 100) = -2;
winsArray(3, 101) = -3;
winsArray(3, 102) = -3;
winsArray(3, 103) = -2;
winsArray(3, 104) = -1;
winsArray(3, 105) = 1;
winsArray(3, 106) = 2;
winsArray(3, 107) = 1;
winsArray(3, 108) = 1;
winsArray(3, 109) = 2;
winsArray(3, 110) = 3;
winsArray(3, 111) = 5;
winsArray(3, 112) = 4;
winsArray(3, 113) = 3;
winsArray(3, 114) = 3;
winsArray(3, 115) = 2;
winsArray(3, 116) = 0;
winsArray(3, 117) = 0;
winsArray(3, 118) = -1;
winsArray(3, 119) = 0;
winsArray(3, 120) = 1;
winsArray(3, 121) = 0;
winsArray(3, 122) = 0;
winsArray(3, 123) = 0;
winsArray(3, 124) = 0;
winsArray(3, 125) = 1;
winsArray(3, 126) = -1;
winsArray(3, 127) = -1;
winsArray(3, 128) = 1;
winsArray(3, 129) = 2;
winsArray(3, 130) = 3;
winsArray(3, 131) = 2;
winsArray(3, 132) = 3;
winsArray(3, 133) = 1;
winsArray(3, 134) = 1;
winsArray(3, 135) = -1;
winsArray(3, 136) = -2;
winsArray(3, 137) = -3;
winsArray(3, 138) = -4;
winsArray(3, 139) = -3;
winsArray(3, 140) = -2;
winsArray(3, 141) = -2;
winsArray(3, 142) = -3;
winsArray(3, 143) = -2;
winsArray(3, 144) = -1;
winsArray(3, 145) = -1;
winsArray(3, 146) = 0;
winsArray(3, 147) = 3;
winsArray(3, 148) = 3;
winsArray(3, 149) = 3;
winsArray(4, 1) = -2;
winsArray(4, 2) = 0;
winsArray(4, 3) = 0;
winsArray(4, 4) = 1;
winsArray(4, 5) = 1;
winsArray(4, 6) = 0;
winsArray(4, 7) = 0;
winsArray(4, 8) = -1;
winsArray(4, 9) = -2;
winsArray(4, 10) = -3;
winsArray(4, 11) = -3;
winsArray(4, 12) = -4;
winsArray(4, 13) = -4;
winsArray(4, 14) = -3;
winsArray(4, 15) = -3;
winsArray(4, 16) = -1;
winsArray(4, 17) = 0;
winsArray(4, 18) = 0;
winsArray(4, 19) = 1;
winsArray(4, 20) = 1;
winsArray(4, 21) = 2;
winsArray(4, 22) = 2;
winsArray(4, 23) = 3;
winsArray(4, 24) = 4;
winsArray(4, 25) = 4;
winsArray(4, 26) = 5;
winsArray(4, 27) = 4;
winsArray(4, 28) = 3;
winsArray(4, 29) = 2;
winsArray(4, 30) = 4;
winsArray(4, 31) = 4;
winsArray(4, 32) = 4;
winsArray(4, 33) = 3;
winsArray(4, 34) = 2;
winsArray(4, 35) = 0;
winsArray(4, 36) = -1;
winsArray(4, 37) = -2;
winsArray(4, 38) = -1;
winsArray(4, 39) = -1;
winsArray(4, 40) = -3;
winsArray(4, 41) = -5;
winsArray(4, 42) = -5;
winsArray(4, 43) = -3;
winsArray(4, 44) = -1;
winsArray(4, 45) = -1;
winsArray(4, 46) = 0;
winsArray(4, 47) = -1;
winsArray(4, 48) = 1;
winsArray(4, 49) = 1;
winsArray(4, 50) = 1;
winsArray(4, 51) = 3;
winsArray(4, 52) = 2;
winsArray(4, 53) = 2;
winsArray(4, 54) = 0;
winsArray(4, 55) = 0;
winsArray(4, 56) = -1;
winsArray(4, 57) = -1;
winsArray(4, 58) = -2;
winsArray(4, 59) = -2;
winsArray(4, 60) = -1;
winsArray(4, 61) = 0;
winsArray(4, 62) = 0;
winsArray(4, 63) = 3;
winsArray(4, 64) = 3;
winsArray(4, 65) = 0;
winsArray(4, 66) = -1;
winsArray(4, 67) = -1;
winsArray(4, 68) = 0;
winsArray(4, 69) = 0;
winsArray(4, 70) = -1;
winsArray(4, 71) = -2;
winsArray(4, 72) = -2;
winsArray(4, 73) = -4;
winsArray(4, 74) = -4;
winsArray(4, 75) = -2;
winsArray(4, 76) = 0;
winsArray(4, 77) = -2;
winsArray(4, 78) = -1;
winsArray(4, 79) = -1;
winsArray(4, 80) = -2;
winsArray(4, 81) = -3;
winsArray(4, 82) = -2;
winsArray(4, 83) = -4;
winsArray(4, 84) = -5;
winsArray(4, 85) = -5;
winsArray(4, 86) = -4;
winsArray(4, 87) = -3;
winsArray(4, 88) = -4;
winsArray(4, 89) = -4;
winsArray(4, 90) = -4;
winsArray(4, 91) = -3;
winsArray(4, 92) = -3;
winsArray(4, 93) = -3;
winsArray(4, 94) = -3;
winsArray(4, 95) = -3;
winsArray(4, 96) = -3;
winsArray(4, 97) = -1;
winsArray(4, 98) = 0;
winsArray(4, 99) = -2;
winsArray(4, 100) = -3;
winsArray(4, 101) = -4;
winsArray(4, 102) = -3;
winsArray(4, 103) = -2;
winsArray(4, 104) = -1;
winsArray(4, 105) = 1;
winsArray(4, 106) = 2;
winsArray(4, 107) = 4;
winsArray(4, 108) = 4;
winsArray(4, 109) = 3;
winsArray(4, 110) = 2;
winsArray(4, 111) = 1;
winsArray(4, 112) = 2;
winsArray(4, 113) = 1;
winsArray(4, 114) = 1;
winsArray(4, 115) = 1;
winsArray(4, 116) = 0;
winsArray(4, 117) = 0;
winsArray(4, 118) = 2;
winsArray(4, 119) = 3;
winsArray(4, 120) = 3;
winsArray(4, 121) = 4;
winsArray(4, 122) = 3;
winsArray(4, 123) = 2;
winsArray(4, 124) = 1;
winsArray(4, 125) = 1;
winsArray(4, 126) = 3;
winsArray(4, 127) = 3;
winsArray(4, 128) = 3;
winsArray(4, 129) = 4;
winsArray(4, 130) = 3;
winsArray(4, 131) = 2;
winsArray(4, 132) = 3;
winsArray(4, 133) = 1;
winsArray(4, 134) = 1;
winsArray(4, 135) = -1;
winsArray(4, 136) = -1;
winsArray(4, 137) = -2;
winsArray(4, 138) = 0;
winsArray(4, 139) = 2;
winsArray(4, 140) = 3;
winsArray(4, 141) = 3;
winsArray(4, 142) = 4;
winsArray(4, 143) = 3;
winsArray(4, 144) = 2;
winsArray(4, 145) = 2;
winsArray(4, 146) = 0;
winsArray(4, 147) = -1;
winsArray(4, 148) = -1;
winsArray(4, 149) = -1;

% RISK MATRIX
% Give each state a % chance of 'flipping' its reward (i.e. multiplying it
%   by -1)
%risk = zeros(numStates, numBoards);
%for i = 1:numBoards
    % only give this to level 3, and only give it to rewards
%    risk(boards(22:85,i) > 0, i) = randsample(50, sum(boards(22:85,i) > 0), true);
%end

[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
save(strcat(currentPath, '/Board13.mat'), 'boards', 'transitions', 'numStates', 'numMoves', 'numActions', 'numBoards', 'numSwitches', 'rewardRange', 'winsArray');