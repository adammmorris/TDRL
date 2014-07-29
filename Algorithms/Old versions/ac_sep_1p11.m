% Fiery's Separated Actor-Critic Learning Algorithm
% Inputs:
%   x = [alphaR, alphaP, betaR, betaP, tempR, tempP]
%   numInstances (optional) = the number of times to run the algorithm (i.e. the
%       number of board-agent instances to run through)
%       default: numBoards

function [totEarnings, stdEarnings, learnCurve, likelihood, likelihood_alt, slips] = ac_sep_1p11(x, numInstances, numPlays, boardPath, x_alt)

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

[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
load(strcat(currentPath, '/Boards/', boardPath, '.mat'));

% Are we testing alt?
testingAlt = 0;
if nargin == 5
    testingAlt = 1;
end

% Add stochasticism (2 types)
% For how this works, see txt file

% Long-term
% Every numPlaysBeforeShift plays, the board shifts semi-permanently
% How?
%   Decide whether to go up or down (randomly)
%   If up, by normal(+avg_shift_lt%, +std_shift_lt%)
%   If down, by normal(-avg_shift_lt%, +std_shift_lt%)
numPlaysBeforeShift = numPlays / 10; % If you don't want LT stochasticism, set this to numPlays
%avg_shift_lt = 30;
%std_shift_lt = 15;

% Short-term
% Each play, shift reward around normal(0%, std_shift_st%)
% And, according to the % in risk(state, board), decide whether to multiply
%   by -1
std_shift_st = 0; % If you don't want ST stochasticism, set this to 0

% Do I want there to be a death function?
% If no, set death = 0
% If yes, death is an n x 2 matrix
%   set death(i, 1) = the ith cutoff and death(i, 2) = the probability of
%       dying if the agent goes below the ith cutoff
%   Put it in descending order (i.e. first cutoff = -50, second = -100,
%       etc.)
death = 0;

% Switching
numPlaysBeforeSwitch = 20;
currentSwitch = 1;

% Start properties.
% Right now, only one starting position.
% starts = randsample(1:width,numBoards,true); % starting location for agent

% AGENT PARAMETERS

% Set gammas, alphas, betas, temps

% Temporal discount rates have been chosen based on my review of the literature, which seems
%   to indicate people choose the gammas to be somewhere between .75 and .99
gammaR = .85;
gammaP = .85;

alphaR = x(1);
alphaP = x(2);

betaR = x(3);
betaP = x(4);

tempR = x(5);
tempP = x(6);

if testingAlt == 1
    alphaR_alt = x_alt(1);
    alphaP_alt = x_alt(2);
    betaR_alt = x_alt(3);
    betaP_alt = x_alt(4);
    tempR_alt = x_alt(5);
    tempP_alt = x_alt(6);
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
likelihood_alt = zeros(numInstances, 1);

slips = zeros(numInstances, 1); % Count the # of avoidance failures

% Loop through each to-be-instantiated agent-board system.
for thisBoard = 1:numInstances
    
    % Initialize this agent's policy matrix(actor)
    policyR = policy0;
    policyP = policy0;
    
    % Initialize this agent's value matrix (critic)
    valuesR = values0;
    valuesP = values0;
    
    if testingAlt == 1
        policyR_alt = policy0;
        policyP_alt = policy0;
        valuesR_alt = values0;
        valuesP_alt = values0;
    end
    
    % Initializes a counter for the long-term stochasticism element
    % Marks which play you're on, until you hit numPlaysBeforeShift, then
    %   goes back to 0
    stochastic_counter = 0;
    
    % Also a counter for switching
    switching_counter = 0;
    
    % For this agent-board system, loop through each of the agent's plays.
    for thisPlay = 1:numPlays
        
        %state = starts(thisBoard);
        state = 1;
        
        rewardSum = 0;
        
        stochastic_counter = stochastic_counter + 1;
        switching_counter = switching_counter + 1;
        
        % Move through the board.
        for thisMove = 1:numMoves
            
            % Add long-term stochasticism
            % Check if it's time to shift
            if stochastic_counter > numPlaysBeforeShift
                % Loop through each state
                for thisState = 1 : numStates
                    % Calculate shift
                    shift = avg_shift_lt + std_shift_lt .* randn(1,1);
                    
                    % Decide whether to go up or down
                    if rand() > .5
                        % Go up
                        boards(thisState, thisBoard) = boards(thisState, thisBoard) .* (1 + (shift / 100));
                    else
                        % Go down
                        boards(thisState, thisBoard) = boards(thisState, thisBoard) .* (1 - (shift / 100));
                    end
                end
                
                % Reset counter
                stochastic_counter = 0;
            end
            
            % Check if it's time to switch
            if switching_counter > numPlaysBeforeSwitch
                % If we've hit the limit of switches
                if currentSwitch == size(boards, 3)
                    currentSwitch = 1; % start again
                else % Otherwise increment
                    currentSwitch = currentSwitch + 1;
                end
                switching_counter = 0;
            end
            
            % Select action w/ softmax
            % Make decisions based on normal values - just record alt ones
            probs_numerator = exp(tempR .* policyR(state,:) + tempP .* policyP(state,:));
            probs_denominator = sum(probs_numerator);
            
            % Clean out infinities (change them to realmax's).
            probs_numerator(isinf(probs_numerator)) = realmax .* ones(sum(isinf(probs_numerator)), 1);
            probs_denominator(isinf(probs_denominator)) = realmax .* ones(sum(isinf(probs_denominator)), 1);
            
            probs = probs_numerator ./ probs_denominator;
            
            if testingAlt == 1
                probs_numerator_alt = exp(tempR_alt .* policyR_alt(state,:) + tempP_alt .* policyP_alt(state,:));
                probs_denominator_alt = sum(probs_numerator_alt);

                % Clean out infinities (change them to realmax's).
                probs_numerator_alt(isinf(probs_numerator_alt)) = realmax .* ones(sum(isinf(probs_numerator_alt)), 1);
                probs_denominator_alt(isinf(probs_denominator_alt)) = realmax .* ones(sum(isinf(probs_denominator_alt)), 1);

                probs_alt = probs_numerator_alt ./ probs_denominator_alt;
            end
            
            action = randsample(numActions, 1, true, probs);
            
            if testingAlt == 1
                likelihood(thisBoard) = likelihood(thisBoard) + log(probs(action));
                likelihood_alt(thisBoard) = likelihood_alt(thisBoard) + log(probs_alt(action));
            end
            
            % Move
            newstate = transitions(state,action,thisBoard);
            reward = boards(newstate,thisBoard,currentSwitch);
            
            % Add short-term stochasticism
            % Shift according to normal
            if std_shift_lt > 0
                shift = std_shift_lt .* randn(1);
                reward = reward .* (1 + (shift/100));
            end
            
            if reward < 0 && policyR(state,action) < 0
                slips(thisBoard) = slips(thisBoard) + 1;
            end
            
            rewardSum = rewardSum + reward;
            
            % Update actor
            policyR(state,action) = policyR(state,action) + betaR.*(((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state)));
            policyP(state,action) = policyP(state,action) + betaP.*(((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state)));

            % Update critic
            valuesR(state) = valuesR(state) + alphaR.*((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state));
            valuesP(state) = valuesP(state) + alphaP.*((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state));

            if testingAlt == 1
                policyR_alt(state,action) = policyR_alt(state,action) + betaR_alt.*(((max(reward,0) + gammaR.*valuesR_alt(newstate)) - valuesR_alt(state)));
                policyP_alt(state,action) = policyP_alt(state,action) + betaP_alt.*(((min(reward,0) + gammaP.*valuesP_alt(newstate)) - valuesP_alt(state)));
                valuesR_alt(state) = valuesR_alt(state) + alphaR_alt.*((max(reward,0) + gammaR.*valuesR_alt(newstate)) - valuesR_alt(state));
                valuesP_alt(state) = valuesP_alt(state) + alphaP_alt.*((min(reward,0) + gammaP.*valuesP_alt(newstate)) - valuesP_alt(state));
            end
            
            % Update state
            state = newstate;
            
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