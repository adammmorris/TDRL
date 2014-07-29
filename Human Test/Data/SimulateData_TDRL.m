%% Collect simulated data

%% Let's do combined stuff first

% Get data from random 'participants'
numSubjects = 50;
numRounds = 125;
normed = 0;
magic = 0;

% Set up their parameters
real_params = zeros(numSubjects,7);
for thisSubj = 1:numSubjects
    alphaR = rand();
    alphaP = rand();
    betaR = rand();
    betaP = rand();
    temp = rand()*1.5; % from 0 to 1.5
    gamma = .85;
    real_params(thisSubj,:) = [alphaR alphaP betaR betaP temp gamma gamma]; % betaR = betaP & gammaR = gammaP = .85
end

% Run them all!
[earnings, negLLs, results] = ac_sep_2step(real_params,numSubjects,numRounds,'2step/2step',0,0,0);

% Parse results matrix
id = results(:,1);
A1 = results(:,2);
S2 = results(:,3);
A2 = results(:,4);
Re = results(:,5);

% Analyze data
A = [];
b = [];

% ABT
starts = [0 0 .5; .5 .5 1; 1 1 1.5];
bounds = [0 0 0; 1 1 2];
%model = @(in_A1,in_S2,in_A2,in_Re,in_normed) getIndivLike_AC_comb_v5('ArApBrBpT',in_A1,in_S2,in_A2,in_Re,in_normed);
[sim_optimalIndivParams_ABT] = getIndivParams_TDRL(@getIndivLike_AC,'ABT',id,A1,S2,A2,Re,normed,starts,A,b,bounds,[]);

% ArApBrBpT
starts = [0 0 0 0 .5; .5 .5 .5 .5 1; 1 1 1 1 1.5];
bounds = [0 0 0 0 0; 1 1 1 1 2];
%model = @(in_A1,in_S2,in_A2,in_Re,in_normed) getIndivLike_AC_comb_v5('ArApBrBpT',in_A1,in_S2,in_A2,in_Re,in_normed);
[sim_optimalIndivParams_ArApBrBpT] = getIndivParams_TDRL(@getIndivLike_AC,'ArApBrBpT',id,A1,S2,A2,Re,normed,starts,A,b,bounds,[]);


% % Model 1: ABT_Combined
% starts = [0 0 .5; .5 .5 1; 1 1 1.5];
% bounds = [0 0 0; 1 1 2];
% %model = @(in_A1,in_S2,in_A2,in_Re,in_normed) getIndivLike_AC_comb_v5('ABT',in_A1,in_S2,in_A2,in_Re,in_normed);
% [sim_optimalIndivParams_ABT_combined] = getIndivParams_TDRL(@getIndivLike_AC_comb_v5,'ABT',id,A1,S2,A2,Re,starts,A,b,bounds,[]);

% % Model 2: ArApBT_Combined
% starts = [0 0 0 .5; .5 .5 .5 1; 1 1 1 1.5];
% bounds = [0 0 0 0; 1 1 1 2];
% [sim_optimalIndivParams_ArApBT_combined] = getIndivParams_TDRL(model,id,A1,S2,A2,Re,starts,A,b,bounds,[]);
% 
% % Model 3: ABrBpT_Combined
% starts = [0 0 0 .5; .5 .5 .5 1; 1 1 1 1.5];
% bounds = [0 0 0 0; 1 1 1 2];
% [sim_optimalIndivParams_ABrBpT_combined] = getIndivParams_TDRL(model,id,A1,S2,A2,Re,starts,A,b,bounds,[]);

% Model 4: ArApBrBpT_Combined
%starts = [0 0 0 0 .5; .5 .5 .5 .5 1; 1 1 1 1 1.5];
%bounds = [0 0 0 0 0; 1 1 1 1 2];
%model = @(in_A1,in_S2,in_A2,in_Re,in_normed) getIndivLike_AC_comb_v5('ArApBrBpT',in_A1,in_S2,in_A2,in_Re,in_normed);
%[sim_optimalIndivParams_ArApBrBpT_combined] = getIndivParams_TDRL(@getIndivLike_AC_comb_v5,'ArApBrBpT',id,A1,S2,A2,Re,normed,starts,A,b,bounds,[]);

