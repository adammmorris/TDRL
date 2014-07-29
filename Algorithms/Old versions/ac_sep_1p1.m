% Fiery's Separated Actor-Critic Learning Algorithm
% x = [gammaR,alphaR,betaR,gammaP,alphaP,betaP,tempR,tempP];

function [totEarnings, stdEarnings, learnCurve] = ac_sep_1p1(x)

% AGENT PARAMETERS

% Set gammas, alphas, betas, temps
gammaR = x(1);
alphaR = x(2);
betaR = x(3);
gammaP = x(4);
alphaP = x(5);
betaP = x(6);
tempR = x(7);
tempP = x(8);

% ENVIRONMENT PARAMETERS

boardSize = 8;
numPlays = 50; % number of times the board is played
% numMoves = height-1;
numMoves = 2;
numBoards = 1000;
numActions = 2;

load 2sp3_boards.mat
% starts = randsample(1:width,numBoards,true); % starting location for agent

% Set up state transition matrix

% transitions = zeros(boardSize,numActions); % left, right, up, down
% for i = 1:boardSize
%         transitions(i,1:numActions) = randsample(width+ceil(i./width),numActions)';
% end

load 2s_transitions.mat

% Set up earnings matrix

earnings = zeros(numPlays,numBoards);

% Set up state/action preference matrix (actor)

policy = zeros(boardSize,numActions);
    % Prevent moves off the board
%     for i = 1:height
%         policy((i-1).*height+1,1) = NaN; % left
%         policy(i.*height,2) = NaN; % right
%     end
%     policy(1:width,3) = NaN(1:width,1); % up
%     policy(boardSize - width:boardSize,numActions) = NaN(1:width,1); % down

% Play the board

for thisBoard = 1:numBoards
    
    % Set up policy matrix (actor)
    
    policyR = policy;
    policyP = policy;
    
    
    % Set up state value matrix (critic)
    
    valuesR = zeros(boardSize,1);
    valuesP = zeros(boardSize,1);
    
    for thisPlay = 1:numPlays
        
        %state = starts(thisBoard);
        state = 1;
        
        rewardSum = 0;
        
        for thisMove = 1:numMoves;
           
            % Select action
            
            %probs = exp(temp.*policy(state,:))./nansum(exp(temp.*policy(state,:)));
            %normsR = zscore(policyR(state,:));
            %normsP = zscore(policyP(state,:));
            %probs = exp(weight.*(temp.*normsR)+(1-weight).*(temp.*normsP))./nansum(exp(weight.*(temp.*normsR)+(1-weight).*(temp.*normsP)));
            probs = exp(tempR.*policyR(state,:)+tempP.*policyP(state,:))./nansum(exp(tempR.*policyR(state,:)+tempP.*policyP(state,:)));
            probs(isnan(probs)) = zeros(sum(isnan(probs)),1);
            %action = randsample(numActions,1,true,probs);
            action = 1 + (rand() < probs(2));
            
            % Move
            
            newstate = transitions(state,action,thisBoard);
            reward = boards(newstate,thisBoard);
            rewardSum = rewardSum + reward;
            
            % Update actor
            
            %policy(state,action) = policy(state,action) + betaR.*(((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state)))...
            %                                            + betaP.*(((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state)));
            
            policyR(state,action) = policyR(state,action) + betaR.*(((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state)));
            policyP(state,action) = policyP(state,action) + betaP.*(((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state)));

            
            % Update critic
            
            valuesR(state) = valuesR(state) + alphaR.*((max(reward,0) + gammaR.*valuesR(newstate)) - valuesR(state));
            valuesP(state) = valuesP(state) + alphaP.*((min(reward,0) + gammaP.*valuesP(newstate)) - valuesP(state));
                        
            % Update state
            
            state = newstate;
            
        end
       
        earnings(thisPlay,thisBoard) = earnings(thisPlay,thisBoard) + rewardSum;

    end
end
totEarnings = -mean(sum(earnings)); % - for minimizer
stdEarnings = std(sum(earnings));
learnCurve = sum(earnings, 2);
end