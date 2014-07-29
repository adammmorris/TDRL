%% getIndivLikelihood_Sarsa_Undiff
% This is a normal SARSA model w/ eligibility traces

%% Params
% x should be [alpha1 alpha2 elig temp]

function [likelihood] = getIndivLikelihood_Sarsa_Undiff(x, A1, S2, A2, Re)

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
numMoves = 2;
numActions = 2;

numInstances = 1;
numPlays = length(A1);

% Data variables:
% id, A1, S2, A2, Re

%% AGENT PARAMETERS

% Set gammas, alphas, temps

alpha1 = x(1);
alpha2 = x(2);
elig = x(3);
temp = x(4);
gamma = .85;

% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
Q0 = zeros(numStates,numActions);

%% PLAY THE BOARD

% Calculate likelihoods
likelihood = zeros(numInstances, 1);

% Start off first player
thisBoard = 1;

rewardSum = 0;

Q = Q0;

% Loop through each of the rounds
for thisRound = 1:length(A1)
    
    % We're starting off a new play, so...
    state = 1;
    
    % FIRST MOVE
    probs_numerator = exp(temp .* Q(state,:));
    probs_denominator = sum(probs_numerator);
    
    % Clean out infinities (change them to realmax's).
    probs_numerator(isinf(probs_numerator)) = realmax .* ones(sum(isinf(probs_numerator)), 1);
    probs_denominator(isinf(probs_denominator)) = realmax .* ones(sum(isinf(probs_denominator)), 1);
    
    probs = probs_numerator ./ probs_denominator;
    
    %action = randsample(numActions, 1, true, probs);
    
    action1 = A1(thisRound) + 1; % the +1 is because Fiery's dataset uses actions 0 and 1
    
    likelihood(thisBoard) = likelihood(thisBoard) + log(probs(action1));
    
    % Move
    %newstate = transitions(state,action,thisBoard);
    %reward = boards(newstate,thisBoard,currentSwitch);
    
    state2 = S2(thisRound) + 2; %+2 because we really want states 2 or 3 here (and Fiery uses 0 or 1)
    reward = 0;
    
    rewardSum = rewardSum + reward;
    
    % SECOND MOVE
    probs_numerator = exp(temp .* Q(state2,:));
    probs_denominator = sum(probs_numerator);
    
    % Clean out infinities (change them to realmax's).
    probs_numerator(isinf(probs_numerator)) = realmax .* ones(sum(isinf(probs_numerator)), 1);
    probs_denominator(isinf(probs_denominator)) = realmax .* ones(sum(isinf(probs_denominator)), 1);
    
    probs = probs_numerator ./ probs_denominator;
    
    %action = randsample(numActions, 1, true, probs);
    
    action2 = A2(thisRound);
    
    % We already have the previous state info - don't need to retain it in
    %   action #
    if action2 == 3
        action2 = 1;
    elseif action2 == 4
        action2 = 2;
    end
    
    likelihood(thisBoard) = likelihood(thisBoard) + log(probs(action2));
    
    % Move
    %newstate = transitions(state,action,thisBoard);
    %reward = boards(newstate,thisBoard,currentSwitch);
    
    reward = Re(thisRound);
    
    rewardSum = rewardSum + reward;
    
    % Update SARSA
    % 1st level
    delta = gamma*Q(state2,action2) - Q(1,action1);
    Q(1,action1) = Q(1,action1) + alpha1 * delta;
    
    % 2nd level
    delta = reward - Q(state2,action2);
    Q(state2,action2) = Q(state2,action2) + alpha2 * delta;
    Q(1,action1) = Q(1,action1) + elig * alpha1 * delta;
end

likelihood = -likelihood; % for patternsearch (or fmincon)
end