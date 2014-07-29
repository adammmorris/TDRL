% This finds the likelihood of the given set of actions from a single subject on a two-step task,
%   given the inputted parameters.
% Uses a differentiated a/c model

function [likelihood, numSlips] = getLikelihood_aDiff_bUndiff(x, A1, S2, A2, Re)

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
gammaR = .85;
gammaP = .85;

% Here, betaR and betaP are yoked
alphaR = x(1);
alphaP = x(2);
betaR = x(3);
betaP = x(3);
tempR = x(4);
tempP = x(4);

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

policyR = policy0;
policyP = policy0;
valuesR = values0;
valuesP = values0;

numSlips = 0; % records the # of times the person does the same thing again after being punished last round

% Loop through each of the rounds
for thisRound = 1:length(A1)
    
    % We're starting off a new play, so...
    state = 1;
    
    % FIRST MOVE
    probs_numerator = exp(tempR .* policyR(state,:) + tempP .* policyP(state,:));
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
    policyR(state,action) = policyR(state,action) + betaR.*(((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state)));
    policyP(state,action) = policyP(state,action) + betaP.*(((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state)));
    
    % Update critic
    valuesR(state) = valuesR(state) + alphaR.*((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state));
    valuesP(state) = valuesP(state) + alphaP.*((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state));
            
    % Update state
    state = newstate;
    
    
    % SECOND MOVE
    probs_numerator = exp(tempR .* policyR(state,:) + tempP .* policyP(state,:));
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
    policyR(state,action) = policyR(state,action) + betaR.*(((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state)));
    policyP(state,action) = policyP(state,action) + betaP.*(((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state)));
    
    % Update critic
    valuesR(state) = valuesR(state) + alphaR.*((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state));
    valuesP(state) = valuesP(state) + alphaP.*((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state));
   
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