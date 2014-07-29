%% softmax_TDRL
% This function takes in a temperature & policy row, and outputs the
%   appropriate probability of each action
% I'm consolidating this into a function just to standardize across scripts

%% Inputs
% temp: the temperature
% policy: should be one row, with numActions columns
% normed: set to 0 if you want unnormed, set to 1 if you want to norm

function [probs] = softmax_TDRL(temp,policy,normed)
if normed == 1
    probs_numerator = exp(temp .* (policy ./ sum(abs(policy))));
else
    probs_numerator = exp(temp .* policy);
end

% If they're all zeros (can happen if temp is high & policy
%   values are incredibly low), just make them all equally
%   likely
if ~any(probs_numerator)
    probs_numerator = ones(length(probs_numerator),1);
end

probs_denominator = sum(probs_numerator);

% Clean out infinities (change them to realmax's).
probs_numerator(isinf(probs_numerator)) = realmax .* ones(sum(isinf(probs_numerator)), 1);
probs_denominator(isinf(probs_denominator)) = realmax .* ones(sum(isinf(probs_denominator)), 1);

probs = probs_numerator ./ probs_denominator;
end