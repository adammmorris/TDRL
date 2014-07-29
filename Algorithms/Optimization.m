% This optimizes the TD learning algorithm over any subset of its 8
%   parameters.

options = psoptimset('UseParallel', 'always', 'CompletePoll', 'on', 'Vectorized', 'off', 'SearchMethod', {@searchlhs}, 'MeshExpansion', 1.75, 'MeshContraction', .85, 'PlotFcns',{@psplotbestf,@psplotfuncount});

x0 = [.5 .5];
lower_bound = [0 0];
upper_bound = [1 1];

[X1,Fval,ExitFlag,Output] = patternsearch(@(x) ac_sep_1p6(x, 10000), x0,[],[],[],[], lower_bound, upper_bound, [], options);