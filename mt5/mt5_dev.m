codes_fx =  {'audusd';'eurusd';'gbpusd';'usdcad';'usdchf';'usdjpy';'xauusd'};
nfx = size(codes_fx,1);
freq_d1 = 'd1';
nfractal_d1 = charlotte_freq2nfractal(freq_d1);
%
output_fx_d1_mt5 = fractal_kelly_summary('codes',codes_fx,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both',...
    'nfractal',nfractal_d1,'useMT5',1);
[~,~,tbl_fx_d1_mt5,~,~,~,~,strat_fx_d1_mt5] = kellydistributionsummary(output_fx_d1_mt5);
[tbl_report_fx_d1_mt5,stats_report_fx_d1_mt5] = kellydistributionreport(tbl_fx_d1_mt5,strat_fx_d1_mt5);
%%
w = zeros(nfx,1);
r = w;k = w;
winavg = w;lossavg = w;n = w;
maxdrawdown = w;
for i = 1:nfx
    idx_i = strcmpi(tbl_report_fx_d1_mt5.code,codes_fx{i}) & tbl_report_fx_d1_mt5.use2 == 1;
    tbl_i = tbl_report_fx_d1_mt5(idx_i,:);
    output_i = kellyratio2(tbl_i.pnlrel);
    w(i) = output_i.w;
    r(i) = output_i.r;
    k(i) = output_i.k;
    winavg(i) = output_i.winavg;
    lossavg(i) = output_i.lossavg;
    n(i) = output_i.n;
    maxdrawdown(i) = output_i.maxdrawdown;
end
tbloutput = table(codes_fx,n,w,r,k,winavg,lossavg,maxdrawdown);
% 
% 'audusd'	163	0.496932515337423	1.89583787007112	0.231578872705681	0.0120739021183886	-0.00636863642666642	-0.0552317056699450
% 'eurusd'	129	0.496124031007752	2.19396392371483	0.266459375383386	0.0127789177527441	-0.00582457970918081	-0.0612228594865018
% 'gbpusd'	189	0.571428571428571	1.80902724275293	0.334521454474798	0.0104134089322811	-0.00575635827155059	-0.0625026353569622
% 'usdcad'	190	0.526315789473684	1.75784806630708	0.256847557488516	0.00870132738410327	-0.00494998831291669	-0.0471364721199292
% 'usdchf'	244	0.561475409836066	1.84966760355459	0.324392493250836	0.0104832334683512	-0.00566763101013670	-0.0671444027394340
% 'usdjpy'	248	0.544354838709677	1.91950828681150	0.306978858402139	0.0116112841692772	-0.00604909301463071	-0.0511316838397895
% 'xauusd'	309	0.605177993527508	1.99998997844027	0.407766001103225	0.0221706668475207	-0.0110853889702042	-0.115026916325010
%
%%
fprintf('sum of kellies: %.4f\n',sum(k))
clear outcomes;
[outcomes{1:nfx}] = ndgrid([0,1]); % 0=?, 1=?
outcome_mat = reshape(cat(nfx+1, outcomes{:}), [], nfx);
num_outcomes = size(outcome_mat, 1);
% probability of different scenarios
prob = prod(outcome_mat .* w' + (1-outcome_mat) .* (1-w'), 2);
% objective function
objective = @(f) -kelly_calcgrowth(f,r,w);

% constraints
usage = 1.0;
A = ones(1, nfx); 
b_sum = usage;
lb = zeros(1, nfx);
ub = usage*ones(1,nfx);

% initial value
f0 = min(1, k / sum(k)) * 1.0;
% calibration parameters
options = optimoptions('fmincon', 'Display', 'iter', ...
    'Algorithm', 'sqp', 'MaxFunctionEvaluations', 10000);

% use fmincon to calibrate
[f_opt, fval] = fmincon(objective, f0, A, b_sum, [], [], lb, ub, [], options);
optimal_growth = -fval;
% 1. The optimal asset allocation 
fprintf('\n===== best strategy fx allocation =====\n');
for i = 1:nfx
    fprintf('%s: %6.1f%% (standalone: %4.1f%%)\n', ...
        codes_fx{i}, f_opt(i)*100, k(i)*100);
end
fprintf('Total: %.1f%%\n', sum(f_opt)*100);
% 2. calculate the max log growth rate
[growth,~] = kelly_calcgrowth(f_opt,r,w);
fprintf('\n');
fprintf('expected log growth rate: %4.1f%%\n', growth*100);
% 3. compare different strategies
[max_k, max_k_idx] = max(k);
singlebest = zeros(1,nfx);
singlebest(max_k_idx) = min(max_k,usage);
strategies = {
    'normalized', usage*min(1, k/sum(k));
    'kelly',f_opt;
    'singlebest',singlebest;
    'overbet',k;
};

fprintf('\n===== Comparision of different Strategies =====\n');
for s = 1:size(strategies,1)
    f_strategy = strategies{s,2};
        
    [growth_rate, ~] = kelly_calcgrowth(f_strategy, r, w);
    
    allocation_str = strjoin(cellstr(num2str(f_strategy(:), '%.2f')), ', ');
    fprintf('%12s%15.1f%%%12.1f%%\t[%s]\n', ...
            strategies{s,1}, ...
            100*growth_rate, ...
            sum(f_strategy)*100, ...
            allocation_str);
end
% ===== Comparision of different Strategies =====
%   normalized           25.3%       100.0%	[0.11, 0.13, 0.16, 0.12, 0.15, 0.14, 0.19]
%        kelly           38.8%        98.4%	[0.07, 0.12, 0.16, 0.08, 0.15, 0.14, 0.26]
%   singlebest           15.4%        40.8%	[0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.41]
%      overbet          -48.9%       212.9%	[0.23, 0.27, 0.33, 0.26, 0.32, 0.31, 0.41]

