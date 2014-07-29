%% ac_sep_twosteptask
% This is the separated actor/critic model for a two-step task

%% Params
% x should be [alphaR alphaP betaR betaP temp gammaR gammaP]

function [totEarnings, stdEarnings, learnCurve, likelihood, numSlips, numPunishments] = ac_sep_twosteptask(x, numInstances, numPlays, boardPath)

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

% Implement random drifting
directions = ones(numStates, 1); % +1 or -1 for up or down
increment = 1; % how much to increment by
weights = [.25 .25 .5]; % probs of (-increment, 0, increment)

% Initialize random directions for drifting
for i=1:numStates
    if rand() < .5
        directions(i) = directions(i) * -1;
    end
end

% Not doing switches
currentSwitch = 1;

stochasticTransitions = 0;
staticRewards = 0;

%% AGENT PARAMETERS

% Set gammas, alphas, betas, temps

alphaR = x(1);
alphaP = x(2);

betaR = x(3);
betaP = x(4);

temp = x(5);

gammaR = x(6);
gammaP = x(7);

% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
policy0 = zeros(numStates,numActions);
values0 = zeros(numStates, 1);

% Set up earnings matrix.
earnings = zeros(numPlays,numInstances);

% Calculate likelihoods
likelihood = zeros(numInstances, 1);
likelihood_alt = zeros(numInstances, 1);

numSlips = zeros(numInstances,1); % records the # of times the person does the same thing again after being punished last round
numPunishments = zeros(numInstances,1); % records the # of times a person got a punishment
lastPunished = zeros(numStates,numActions); % 1 if the last time you took action A in state S, you were punished

%% Loop through each to-be-instantiated agent-board system.
for thisBoard = 1:numInstances
    
    % Initialize this agent's policy matrix(actor)
    policyR = policy0;
    policyP = policy0;
    
    % Initialize this agent's value matrix (critic)
    valuesR = values0;
    valuesP = values0;
   
    % For this agent-board system, loop through each of the agent's plays.
    for thisPlay = 1:numPlays
        
        %state = starts(thisBoard);
        state = 1;
        
        rewardSum = 0;
        
        % Move through the board.
        for thisMove = 1:numMoves
    
            % Select action w/ softmax
            % Make decisions based on normal values - just record alt ones
            probs_numerator = exp(temp .* policyR(state,:) + temp .* policyP(state,:));
            probs_denominator = sum(probs_numerator);
            
            % Clean out infinities (change them to realmax's).
            probs_numerator(isinf(probs_numerator)) = realmax .* ones(sum(isinf(probs_numerator)), 1);
            probs_denominator(isinf(probs_denominator)) = realmax .* ones(sum(isinf(probs_denominator)), 1);
            
            probs = probs_numerator ./ probs_denominator;
            
            action = randsample(numActions, 1, true, probs);
            
            likelihood(thisBoard) = likelihood(thisBoard) + log(probs(action));
            
            % Move
            
            % Implement the transition probabilities for Fiery's 2-step
            %   task
            % If we're doing stochastic transitions & they're making the first choice..
            if stochasticTransitions == 1 && state == 1
                % If they chose left..
                if action == 1
                    % 70% of the time, go to state 2
                    if rand() > .3
                        newstate = 2;
                    else
                        newstate = 1;
                    end
                    % If they chose right..
                elseif action == 2
                    % 70% of the time, go to state 3
                    if rand() > .3
                        newstate = 3;
                    else
                        newstate = 2;
                    end
                end
            % Otherwise, just do deterministic transitions
            else
                newstate = transitions(state,action,thisBoard);
            end
            
            % Are we implementing his rewards?
            if staticRewards == 1
                if newstate >= 4
                    reward = winsArray(newstate - 3, thisPlay);
                else
                    reward = 0;
                end
            else
                reward = boards(newstate,thisBoard,currentSwitch);
            end
            
            rewardSum = rewardSum + reward;
            
            % Update actor
            policyR(state,action) = policyR(state,action) + betaR.*(((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state)));
            policyP(state,action) = policyP(state,action) + betaP.*(((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state)));

            % Update critic
            valuesR(state) = valuesR(state) + alphaR.*((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state));
            valuesP(state) = valuesP(state) + alphaP.*((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state));
            
            % Check if this move was a slip
            if lastPunished(state,action) == 1
                numSlips(thisBoard) = numSlips(thisBoard) + 1;
            end
            
            % Were we punished for doing this?
            if reward < 0
                lastPunished(state,action) = 1;
                numPunishments(thisBoard) = numPunishments(thisBoard) + 1;
            else
                lastPunished(state,action) = 0;
            end
            
            % Update state
            state = newstate;
            
        end
       
        % Drift
        % Loop through each rewardable state
        for curState = 4:7
            % Are we at an extreme?
            if boards(curState,thisBoard,currentSwitch) == rewardRange
                directions(curState) = -1;
            elseif boards(curState,thisBoard,currentSwitch) == -rewardRange
                directions(curState) = 1;
            end
            
            % Get shift according to weights & then multiply it by
            %   curDirection
            shift = randsample([-increment 0 increment], 1, true, weights) * directions(curState);
            
            % Do it!
            boards(curState,thisBoard,currentSwitch) = boards(curState,thisBoard,currentSwitch) + shift;
        end
        
        % Update earnings.
        earnings(thisPlay,thisBoard) = earnings(thisPlay,thisBoard) + rewardSum;
    end
end

% Return results.
totEarnings = mean(sum(earnings)); % not using patternsearch, so I got rid of -
stdEarnings = std(sum(earnings));
learnCurve = sum(earnings, 2);

end