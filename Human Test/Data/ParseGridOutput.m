%% ParseGridOutput

path = '/home/amm4/git/TDRL/Human Test/Data/Analysis/Real Data v2/Take 2/ArApBrBpSE/';
numParams = 6;
numSubjects = length(subjMarkers);
params_ArApBrBpSE = zeros(numSubjects,numParams+2);

for i = 1:length(subjMarkers)
    params_ArApBrBpSE(i,:) = csvread([path 'Params_Subj' num2str(i) '.txt']);
end