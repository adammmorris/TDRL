% this should correspond to the model Sam used for the fmri. two learning rates, two betas, eligibility trace, etc.`

function [results] = maxliks(m3)

numSubs = max(m3(:,1));
results = zeros(numSubs,7);

state2 = 3;
act2 = 4;
act1 = 2;
reward = 5;
round = 9;

matlabpool('sixcore', 6)

parfor j = 1:numSubs
    c1 = m3(m3(:,1) == j,act1) + 1;
    s = m3(m3(:,1) == j,state2) + 2;
    c2 = m3(m3(:,1) == j,act2);
    c2(c2 > 2) = c2(c2 > 2) - 2;
    r = m3(m3(:,1) == j,reward);
    k = m3(m3(:,1) == j,round);
    
    %options = psoptimset('CompleteSearch','on','SearchMethod',{@searchlhs},'UseParallel','Never');    
    %[max_params, lik, ~] = patternsearch(@(params) newtasklik_fc(params,c1,s,c2,r,k),[1 .5 .5 .6 1 .5],[],[],[],[],[0 0 0 0 0 0],[4 1 1 1 4 1], options);
    
    [max_params, lik, ~] = fmincon(@(params) newtasklik_fc(params,c1,s,c2,r,k),[1 .5 .5 .6 1 .5],[],[],[],[],[0 0 0 0 0 0],[4 1 1 1 4 1]);
    
    %ms = MultiStart;
    %opts = optimset('Algorithm','interior-point');
    %minfunc = @(params) newtasklik_fc(params,c1,s,c2,r,k);
    %problem = createOptimProblem('fmincon','x0',[1 .5 .5 .6 1 .5],'objective',minfunc,'lb',[0 0 0 0 0 0],'ub',[4 1 1 1 4 1],'options',opts);
    %[max_params, lik, ~, ~, ~] = run(ms,problem,50);
    
    results(j,:) = cat(2,max_params,lik);
    
end

matlabpool close

function [lik] = newtasklik_fc(params,c1,s,c2,r,k)

    beta1 = params(1); % model-based temp
    %beta2 = params(7); % model-free temp
    lr1 = params(2); % model-free alpha for choice 1 update
    lr2 = params(3); % model-free alpha for cohice 2 update
    e = params(4); % eligability trace
    ps = params(5); % stay bonus
    w = params(6); % a weighting parameter between model-based and model-free choice

    %beta1 = 1; % model-based temp
    %beta2 = params(7); % model-free temp
    %lr1 = 1; % model-free alpha for choice 1 update
    %lr2 = 1; % model-free alpha for cohice 2 update
    %e = 1; % eligability trace
    %ps = params(5); % stay bonus
    %w = params(6); % a weighting parameter between model-based and model-free choice
    
    Q = zeros(3,2);
    Qm = zeros(3,2);
    Tcounts = [1 1; 1 1];
    T = [.5 .5; .5 .5];
    lik1 = 0;
    %lik2 = 0;

    prevc = 0;

    for i = 1:length(c1)

        if k(i) < 26

            Tcounts(s(i)-1,c1(i)) = Tcounts(s(i)-1,c1(i)) + 1;

            T = Tcounts./repmat(sum(Tcounts),2,1); 

        else

            if (c1(i))

                % Model Based

                Qm(1,:) = T' * max(Qm(2:3,:),[],2);

                weff = w;

                Qd = weff * Qm(1,:)' + (1-weff) * Q(1,:)';
                if prevc
                    Qd(prevc) = Qd(prevc) + ps;
                end
                
                if i > 75
                    lik1 = lik1 + beta1 * Qd(c1(i)) - log(sum(exp(beta1 * Qd)));
                end
                
                Tcounts(s(i)-1,c1(i)) = Tcounts(s(i)-1,c1(i)) + 1;

                T = Tcounts./repmat(sum(Tcounts),2,1);

                % Model Free

                if (c2(i))
                    delta = Q(s(i),c2(i)) - Q(1,c1(i));
                else
                    delta = max(Q(s(i),:)) - Q(1,c1(i));
                end

                Q(1,c1(i)) = Q(1,c1(i)) + lr1 * delta;

                if (c2(i))
                    %lik2 = lik2 + beta2 * Q(s(i),c2(i)) - log(sum(exp(beta2 * Q(s(i),:))));
                    delta = r(i) - Q(s(i),c2(i));

                    Q(s(i),c2(i)) = Q(s(i),c2(i)) + lr2 * delta;
                    Q(1,c1(i)) = Q(1,c1(i)) + e * lr1 * delta;

                    Qm(2:3,:) = Q(2:3,:);
                end
            end

            prevc = c1(i);

        end


    end

    %lik = -(lik1 + lik2);
    lik = -lik1;
    %lik = -lik2;

end

end