%% Analyze Data
% This script just sets up function calls to get parameters for various
%   models

function AnalyzeData(datapath,tasknum)

% load shit
load(datapath);

% tasknum is from 1 to numSubjects
numSubjects = length(subjMarkers);
if (tasknum < 1 || tasknum > numSubjects)
    error('tasknum must be between 1 and numSubjects');
end

comb = 1;
temp = .5;
gamma = .85;

tosslist = [];

numStarts = 11;

actions = [A1 A2];
states = [ones(length(S2),1) S2];
rewards = [zeros(length(Re),1) Re];

% ABSE
bounds = [0 0 0 0; 1 1 10 1];
model = @(x,actions,states,rewards,roundNum,comb) getIndivLike_AC([x(1) x(1) x(2) x(2) temp x(3) x(4) x(4) gamma gamma],actions,states,rewards,roundNum,comb);
optParams = getIndivParams_TDRL(model,id,actions,states,rewards,round1,comb,[],[],numStarts,bounds,tasknum);

% % starts = [0 0 0 0 0; .5 .5 5 .5 .5; 1 1 10 1 1];
% % bounds = [0 0 0 0 0; 1 1 10 1 1];
% % [optIndivParams_ABSErEp_comb] = getIndivParams_TDRL_3levels(@getIndivLike_AC_comb_3levels,'ABSErEp',id,A1,S2,A2,S3,A3,Re,round1,normed,starts,A,b,bounds,tosslist_ABS_comb_loW);
% % 
% % starts = [0 0 0 0 0 0; .5 .5 .5 5 .5 .5; 1 1 1 10 1 1];
% % bounds = [0 0 0 0 0 0; 1 1 1 10 1 1];
% % [optIndivParams_ArApBSErEp_comb] = getIndivParams_TDRL_3levels(@getIndivLike_AC_comb_3levels,'ArApBSErEp',id,A1,S2,A2,S3,A3,Re,round1,normed,starts,A,b,bounds,tosslist_ABS_comb_loW);
% 
% starts = [0 0 0 0 0; .5 .5 .5 5 .5; 1 1 1 10 1];
% bounds = [0 0 0 0 0; 1 1 1 10 1];
% [optIndivParams_ArApBSE_comb3] = getIndivParams_TDRL_3levels(@getIndivLike_AC_comb_3levels_v2,'ArApBSE',id,A1,S2,A2,S3,A3,Re,round1,normed,starts,A,b,bounds,tosslist_ABSE_comb2_loW);

% starts = [0 0 0 0 0 0; .5 .5 .5 5 .5 .5; 1 1 1 10 1 1]; bounds = [0 0 0 0
% 0 0; 1 1 1 10 1 1]; [optIndivParams_ABrBpSErEp] =
% getIndivParams_TDRL(@getIndivLike_AC_comb_v2,'ABrBpSErEp',id,A1,S2,A2,Re,round1,normed,starts,A,b,bounds,tosslist_lowW);
% 
% starts = [0 0 0 0 0 0 0; .5 .5 .5 .5 5 .5 .5; 1 1 1 1 10 1 1]; bounds =
% [0 0 0 0 0 0 0; 1 1 1 1 10 1 1]; [optIndivParams_ArApBrBpSErEp_comb3] =
% getIndivParams_TDRL(@getIndivLike_AC_comb_v2,'ArApBrBpSErEp',id,A1,S2,A2,Re,round1,normed,starts,A,b,bounds,tosslist_lowW);

name = [fileparts(datapath) '/Params_Subj' num2str(tasknum) '.txt'];
csvwrite(name,optParams);
end