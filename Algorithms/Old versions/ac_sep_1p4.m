% Fiery's Separated Actor-Critic Learning Algorithm
% Inputs:
%   x = [gammaR,alphaR,betaR,gammaP,alphaP,betaP,tempR,tempP]
%       if set to < 0, will use default: x0
%   numInstances (optional) = the number of times to run the algorithm (i.e. the
%       number of board-agent instances to run through)
%       default: numBoards

function [totEarnings, stdEarnings, learnCurve] = ac_sep_1p4(x, numInstances)

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

load /Boards/Board2/Board2.mat

if nargin < 2
    numInstances = numBoards;
end

% Start properties.
% Right now, only one starting position.
% starts = randsample(1:width,numBoards,true); % starting location for agent

% AGENT PARAMETERS

% Set gammas, alphas, betas, temps

x0 = [.5 .5 .8 .5 .5 .8 1 1]; 
for i = 1:length(x)
    if x(i) < 0 % has to be this, because what if you want one of the values to be zero?
        x(i) = x0(i);
    end
end

gammaR = x(1);
alphaR = x(2);
betaR = x(3);
gammaP = x(4);
alphaP = x(5);
betaP = x(6);
tempR = x(7);
tempP = x(8);

% Set the # of plays each agent gets to make.
numPlays = 50;

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

    end
end

% Return results.
totEarnings = -mean(sum(earnings)); % - for minimizer
stdEarnings = std(sum(earnings));
learnCurve = sum(earnings, 2);

end