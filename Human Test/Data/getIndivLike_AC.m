%% getIndivLike_AC
% This is our actor-critic model.

%% Params
% x: [alphaR alphaP betaR betaP temp stay eligR eligP gammaR gammaP] (length=10)
% actions: [A1 A2] or [A1 A2 A3]
%   should all be 1 or 2
% states: [1 S2] or [1 S2 S3]
%   2nd column should be 2 or 3, 3rd column (if it exists) should be 4-7
% rewards: [0 0 re]
%   reward received for each move in each round (should be between -5 and 5)
% round: the round # for each row
% comb: set to 1 if you want to use the combined model, 0 if you want to
%   use the uncombined

%% Versions
% v1.2: getting rid of slips
% v1.3: changing normalization to real instead of just for softmax
% v1.4: adding optional eligibility traces, making two normalization options
% v1.5: oh god, fixed an ugly bug
% v2 (7/28/2014): took out type, adding 'comb' parameter, making numLevels fluid

function [likelihood] = getIndivLike_AC(x, actions, states, rewards, roundNum, comb)

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
numMoves = size(actions,2);
numStates = 2^(numMoves+1);
numActions = 2;
practiceCutoff = 25;

% Data variables:
% id, A1, S2, A2, Re

%% AGENT PARAMETERS

% Set gammas, alphas, betas, temps

alphaR = x(1);
alphaP = x(2);
betaR = x(3);
betaP = x(4);
temp = x(5);
stay = x(6);
eligR = x(7);
eligP = x(8);
gammaR = x(9);
gammaP = x(10);

% Set up initial state/action preference matrix (actor) and initial value
%   matrix (critic)
policy0 = zeros(numStates,numActions);
values0 = zeros(numStates, 1);

%% PLAY THE BOARD

% Calculate likelihoods
likelihood = 0;

if comb==1
    policy = policy0;
    values = values0;
else
    policyR = policy0;
    policyP = policy0;
    valuesR = values0;
    valuesP = values0;
end

prevActions = zeros(1,numMoves);

% Loop through each of the rounds
for thisRound = 1:length(A1)
    % Only do rounds that aren't practice rounds
    if roundNum(thisRound) > practiceCutoff
        for thisMove = 1:numMoves
            % GET WHAT HAPPENED
            
            state = states(thisRound,thisMove);
            action = actions(thisRound,thisMove);
            % For newstate, if it's the last move we have to calculate it
            if thisMove < numMoves, newstate = curStates(thisMove+1);
            else newstate = state*numActions+action-1; end
            reward = rewards(thisRound,thisMove);
            
            % MAKE MOVE
            
            % If combined, use policy; if not, add policies
            temppolicy = policy*(comb==1)+(policyR+policyP)*(comb==0);
            % Give stay bonus
            if prevActions(thisMove), temppolicy(state,prevActions(thisMove)) = policy(state,prevActions(thisMove))+stay; end
            % Do move
            probs = softmax_TDRL(temp,temppolicy(state,:),0);
            % Update likelihood
            likelihood = likelihood + log(probs(action));
            
            % UPDATE MODEL FREE
            
            % Combined model?
            if comb == 1
                % Reward? Use r parameters
                if reward >= 0
                    alpha = alphaR;
                    beta = betaR;
                    elig = eligR;
                    gamma = gammaR;
                else % Otherwise use p parameters
                    alpha = alphaP;
                    beta = betaP;
                    elig = eligP;
                    gamma = gammaP;
                end
                
                % Do main update
                delta = reward + gamma*values(newstate) - values(state);
                policy(state,action) = policy(state,action) + beta*delta;
                values(state) = values(state) + alpha*delta;
                
                % Do eligiblity traces
                % Walk backwards through moves
                for i=(thisMove-1):-1:1
                    eligstate = states(thisRound,i);
                    eligaction = actions(thisRound,i);
                    policy(eligstate,eligaction) = policy(eligstate,eligaction) + (elig^i)*beta*delta;
                    values(eligstate) = values(eligstate) + (elig^i)*alpha*delta;
                end
            else % Uncombined model?
                deltaR = max(reward,0) + gammaR*valuesR(newstate) - valuesR(state);
                deltaP = min(reward,0) + gammaP*valuesP(newstate) - valuesP(state);
                
                policyR(state,action) = policyR(state,action) + betaR*deltaR;
                policyP(state,action) = policyP(state,action) + betaP*deltaP;
                valuesR(state) = valuesR(state) + alphaR*deltaR;
                valuesP(state) = valuesP(state) + alphaP*deltaP;
                
                % Do eligiblity traces
                % Walk backwards through moves
                for i=(thisMove-1):-1:1
                    eligstate = states(thisRound,i);
                    eligaction = actions(thisRound,i);
                    policyR(eligstate,eligaction) = policyR(eligstate,eligaction) + (eligR^i)*betaR*deltaR;
                    policyP(eligstate,eligaction) = policyP(eligstate,eligaction) + (eligP^i)*betaP*deltaP;
                    valuesR(eligstate) = valuesR(eligstate) + (eligR^i)*alphaR*deltaR;
                    valuesP(eligstate) = valuesP(eligstate) + (eligP^i)*alphaP*deltaP;
                end
            end
        end
    end
end

likelihood = -likelihood; % for patternsearch (or fmincon)
end