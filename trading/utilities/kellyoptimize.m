function [f_opt,growth_opt,outcome_mat,probvec] = kellyoptimize(p,b)

n = size(p,1);

k = p -(1.0-p)./b;

[outcomes{1:n}] = ndgrid([0,1]); % 0=?, 1=?
outcome_mat = reshape(cat(n+1, outcomes{:}), [], n);

% probability of different scenarios
probvec = prod(outcome_mat .* p' + (1-outcome_mat) .* (1-p'), 2);

% objective function
objective = @(f) -kelly_calcgrowth(f,b,p);

% constraints
usage = 1;
A = ones(1, n); 
b_sum = usage;
lb = zeros(1, n);
ub = usage*ones(1,n);

% initial value
% f0 = min(usage, k / sum(k)) * 1.0;
f0 = usage*min(1, ones(n,1)/n);
% f0 = selected.kRet;
% calibration parameters
options = optimoptions('fmincon', 'Display', 'iter', ...
    'Algorithm', 'sqp', 'MaxFunctionEvaluations', 10000);

% use fmincon to calibrate
[f_opt, fval] = fmincon(objective, f0, A, b_sum, [], [], lb, ub, [], options);
growth_opt = -fval;