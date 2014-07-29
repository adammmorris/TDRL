%% Make Param Plot
% This script just makes a param plot for undiff and diff parameters
subplot(3,1,1)
hist(optimalIndivParams_SARSA_undiff(:,2))
title('Undiff Alphas');
subplot(3,1,2)
hist(optimalIndivParams_SARSA_diff(:,2))
title('AlphaR');
subplot(3,1,3)
hist(optimalIndivParams_SARSA_diff(:,3))
title('AlphaP');

subplot(2,1,1);
hist(optIndivParams_ArApBT_comb_normed(:,2));
title('AlphaR');
subplot(2,1,2);
hist(optIndivParams_ArApBT_comb_normed(:,3));
title('AlphaP');