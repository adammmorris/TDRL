% Fiery's Separated Actor-Critic Learning Algorithm
% Inputs:
%   x = [alphaR, alphaP, betaR, betaP, tempR, tempP]
%   numInstances (optional) = the number of times to run the algorithm (i.e. the
%       number of board-agent instances to run through)
%       default: numBoards
% THIS VERSION IS FOR TESTING DAW'S DATA

function [totEarnings, stdEarnings, learnCurve, likelihood, likelihood_alt] = ac_sep_daw(x, x_alt, numInstances, numPlays, id, A1, S2, A2, Re, Round, Toss, Betas, Lr1, useCalculatedTemps)

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

testingAlt = 1;

% Data variables:
% id, A1, S2, A2, Re, Round, Toss, Betas, Lr1
% if useCalcuatedTemps == 1, use individual temps that fiery calculated
% if == 0, use standard inputted temp for all ppl

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

% Start off first player
thisBoard = 1;

rewardSum = 0;

policyR = policy0;
policyP = policy0;

valuesR = values0;
valuesP = values0;

if testingAlt == 1
    policyR_alt = policy0;
    policyP_alt = policy0;
    valuesR_alt = values0;
    valuesP_alt = values0;
end

if useCalculatedTemps == 1
    tempR = Betas(1);
    tempP = Betas(1);
    tempR_alt = Betas(1);
    tempP_alt = Betas(1);
end

% Loop through each play of each player
for thisDataPoint = 1:length(id)
    
    % Check if there's any reason to disqualify this play
    if (Lr1(thisDataPoint) >= .2 && ~isnan(id(thisDataPoint)) && ~isnan(A1(thisDataPoint)) && ~isnan(S2(thisDataPoint)) && ~isnan(A2(thisDataPoint)) && ~isnan(Re(thisDataPoint)) && ~isnan(Betas(thisDataPoint)))
        
        % We're starting off a new play, so...
        state = 1;
        
        % FIRST MOVE
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
        
        %action = randsample(numActions, 1, true, probs);
        
        action = A1(thisDataPoint) + 1; % the +1 is because Fiery's dataset uses actions 0 and 1
        
        if testingAlt == 1
            likelihood(thisBoard) = likelihood(thisBoard) + log(probs(action));
            likelihood_alt(thisBoard) = likelihood_alt(thisBoard) + log(probs_alt(action));
        end
        
        % Move
        %newstate = transitions(state,action,thisBoard);
        %reward = boards(newstate,thisBoard,currentSwitch);
        
        newstate = S2(thisDataPoint) + 2; %+2 because we really want states 2 or 3 here (and Fiery uses 0 or 1)
        reward = 0;
        
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
        
        
        % SECOND MOVE
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
        
        %action = randsample(numActions, 1, true, probs);
        
        action = A2(thisDataPoint);
        
        % We already have the previous state info - don't need to retain it in
        %   action #
        if action == 3
            action = 1;
        elseif action == 4
            action = 2;
        end
        
        if testingAlt == 1
            likelihood(thisBoard) = likelihood(thisBoard) + log(probs(action));
            likelihood_alt(thisBoard) = likelihood_alt(thisBoard) + log(probs_alt(action));
        end
        
        % Move
        %newstate = transitions(state,action,thisBoard);
        %reward = boards(newstate,thisBoard,currentSwitch);
        
        newstate = 8;
        reward = Re(thisDataPoint);
        
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
        
        % Update earnings.
        %earnings(Round(thisDataPoint) + 1,thisBoard) = earnings(Round(thisDataPoint) + 1,thisBoard) + rewardSum;
        
        % Check if we're about to move onto a new ID
        if (thisDataPoint ~= length(id) && id(thisDataPoint) ~= id(thisDataPoint + 1))
            
            % Move on to the next player
            thisBoard = thisBoard + 1;
            rewardSum = 0;
            
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
            
            if useCalculatedTemps == 1
                tempR = Betas(thisDataPoint);
                tempP = Betas(thisDataPoint);
                tempR_alt = Betas(thisDataPoint);
                tempP_alt = Betas(thisDataPoint);
            end
        end
    end
end

% Return results.
totEarnings = mean(sum(earnings)); % not using patternsearch, so I got rid of -
stdEarnings = std(sum(earnings));
learnCurve = sum(earnings, 2);

end