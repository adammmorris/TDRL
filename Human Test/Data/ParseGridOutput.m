%% ParseGridOutput

path = '/home/amm4/git/TDRL/Dawes 2-Step Task/Take3/ABSE/';
numParams = 4;
numSubjects = length(subjMarkers);
params_ABSE = zeros(numSubjects,numParams+2);

for i = 1:length(subjMarkers)
    params_ABSE(i,:) = csvread([path 'Params_Subj' num2str(i) '.txt']);
end