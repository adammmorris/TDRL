function [totEarnings, stdEarnings, learnCurve] = q_sep_1p1(x)

%[gammaR,alphaR,betaR,gammaP,alphaP,betaP,tempR,tempP] = x;
gammaR = x(1);
alphaR = x(2);
gammaP = x(3);
alphaP = x(4);
tempR = x(5);
tempP = x(6);

% Agent parameters

% gamma = .8;
% alpha = .5;
% temp = 1;


% Build board
%height = 10;
%width = 10;
% boardSize = prod([height width]);
boardSize = 8;

% Environment parameters

numPlays = 50; % number of times the board is played
% numMoves = height-1;
numMoves = 2;
numBoards = 10000;
numActions = 2;

load /Users/fiery/Documents/Matlab/badgood/2sp3_boards.mat
% starts = randsample(1:width,numBoards,true); % starting location for agent

% Set up state transition matrix

% transitions = zeros(boardSize,numActions); % left, right, up, down
% for i = 1:boardSize
%         transitions(i,1:numActions) = randsample(width+ceil(i./width),numActions)';
% end

load /Users/fiery/Documents/Matlab/badgood/2s_transitions.mat

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
    
    % Set up Q array
    
    policyR = policy;
    policyP = policy;
        
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
            
            % Update
            
            [~, maxActionR] = max(policyR(newstate,:));
            [~, maxActionP] = max(policyR(newstate,:));
            
            policyR(state,action) = policyR(state,action) + alphaR.*(((max(reward,0) + gammaR.*policyR(newstate,maxActionR)) - policyR(state,action)));
            policyP(state,action) = policyP(state,action) + alphaP.*(((min(reward,0) + gammaP.*policyP(newstate,maxActionP)) - policyP(state,action)));

            % Update state
            
            state = newstate;
            
        end
                
        % Terminal State
        
        probs = exp(tempR.*policyR(state,:)+tempP.*policyP(state,:))./nansum(exp(tempR.*policyR(state,:)+tempP.*policyP(state,:)));
        probs(isnan(probs)) = zeros(sum(isnan(probs)),1);
        action = 1 + (rand() < probs(2));
        
        % Update

        policyR(state,action) = policyR(state,action) + alphaR.*(0 - policyR(state,action));
        policyP(state,action) = policyP(state,action) + alphaP.*(0 - policyP(state,action));

        earnings(thisPlay,thisBoard) = earnings(thisPlay,thisBoard) + rewardSum;

    end
end
totEarnings = -mean(sum(earnings));
stdEarnings = std(sum(earnings));
learnCurve = sum(earnings');
end