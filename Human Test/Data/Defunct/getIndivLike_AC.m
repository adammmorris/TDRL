%% getIndivLike_AC
% This is the uncombined actor-critic model
% Can modulate which parameters are differentiated with 'type'

%% Params
% type: 'ABT', 'ArApBT', 'ABrBpT', 'ArApBrBpT' (or 'ABET', just for yucks)
% x depends on type
% normed:
%   - set to 1 if you want to norm policy before sending to softmax
%   function ('_normedEZ')
%   - set to 2 if you want to norm policy for real ('_normed')

function [likelihood] = getIndivLike_AC(type, x, A1, S2, A2, Re, round1, normed)

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

%[currentPath, ~, ~] = fileparts(mfilename('fullpath'));
%load(strcat(currentPath, '/Boards/', boardPath, '.mat'));

% Info about his board
numStates = 8;
numActions = 2;
practiceCutoff = 25;

% Data variables:
% id, A1, S2, A2, Re

%% AGENT PARAMETERS

% Set gammas, alphas, betas, temps

eligR = 0;
eligP = 0;
gammaR = .85;
gammaP = .85;
temp = .5;
stay = 0;

if strcmpi(type,'ABT') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    temp = x(3);
elseif strcmpi(type,'ArApBT') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(3);
    temp = x(4);
elseif strcmpi(type,'ABrBpT') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(3);
    temp = x(4);
elseif strcmpi(type,'ArApBrBpT') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(4);
    temp = x(5);
elseif strcmpi(type,'ABS') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    stay = x(3);
elseif strcmpi(type,'ArApBS') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(3);
    stay = x(4);
elseif strcmpi(type,'ABrBpS') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(3);
    stay = x(4);
elseif strcmpi(type,'ArApBrBpS') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(4);
    stay = x(5);
elseif strcmpi(type,'ABSE') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    stay = x(3);
    eligR = x(4);
    eligP = x(4);
elseif strcmpi(type,'ArApBSE') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(3);
    stay = x(4);
    eligR = x(5);
    eligP = x(5);
elseif strcmpi(type,'ABrBpSE') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(3);
    stay = x(4);
    eligR = x(5);
    eligP = x(5);
elseif strcmpi(type,'ArApBrBpSE') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(4);
    stay = x(5);
    eligR = x(6);
    eligP = x(6);
elseif strcmpi(type,'ABET') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    eligR = x(3);
    eligP = x(3);
    temp = x(4);
elseif strcmpi(type,'ABTGrGp') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    temp = x(3);
    gammaR = x(4);
    gammaP = x(5);
elseif strcmpi(type,'ABTErEp') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    temp = x(3);
    eligR = x(4);
    eligP = x(5);
elseif strcmpi(type,'ArApBTE') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(3);
    temp = x(4);
    eligR = x(5);
    eligP = x(5);
end

% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
policy0 = zeros(numStates,numActions);
values0 = zeros(numStates, 1);

%% PLAY THE BOARD

% Calculate likelihoods
likelihood = 0;

rewardSum = 0;

policyR = policy0;
policyP = policy0;
valuesR = values0;
valuesP = values0;

prevA1 = 0;
prevA2 = 0;

% Loop through each of the rounds
for thisRound = 1:length(A1)
    if round1(thisRound) > practiceCutoff
        % FIRST MOVE
        temp_policy = policyR+policyP;
        if prevA1,temp_policy(1,prevA1) = temp_policy(1,prevA1) + stay; end
        probs = softmax_TDRL(temp,temp_policy(1,:),0);
        
        %action = randsample(numActions, 1, true, probs);
        
        action1 = A1(thisRound)+1; % the +1 is because Fiery's dataset uses actions 0 and 1
        
        likelihood = likelihood + log(probs(action1));
        
        % Move
        %newstate = transitions(state,action,thisBoard);
        %reward = boards(newstate,thisBoard,currentSwitch);
        
        state2 = S2(thisRound) + 2*(S2(thisRound)<2); %+2 because we really want states 2 or 3 here (and Fiery uses 0 or 1)
        
        
        % SECOND MOVE
        if prevA2,temp_policy(state2,prevA2) = temp_policy(state2,prevA2) + stay; end
        probs = softmax_TDRL(temp,temp_policy(state2,:),0);
        
        %action = randsample(numActions, 1, true, probs);
        
        action2 = A2(thisRound)-2*(A2(thisRound)>2); % If it's equal to 3 or 4, we don't need that info.. just drop it to 1 and 2
        
        likelihood = likelihood + log(probs(action2));
        
        % Move
        %newstate = transitions(state,action,thisBoard);
        %reward = boards(newstate,thisBoard,currentSwitch);
        
        reward = Re(thisRound);
        
        rewardSum = rewardSum + reward;
        
        % Update actor & critic
        
        % Do 1st level first
        deltaR = gammaR*valuesR(state2)-valuesR(1);
        deltaP = gammaP*valuesP(state2)-valuesP(1);
        policyR(1,action1) = policyR(1,action1)+betaR*deltaR;
        policyP(1,action1) = policyP(1,action1)+betaP*deltaP;
        valuesR(1) = valuesR(1)+alphaR*deltaR;
        valuesP(1) = valuesP(1)+alphaP*deltaP;
        
        % Then 2nd level
        deltaR = max(reward,0)-valuesR(state2);
        deltaP = min(reward,0)-valuesP(state2);
        policyR(state2,action2) = policyR(state2,action2)+betaR*deltaR;
        policyP(state2,action2) = policyP(state2,action2)+betaP*deltaP;
        valuesR(state2) = valuesR(state2)+alphaR*deltaR;
        valuesP(state2) = valuesP(state2)+alphaP*deltaP;
        
        % Then eligibility trace
        valuesR(1) = valuesR(1)+eligR*alphaR*deltaR;
        valuesP(1) = valuesP(1)+eligP*alphaP*deltaP;
        
        prevA1 = action1;
        prevA2 = action2;
    end
end

likelihood = -likelihood; % for patternsearch (or fmincon)
end