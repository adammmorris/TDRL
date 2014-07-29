%% ac_sep_2steptask_v2
% This is the separated actor/critic model for a two-step task
% This version uses an uncombined actor/critic

%% Params
% x should be either:
%   [alphaR alphaP betaR betaP temp gammaR gammaP]
%   or a numInstance x 1, where each row is that vector (for each subject)

%% Output
% earnings is numInstances x 1
% negLLs is numInstances x 1
% results is (numInstances * numPlays) x 5
%   columns are id a1 s2 a2 re

function [earnings, negLLs, results] = ac_sep_2step(x, numInstances, numPlays, boardPath, stochasticTransitions,normed,magic)

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
    alphaR = x(:,1);
    alphaP = x(:,2);
    betaR = x(:,3);
    betaP = x(:,4);
    temp = x(:,5);
    gammaR = x(:,6);
    gammaP = x(:,7);
elseif size(x,1) == 1
    alphaR = repmat(x(1),numInstances);
    alphaP = repmat(x(2),numInstances);
    betaR = repmat(x(3),numInstances);
    betaP = repmat(x(4),numInstances);
    temp = repmat(x(5),numInstances);
    gammaR = repmat(x(6),numInstances);
    gammaP = repmat(x(7),numInstances);
else
    error('x must have either numInstances or 1 row');
end
% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
policy0 = zeros(numStates,numActions);
values0 = zeros(numStates, 1);

% Set up earnings matrix.
earnings = zeros(numInstances,1);

% Set up results matrix
results = zeros(numInstances*numPlays,5);
roundIndex = 1;

% Calculate likelihoods
likelihood = zeros(numInstances, 1);

%% Loop through each to-be-instantiated agent-board system.
for thisBoard = 1:numInstances
    if magic <= 0, magic = thisBoard; end
    
    % Initialize this agent's policy matrix(actor)
    policyR = policy0;
    policyP = policy0;
    
    % Initialize this agent's value matrix (critic)
    valuesR = values0;
    valuesP = values0;
   
    % For this agent-board system, loop through each of the agent's plays.
    for thisPlay = 1:numPlays
        
        % Initalize results stuff
        a1 = 0;
        s2 = 0;
        a2 = 0;
        re = 0;
        
        %state = starts(thisBoard);
        state = 1;
        
        rewardSum = 0;
        
        % Move through the board.
        for thisMove = 1:numMoves
    
            % Select action w/ softmax
            % Make decisions based on normal values - just record alt ones
            probs = softmax_TDRL(temp(thisBoard),policyR(state,:)+policyP(state,:),normed==1);
            
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
                newstate = transitions(state,action,magic);
            end
            
            
            reward = boards(newstate,thisPlay,magic);
            
            rewardSum = rewardSum + reward;
            
            policyR(state,action) = policyR(state,action) + betaR(thisBoard).*(((max(reward,0) + gammaR(thisBoard).*valuesR(newstate)) - valuesR(state)));
            policyP(state,action) = policyP(state,action) + betaP(thisBoard).*(((min(reward,0) + gammaP(thisBoard).*valuesP(newstate)) - valuesP(state)));

            % Update critic
            valuesR(state) = valuesR(state) + alphaR(thisBoard).*((max(reward,0) + gammaR(thisBoard).*valuesR(newstate)) - valuesR(state));
            valuesP(state) = valuesP(state) + alphaP(thisBoard).*((min(reward,0) + gammaP(thisBoard).*valuesP(newstate)) - valuesP(state));
            
            % Get stuff for results matrix
            if state == 1 % if they were making their first choice
                a1 = action - 1; % action they took (subtraction is b/c Fiery uses 0 or 1)
                s2 = newstate-2; % subtraction is b/c Fiery uses 0 or 1
            elseif any(2:3 == state) % if they were making their second choice
                a2 = action; % this is correct, should be 1 or 2 (super weird, I know)
                re = reward;
            end
            
            % Update state
            state = newstate;
        end
       
        % Update results matrix
        results(roundIndex,:) = [thisBoard a1 s2 a2 re];
        roundIndex = roundIndex + 1;
        
        % Update earnings.
        earnings(thisBoard) = earnings(thisBoard) + rewardSum;
    end
end

negLLs = -likelihood;

end