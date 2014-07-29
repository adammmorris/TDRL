%% ac_sep_comb_2step
% This is the separated actor/critic model for a two-step task
% This version uses a 'combined' actor/critic that switches its parameters
%   for rewards and punishments, but keeps one combined matrix of values &
%   policies
% Note that it can be used with other environments too, but some of the
%   features (i.e. stochastic transitions, the 'results' output) won't work

%% Params
% x should be either:
%   [alphaR alphaP betaR betaP temp gammaR gammaP]
%   or a numInstance x 1, where each row is that vector (for each subject)
% normed: should be 0 if you don't want to norm, 1 if you want to norm just
%   in the softmax function, and 2 if you want to norm for realz
% magic: set to 0 if you want to use a different board for each instance.
%   If you want to use one board for all instances, set magic=that board #

%% Output
% earnings is numInstances x 1
% negLLs is numInstances x 1
% results is (numInstances * numPlays) x 5
%   columns are id a1 s2 a2 re

%% Versions
% v3: cleaning up code (i.e. getting rid of drifting rewards in here, cause
%   its now in the board itself)
% v4:
%   - adding norming option (to norm the policy before sending it to
%   softmax function)
%   - also encapsulated softmax procedure in separate function
% v5:
%   - changed the normalization to actually normalizing the weights instead
%   of just normalizing what you send to the softmax function

function [earnings, negLLs, results] = ac_sep_comb_2step(x, numInstances, numPlays, boardPath, stochasticTransitions, normed, magic)

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
    alphaR = repmat(x(1),numInstances,1);
    alphaP = repmat(x(2),numInstances,1);
    betaR = repmat(x(3),numInstances,1);
    betaP = repmat(x(4),numInstances,1);
    temp = repmat(x(5),numInstances,1);
    gammaR = repmat(x(6),numInstances,1);
    gammaP = repmat(x(7),numInstances,1);
else
    error('x must have either numInstances or 1 row');
end

% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
if normed == 2
    policy0 = .01+zeros(numStates,numActions);
else
    policy0 = zeros(numStates,numActions);
end
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
    policy = policy0;
    
    % Initialize this agent's value matrix (critic)
    values = values0;
   
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
            probs = softmax_TDRL(temp(thisBoard),policy(state,:),normed==1);
            
            %fprintf('Temp: %d\nPolicy (Action 1): %d\nPolicy (Action 2): %d\n',temp(thisBoard),policy(state,1),policy(state,2));
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
%             reward = 0;
%             if newstate == 4, reward=3; end
            rewardSum = rewardSum + reward;
            
            % Update actor/critic
            if reward >= 0
                delta = reward + gammaR(thisBoard) .* values(newstate) - values(state);
                policy(state,action) = policy(state,action) + betaR(thisBoard) * delta;
                values(state) = values(state) + alphaR(thisBoard) * delta;
            else
                delta = reward + gammaP(thisBoard) .* values(newstate) - values(state);
                policy(state,action) = policy(state,action) + betaP(thisBoard) * delta;
                values(state) = values(state) + alphaP(thisBoard) * delta;
            end
            
            % Get stuff for results matrix
            if state == 1 % if they were making their first choice
                a1 = action - 1; % action they took (subtraction is b/c Fiery uses 0 or 1)
                s2 = newstate-2; % subtraction is b/c Fiery uses 0 or 1
            elseif any(2:3 == state) % if they were making their second choice
                a2 = action; % this is correct, should be 1 or 2 (super weird, I know)
                re = reward;
            end
                   
            % Norm?
            if normed == 2
                policy(state,:) = policy(state,:) ./ sum(abs(policy(state,:)));
            end
            
            %printState(thisPlay,state,action,newstate,values,policy,boards(4:7,thisPlay,magic));
            
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