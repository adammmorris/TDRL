%% GetPredictors
subjMarkers = getSubjMarkers(id);
numSubjects = length(subjMarkers);
numRounds = length(id);

rowsToToss = [];

choices_level1 = zeros(numRounds,1);
subjIDs = zeros(numRounds,1);
r_level1 = zeros(numRounds,1);
p_level1 = zeros(numRounds,1);

choices_level2 = zeros(numRounds,1);
r_level2 = zeros(numRounds,1);
p_level2 = zeros(numRounds,1);

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
                    if Re(thisRound-counter) >= 0
                        % Woohoo!
                        if A1(thisRound-counter) == 0
                            r_level1(thisRound) = -Re(thisRound-counter);
                        else
                            r_level1(thisRound) = Re(thisRound-counter);
                        end
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
                    if Re(thisRound-counter) < 0
                        % Woohoo!
                        if A1(thisRound-counter) == 0
                            p_level1(thisRound) = -Re(thisRound-counter);
                        else
                            p_level1(thisRound) = Re(thisRound-counter);
                        end
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
                    if S2(thisRound-counter) == S2(thisRound) && Re(thisRound-counter) >= 0
                        % Woohoo!
                        if any(A2(thisRound-counter) == [1 3])
                            r_level2(thisRound) = -Re(thisRound-counter);
                        else
                            r_level2(thisRound) = Re(thisRound-counter);
                        end
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
                    if S2(thisRound-counter) == S2(thisRound) && Re(thisRound-counter) < 0
                        % Woohoo!
                        if any(A2(thisRound-counter) == [1 3])
                            p_level2(thisRound) = -Re(thisRound-counter);
                        else
                            p_level2(thisRound) = Re(thisRound-counter);
                        end
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
r_level1 = removerows(r_level1,'ind',rowsToToss);
p_level1 = removerows(p_level1,'ind',rowsToToss);
choices_level2 = removerows(choices_level2,'ind',rowsToToss);
r_level2 = removerows(r_level2,'ind',rowsToToss);
p_level2 = removerows(p_level2,'ind',rowsToToss);

% Grand mean center
r_level1 = r_level1 - mean(r_level1);
p_level1 = p_level1 - mean(p_level1);
r_level2 = r_level2 - mean(r_level2);
p_level2 = p_level2 - mean(p_level2);

%csvwrite('test.csv',[r_level1 p_level1 r_level2 p_level2 choices_level1 choices_level2 subjIDs]);