%% Now let's do some real optimizations
to_test = 0:.1:1;
num_to_test = length(to_test);
num_instances = 1000;
num_plays = 150;

normed = 2;

realBeta = .47;
realTemp = 2.1;

t1 = cputime;

% #1: 2 step, deterministic
% Using real mean parameters
fvals_alphas_1 = zeros(num_to_test, num_to_test, 3);
stochastic = 0;

for i = 1 : num_to_test
    parfor j = 1 : num_to_test
        fvals_alphas_1(i, j, :) = [to_test(i) to_test(j) mean(ac_sep_comb_2step([to_test(i) to_test(j) realBeta realBeta realTemp .85 .85], num_instances, num_plays, '2step/2step', stochastic, normed))];
    end
end

e1 = cputime - t1;

% Using random values

% #2: 2 step, deterministic
% Using random values
fvals_alphas_2 = zeros(num_to_test, num_to_test, 3);
stochastic = 0;

t2 = cputime;

for i = 1 : num_to_test
    parfor j = 1 : num_to_test
        randParams = rand(num_instances,2);
        randParams = [repmat([to_test(i) to_test(j)],num_instances,1) randParams(:,1) randParams(:,1) randParams(:,2).*1.5 repmat([.85 .85],num_instances,1)];
        fvals_alphas_2(i,j,:) = [to_test(i) to_test(j) mean(ac_sep_comb_2step(randParams,num_instances,num_plays,'2step/2step',stochastic,normed))];
    end
end

e2 = cputime - t2;

% #3: 2-step, deterministic
% Using optimal beta*temp
to_test_temp = linspace(0,5,num_to_test);
temp = zeros(num_to_test,num_to_test,3);
stochastic = 0;

for i = 1:num_to_test
    parfor j = 1:num_to_test
        temp(i,j,:) = [to_test(i) to_test(j)*to_test_temp(j) mean(ac_sep_comb_2step([to_test(i) to_test(i) to_test(j) to_test(j) to_test_temp(j) .85 .85],num_instances,num_plays,'2step/2step',stochastic,normed))];
    end
end

bestBeta = 1;
bestTemp = 5;

fvals_alphas_3 = zeros(num_to_test, num_to_test, 3);
stochastic = 0;

for i = 1 : num_to_test
    parfor j = 1 : num_to_test
        fvals_alphas_3(i, j, :) = [to_test(i) to_test(j) mean(ac_sep_comb_2step([to_test(i) to_test(j) bestBeta bestBeta bestTemp .85 .85], num_instances, num_plays, '2step/2step', stochastic, normed))];
    end
end

% #4: 2-step, stochastic
% Using optimal beta*temp
fvals_alphas_4 = zeros(num_to_test, num_to_test, 3);
stochastic = 1;
board = '2step/2step';

for i = 1 : num_to_test
    parfor j = 1 : num_to_test
        fvals_alphas_4(i, j, :) = [to_test(i) to_test(j) mean(ac_sep_comb_2step([to_test(i) to_test(j) bestBeta bestBeta bestTemp .85 .85], num_instances, num_plays, board, stochastic, normed))];
    end
end

% #5: 3-step, deterministic
% Using optimal beta*temp
fvals_alphas_5 = zeros(num_to_test, num_to_test, 3);
stochastic = 0;
board = '3step/3step';

for i = 1 : num_to_test
    parfor j = 1 : num_to_test
        fvals_alphas_5(i, j, :) = [to_test(i) to_test(j) mean(ac_sep_comb_2step([to_test(i) to_test(j) bestBeta bestBeta bestTemp .85 .85], num_instances, num_plays, board, stochastic, normed))];
    end
end