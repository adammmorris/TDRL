% Find optimal (alpha, beta*temp)
alphas = 0:.1:1;
betaR = .5;
betaP = .9;
temp = 2;

num_instances = 1000;
num_plays = 150;
boardPath = '2step/2step';

param_map_ArAp = zeros(11,11,3); % optimal(alpha,beta*temp,3) gives you value

for i=1:11
    parfor j = 1:11
        param_map_ArAp(i, j, :) = [alphas(i) alphas(j) mean(ac_sep_comb_2step([alphas(i) alphas(j) betaR betaP temp .85 .85], num_instances, num_plays, boardPath, 0, 0))];
    end
end