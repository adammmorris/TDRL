%% GetPredictors
subjMarkers = getSubjMarkers(id);
numSubjects = length(subjMarkers);
numRounds = length(id);

rowsToToss = [];
subjToToss = [];

tosslist = [];
practiceCutoff = 25;

subjIDs = zeros(numRounds,1);

% Level 1
stay = zeros(numRounds,1);
common = zeros(numRounds,1);
reinf = zeros(numRounds,1);
rp = zeros(numRounds,1); % 0/1 dummy variable - 0 for punishments, 1 for rewards

% DVs
moral_touse = [];
crt_touse = [];

% Level 2 - only do trials in which you end up in the same state2 as last
% trial
% stay2 = [];
% common2 = [];
% reinf2 = [];
% rp2 = [];
% subjIDs2 = [];

for thisSubj=1:numSubjects
    if thisSubj < numSubjects
        index = subjMarkers(thisSubj):(subjMarkers(thisSubj + 1) - 1);
    else
        index = subjMarkers(thisSubj):length(id);
    end
    
    % Basic exclusion here
    if numTrialsCompleted(thisSubj) < 100 || numTrialsCompleted(thisSubj) > 150 || isnan(moral(thisSubj)) || isnan(crt(thisSubj))
        rowsToToss = horzcat(rowsToToss,index);
        subjToToss(end+1) = thisSubj;
    else
        % DVs
        moral_touse(end+1) = moral2(thisSubj);
        crt_touse(end+1) = crt(thisSubj);
        
        for thisRound = index
            if round1(thisRound) <= practiceCutoff % why <=? because we can't use the first real row
                rowsToToss(end+1) = thisRound;
                subjToToss(end+1) = thisSubj;
            else
                subjIDs(thisRound) = thisSubj;
                
                % Level 1
                reinf(thisRound) = Re(thisRound-1); % not mean centering this
                rp(thisRound) = reinf(thisRound) >= 0;
                %common(thisRound) = (A1(thisRound-1)==1 & any(S3(thisRound-1)==[4 5])) | (A1(thisRound-1)==2 & any(S3(thisRound-1)==[6 7])); % +1/-1
                common(thisRound) = (A1(thisRound-1)==(S2(thisRound-1)-1))*2-1; % +1/-1
                stay(thisRound) = A1(thisRound)==A1(thisRound-1); % 0/1
               
                
                % Level 2
                
                % Were we in the same state last trial?
%                 if S2(thisRound-1)==S2(thisRound)
%                     reinf2(end+1,1)=reinf(thisRound);
%                     rp2(end+1,1)=rp(thisRound);
%                     common2(end+1,1)=common(thisRound);
%                     stay2(end+1,1)=stay(thisRound);
%                     subjIDs2(end+1,1)=thisSubj;
%                 end
                
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
reinf = removerows(reinf,'ind',rowsToToss);
rp = removerows(rp,'ind',rowsToToss);
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
% p2 = p2-mean(p2);x
% stroop = stroop-mean(stroop);

%% Write to CSV
csvwrite('Predictors.csv',[reinf rp common stay subjIDs]);
%csvwrite('Predictors_lev2.csv',[reinf2 rp2 common2 stay2 subjIDs2]);
csvwrite('DVs.csv',[crt_touse' moral_touse']);