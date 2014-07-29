function [numSlips] = findSlips(id,A1,S2,A2,Re,tosslist)
subjMarkers = getSubjMarkers(id);
numSubjects = length(subjMarkers);
numSlips = zeros(numSubjects,1);
for thisSubj=1:numSubjects
    if ~any(tosslist==thisSubj)
        if thisSubj < numSubjects
            index = subjMarkers(thisSubj):(subjMarkers(thisSubj + 1) - 1);
        else
            index = subjMarkers(thisSubj):length(id);
        end

        % Go through all trials after the first one
        for i = index(2):index(end)
            % If you got a punishment..
            if (Re(i-1) < 0)
                % If you did the same thing again..
                if (A1(i-1)==A1(i) && S2(i-1)==S2(i) && A2(i-1)==A2(i))
                    % Slip!
                    numSlips(thisSubj) = numSlips(thisSubj)+1;
                end
            end
        end
    end
end

numSlips = removerows(numSlips,'ind',tosslist);
end