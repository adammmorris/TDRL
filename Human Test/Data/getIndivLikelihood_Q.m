%% getIndivLikelihood_Q
% This is a Q-learning model

%% Params
% x should be [alpha temp]

function [likelihood, numSlips] = getIndivLikelihood_Q(x, A1, S2, A2, Re)

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

alpha = x(1);
temp = x(2);
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

numSlips = 0; % records the # of times the person does the same thing again after being punished last round

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
    
    action = A1(thisRound) + 1; % the +1 is because Fiery's dataset uses actions 0 and 1
    
    likelihood(thisBoard) = likelihood(thisBoard) + log(probs(action));
    
    % Move
    %newstate = transitions(state,action,thisBoard);
    %reward = boards(newstate,thisBoard,currentSwitch);
    
    newstate = S2(thisRound) + 2; %+2 because we really want states 2 or 3 here (and Fiery uses 0 or 1)
    reward = 0;
    
    rewardSum = rewardSum + reward;
    
    % Update Q-learner
    delta = reward + gamma .* max(Q(newstate,:)) - Q(state,action);
    Q(state,action) = Q(state,action) + alpha * delta;
   
    % Update state
    state = newstate;
    
    
    % SECOND MOVE
    probs_numerator = exp(temp .* Q(state,:));
    probs_denominator = sum(probs_numerator);
    
    % Clean out infinities (change them to realmax's).
    probs_numerator(isinf(probs_numerator)) = realmax .* ones(sum(isinf(probs_numerator)), 1);
    probs_denominator(isinf(probs_denominator)) = realmax .* ones(sum(isinf(probs_denominator)), 1);
    
    probs = probs_numerator ./ probs_denominator;
    
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
    
    % Update Q-learner
    delta = reward + gamma .* max(Q(newstate,:)) - Q(state,action);
    Q(state,action) = Q(state,action) + alpha * delta;
    
    % Check if this round was a slip
    % If the last round was a punishment..
    if thisRound ~= 1
        if Re(thisRound - 1) < 0
            % If we did the same thing this round as before..
            if (A1(thisRound - 1) == A1(thisRound)) && (A2(thisRound - 1) == A2(thisRound))
                numSlips = numSlips + 1;
            end
        end
    end
end

likelihood = -likelihood; % for patternsearch (or fmincon)
end