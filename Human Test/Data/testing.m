function [likelihood] = testing(A1, S2, A2, Re, normed)

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
numStates = 8;
numActions = 2;

numInstances = 1;

% Data variables:
% id, A1, S2, A2, Re

%% AGENT PARAMETERS

% Set gammas, alphas, betas, temps

elig = 0;
alphaR = .25;
alphaP = .25;
betaR = .25;
betaP = .25;
temp = 1;
gammaR = .85;
gammaP = .85;

% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
if normed == 1
    policy0 = .01.*zeros(numStates,numActions);
else
    policy0 = zeros(numStates,numActions);
end
values0 = zeros(numStates, 1);
Q0 = zeros(numStates,numActions);

%% PLAY THE BOARD

% Calculate likelihoods
likelihood_AC = zeros(numInstances, 1);
likelihood_SARSA = zeros(numInstances,1);

% Start off first player
thisBoard = 1;

rewardSum = 0;

policy = policy0;
values = values0;
Q = Q0;

% Loop through each of the rounds
for thisRound = 1:length(A1)
    
    % We're starting off a new play, so...
    state1 = 1;
    
    % FIRST MOVE
    probs_AC = softmax_TDRL(temp,policy(state1,:),0);
    probs_SARSA = softmax_TDRL(temp,Q(state1,:),0);
    
    %action = randsample(numActions, 1, true, probs);
    
    action = A1(thisRound) + 1; % the +1 is because Fiery's dataset uses actions 0 and 1
    
    likelihood_AC(thisBoard) = likelihood_AC(thisBoard) + log(probs_AC(action));
    likelihood_SARSA(thisBoard) = likelihood_SARSA(thisBoard) + log(probs_SARSA(action));
    
    % Move
    %newstate = transitions(state,action,thisBoard);
    %reward = boards(newstate,thisBoard,currentSwitch);
    
    state2 = S2(thisRound) + 2; %+2 because we really want states 2 or 3 here (and Fiery uses 0 or 1)
    reward = 0;
    
    rewardSum = rewardSum + reward;
    
    % Update actor & critic
    if reward >= 0
        delta = reward + gammaR .* values(state2) - values(state1);
        policy(state1,action) = policy(state1,action) + betaR * delta;
        values(state1) = values(state1) + alphaR * delta;
    else
        delta = reward + gammaP .* values(state2) - values(state1);
        policy(state1,action) = policy(state1,action) + betaP * delta;
        values(state1) = values(state1) + alphaP * delta;
    end
   
    if normed == 1
        policy(state1,:) = policy(state1,:) ./ sum(abs(policy(state1,:)));
    end
    
    % Update state
    %state = state2;
    
    
    % SECOND MOVE
    probs_AC = softmax_TDRL(temp,policy(state2,:),0);
    probs_SARSA = softmax_TDRL(temp,Q(state2,:),0);
    
    %action = randsample(numActions, 1, true, probs);
    
    action = A2(thisRound);
    
    % We already have the previous state info - don't need to retain it in
    %   action #
    if action == 3
        action = 1;
    elseif action == 4
        action = 2;
    end
    
    likelihood_AC(thisBoard) = likelihood_AC(thisBoard) + log(probs_AC(action));
    likelihood_SARSA(thisBoard) = likelihood_SARSA(thisBoard) + log(probs_SARSA(action));
    
    % Move
    %newstate = transitions(state,action,thisBoard);
    %reward = boards(newstate,thisBoard,currentSwitch);
    
    state2 = 8;
    reward = Re(thisRound);
    
    rewardSum = rewardSum + reward;
    
    % Update actor & critic
    if reward >= 0
        delta = reward + gammaR .* values(state2) - values(state);
        policy(state,action) = policy(state,action) + betaR * delta;
        values(state) = values(state) + alphaR * delta;
        values(1) = values(1) + elig * alphaR * delta;
    else
        delta = reward + gammaP .* values(state2) - values(state);
        policy(state,action) = policy(state,action) + betaP * delta;
        values(state) = values(state) + alphaP * delta;
        values(1) = values(1) + elig * alphaP * delta;
    end
    
    if normed == 1
        policy(state,:) = policy(state,:) ./ sum(abs(policy(state,:)));
    end
    
    % Update SARSA
    if reward >= 0
        % 1st level
        delta = gamma*Q(state2,action2) - Q(1,action1);
        Q(1,action1) = Q(1,action1) + alphaR * delta;

        % 2nd level
        delta = reward - Q(state2,action2);
        Q(state2,action2) = Q(state2,action2) + alphaR * delta;
        Q(1,action1) = Q(1,action1) + eligR * alphaR * delta;
    else
        % 1st level
        delta = gamma*Q(state2,action2) - Q(1,action1);
        Q(1,action1) = Q(1,action1) + alphaP * delta;

        % 2nd level
        delta = reward - Q(state2,action2);
        Q(state2,action2) = Q(state2,action2) + alphaP * delta;
        Q(1,action1) = Q(1,action1) + eligP * alphaP * delta;
    end
end

likelihood = -likelihood; % for patternsearch (or fmincon)
end