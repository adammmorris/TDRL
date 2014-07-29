% Optimize just the punishment system, given optimal rewards

range = 0:.1:1;
results = zeros(length(range),length(range));

for i = 1:length(range)
    parfor j = 1:length(range)
        results(i,j) = ac_sep_twosteptask([.4, range(i), 1, sqrt(range(j)), 1, sqrt(range(j))], 1000, 150, 'Board13/Board13', 0, 0, [0 0 0 0 0 0]);
    end
end

surf(range,range,results'); % the ' is because matlab is weird and does x=columns, y=rows for surf..