%% sarsa_sep_2steptask
% This is the separated actor/critic model for a two-step task
% This version uses a 'combined' actor/critic that switches its parameters
%   for rewards and punishments, but keeps one combined matrix of values &
%   policies
% Note that it can be used with other environments too, but some of the
%   features (i.e. stochastic transitions, the 'results' output) won't work

%% Params
% x should be either:
%   [alpha1_R alpha1_P alpha2_R alpha2_P elig temp gamma]
%   or a numInstance x 1, where each row is that vector (for each subject)

%% Output
% earnings is numInstances x 1
% negLLs is numInstances x 1
% results is (numInstances * numPlays) x 5
%   columns are id a1 s2 a2 re

%% Versions
% v3: cleaning up code (i.e. getting rid of drifting rewards in here, cause
%   its now in the board itself)

function [earnings, negLLs, results] = sarsa_sep_2steptask(x, numInstances, numPlays, boardPath, stochasticTransitions)

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

[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
load(strcat(currentPath, '/Boards/', boardPath, '.mat'));

%% AGENT PARAMETERS

% Set gammas, alphas, betas, temps

if size(x,1) == numInstances
    alpha1_R = x(:,1);
    alpha1_P = x(:,2);
    alpha2_R = x(:,3);
    alpha2_P = x(:,4);
    elig = x(:,5);
    temp = x(:,6);
    gamma = x(:,7);
elseif size(x,1) == 1
    alpha1_R = repmat(x(1),numInstances);
    alpha1_P = repmat(x(2),numInstances);
    alpha2_R = repmat(x(3),numInstances);
    alpha2_P = repmat(x(4),numInstances);
    elig = repmat(x(5),numInstances);
    temp = repmat(x(6),numInstances);
    gamma = repmat(x(7),numInstances);
else
    error('x must have either numInstances or 1 row');
end

% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
Q0 = zeros(numStates,numActions);

% Set up earnings matrix.
earnings = zeros(numInstances,1);

% Set up results matrix
results = zeros(numInstances*numPlays,5);
roundIndex = 1;

% Calculate likelihoods
likelihood = zeros(numInstances, 1);

%% Loop through each to-be-instantiated agent-board system.
for thisBoard = 1:numInstances
    
    % Initialize this agent's policy matrix(actor)
    Q = Q0;
    
    % For this agent-board system, loop through each of the agent's plays.
    for thisPlay = 1:numPlays
        
        % Initalize results stuff
        %a1 = 0;
        %s2 = 0;
        %a2 = 0;
        %re = 0;
        
        rewardSum = 0;
        
        % We're starting off a new play, so...
        state = 1;
        
        % FIRST MOVE
        probs_numerator = exp(temp(thisBoard) .* Q(state,:));
        probs_denominator = sum(probs_numerator);
        
        % Clean out infinities (change them to realmax's).
        probs_numerator(isinf(probs_numerator)) = realmax .* ones(sum(isinf(probs_numerator)), 1);
        probs_denominator(isinf(probs_denominator)) = realmax .* ones(sum(isinf(probs_denominator)), 1);
        
        probs = probs_numerator ./ probs_denominator;
        
        action1 = randsample(numActions, 1, true, probs);
            
        likelihood(thisBoard) = likelihood(thisBoard) + log(probs(action1));
        
        % Move
        %newstate = transitions(state,action,thisBoard);
        %reward = boards(newstate,thisBoard,currentSwitch);
        
        state2 = transitions(state,action1,thisBoard);
        reward = 0;
        
        rewardSum = rewardSum + reward;
        
        % SECOND MOVE
        probs_numerator = exp(temp(thisBoard) .* Q(state2,:));
        probs_denominator = sum(probs_numerator);
        
        % Clean out infinities (change them to realmax's).
        probs_numerator(isinf(probs_numerator)) = realmax .* ones(sum(isinf(probs_numerator)), 1);
        probs_denominator(isinf(probs_denominator)) = realmax .* ones(sum(isinf(probs_denominator)), 1);
        
        probs = probs_numerator ./ probs_denominator;
        
        action2 = randsample(numActions, 1, true, probs);
        
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
        
        reward = boards(transitions(state2,action2,thisBoard),thisPlay,thisBoard);
        
        rewardSum = rewardSum + reward;
        
        % Update SARSA
        if reward >= 0
            % 1st level
            delta = gamma(thisBoard)*Q(state2,action2) - Q(1,action1);
            Q(1,action1) = Q(1,action1) + alpha1_R(thisBoard) * delta;
            
            % 2nd level
            delta = reward - Q(state2,action2);
            Q(state2,action2) = Q(state2,action2) + alpha2_R(thisBoard) * delta;
            Q(1,action1) = Q(1,action1) + elig(thisBoard) * alpha1_R(thisBoard) * delta;
        else
            % 1st level
            delta = gamma(thisBoard)*Q(state2,action2) - Q(1,action1);
            Q(1,action1) = Q(1,action1) + alpha1_P(thisBoard) * delta;
            
            % 2nd level
            delta = reward - Q(state2,action2);
            Q(state2,action2) = Q(state2,action2) + alpha2_P(thisBoard) * delta;
            Q(1,action1) = Q(1,action1) + elig(thisBoard) * alpha1_P(thisBoard) * delta;
        end
        
        % Get stuff for results matrix
        %if state == 1 % if they were making their first choice
        %    a1 = action - 1; % action they took (subtraction is b/c Fiery uses 0 or 1)
        %    s2 = newstate; % second-level state they got to (in case there were stochastic transitions)
        %elseif any(2:3 == state) % if they were making their second choice
        %    a2 = action;
        %    re = reward;
        %end
        
        % Update results matrix
        %results(roundIndex,:) = [thisBoard a1 s2 a2 re];
        %roundIndex = roundIndex + 1;
        
        % Update earnings.
        earnings(thisBoard) = earnings(thisBoard) + rewardSum;
    end
end

negLLs = -likelihood;

end