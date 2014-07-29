%% GetPredictors
subjMarkers = getSubjMarkers(id);
numSubjects = length(subjMarkers);
numRounds = length(id);

rowsToToss = [];

choices_level1 = zeros(numRounds,1);
subjIDs = zeros(numRounds,1);
rX_level1 = zeros(numRounds,1);
pX_level1 = zeros(numRounds,1);
rY_level1 = zeros(numRounds,1);
pY_level1 = zeros(numRounds,1);

choices_level2 = zeros(numRounds,1);
rX_level2 = zeros(numRounds,1);
pX_level2 = zeros(numRounds,1);
rY_level2 = zeros(numRounds,1);
pY_level2 = zeros(numRounds,1);

for thisSubj=1:numSubjects
    if thisSubj < numSubjects
        index = subjMarkers(thisSubj):(subjMarkers(thisSubj + 1) - 1);
    else
        index = subjMarkers(thisSubj):length(id);
    end
    
    if any(tosslist==thisSubj)
        rowsToToss = horzcat(rowsToToss,index);
    else
        for thisRound = index
            if round(thisRound) < practiceCutoff
                rowsToToss(end+1) = thisRound;
            else
                subjIDs(thisRound) = thisSubj;
                
                % LEVEL 1
                
                % Get lastReward_X
                found = 0;
                counter = 1;
                % Loop until you find it or you hit the beginning of that
                %   subject's rounds
                while found == 0 && (thisRound - counter) >= index(1)
                    if A1(thisRound-counter) == 0 && Re(thisRound-counter) >= 0
                        % Woohoo!
                        rX_level1(thisRound) = Re(thisRound-counter);
                        found = 1;
                    else
                        counter = counter+1;
                    end
                end
                
                % Get lastPunishment_X
                found = 0;
                counter = 1;
                % Loop until you find it or you hit the beginning of that
                %   subject's rounds
                while found == 0 && (thisRound - counter) >= index(1)
                    if A1(thisRound-counter) == 0 && Re(thisRound-counter) < 0
                        % Woohoo!
                        pX_level1(thisRound) = -Re(thisRound-counter);
                        found = 1;
                    else
                        counter = counter+1;
                    end
                end
                
                % Get lastReward_Y
                found = 0;
                counter = 1;
                % Loop until you find it or you hit the beginning of that
                %   subject's rounds
                while found == 0 && (thisRound - counter) >= index(1)
                    if A1(thisRound-counter) == 1 && Re(thisRound-counter) >= 0
                        % Woohoo!
                        rY_level1(thisRound) = Re(thisRound-counter);
                        found = 1;
                    else
                        counter = counter+1;
                    end
                end
                
                % Get lastPunishment_Y
                found = 0;
                counter = 1;
                % Loop until you find it or you hit the beginning of that
                %   subject's rounds
                while found == 0 && (thisRound - counter) >= index(1)
                    if A1(thisRound-counter) == 1 && Re(thisRound-counter) < 0
                        % Woohoo!
                        pY_level1(thisRound) = -Re(thisRound-counter);
                        found = 1;
                    else
                        counter = counter+1;
                    end
                end
                
                choices_level1(thisRound) = A1(thisRound);
                
                % LEVEL 2
                
                % Get lastReward_X
                % Last reward you got from choosing 0 in S2
                found = 0;
                counter = 1;
                % Loop until you find it or you hit the beginning of that
                %   subject's rounds
                while found == 0 && (thisRound - counter) >= index(1)
                    if S2(thisRound-counter) == S2(thisRound) && any(A2(thisRound-counter) == [1 3]) && Re(thisRound-counter) >= 0
                        % Woohoo!
                        rX_level2(thisRound) = Re(thisRound-counter);
                        found = 1;
                    else
                        counter = counter+1;
                    end
                end
                
                % Get lastPunishment_X
                found = 0;
                counter = 1;
                % Loop until you find it or you hit the beginning of that
                %   subject's rounds
                while found == 0 && (thisRound - counter) >= index(1)
                    if S2(thisRound-counter) == S2(thisRound) && any(A2(thisRound-counter) == [1 3]) && Re(thisRound-counter) < 0
                        % Woohoo!
                        pX_level2(thisRound) = -Re(thisRound-counter);
                        found = 1;
                    else
                        counter = counter+1;
                    end
                end
                
                % Get lastReward_Y
                found = 0;
                counter = 1;
                % Loop until you find it or you hit the beginning of that
                %   subject's rounds
                while found == 0 && (thisRound - counter) >= index(1)
                    if S2(thisRound-counter) == S2(thisRound) && any(A2(thisRound-counter) == [2 4]) && Re(thisRound-counter) >= 0
                        % Woohoo!
                        rY_level2(thisRound) = Re(thisRound-counter);
                        found = 1;
                    else
                        counter = counter+1;
                    end
                end
                
                % Get lastPunishment_Y
                found = 0;
                counter = 1;
                % Loop until you find it or you hit the beginning of that
                %   subject's rounds
                while found == 0 && (thisRound - counter) >= index(1)
                    if S2(thisRound-counter) == S2(thisRound) && any(A2(thisRound-counter) == [2 4]) && Re(thisRound-counter) < 0
                        % Woohoo!
                        pY_level2(thisRound) = -Re(thisRound-counter);
                        found = 1;
                    else
                        counter = counter+1;
                    end
                end
                
                choices_level2(thisRound) = A2(thisRound)-(1+2*(S2(thisRound)==1));
            end   
        end
    end
end

% Remove bad rows
subjIDs = removerows(subjIDs,'ind',rowsToToss);
choices_level1 = removerows(choices_level1,'ind',rowsToToss);
rX_level1 = removerows(rX_level1,'ind',rowsToToss);
pX_level1 = removerows(pX_level1,'ind',rowsToToss);
rY_level1 = removerows(rY_level1,'ind',rowsToToss);
pY_level1 = removerows(pY_level1,'ind',rowsToToss);
choices_level2 = removerows(choices_level2,'ind',rowsToToss);
rX_level2 = removerows(rX_level2,'ind',rowsToToss);
pX_level2 = removerows(pX_level2,'ind',rowsToToss);
rY_level2 = removerows(rY_level2,'ind',rowsToToss);
pY_level2 = removerows(pY_level2,'ind',rowsToToss);

% Grand mean center
rX_level1 = rX_level1 - mean(rX_level1);
pX_level1 = pX_level1 - mean(pX_level1);
rY_level1 = rY_level1 - mean(rY_level1);
pY_level1 = pY_level1 - mean(pY_level1);
rX_level2 = rX_level2 - mean(rX_level2);
pX_level2 = pX_level2 - mean(pX_level2);
rY_level2 = rY_level2 - mean(rY_level2);
pY_level2 = pY_level2 - mean(pY_level2);

%csvwrite('test.csv',[lastReward_X lastPunishment_X lastReward_Y lastPunishment_Y choices_level1 subjIDs]);