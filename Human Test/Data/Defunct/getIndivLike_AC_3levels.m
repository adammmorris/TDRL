%% getIndivLike_AC_comb
% This is our combined actor-critic model
% Can modulate which parameters are differentiated with 'type'

%% Params
% type: 'ABT', 'ArApBT', 'ABrBpT', 'ArApBrBpT' (or 'ABET', just for yucks)
% x depends on type
% normed:
%   - set to 1 if you want to norm policy before sending to softmax
%   function ('_normedEZ')
%   - set to 2 if you want to norm policy for real ('_normed')

%% Versions
% v2: getting rid of slips
% v3: changing normalization to real instead of just for softmax
% v4: adding optional eligibility traces, making two normalization options
% v5: oh god, fixed an ugly bug

function [likelihood] = getIndivLike_AC_3levels(type, x, A1, S2, A2, S3, A3, Re, round, normed)

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
numStates = 16;
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
stay = 0;
temp = .5;

if strcmpi(type,'ABT') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    temp = x(3);
elseif strcmpi(type,'ABS') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    stay = x(3);
elseif strcmpi(type,'ABSE') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    stay = x(3);
    eligR = x(4);
    eligP = x(4);
elseif strcmpi(type,'ABSErEp') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    stay = x(3);
    eligR = x(4);
    eligP = x(5);
elseif strcmpi(type,'ArApBrBpSE') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(4);
    stay = x(5);
    eligR = x(6);
    eligP = x(6);
elseif strcmpi(type,'ArApBrBpSErEp') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(4);
    stay = x(5);
    eligR = x(6);
    eligP = x(7);
elseif strcmpi(type,'ABrBpS') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(3);
    stay = x(4);
elseif strcmpi(type,'ArApBS') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(3);
    stay = x(4);
elseif strcmpi(type,'ArApBrBpS') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(4);
    stay = x(5);
elseif strcmpi(type,'ABTS') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    temp = x(3);
    stay = x(4);
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
elseif strcmpi(type,'ABrBpTS') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(3);
    temp = x(4);
    stay = x(5);
elseif strcmpi(type,'ArApBrBpT') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(4);
    temp = x(5);
elseif strcmpi(type,'ArApBrBpTS') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(4);
    temp = x(5);
    stay = x(6);
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
elseif strcmpi(type,'ABTSE') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(2);
    temp = x(3);
    stay = x(4);
    eligR = x(5);
    eligP = x(5);
elseif strcmpi(type,'ABrBpTSE') == 1
    alphaR = x(1);
    alphaP = x(1);
    betaR = x(2);
    betaP = x(3);
    temp = x(4);
    stay = x(5);
    eligR = x(6);
    eligP = x(6);
elseif strcmpi(type,'ArApBrBpTSErEp') == 1
    alphaR = x(1);
    alphaP = x(2);
    betaR = x(3);
    betaP = x(4);
    temp = x(5);
    stay = x(6);
    eligR = x(7);
    eligP = x(8);
end

% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
policy0 = zeros(numStates,numActions);
values0 = zeros(numStates, 1);

%% PLAY THE BOARD

% Calculate likelihoods
likelihood = 0;

policyR = policy0;
policyP = policy0;
valuesR = values0;
valuesP = values0;

prevA1 = 0;
prevA2 = 0;
prevA3 = 0;

% Loop through each of the rounds
for thisRound = 1:length(A1)
    action1 = A1(thisRound); % this should be 1 or 2, but sometimes we have to add +1 b/c flash uses 0 or 1
    state2 = S2(thisRound); % this should be 2 or 3
    action2 = A2(thisRound); % should be 1 or 2
    state3 = S3(thisRound); % this should be 4-7
    action3 = A3(thisRound); % should be 1 or 2
    reward = Re(thisRound);
    
    % Only do rounds that aren't practice rounds
    if round(thisRound) > practiceCutoff
        
        % We're starting off a new play, so...
        state = 1;
        
        % FIRST MOVE
        temppolicy = policyR+policyP;
        if prevA1, temppolicy(state,prevA1) = temppolicy(state,prevA1)+stay; end
        probs = softmax_TDRL(temp,temppolicy(state,:),0);
        likelihood = likelihood + log(probs(action1));
        
        % SECOND MOVE
        if prevA2, temppolicy(state2,prevA2) = temppolicy(state2,prevA2)+stay; end
        probs = softmax_TDRL(temp,temppolicy(state2,:),0);
        likelihood = likelihood + log(probs(action2));
        
        % THIRD MOVE
        if prevA3, temppolicy(state3,prevA3) = temppolicy(state3,prevA3)+stay; end
        probs = softmax_TDRL(temp,temppolicy(state3,:),0);
        likelihood = likelihood + log(probs(action3));
        
        % UPDATE MODEL-FREE
        % Reward
        % First move - no reward
        delta = gammaR .* valuesR(state2) - valuesR(1);
        policyR(1,action1) = policyR(1,action1) + betaR * delta;
        valuesR(1) = valuesR(1) + alphaR * delta;
        
        % Second move - no reward
        delta = gammaR .* valuesR(state3) - valuesR(state2);
        policyR(state2,action2) = policyR(state2,action2) + betaR*delta;
        valuesR(state2) = valuesR(state2) + alphaR*delta;
        
        % Elig trace
        valuesR(1) = valuesR(1) + eligR * alphaR * delta;
        policyR(1,action1) = policyR(1,action1) + eligR*betaR*delta;
        
        % Third move
        delta = reward - valuesR(state3);
        policyR(state3,action3) = policyR(state3,action3) + betaR * delta;
        valuesR(state3) = valuesR(state3) + alphaR * delta;
        
        % Eligibility traces
        valuesR(1) = valuesR(1) + (eligR^2) * alphaR * delta;
        valuesR(state2) = valuesR(state2) + eligR * alphaR * delta;
        policyR(1,action1) = policyR(1,action1) + (eligR^2)*betaR*delta;
        policyR(state2,action2) = policyR(state2,action2) + eligR*betaR*delta;
        
        % Punishment
        delta = gammaP .* valuesP(state2) - valuesP(1);
        policyP(1,action1) = policyP(1,action1) + betaP * delta;
        valuesP(1) = valuesP(1) + alphaP * delta;
        
        delta = gammaP .* valuesP(state3) - valuesP(state2);
        policyP(state2,action2) = policyP(state2,action2) + betaP*delta;
        valuesP(state2) = valuesP(state2) + alphaP*delta;
        
        % Elig trace
        valuesP(1) = valuesP(1) + eligP * alphaP * delta;
        policyP(1,action1) = policyP(1,action1) + eligP*betaP*delta;
        
        delta = reward - valuesP(state3);
        policyP(state3,action3) = policyP(state3,action3) + betaP * delta;
        valuesP(state3) = valuesP(state3) + alphaP * delta;
        
        % Eligibility traces
        valuesP(1) = valuesP(1) + (eligP^2) * alphaP * delta;
        valuesP(state2) = valuesP(state2) + eligP * alphaP * delta;
        policyP(1,action1) = policyP(1,action1) + (eligP^2)*betaP*delta;
        policyP(state2,action2) = policyP(state2,action2) + eligP*betaP*delta;
        
        prevA1 = action1;
        prevA2 = action2;
        prevA3 = action3;
    end
end

likelihood = -likelihood; % for patternsearch (or fmincon)
end