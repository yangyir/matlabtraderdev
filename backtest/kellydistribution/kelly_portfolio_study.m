%%
data = load([dir_,'tbl2check_fx_h4_all.mat']);
tbl2check_fx_h4_all = data.tbl2check_fx_h4_all;
%%
code = "eurusd";
[p_running,r_running,k_running] = calcrunningkelly(tbl2check_fx_m5_all.pnlrel(strcmpi(tbl2check_fx_m5_all.code,code)));

%%
chooseFlag = input("Choose P/R/K?: ",'s');
if strcmpi(chooseFlag,'P')
    cumulativeMeans = p_running;
    title1 = 'Convergence of Win Ratio';
    title2 = 'Distribution of Win Ratio';
    ylabel1 = 'Win Ratio';
elseif strcmpi(chooseFlag,'R')
    cumulativeMeans = r_running;
    title1 = 'Convergence of Fractional Odds';
    title2 = 'Distribution of Fractional Odds';
    ylabel1 = 'Fractional Odds';
elseif strcmpi(chooseFlag,'K')
    title1 = 'Convergence of  Kelly Criterion';
    title2 = 'Distribution of Kelly Criterion';
    ylabel1 = 'Kelly Criterion';
    cumulativeMeans = k_running;
end
n = length(cumulativeMeans);
fit_start = 150;
x_fit = cumulativeMeans(fit_start:n);
x = (x_fit - mean(x_fit))/std(x_fit);
h = kstest(x,'tail','larger');
[xMu,xSigma] = normfit(x_fit,0.01);

close all;
figure('Color','White');
subplot(3,1,1);
plot(1:fit_start-1, cumulativeMeans(1:fit_start-1), 'b--', 'LineWidth', 1.8);
hold on;
plot(fit_start:n, x_fit, 'b', 'LineWidth', 1.8);

% yline(xMu+xSigma, 'r--', 'LineWidth', 1.5, 'Label', '+stdev','LabelVerticalAlignment','top');
yline(cumulativeMeans(end), 'r--', 'LineWidth', 1.5, 'Label', 'lastvalue');
% yline(xMu-xSigma, 'r--', 'LineWidth', 1.5, 'Label', '-stdev','LabelVerticalAlignment','bottom');
hold off;
title(title1, 'FontSize', 10, 'FontWeight', 'bold');
xlabel('#Trades', 'FontSize', 10);
ylabel(ylabel1, 'FontSize', 10);
grid on;
% set(gca, 'FontSize', 11, 'XScale', 'log');

subplot(3,1,2);
[f,x_values] = ecdf(x);
J = plot(x_values,f);
hold on;
K = plot(x_values,normcdf(x_values),'r--');
set(J,'LineWidth',2);
set(K,'LineWidth',2);
legend([J K],'Empirical CDF','Standard Normal CDF','Location','Best','FontSize',8);
legend('boxoff');
title(title2,'FontSize', 10, 'FontWeight', 'bold');


