function [] = kellyvisual(p,b,f_opt,names)
n = size(p,1);

k = p - (1.0-p)./b;

[outcomes{1:n}] = ndgrid([0,1]); % 0=?, 1=?
%outcome matrix
outcome_mat = reshape(cat(n+1, outcomes{:}), [], n);

% probability of different scenarios
probvec = prod(outcome_mat .* p' + (1-outcome_mat) .* (1-p'), 2);

[max_k, max_k_idx] = max(k);
singlebest = zeros(1,n);
singlebest(max_k_idx) = min(max_k,1.0);
strategies = {
    'normalized', 1.0*min(1, k/sum(k));
    'equal', min(1, ones(n,1)/n);
    'kelly',f_opt;
    'singlebest',singlebest;
    'overbet',k;
};

% Visualization
% 1. pie chart
set(0,'defaultfigurewindowstyle','docked');
close all;
% figure('Position', [100, 100, 800, 600], 'Color', 'white');
subplot(2,2,1);
explode = double(f_opt == max(f_opt));
pie(f_opt, explode, names);
title('Optimized Asset Allocation', 'FontSize', 12);

subplot(2,2,2);
[growth,W] = kelly_calcgrowth(f_opt,b,p);
[growth_1,W_1] = kelly_calcgrowth(strategies{1,2},b,p);
[unique_W, ~, idx] = unique(round(W, 8));
[unique_W_1, ~, idx_1] = unique(round(W_1, 8));
prob_W = accumarray(idx, probvec);
prob_W_1 = accumarray(idx_1, probvec);
[sorted_W, sort_idx] = sort(unique_W);
[sorted_W_1, sort_idx_1] = sort(unique_W_1);
sorted_prob = prob_W(sort_idx);
sorted_prob_1 = prob_W_1(sort_idx_1);
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
% set(gca, 'FontSize', 10, 'YScale', 'log');
set(gca, 'FontSize', 10);
%
subplot(2,2,3);
strategy_names = strategies(:,1);
growth_rates = zeros(size(strategies,1),1);
for s = 1:size(strategies,1)
    f_s = strategies{s,2};
    [growth_rates(s), ~] = kelly_calcgrowth(f_s, b, p);
end
bar(growth_rates, 'FaceColor', [0.8 0.4 0.1]);
set(gca, 'XTickLabel', strategy_names, 'XTickLabelRotation', 45);
title('Comparison of Different Strategies', 'FontSize', 12);
ylabel('E[log(W)]');


% 4. wealth distribution function
subplot(2,2,4);
cdf_prob = cumsum(sorted_prob);
cdf_prob_1 = cumsum(sorted_prob_1);
stairs(sorted_W, cdf_prob, 'LineWidth', 2, 'Color', 'b');
hold on;
stairs(sorted_W_1, cdf_prob_1, 'LineWidth', 2, 'Color', 'r');
yline(0.95, 'g--', '95%Pecentile', 'LineWidth', 1.5);
xline(1, 'r--', 'BreakEven', 'LineWidth', 1.5);
title('CDF of Wealth', 'FontSize', 12);
xlabel('Log Wealth Multiplier');
ylabel('CDF');
grid on;hold off;
set(gca, 'FontSize', 10);
legend('optimal','normalized');
% set(gca, 'FontSize', 10, 'YScale', 'log');