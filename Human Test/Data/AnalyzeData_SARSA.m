% Q-learning model
%starts = [.25 .25 .75 .25 .25; .75 .75 1.5 .75 .75];
starts = [0 .5; .5 1; 1 1.5];
bounds = [0 0; 1 2];
[optimalIndivParams_Q] = getIndivParams_TDRL(@getIndivLikelihood_Q,id,A1,S2,A2,Re,starts,[],[],bounds,tosslist);

% SARSA undiff model
%starts = [.25 .25 .75 .25 .25; .75 .75 1.5 .75 .75];
starts = [0 0 0 .5; .5 .5 .5 1; 1 1 1 1.5];
bounds = [0 0 0 0; 1 1 1 2];
[optimalIndivParams_SARSA_undiff] = getIndivParams_TDRL(@getIndivLikelihood_Sarsa_Undiff,id_noprac,A1_noprac,S2_noprac,A2_noprac,Re_noprac,starts,[],[],bounds,tosslist);

% SARSA diff model
%starts = [.25 .25 .75 .25 .25; .75 .75 1.5 .75 .75];
starts = [0 0 0 0 0 .5; .5 .5 .5 .5 .5 1; 1 1 1 1 1 1.5];
bounds = [0 0 0 0 0 0; 1 1 1 1 1 2];
[optimalIndivParams_SARSA_diff] = getIndivParams_TDRL(@getIndivLikelihood_Sarsa_Diff,id_noprac,A1_noprac,S2_noprac,A2_noprac,Re_noprac,starts,[],[],bounds,tosslist);