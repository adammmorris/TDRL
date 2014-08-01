%% Analyze Data
% This script just sets up function calls to get parameters for various
%   models

function AnalyzeData(datapath,savepath,comb,tasknum)

% load shit
load(datapath);

% tasknum is from 1 to numSubjects
numSubjects = length(subjMarkers);
if (tasknum < 1 || tasknum > numSubjects)
    error('tasknum must be between 1 and numSubjects');
end

temp = .5;
gamma = .85;

numStarts = 11;

actions = [A1 A2];
states = [ones(length(S2),1) S2];
rewards = [zeros(length(Re),1) Re];

% ABSE
% bounds = [0 0 0 0; 1 1 10 1];
% model = @(x,actions,states,rewards,roundNum,comb) getIndivLike_AC([x(1) x(1) x(2) x(2) temp x(3) x(4) x(4) gamma gamma],actions,states,rewards,roundNum,comb);
% optParams = getIndivParams_TDRL(model,id,actions,states,rewards,round1,comb,[],[],numStarts,bounds,tasknum);

% ABrBpSErEp
% bounds = [0 0 0 0 0 0; 1 1 1 10 1 1];
% model = @(x,actions,states,rewards,roundNum,comb) getIndivLike_AC([x(1) x(1) x(2) x(3) temp x(4) x(5) x(6) gamma gamma],actions,states,rewards,roundNum,comb);
% optParams = getIndivParams_TDRL(model,id,actions,states,rewards,round1,comb,[],[],numStarts,bounds,tasknum);

% ArApBrBpSE
bounds = [0 0 0 0 0 0; 1 1 1 1 10 1];
model = @(x,actions,states,rewards,roundNum,comb) getIndivLike_AC([x(1) x(2) x(3) x(4) temp x(5) x(6) x(6) gamma gamma],actions,states,rewards,roundNum,comb);
optParams = getIndivParams_TDRL(model,id,actions,states,rewards,round1,comb,[],[],numStarts,bounds,tasknum);

% ArApBrBpSErEp
% bounds = [0 0 0 0 0 0 0; 1 1 1 1 10 1 1];
% model = @(x,actions,states,rewards,roundNum,comb) getIndivLike_AC([x(1) x(2) x(3) x(4) temp x(5) x(6) x(7) gamma gamma],actions,states,rewards,roundNum,comb);
% optParams = getIndivParams_TDRL(model,id,actions,states,rewards,round1,comb,[],[],numStarts,bounds,tasknum);

name = [savepath '/Params_Subj' num2str(tasknum) '.txt'];
csvwrite(name,optParams);
end