%% getIndivLike_AC_comb
% This is our combined actor-critic model
% Can modulate which parameters are differentiated with 'type'

%% Params
% x should be [lr temp stay w elig]
% normed:
%   - set to 1 if you want to norm policy before sending to softmax
%   function ('_normedEZ')
%   - set to 2 if you want to norm policy for real ('_normed')

%% Versions
% v2: getting rid of slips
% v3: changing normalization to real instead of just for softmax
% v4: adding optional eligibility traces, making two normalization options
% v5: oh god, fixed an ugly bug

function [likelihood] = getIndivLike_AC_comb_3levels_withW(type, x, A1, S2, A2, S3, A3, Re, round, normed)

%% ENVIRONMENT PARAMETERS

% Board properties.
% Board variables we get from the boards file:
%   boards - boards(state_i, board_k) = the reward from state_i in board_k
%   transitions - transitions(state_i, action_j, board_k) is the state arrived at after
%       taking action_j at state_i in board_k.
%   numStates (# of states)
%   numMoves (# of moves each agent makes)
%   numActions (# of choices at each agent decision point)
%   numBoards (number of agent-board systems to be instantiated and played
%       through separately)

%[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
%load(strcat(currentPath, '/Boards/', boardPath, '.mat'));

% Info about his board
numStates = 16;
numActions = 2;
practiceCutoff = 25;

% Data variables:
% id, A1, S2, A2, Re

%% AGENT PARAMETERS

% Set gammas, alphas, betas, temps

lr = x(1);
temp = x(2);
stay = x(3);
w = x(4);
elig = x(5);
%elig = .85;
gamma = 1;

%% PLAY THE BOARD

% Calculate likelihoods
likelihood = 0;

Q = zeros(numStates,numActions);
Qmb = zeros(numStates,numActions);
Tcounts_lev1 = ones(2,2); % actions to states
Tcounts_lev2 = ones(4,4); % actions to states
T_lev1 = [.5 .5; .5 .5];
T_lev2 = repmat(1/4*ones(1,4),4,1);

prevA1 = 0;
prevA2 = 0;

% Loop through each of the rounds
for thisRound = 1:length(A1)
    action1 = A1(thisRound); % this should be 1 or 2, but sometimes we have to add +1 b/c flash uses 0 or 1
    state2 = S2(thisRound); % this should be 2 or 3
    action2 = A2(thisRound); % should be 1 or 2
    state3 = S3(thisRound); % this should be 4-7
    action3 = A3(thisRound); % should be 1 or 2
    reward = Re(thisRound);
    
    % Only do rounds that aren't practice rounds
    if round(thisRound) > practiceCutoff
        % MODEL-BASED
        
        Qmb(1,:) = T_lev1*max(Qmb(2:3,:),[],2);
        Qmb(2,:) = T_lev2(1:2,:)*max(Qmb(4:7,:),[],2);
        Qmb(3,:) = T_lev2(3:4,:)*max(Qmb(4:7,:),[],2);
        
        % FIRST MOVE
        Qd = w*Qmb(1,:)'+(1-w)*Q(1,:)';
        if prevA1, Qd(prevA1) = Qd(prevA1)+stay; end
        likelihood = likelihood + temp*Qd(action1)-log(sum(exp(temp*Qd)));
        
        % SECOND MOVE
        Qd = w*Qmb(state2,:)'+(1-w)*Q(state2,:)';
        if prevA2, Qd(prevA2) = Qd(prevA2)+stay; end
        likelihood = likelihood + temp*Qd(action2)-log(sum(exp(temp*Qd)));
        
        % First move - no reward
        delta = gamma .* Q(state2,action2) - Q(1,action1);
        Q(1,action1) = Q(1,action1) + lr * delta;
        
        % Second move - no reward
        delta = gamma .* Q(state3,action3) - Q(state2,action2);
        Q(state2,action2) = Q(state2,action2) + lr*delta;
        Q(1,action1) = Q(1,action1) + elig*lr*delta;
        
        % Third move
        delta = reward - Q(state3,action3);
        Q(state3,action3) = Q(state3,action3) + lr * delta;
        Q(state2,action2) = Q(state2,action2) + elig*lr*delta;
        Q(1,action1) = Q(1,action1) + (elig^2)*lr*delta;
        
        Qmb(4:7,:) = Q(4:7,:);
        
        prevA1 = action1;
        prevA2 = action2;
    end
    
    % Do transition counts & probs
    Tcounts_lev1(action1,state2-1) = Tcounts_lev1(action1,state2-1)+1;
    Tcounts_lev2(action2+2*(state2==3),state3-3) = Tcounts_lev2(action2+2*(state2==3),state3-3)+1;
    T_lev1 = Tcounts_lev1./repmat(sum(Tcounts_lev1,2),1,2);
    T_lev2 = Tcounts_lev2./repmat(sum(Tcounts_lev2,2),1,4);
end

likelihood = -likelihood; % for patternsearch (or fmincon)
end