subplot(3,1,3);
relative_error = abs(cumulativeMeans - xMu) / xMu * 100; 
plot(1:fit_start-1, relative_error(1:fit_start-1), 'LineWidth', 1.8, 'Color', [0.9, 0.4, 0.1],'LineStyle','--');
hold on;
plot(fit_start:n, relative_error(fit_start:n), 'LineWidth', 1.8, 'Color', [0.9, 0.4, 0.1]);
hold off;
title('Relative Error', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('#Trades', 'FontSize', 10);
ylabel('Relative Error(%)', 'FontSize', 10);
grid on;
set(gca, 'FontSize', 10);
yline(xSigma*100, 'g--', 'stdev', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'right');

% error = a * n^(-b)
y_fit = relative_error(1:n);
log_x = log(1:n);log_x = log_x';
log_y = log(y_fit);
coeffs = polyfit(log_x, log_y, 1);
b = -coeffs(1);
a = exp(coeffs(2));
fprintf('===== Summary =====\n');
fprintf('Number of Trades: %d\n', n);
fprintf('Theoritical: %.4f\n', xMu);
fprintf('LastObsevation: %.4f\n', cumulativeMeans(end));
fprintf('Stdev: %.4f\n', xSigma);
fprintf('RelativeError = %.4f * n^{-%.4f}\n', a, b);
fprintf('Convergence: b = %.4f\n', b);
%%
%% portfolio analysis
%clc; clear; close all;

investments = {
    % name     p      b
    'eurusd-m15',   0.444,  2.29;
    'xauusd-m15',   0.413,  2.55;
    'gbpusd-m30',   0.500,  1.96;
    'xauusd-m30',   0.429,  2.55;
    'audusd-h1',   0.500,   1.89;   
    'gbpusd-h1',   0.483,   2.01;   
    'usdchf-h1',   0.471,   1.90;   
    'usdjpy-h1',   0.485,   1.95;   
    'xauusd-h1',   0.546,   2.08;   
    'eurusd-h4',    0.608,  1.22;
    'gbpusd-h4',    0.457,  1.83;
    'usdcad-h4',    0.462,  2.06;
    'usdjpy-h4',    0.500,  1.56;
    'xauusd-h4',    0.490,  1.98;
};
% 0.2354+0.2251+0.2139+0.2164+0.3243 = 1.2151 > 1

names = investments(:,1);
p = cell2mat(investments(:,2));
b = cell2mat(investments(:,3));
n = length(p);

kelly_f = (p.*b - (1-p)) ./ b;
fprintf('sum of kellies: %.4f\n', sum(kelly_f));

%% portfolio optimization
% number of outcomes (2^n?)
[outcomes{1:n}] = ndgrid([0,1]); % 0=?, 1=?
outcome_mat = reshape(cat(n+1, outcomes{:}), [], n);
num_outcomes = size(outcome_mat, 1);

% probability of different scenarios
prob = prod(outcome_mat .* p' + (1-outcome_mat) .* (1-p'), 2);

% objective function
objective = @(f) -kelly_calcgrowth(f,b,p);

% constraints
A = ones(1, n);  % ??????? (?f_i ? 1)
b_sum = 1.0;
lb = zeros(1, n);
ub = ones(1,n);

% initial value
f0 = min(1, kelly_f / sum(kelly_f)) * 1.0;

% calibration parameters
options = optimoptions('fmincon', 'Display', 'iter', ...
    'Algorithm', 'sqp', 'MaxFunctionEvaluations', 10000);

% use fmincon to calibrate
[f_opt, fval] = fmincon(objective, f0, A, b_sum, [], [], lb, ub, [], options);
optimal_growth = -fval;

%% Results Analysis
% 1. The optimal asset allocation 
fprintf('\n===== best strategy asset allocation =====\n');
for i = 1:n
    fprintf('%s: %.2f%% (standalone: %.2f%%)\n', ...
        names{i}, f_opt(i)*100, kelly_f(i)*100);
end
fprintf('Total: %.2f%%\n', sum(f_opt)*100);

% 2. calculate the max log growth rate
[growth,W] = kelly_calcgrowth(f_opt,b,p);
fprintf('\n');
fprintf('expected log growth rate: %.6f\n', growth);

% 3. compare different strategies
strategies = {
    'normalized', min(1, kelly_f/sum(kelly_f));
    'equal', min(1, ones(n,1)/n);
    'optimized',f_opt;
};

fprintf('\n===== Comparision of different Strategies =====\n');
for s = 1:size(strategies,1)
    f_strategy = strategies{s,2};
    
    if sum(f_strategy) > 0.9999
        f_strategy = f_strategy / sum(f_strategy)*0.9999;
    end
    
    [growth_rate, ~] = kelly_calcgrowth(f_strategy, b, p);
    
    allocation_str = strjoin(cellstr(num2str(f_strategy(:), '%.4f')), ', ');
    fprintf('%12s%15.3f%12.2f%%\t[%s]\n', ...
            strategies{s,1}, ...
            growth_rate, ...
            sum(f_strategy)*100, ...
            allocation_str);
