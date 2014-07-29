%% debug_TDRL
% It's hard to debug internal functions such as getIndivLike using the
%   normal top-level scripts, because they're wrapped in patternsearch
% So this script is just meant to help debug those functions

% Get data from random 'participants'
numSubjects = 25;
numRounds = 125;
normed = 0;

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
[earnings, negLLs, results] = ac_sep_comb_2step(real_params,numSubjects,numRounds,'3step/3step',0,0,0);

% Parse results matrix
id = results(:,1);
A1 = results(:,2);
S2 = results(:,3);
A2 = results(:,4);
Re = results(:,5);
%% Analysis

subjMarkers = getSubjMarkers(id);
numSubjects = length(subjMarkers);

for thisSubj = 1:numSubjects
    % Get the appropriate index
    if thisSubj < length(subjMarkers)
        index = subjMarkers(thisSubj):(subjMarkers(thisSubj + 1) - 1);
    else
        index = subjMarkers(thisSubj):length(id);
    end
    
    getIndivLike_AC_3levels('ArApBrBpT',real_params(thisSubj,1:5),A1(index),S2(index),A2(index),Re(index));
end