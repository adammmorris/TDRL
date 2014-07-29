% Fiery's Separated Actor-Critic Learning Algorithm
% Inputs:
%   x = [alphaR, alphaP, betaR, betaP, tempR, tempP]
%   numInstances (optional) = the number of times to run the algorithm (i.e. the
%       number of board-agent instances to run through)
%       default: numBoards

function [totEarnings, stdEarnings, learnCurve] = ac_sep_1p8(x, numInstances, numPlays, boardPath, stochastic)

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

if nargin < 2
    numInstances = numBoards;
end

% Do I want it to be stochastic?
% If no, set stochastic = 0
% If yes, set stochastic like this:
%   If you want there to be a 1/10 chance of multiplying the reward by 10,
%   set stochastic = 10;
%stochastic = 0;

% Do I want there to be a death function?
% If no, set death = 0
% If yes, death is an n x 2 matrix
%   set death(i, 1) = the ith cutoff and death(i, 2) = the probability of
%       dying if the agent goes below the ith cutoff
%   Put it in descending order (i.e. first cutoff = -50, second = -100,
%       etc.)
death = 0;

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

% Set the # of plays each agent gets to make.
%numPlays = 50;  I've made this an input now

% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
policy0 = zeros(numStates,numActions);
values0 = zeros(numStates, 1);

% Set up earnings matrix.
earnings = zeros(numPlays,numInstances);


% PLAY THE BOARD

% Loop through each to-be-instantiated agent-board system.
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
        for thisMove = 1:numMoves;
           
            % Select action w/ softmax
            probs_numerator = exp(tempR .* policyR(state,:) + tempP .* policyP(state,:));
            probs_denominator = sum(probs_numerator);
            
            % Clean out infinities (change them to realmax's).
            probs_numerator(isinf(probs_numerator)) = realmax .* ones(sum(isinf(probs_numerator)), 1);
            probs_denominator(isinf(probs_denominator)) = realmax .* ones(sum(isinf(probs_denominator)), 1);
            
            probs = probs_numerator ./ probs_denominator;
            
            action = randsample(numActions, 1, true, probs);
            
            % Move
            newstate = transitions(state,action,thisBoard);
            reward = boards(newstate,thisBoard);
            
            % Add stochastic element
            if stochastic > 0
                if rand() < (1 / stochastic)
                    reward = reward * stochastic;
                end
            end
            
            rewardSum = rewardSum + reward;
            
            % Update actor
            policyR(state,action) = policyR(state,action) + betaR.*(((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state)));
            policyP(state,action) = policyP(state,action) + betaP.*(((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state)));
            
            % Update critic
            valuesR(state) = valuesR(state) + alphaR.*((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state));
            valuesP(state) = valuesP(state) + alphaP.*((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state));
                        
            % Update state
            state = newstate;
            
        end
       
        % Update earnings.
        earnings(thisPlay,thisBoard) = earnings(thisPlay,thisBoard) + rewardSum;
        
        % Death function
        % We're not using this, but, since I already implemented it, I just
        %   left it in here
        if any(death)
            killAgent = 0;
            total_earnings = sum(earnings(:, thisBoard), 1);
            
            % Search through cutoffs, starting at lowest one
            for i = size(death, 1) : -1 : 1
                if total_earnings < death(i, 1)
                    if rand() < death(i, 2)
                        killAgent = 1;
                        break % jump out of this search
                    end
                end
            end
            
            if killAgent == 1
                break % kill agent (mwahahahaha)
            end
        end
        
    end
end

% Return results.
totEarnings = mean(sum(earnings)); % not using patternsearch, so I got rid of -
stdEarnings = std(sum(earnings));
learnCurve = sum(earnings, 2);

end