% Visualization
% 1. pie chart
close all;
% figure('Position', [100, 100, 800, 600], 'Color', 'white');
subplot(2,2,1);
explode = double(f_opt == max(f_opt));
pie(f_opt, explode, codes_fx);
title('Optimized Asset Allocation', 'FontSize', 12);

% 2. distribution of wealth
subplot(2,2,2);
[growth,W] = kelly_calcgrowth(f_opt,r,w);
[growth_1,W_1] = kelly_calcgrowth(strategies{1,2},r,w);
[unique_W, ~, idx] = unique(round(W, 8));
[unique_W_1, ~, idx_1] = unique(round(W_1, 8));
prob_W = accumarray(idx, prob);
prob_W_1 = accumarray(idx_1, prob);
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
% plot(sorted_W(max_idx), max_prob, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
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

% 3. comparison of different strategies
subplot(2,2,3);
strategy_names = strategies(:,1);
growth_rates = zeros(size(strategies,1),1);
for s = 1:size(strategies,1)
    f_s = strategies{s,2};
    [growth_rates(s), ~] = kelly_calcgrowth(f_s, r, w);
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
%%
tblused = tbl_report_fx_d1_mt5(tbl_report_fx_d1_mt5.use2 == 1,:);
ntrades = size(tblused,1);
totalnotional = 1;
notionalused = zeros(ntrades,1);
pnlcash = zeros(ntrades,1);
for i = 1:ntrades
    notionalused(i) = f_opt(strcmpi(tblused.code{i},codes_fx))*totalnotional;
    pnlcash(i) = notionalused(i) * tblused.pnlrel(i);
end



%%
tbl2check_fx_d1_mt5 = cell(nfx,1);
parfor i = 1:nfx
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_d1,'nfractal',nfractal_d1,'usemt5',1);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_d1_mt5{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,...
        'kellytables',strat_fx_d1_mt5,'showlogs',false,'doplot',false,'frequency',freq_d1,'nfractal',nfractal_d1,...
        'compulsorycheckforconditional',true,...
        'usemt5',1);
end
%%
% statsout_mt5 = cell(nfx,1);
% for i = 1:nfx
%     pnlret = tbl2check_fx_d1_mt5{i}.pnlrel;
%     opendt = tbl2check_fx_d1_mt5{i}.opendatetime;
%     opendt = datestr(opendt,'yyyymm');
%     opendtyymm = zeros(size(opendt,1),1);
%     
%     for j = 1:size(opendt,1)
%         opendtyymm(j) = str2double(opendt(j,:));
%     end
%         
%     [winp_running,r_running,kelly_running] = calcrunningkelly(pnlret);
%     Wret = winp_running(end);
%     Rret = r_running(end);
%     Kret = kelly_running(end);
%     pnlretcum = cumsum(pnlret);
%     pnlretmax = pnlretcum;
%     for j = 1:length(pnlretmax)
%         pnlretmax(j) = max(pnlretcum(1:j));
%     
%         if pnlretmax(j) < 0, pnlretmax(j) = 0;end
%     end
%     pnlretdrawdown = pnlretcum - pnlretmax;
%     pnlretdrawdownmax = min(pnlretdrawdown);
%     
%     opendtyymmunique = unique(opendtyymm);
%     res_i = opendtyymmunique;
%     for j = 1:size(opendtyymmunique)
%         idx_j = find(opendtyymm <= opendtyymmunique(j),1,'last');
%         res_i(j,2) = idx_j;
%         res_i(j,3) = winp_running(idx_j);
%         res_i(j,4) = r_running(idx_j);
%         res_i(j,5) = kelly_running(idx_j);
%     end
%     
%     p_converge = -1;
%     for j = 2:size(winp_running)
%         if winp_running(j) == inf || winp_running(j) == -inf, continue;end
%         x = winp_running(j:end);
%         x = (x - mean(x))/std(x);
%         h = kstest(x,'alpha',0.05);
%         if h == 0
%             p_converge = j;
%             break;
%         end
%     end
%     
%     r_converge = -1;
%     for j = 2:size(r_running)
%         if r_running(j) == inf || r_running(j) == -inf, continue;end
%         x = r_running(j:end);
%         x = (x - mean(x))/std(x);
%         h = kstest(x,'alpha',0.05);
%         if h == 0
%             r_converge = j;
%             break;
%         end
%     end
%     
%     k_converge = -1;
%     for j = 2:size(kelly_running)
%         if kelly_running(j) == inf || kelly_running(j) == -inf, continue;end
%         x = kelly_running(j:end);
%         x = (x - mean(x))/std(x);
%         h = kstest(x,'alpha',0.05);
%         if h == 0
%             k_converge = j;
%             break;
%         end
%     end
%     
% 
%     
%     statsout_mt5{i} = struct('code',codes_fx{i},...
%         'nTotal',size(pnlret,1),...
%         'Pwin',Wret,...
%         'Rret',Rret,...
%         'Kret',Kret,...
%         'MaxDrawdownret',pnlretdrawdownmax,...
%         'PConverge',p_converge,...
%         'RConverge',r_converge,...
%         'KConverge',k_converge,...
%         'ResMonthByMonth',{res_i},...
%         'PRunning',{winp_running},...
%         'RRunning',{r_running},...
%         'KRunning',{kelly_running});
% 
% end
% 
% open statsout_mt5