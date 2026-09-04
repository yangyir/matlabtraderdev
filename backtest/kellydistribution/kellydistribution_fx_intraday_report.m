code2check = 'XAUUSD';
freq2check = '4h';
replay1 = '2026-08-20';
replay2 = '2026-09-04';
showLogs = true;
doPlot = true;
useMT5 = 1;
appendix = lower(freq2mt4freq(freq2check));
if ~useMT5
    dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
    strat_fx_i = load([dir_,'strat_fx_',appendix,'.mat']);
    strat_fx_i = strat_fx_i.(['strat_fx_',appendix]);
else
    d = load('mt5\strat_fx_h1_mt5.mat');
    strat_fx_i = d.strat_fx_h1_mt5;
end
%
nfractal2check = charlotte_freq2nfractal(freq2check);
[ut,ct,tbl2check_fx,resstruct] = charlotte_backtest_period('code',code2check,'fromdate',replay1,'todate',replay2,'kellytables',strat_fx_i,'showlogs',showLogs,'doplot',doPlot,'frequency',freq2check,'nfractal',nfractal2check,'useMT5',useMT5);
open tbl2check_fx
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
codes_fx = {'audusd';'eurusd';'gbpusd';'usdcad';'usdchf';'usdjpy';'xauusd'};
% codes_fx = {'xauusd';};
% freqs = {'15m';'30m';'1h';'4h'};
% freqsmt4 = {'m15';'m30';'h1';'h4'};
freqs = {'1h';'4h'};
freqsmt4 = {'h1';'h4'};
count = 0;
code = cell(100,1);
nTotal = zeros(100,1);
pWin = zeros(100,1);
rRet = zeros(100,1);
kRet = zeros(100,1);
maxDrawdown = zeros(100,1);
annualRet = zeros(100,1);
freq = cell(100,1);
% cashpnl = zeros(100,1);
riskLimit = zeros(100,1);
for ifreq = 1:length(freqs)
    data = load([dir_,'tbl2check_fx_',freqsmt4{ifreq},'_all.mat']);
    tbl2check = data.(['tbl2check_fx_',freqsmt4{ifreq},'_all']);
    for i = 1:size(codes_fx,1)
        idxselect = strcmpi(tbl2check.code,codes_fx{i});
        pnlret = tbl2check.pnlrel(idxselect);
        [winp_running,r_running,kelly_running] = calcrunningkelly(pnlret);
        Wret = winp_running(end);
        Rret = r_running(end);
        Kret = kelly_running(end);
        pnlretcum = cumsum(pnlret);
        pnlretmax = pnlretcum;
        for j = 1:length(pnlretmax)
            pnlretmax(j) = max(pnlretcum(1:j));
            if pnlretmax(j) < 0, pnlretmax(j) = 0;end
        end
        pnlretdrawdown = pnlretcum - pnlretmax;
        pnlretdrawdownmax = min(pnlretdrawdown);
        count = count + 1;
        code{count} = codes_fx{i};
        freq{count} = freqsmt4{ifreq};
        nTotal(count) = size(pnlret,1);
        pWin(count) = Wret;
        rRet(count) = Rret;
        kRet(count) = Kret;
        maxDrawdown(count) = pnlretdrawdownmax;
        t2 = tbl2check.closedatetime(idxselect);
        t2 = datenum(t2(end),'yyyy-mm-dd HH:MM:SS');
        t1 = tbl2check.opendatetime(idxselect);
        t1 = datenum(t1(1),'yyyy-mm-dd HH:MM:SS');
        deltaT = (t2-t1)/365;
        annualRet(count) = pnlretcum(end)/deltaT;
%         cashpnl(count) = sum(tbl2check.closepnl(idxselect));
        if strcmpi(codes_fx{i},'xauusd')
            riskLimit(count) = 1000;
        else
            riskLimit(count) = 1000;
        end
    end
end
code = code(1:count);
freq = freq(1:count);
nTotal = nTotal(1:count);
pWin = pWin(1:count);
rRet = rRet(1:count);
kRet = kRet(1:count);
% cashpnl = cashpnl(1:count);
maxDrawdown = maxDrawdown(1:count);
annualRet = annualRet(1:count);
riskLimit = riskLimit(1:count);
% tblreport = table(code,freqcol,nTotal,pWin,rRet,kRet,maxDrawdown,annualRet,cashpnl);
tblreport = table(code,freq,nTotal,pWin,rRet,kRet,maxDrawdown,annualRet,riskLimit);
tblreport = sortrows(tblreport,'code','ascend');
open tblreport;

%%
n = size(tblreport,1);
nSelect = 0;
codesSelected = cell(n,5);
%
kThreshold = [0.167,0.10];
pThreshold = [0.5,0.42];
%
for i = 1:n
    if (tblreport.kRet(i) > kThreshold(1) && tblreport.pWin(i) > pThreshold(1)) || ...
            (tblreport.kRet(i) > kThreshold(2) && tblreport.pWin(i) > pThreshold(2))
        nSelect = nSelect + 1;
        codesSelected{nSelect,1} = tblreport.code{i};
        codesSelected{nSelect,2} = tblreport.freq{i};
    end        
