% This finds the likelihood of the given set of actions on a two-step task,
%   given the inputted parameters.
% Uses an undifferentiated a/c model

% Currently, alpha & beta are done per-subject, temperature is done
%   globally

function [likelihood] = getLikelihood_undiff(x, A1, S2, A2, Re, separateTemp)

% ENVIRONMENT PARAMETERS

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

% AGENT PARAMETERS

% Set gammas, alphas, betas, temps

% Temporal discount rates have been chosen based on my review of the literature, which seems
%   to indicate people choose the gammas to be somewhere between .75 and .99
gamma = .85;

alpha = x(1);

if separateTemp == 0
    beta = x(2);
    temp = x(3);
elseif separateTemp == 1
    beta = sqrt(x(2));
    temp = sqrt(x(2));
end

% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
policy0 = zeros(numStates,numActions);
values0 = zeros(numStates, 1);

% Set up earnings matrix.
earnings = zeros(numPlays,numInstances);


% PLAY THE BOARD

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
    probs_numerator = exp(temp .* policy(state,:));
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
    
    % Update actor
    policy(state,action) = policy(state,action) + beta.*((reward + gamma.*values(newstate)) - values(state));
    
    % Update critic
    values(state) = values(state) + alpha.*((reward + gamma.*values(newstate)) - values(state));
    
    % Update state
    state = newstate;
    
    
    % SECOND MOVE
    probs_numerator = exp(temp .* policy(state,:) + temp .* policy(state,:));
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
    
    % Update actor
    policy(state,action) = policy(state,action) + beta.*((reward + gamma.*values(newstate)) - values(state));
    
    % Update critic
    values(state) = values(state) + alpha.*((reward + gamma.*values(newstate)) - values(state));
    
end

likelihood = -likelihood; % for patternsearch (or fmincon)
end