function [negLLs_chance] = getChanceNegLLs_3levels(numTrialsCompleted)
negLLs_chance = zeros(length(numTrialsCompleted),1);
for i = 1:length(numTrialsCompleted)
    negLLs_chance(i) = -log(.5 ^ (numTrialsCompleted(i) * 3));
end
end