A1=A1+1;
A2=A2-2*(A2>2);
S2=S2+2;

old_id = subject; clear subject;
subjMarkers = getSubjMarkers(old_id);
numSubjects = length(subjMarkers);

id = zeros(length(old_id),1);

% Populate array (while converting to serial date #s)
for thisSubj = 1:numSubjects
    if thisSubj < length(subjMarkers)
        index = subjMarkers(thisSubj):(subjMarkers(thisSubj + 1) - 1);
    else
        index = subjMarkers(thisSubj):length(id);
    end
    
    id(index) = thisSubj;
end

finalScores = getFinalScores(score,subjMarkers);
numTrialsCompleted = getNumCompleted(id);

moral_old = moral;
moral = moral(subjMarkers);
crt_old = crt;
crt = crt(subjMarkers);