%% Analyze Data
% This script just sets up function calls to get parameters for various
%   models

% starts = [0 0 0 0; .5 .5 5 .5; 1 1 10 1];
% bounds = [0 0 0 0; 1 1 10 1];
% [optIndivParams_ABSE_comb3] = getIndivParams_TDRL_3levels(@getIndivLike_AC_comb_3levels_v2,'ABSE',id,A1,S2,A2,S3,A3,Re,round1,normed,starts,[],[],bounds,[]);
% 
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

starts = [0 0 0 0 0 0; .5 .5 .5 5 .5 .5; 1 1 1 10 1 1];
bounds = [0 0 0 0 0 0; 1 1 1 10 1 1];
[optIndivParams_ABrBpSErEp] = getIndivParams_TDRL(@getIndivLike_AC_comb_v2,'ABrBpSErEp',id,A1,S2,A2,Re,round1,normed,starts,A,b,bounds,tosslist_lowW);

starts = [0 0 0 0 0 0 0; .5 .5 .5 .5 5 .5 .5; 1 1 1 1 10 1 1];
bounds = [0 0 0 0 0 0 0; 1 1 1 1 10 1 1];
[optIndivParams_ArApBrBpSErEp_comb3] = getIndivParams_TDRL(@getIndivLike_AC_comb_v2,'ArApBrBpSErEp',id,A1,S2,A2,Re,round1,normed,starts,A,b,bounds,tosslist_lowW);