end

%% Visualization
% 1. pie chart
close all;
figure('Position', [100, 100, 800, 600], 'Color', 'white');
subplot(2,2,1);
explode = double(f_opt == max(f_opt));
pie(f_opt, explode, names);
title('Optimized Asset Allocation', 'FontSize', 12);

% 2. distribution of wealth
subplot(2,2,2);
[unique_W, ~, idx] = unique(round(W, 8));
prob_W = accumarray(idx, prob);
[sorted_W, sort_idx] = sort(unique_W);
sorted_prob = prob_W(sort_idx);
if length(sorted_W) > 252
    histogram(sorted_W, 50, 'FaceColor', [0.2 0.6 0.9], 'Normalization', 'probability');
else
    bar(sorted_W, sorted_prob, 'BarWidth', 0.8, 'FaceColor', [0.2 0.6 0.9]);
end
hold on;
xline(1, 'r--', 'LineWidth', 2, 'Label', 'BreakEven');
[max_prob, max_idx] = max(sorted_prob);
plot(sorted_W(max_idx), max_prob, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
text(sorted_W(1), sorted_prob(1), sprintf('Worst: %.2f', sorted_W(1)), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
text(sorted_W(end), sorted_prob(end), sprintf('Best: %.2f', sorted_W(end)), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
title('PDF of Wealth', 'FontSize', 12);
xlabel('Log Wealth Multiplier');
ylabel('Prob');
grid on;
set(gca, 'FontSize', 10, 'YScale', 'log');
% set(gca, 'FontSize', 10);

% 3. comparison of different strategies
subplot(2,2,3);
strategy_names = strategies(:,1);
growth_rates = zeros(size(strategies,1),1);
for s = 1:size(strategies,1)
    f_s = strategies{s,2};
    if sum(f_s) >= 0.9999
        f_s = f_s / sum(f_s)*0.9999;
    end
    [growth_rates(s), ~] = kelly_calcgrowth(f_s, b, p);
end
bar(growth_rates, 'FaceColor', [0.8 0.4 0.1]);
set(gca, 'XTickLabel', strategy_names, 'XTickLabelRotation', 45);
title('Comparison of Different Strategies', 'FontSize', 12);
ylabel('E[log(W)]');


% 4. wealth distribution function
subplot(2,2,4);
cdf_prob = cumsum(sorted_prob);
stairs(sorted_W, cdf_prob, 'LineWidth', 2, 'Color', 'b');
yline(0.95, 'g--', '95%Pecentile', 'LineWidth', 1.5);
xline(1, 'r--', 'BreakEven', 'LineWidth', 1.5);
title('CDF of Wealth', 'FontSize', 12);
xlabel('Log Wealth Multiplier');
ylabel('E[log(W)]');
grid on;
set(gca, 'FontSize', 10);
set(gca, 'FontSize', 10, 'YScale', 'log');


%% Monte Carlo
num_sims = 10000;
sim_growth = zeros(num_sims,1);

for sim = 1:num_sims
    outcome = rand(n, 1) < p;
    
    total_return = 0;
    for i = 1:n
        if outcome(i)
            total_return = total_return + f_opt(i) * b(i);
        else
            total_return = total_return - f_opt(i);
        end
    end
    
    W = 1 + total_return;
    if W <= 0
        W = 1e-16;  % strictly positive
    end
    
    sim_growth(sim) = log(W);
end

fprintf('\n===== Monte Carlo Proof =====\n');
fprintf('Expected log growth rate: %.6f\n', optimal_growth);
fprintf('Monte Carlo log growth rate: %.6f\n', sum(sim_growth)/num_sims);
fprintf('Difference: %.6f\n', abs(optimal_growth - sum(sim_growth)/num_sims));