end
codesSelected = codesSelected(1:nSelect,:);
%
%calculate the pnl with trading cost adjustments
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
for i = 1:nSelect
    data = load([dir_,'tbl2check_fx_',codesSelected{i,2},'_all.mat']);
    tbl2check = data.(['tbl2check_fx_',codesSelected{i,2},'_all']);
    idx2check = strcmpi(tbl2check.code,codesSelected{i,1});
    pnlrel2check = tbl2check.pnlrel(idx2check);
    notional2check = tbl2check.opennotional(idx2check);
    if strcmpi(codesSelected{i,1},'audusd') || ...
            strcmpi(codesSelected{i,1},'eurusd') || ...
            strcmpi(codesSelected{i,1},'gbpusd')
        codesSelected{i,3} = sum(pnlrel2check);
        if strcmpi(codesSelected{i,1},'audusd')
            baspread = 2;
        elseif strcmpi(codesSelected{i,1},'eurusd')
            baspread = 3;
        elseif strcmpi(codesSelected{i,1},'gbpusd')
            baspread = 4;
        end
        codesSelected{i,4} = sum((2+baspread)./notional2check);
    elseif strcmpi(codesSelected{i,1},'xauusd')
        baspread = 14;
        codesSelected{i,3} = sum(pnlrel2check);
        codesSelected{i,4} = sum((2+baspread)./notional2check);
    elseif strcmpi(codesSelected{i,1},'xagusd')
        baspread = 15;
        codesSelected{i,3} = sum(pnlrel2check);
        codesSelected{i,4} = sum((2+baspread)*5./notional2check);
    else
        if strcmpi(codesSelected{i,1},'usdcad')
            baspread = 6;
        elseif strcmpi(codesSelected{i,1},'usdchf')
            baspread = 6;
        elseif strcmpi(codesSelected{i,1},'usdjpy')
            baspread = 5;
        end
        codesSelected{i,3} = sum(pnlrel2check);
        codesSelected{i,4} = size(pnlrel2check,1)*(2+baspread)/1e5;
    end
    if codesSelected{i,3} > codesSelected{i,4}
        codesSelected{i,5} = 'select';
    else
        codesSelected{i,5} = 'high cost';
    end
end
%
idxSelected = strcmpi(codesSelected(:,5),'select');
codesSelected = codesSelected(idxSelected,:);
open codesSelected;
%
code = codesSelected(idxSelected,1);
freq = codesSelected(idxSelected,2);
selected = table(code,freq);
selected = join(selected,tblreport);
open selected;
%% portfolio optimization
port = selected;
n = size(port,1);
names = cell(n,1);
for i = 1:n
    names{i} = [port.code{i},'-',port.freq{i}];
end
p = port.pWin;
b = port.rRet;
fprintf('sum of kellies: %.4f\n', sum(port.kRet));

% number of outcomes (2^n?)
clear outcomes;
[outcomes{1:n}] = ndgrid([0,1]); % 0=?, 1=?
outcome_mat = reshape(cat(n+1, outcomes{:}), [], n);
num_outcomes = size(outcome_mat, 1);

% probability of different scenarios
prob = prod(outcome_mat .* p' + (1-outcome_mat) .* (1-p'), 2);

% objective function
objective = @(f) -kelly_calcgrowth(f,b,p);

% constraints
usage = 1.0;
A = ones(1, n); 
b_sum = usage;
lb = zeros(1, n);
ub = usage*ones(1,n);

% initial value
f0 = min(1, selected.kRet / sum(selected.kRet)) * 1.0;
% f0 = usage*min(1, ones(n,1)/n);
% f0 = selected.kRet;
% calibration parameters
options = optimoptions('fmincon', 'Display', 'iter', ...
    'Algorithm', 'sqp', 'MaxFunctionEvaluations', 10000);

% use fmincon to calibrate
[f_opt, fval] = fmincon(objective, f0, A, b_sum, [], [], lb, ub, [], options);
optimal_growth = -fval;
port.f_opt = f_opt;
% port = port(port.f_opt > 0.01,:);
open port

%% Results Analysis
% 1. The optimal asset allocation 
fprintf('\n===== best strategy asset allocation =====\n');
for i = 1:n
    fprintf('%s: %.2f%% (standalone: %.2f%%)\n', ...
        names{i}, f_opt(i)*100, port.kRet(i)*100);
end
fprintf('Total: %.2f%%\n', sum(f_opt)*100);

% 2. calculate the max log growth rate
[growth,W] = kelly_calcgrowth(f_opt,b,p);
fprintf('\n');
fprintf('expected log growth rate: %.6f\n', growth);

