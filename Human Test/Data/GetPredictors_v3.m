%% GetPredictors
subjMarkers = getSubjMarkers(id);
numSubjects = length(subjMarkers);
numRounds = length(id);

rowsToToss = [];

subjIDs = zeros(numRounds,1);

stay = zeros(numRounds,1);
common = zeros(numRounds,1);
% stay2 = zeros(numRounds,1);
% common2 = zeros(numRounds,1);
r = zeros(numRounds,1);

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
            if round1(thisRound) <= practiceCutoff % why <=? because we can't use the first real row
                rowsToToss(end+1) = thisRound;
            else
                subjIDs(thisRound) = thisSubj;
                r(thisRound) = Re(thisRound-1);
                common(thisRound) = (A1(thisRound-1)==1 & any(S3(thisRound-1)==[4 5])) | (A1(thisRound-1)==2 & any(S3(thisRound-1)==[6 7])); % +1/-1
                %if common(thisRound)==0, common(thisRound)=-1; end
                stay(thisRound) = A1(thisRound)==A1(thisRound-1); % 0/1
                
                % LEVEL 2
                % Gotta find last time we were in S2
%                 found = 0;
%                 counter = 1;
%                 % Loop until you find it or you hit the beginning of that
%                 %   subject's rounds
%                 while found == 0 && (thisRound - counter) >= index(1)
%                     if S2(thisRound-counter) == S2(thisRound)
%                         % Woohoo!
%                         if Re(thisRound-counter) >= 0
%                             r2(thisRound) = Re(thisRound-counter);
%                         else
%                             p2(thisRound) = Re(thisRound-counter);
%                         end
%                         stay2(thisRound) = A2(thisRound)==A2(thisRound-counter);
%                         found = 1;
%                     else
%                         counter = counter+1;
%                     end
%                 end
            end
        end
    end
end

% Remove bad rows
subjIDs = removerows(subjIDs,'ind',rowsToToss);
stay = removerows(stay,'ind',rowsToToss);
r = removerows(r,'ind',rowsToToss);
% p = removerows(p,'ind',rowsToToss);
% stay2 = removerows(stay2,'ind',rowsToToss);
% r2 = removerows(r2,'ind',rowsToToss);
% p2 = removerows(p2,'ind',rowsToToss);
common = removerows(common,'ind',rowsToToss);
% stroop = removerows(stroop,'ind',rowsToToss);

% Grand mean center
% r = r-mean(r);
% p = p-mean(p);
% r2 = r2-mean(r2);
% p2 = p2-mean(p2);
% stroop = stroop-mean(stroop);

%csvwrite('test.csv',[r p common stroop stay subjIDs]);