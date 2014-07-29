%% getIndivLike_AC_comb
% This is our combined actor-critic model
% Can modulate which parameters are differentiated with 'type'

%% Params
% type: 'ABT', 'ArApBT', 'ABrBpT', 'ArApBrBpT'
% x depends on type
% normed: set to 1 if you want to norm policy before sending to softmax function

%% Versions
% v2: getting rid of slips
% v3: changing normalization to real instead of just for softmax

function [likelihood] = getIndivLike_AC_comb_v3(type, x, A1, S2, A2, Re, normed)

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

if strcmpi(type,'ABT') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    temp = x(3);
    gammaR = .85;
    gammaP = .85;
elseif strcmpi(type,'ArApBT') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(3);
    temp = x(4);
    gammaR = .85;
    gammaP = .85;
elseif strcmpi(type,'ABrBpT') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(3);
    temp = x(4);
    gammaR = .85;
    gammaP = .85;
elseif strcmpi(type,'ArApBrBpT') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(4);
    temp = x(5);
    gammaR = .85;
    gammaP = .85;
end

% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
if normed == 1
    policy0 = .01.*zeros(numStates,numActions);
else
    policy0 = zeros(numStates,numActions);
end
values0 = zeros(numStates, 1);

%% PLAY THE BOARD

% Calculate likelihoods
likelihood = zeros(numInstances, 1);

% Start off first player
thisBoard = 1;

rewardSum = 0;

policy = policy0;
values = values0;

% Loop through each of the rounds
for thisRound = 1:length(A1)
    
    % We're starting off a new play, so...
    state = 1;
    
    % FIRST MOVE
    probs = softmax_TDRL(temp,policy(state,:),0);
    
    %action = randsample(numActions, 1, true, probs);
    
    action = A1(thisRound) + 1; % the +1 is because Fiery's dataset uses actions 0 and 1
    
    likelihood(thisBoard) = likelihood(thisBoard) + log(probs(action));
    
    % Move
    %newstate = transitions(state,action,thisBoard);
    %reward = boards(newstate,thisBoard,currentSwitch);
    
    newstate = S2(thisRound) + 2; %+2 because we really want states 2 or 3 here (and Fiery uses 0 or 1)
    reward = 0;
    
    rewardSum = rewardSum + reward;
    
    % Update actor & critic
    if reward >= 0
        delta = reward + gammaR .* values(newstate) - values(state);
        policy(state,action) = policy(state,action) + betaR * delta;
        values(state) = values(state) + alphaR * delta;
    else
        delta = reward + gammaP .* values(newstate) - values(state);
        policy(state,action) = policy(state,action) + betaP * delta;
        values(state) = values(state) + alphaP * delta;
    end
   
    if normed == 1
        policy(state,:) = policy(state,:) ./ sum(abs(policy(state,:)));
    end
    
    % Update state
    state = newstate;
    
    
    % SECOND MOVE
    probs = softmax_TDRL(temp,policy(state,:),0);
    
    %action = randsample(numActions, 1, true, probs);
    
    action = A2(thisRound);
    
    % We already have the previous state info - don't need to retain it in
    %   action #
    if action == 3
        action = 1;
    elseif action == 4
        action = 2;
    end
    
    likelihood(thisBoard) = likelihood(thisBoard) + log(probs(action));
    
    % Move
    %newstate = transitions(state,action,thisBoard);
    %reward = boards(newstate,thisBoard,currentSwitch);
    
    newstate = 8;
    reward = Re(thisRound);
    
    rewardSum = rewardSum + reward;
    
    % Update actor & critic
    if reward >= 0
        delta = reward + gammaR .* values(newstate) - values(state);
        policy(state,action) = policy(state,action) + betaR * delta;
        values(state) = values(state) + alphaR * delta;
    else
        delta = reward + gammaP .* values(newstate) - values(state);
        policy(state,action) = policy(state,action) + betaP * delta;
        values(state) = values(state) + alphaP * delta;
    end
    
    if normed == 1
        policy(state,:) = policy(state,:) ./ sum(abs(policy(state,:)));
    end
end

likelihood = -likelihood; % for patternsearch (or fmincon)
end