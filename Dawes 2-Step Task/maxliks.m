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
    c1 = m3(m3(:,1) == j,act1) + 1; % choice 1
    s = m3(m3(:,1) == j,state2) + 2; % state you get to
    c2 = m3(m3(:,1) == j,act2); % choice 2
    c2(c2 > 2) = c2(c2 > 2) - 2; % ahh.. smarter way to bring this back
    r = m3(m3(:,1) == j,reward); % reward
    k = m3(m3(:,1) == j,round); % which round
    
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
    
    Q = zeros(3,2); % (numStates you can be in w/ choice) x (numChoices at each)
    Qm = zeros(3,2);
    Tcounts = [1 1; 1 1];
    T = [.5 .5; .5 .5];
    lik1 = 0;
    %lik2 = 0;

    prevc = 0;

    for i = 1:length(c1) % # of rounds

        if k(i) < 26 % Practice problems

            Tcounts(s(i)-1,c1(i)) = Tcounts(s(i)-1,c1(i)) + 1;

            T = Tcounts./repmat(sum(Tcounts),2,1); % Transition probabilities

        else

            if (c1(i)) % If they made a first choice

                % Model Based

                Qm(1,:) = T' * max(Qm(2:3,:),[],2); % Transition probabilities * the value of the 2nd level down states

                weff = w;

                Qd = weff * Qm(1,:)' + (1-weff) * Q(1,:)'; % Weighting of model-based and model-free
                if prevc % If this isn't the first choice they've made..
                    Qd(prevc) = Qd(prevc) + ps;
                end
                
                if i > 75 % If we're past the 75th trial..
                    lik1 = lik1 + beta1 * Qd(c1(i)) - log(sum(exp(beta1 * Qd))); % calculating actions & then likelihood in one step (using softmax for model-free; model-based is already a probability)
                end
                
                Tcounts(s(i)-1,c1(i)) = Tcounts(s(i)-1,c1(i)) + 1;

                T = Tcounts./repmat(sum(Tcounts),2,1); % Keep updating transition probabilities

                % Model Free

                if (c2(i)) % If we made a second choice..
                    delta = Q(s(i),c2(i)) - Q(1,c1(i)); % difference between Q-value we had for second choice & Q-value we had for first choice.. i don't get this
                else
                    delta = max(Q(s(i),:)) - Q(1,c1(i));
                end

                Q(1,c1(i)) = Q(1,c1(i)) + lr1 * delta; % oh this is the lr1 thing

                if (c2(i)) % Okay this is the real updating
                    %lik2 = lik2 + beta2 * Q(s(i),c2(i)) - log(sum(exp(beta2 * Q(s(i),:))));
                    delta = r(i) - Q(s(i),c2(i));

                    Q(s(i),c2(i)) = Q(s(i),c2(i)) + lr2 * delta; % Update second-level Q
                    Q(1,c1(i)) = Q(1,c1(i)) + e * lr1 * delta; % Update first-level Q

                    Qm(2:3,:) = Q(2:3,:); % AHA!  here's where we're using the same value representations
                end
            end

            prevc = c1(i); % last choice we made

        end


    end

    %lik = -(lik1 + lik2);
    lik = -lik1;
    %lik = -lik2;

end

end