function [growth, W] = kelly_calcgrowth(f, b, p)
    n = length(p);
    
    [outcomes{1:n}] = ndgrid([0,1]); % 0=loose, 1=win
    outcome_mat = reshape(cat(n+1, outcomes{:}), [], n);
    num_outcomes = size(outcome_mat, 1);


    % calc the probability of all combinations
    prob = prod(outcome_mat .* p' + (1-outcome_mat) .* (1-p'), 2);
    
    % calc the return of all combinations
    total_return = zeros(num_outcomes, 1);
    for j = 1:num_outcomes
        outcome = outcome_mat(j, :);
        investment_return = 0;
        for i = 1:n
            if outcome(i) == 1 % win
                investment_return = investment_return + f(i) * b(i);
            else % loose
                investment_return = investment_return - f(i); % loss ammount 
            end
        end
        total_return(j) = investment_return;
    end
    
    % final wealth
    W = 1 + total_return;
    
    % strictly positive
    W(W <= 0) = 1e-16;
    
    % log returns
    growth = sum(prob .* log(W));
end