% Fiery's Separated Q-Learning Algorithm
% x = [gammaR,alphaR,gammaP,alphaP,tempR,tempP];

function [totEarnings, stdEarnings, learnCurve] = q_sep_1p1(x)

% SET PARAMETERS

gammaR = x(1);
alphaR = x(2);
gammaP = x(3); 
alphaP = x(4);
tempR = x(5);
tempP = x(6);

% Build board
%height = 10;
%width = 10;
% boardSize = prod([height width]);
boardSize = 8;

% Environment parameters

numPlays = 50; % number of times the board is played
% numMoves = height-1;
numMoves = 2; % The 3rd move (state 8) is the terminal state
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
    
    % Set up Q array
    
    policyR = policy;
    policyP = policy;
        
    for thisPlay = 1:numPlays
        
        %state = starts(thisBoard);
        state = 1;
        
        rewardSum = 0;
        
        for thisMove = 1:numMoves;
           
            % SELECT ACTION
            
            % Determine softmax probabilities.
            % This gives us a normalized row vector where probs(action_i) = 
            %   exp(tempR .* policyR(state, action_i) + tempP .* policyP(state, action_i))
            probs = exp(tempR .* policyR(state, :) + tempP .* policyP(state, :)) ./ nansum(exp(tempR .* policyR(state, :) + tempP .* policyP(state, :)));
            
            % 0 out any NaNs.
            probs(isnan(probs)) = zeros(sum(isnan(probs)),1);
            
            % Choose action based on probabilities.
            action = 1 + (rand() < probs(2)); % This works b/c we only have two actions
            
            % MOVE
            
            newstate = transitions(state,action,thisBoard);
            reward = boards(newstate,thisBoard);
            rewardSum = rewardSum + reward;
            
            % UPDATE
            
            [~, maxActionR] = max(policyR(newstate,:));
            [~, maxActionP] = max(policyR(newstate,:));
            
            % Why does this work?
            % B/c it updates rewards temporally (i.e. from future-state
            %   info) even when we only got a punishment on this move
            % We still want to keep those 2 temporal chains updating every
            %   move
            policyR(state,action) = policyR(state,action) + alphaR.*(((max(reward,0) + gammaR.*policyR(newstate,maxActionR)) - policyR(state,action)));
            policyP(state,action) = policyP(state,action) + alphaP.*(((min(reward,0) + gammaP.*policyP(newstate,maxActionP)) - policyP(state,action)));
            
            state = newstate;
            
        end
               
        earnings(thisPlay,thisBoard) = earnings(thisPlay,thisBoard) + rewardSum;

    end
end
totEarnings = mean(sum(earnings)); % Why was this negative?
stdEarnings = std(sum(earnings));
learnCurve = sum(earnings');
end