% 3. compare different strategies
[max_k, max_k_idx] = max(port.kRet);
singlebest = zeros(1,n);
singlebest(max_k_idx) = min(max_k,usage);
strategies = {
    'normalized', usage*min(1, port.kRet/sum(port.kRet));
%     'equal', usage*min(1, ones(n,1)/n);
    'kelly',f_opt;
    'singlebest',singlebest;
    'overbet',port.kRet;
};

fprintf('\n===== Comparision of different Strategies =====\n');
for s = 1:size(strategies,1)
    f_strategy = strategies{s,2};
    
%     if sum(f_strategy) > 0.9999
%         f_strategy = f_strategy / sum(f_strategy)*0.9999;
%     end
    
    [growth_rate, ~] = kelly_calcgrowth(f_strategy, b, p);
    
    allocation_str = strjoin(cellstr(num2str(f_strategy(:), '%.4f')), ', ');
    fprintf('%12s%15.3f%12.2f%%\t[%s]\n', ...
            strategies{s,1}, ...
            growth_rate, ...
            sum(f_strategy)*100, ...
            allocation_str);
end

% Visualization
% 1. pie chart
close all;
% figure('Position', [100, 100, 800, 600], 'Color', 'white');
subplot(2,2,1);
explode = double(f_opt == max(f_opt));
pie(f_opt, explode, names);
title('Optimized Asset Allocation', 'FontSize', 12);

% 2. distribution of wealth
subplot(2,2,2);
[growth,W] = kelly_calcgrowth(f_opt,b,p);
[growth_1,W_1] = kelly_calcgrowth(strategies{1,2},b,p);
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


%%
path_ = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Data\'];
fn_ = 'kellytable.txt';
fid = fopen([path_,fn_],'w');
if fid
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
        'code',...
        'freq',...
        'nTotal',...
        'pWin',...
        'rRet',...
        'kRet',...
        'maxDrawdownRet',...
        'annualRet',...
        'riskLimit',...
        'fOpt');
    for i = 1:size(port,1)
        fprintf(fid,'%s\t%s\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
            [upper(port.code{i}),'.lmx'],...
            upper(port.freq{i}),...
            port.nTotal(i),...
            port.pWin(i),...
            port.rRet(i),...
            port.kRet(i),...
            port.maxDrawdown(i),...
            port.annualRet(i),...
            port.riskLimit(i),...
            port.f_opt(i));
            
        
    end
      
end
fclose(fid);  
%%
nSelect = size(port,1);
for i = 1:nSelect
    data = load([dir_,'tbl2check_fx_',codesSelected{i,2},'_all.mat']);
    tbl2check = data.(['tbl2check_fx_',codesSelected{i,2},'_all']);
    idx2check = strcmpi(tbl2check.code,port.code{i,1});
    tbl_i = tbl2check(idx2check,:);
    tbl_i.freq = cell(size(tbl_i,1),1);
    for j = 1:size(tbl_i,1)
        tbl_i.freq{j} = port.freq{i,1};
    end
    
    if i == 1
        tblSelected = tbl_i;
    else
        tblSelected = union(tblSelected,tbl_i);
    end
end
 tblSelected = sortrows(tblSelected,'opendatetime','ascend');
 writetable(tblSelected,'C:\yangyiran\tblselected.xlsx');
%%
replay1 = '2025-08-22';
replay2 = '2025-08-29';
for i = 1:size(port,1)
    strat_fx_i = load([dir_,'strat_fx_',port.freq{i},'.mat']);
    strat_fx_i = strat_fx_i.(['strat_fx_',port.freq{i}]);
    nfractal2check = charlotte_freq2nfractal(port.freq{i});
    [~,~,tbl2check_i] = charlotte_backtest_period('code',port.code{i},'fromdate',replay1,'todate',replay2,'kellytables',strat_fx_i,'showlogs',false,'doplot',false,'frequency',port.freq{i},'nfractal',nfractal2check);
    ntrades = size(tbl2check_i,1);
    freqs = cell(ntrades,1);
    for j = 1:ntrades
        freqs{j} = port.freq{i};
    end
    if ~isempty(tbl2check_i)
        tbl2check_i.freq = freqs;
    end
        
    if i == 1
        if ~isempty(tbl2check_i)
            tbl2check_month = tbl2check_i;
        else
            tbl2check_month = [];
        end
    else
        if ~isempty(tbl2check_month)
            if ~isempty(tbl2check_i)
                tbl2check_month = union(tbl2check_month,tbl2check_i);
            end
        else
            if ~isempty(tbl2check_i)
                tbl2check_month = tbl2check_i;
            else
                tbl2check_month = [];
            end
        end
    end
end
tbl2check_month = sortrows(tbl2check_month,'opendatetime','ascend');
writetable(tbl2check_month,'C:\yangyiran\tbl2check_month.xlsx');
%%



