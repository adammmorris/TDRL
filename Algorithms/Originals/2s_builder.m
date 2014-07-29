t = ones(8,2);
t(1,:) = [2 3];
t(2,:) = [4 5];
t(3,:) = [6 7];
t(4,:) = [8 8];
t(5,:) = [8 8];
t(6,:) = [8 8];
t(7,:) = [8 8];

transitions = zeros(8,2,1000);

for i = 1:10000
    transitions(:,:,i) = t;
end

save('badgood/2s_transitions.mat','transitions')


b = [0 ; 0 ; 0 ; 1 ; -1 ; 0 ; 0 ; 0];
boards = repmat(b,1,1000);
save('badgood/2s_boards.mat','boards')

b = [0 ; 0 ; 0 ; 1 ; -1 ; 2 ; -2 ; 0];
boards = repmat(b,1,1000);
save('badgood/2sp1_boards.mat','boards')

b = [0 ; 0 ; 0 ; 1 ; -1 ; 2 ; -2];
for i = 1:10000
    boards(:,i) = randsample(b,7);
end
boards(8,:) = zeros(1,10000);
save('badgood/2sp2_boards.mat','boards')

b = [1 ; -1 ; 2 ; -2];
boards = zeros(8,10000);
for i = 1:10000
    boards(4:7,i) = randsample(b,4);
end
save('badgood/2sp3_boards.mat','boards')