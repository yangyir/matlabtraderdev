dir_ = 'C:\Users\Charlotte\OneDrive\mt5\futuresfx\'; 

data_m30 = load([dir_,'tbl2check_fxfut_m30_new_combined.mat']);
data_h1 = load([dir_,'tbl2check_fxfut_h1_new_combined.mat']);
data_h4 = load([dir_,'tbl2check_fxfut_h4_new_combined.mat']);

tbl_m30 = data_m30.tbl2check_fxfut_m30_new_combined;
tbl_h1 = data_h1.tbl2check_fxfut_h1_new_combined;
tbl_h4 = data_h4.tbl2check_fxfut_h4_new_combined;

idx_m30_g7 = ~(strcmpi(tbl_m30.code,'GC') | strcmpi(tbl_m30.code,'NE'));
idx_m30_gold = strcmpi(tbl_m30.code,'GC');
idx_h1_g7 = ~(strcmpi(tbl_h1.code,'GC') | strcmpi(tbl_h1.code,'NE'));
idx_h1_gold = strcmpi(tbl_h1.code,'GC');
idx_h4_g7 = ~(strcmpi(tbl_h4.code,'GC') | strcmpi(tbl_h4.code,'NE'));
idx_h4_gold = strcmpi(tbl_h4.code,'GC');

res_m30_g7 = kellyratio2(tbl_m30.pnlrel(idx_m30_g7,:));
res_m30_gold = kellyratio2(tbl_m30.pnlrel(idx_m30_gold,:));

res_h1_g7 = kellyratio2(tbl_h1.pnlrel(idx_h1_g7,:));
res_h1_gold = kellyratio2(tbl_h1.pnlrel(idx_h1_gold,:));

res_h4_g7 = kellyratio2(tbl_h4.pnlrel(idx_h4_g7,:));
res_h4_gold = kellyratio2(tbl_h4.pnlrel(idx_h4_gold,:));

names = {'G7-M30';'gold-M30';'G7-H1';'gold-H1';'G7-H4';'gold-H4'};
p = [res_m30_g7.w;res_m30_gold.w;res_h1_g7.w;res_h1_gold.w;res_h4_g7.w;res_h4_gold.w];
b = [res_m30_g7.r;res_m30_gold.r;res_h1_g7.r;res_h1_gold.r;res_h4_g7.r;res_h4_gold.r];
k = [res_m30_g7.k;res_m30_gold.k;res_h1_g7.k;res_h1_gold.k;res_h4_g7.k;res_h4_gold.k];

fprintf('sum of kellies: %.4f\n', sum(k));
n = size(p,1);

% optimization
[f_opt,growth_opt,outcome_mat,probvec] = kellyoptimize(p,b);


% Results Analysis
% 1. The optimal asset allocation 
fprintf('\n===== best strategy asset allocation =====\n');
for i = 1:n
    fprintf('%10s: %5.2f%% (singlek: %6.2f%%)\n', ...
        names{i}, f_opt(i)*100, k(i)*100);
end
fprintf('%10s: %5.2f%% (combine: %6.2f%%)\n', 'Total',sum(f_opt)*100,sum(k)*100);

% 2. calculate the max log growth rate
fprintf('\n');
fprintf('expected log growth rate: %6.2f%%\n', growth_opt*100);

% 3. compare different strategies
[max_k, max_k_idx] = max(k);
singlebest = zeros(1,n);
singlebest(max_k_idx) = min(max_k,usage);
strategies = {
    'normalized', 1.0*min(1, k/sum(k));
    'equal', usage*min(1, ones(n,1)/n);
    'kelly',f_opt;
    'singlebest',singlebest;
    'overbet',k;
};

fprintf('\n===== Comparision of different Strategies =====\n');
for s = 1:size(strategies,1)
    f_strategy = strategies{s,2};
    
    [growth_rate, ~] = kelly_calcgrowth(f_strategy, b, p);
    
    allocation_str = strjoin(cellstr(num2str(f_strategy(:), '%.4f')), ', ');
    fprintf('%12s%15.3f%12.2f%%\t[%s]\n', ...
            strategies{s,1}, ...
            growth_rate, ...
            sum(f_strategy)*100, ...
            allocation_str);
end

kellyvisual(p,b,f_opt,names);

%%
codes_g7 = {'AD';'EC';'BP';'CD';'SF';'JY';'GC'};
p_m30_g7 = zeros(length(codes_g7),1);
b_m30_g7 = p_m30_g7;
p_h1_g7 = p_m30_g7;b_h1_g7 = b_m30_g7;
p_h4_g7 = p_m30_g7;b_h4_g7 = b_m30_g7;
for i = 1:length(codes_g7)
    res_i = kellyratio2(tbl_m30.pnlrel(strcmpi(tbl_m30.code,codes_g7{i})));
    p_m30_g7(i) = res_i.w;
    b_m30_g7(i) = res_i.r;
end
%
for i = 1:length(codes_g7)
    res_i = kellyratio2(tbl_h1.pnlrel(strcmpi(tbl_h1.code,codes_g7{i})));
    p_h1_g7(i) = res_i.w;
    b_h1_g7(i) = res_i.r;
end
%
for i = 1:length(codes_g7)
    res_i = kellyratio2(tbl_h4.pnlrel(strcmpi(tbl_h4.code,codes_g7{i})));
    p_h4_g7(i) = res_i.w;
    b_h4_g7(i) = res_i.r;
end


names =  {'AD-M30';'EC-M30';'BP-M30';'CD-M30';'SF-M30';'JY-M30';'GC-M30';...
    'AD-H1';'EC-H1';'BP-H1';'CD-H1';'SF-H1';'JY-H1';'GC-H1';...
    'AD-H4';'EC-H4';'BP-H4';'CD-H4';'SF-H4';'JY-H4';'GC-H4'};

%
p_total_g7 = [p_m30_g7;p_h1_g7;p_h4_g7];
b_total_g7 = [b_m30_g7;b_h1_g7;b_h4_g7];


[f_opt_g7,growth_opt_g7,~,~] = kellyoptimize(p_total_g7,b_total_g7);


kellyvisual(p_total_g7,b_total_g7,f_opt_g7,names);

%%
n_m30_g7 = size(tbl_m30,1);
freq_m30_g7 = cell(n_m30_g7,1);freq_m30_g7(:) = {'M30'};
w_m30_g7 = zeros(n_m30_g7,1);
for i = 1:length(codes_g7)
    w_m30_g7(strcmpi(tbl_m30.code,codes_g7{i}),1) = f_opt_g7(i);
end
%
n_h1_g7 = size(tbl_h1,1);
freq_h1_g7 = cell(n_h1_g7,1);freq_h1_g7(:) = {'H1'};
w_h1_g7 = zeros(n_h1_g7,1);
for i = 1:length(codes_g7)
    w_h1_g7(strcmpi(tbl_h1.code,codes_g7{i}),1) = f_opt_g7(i+7);
end
%
n_h4_g7 = size(tbl_h4,1);
freq_h4_g7 = cell(n_h4_g7,1);freq_h4_g7(:) = {'H4'};
w_h4_g7 = zeros(n_h4_g7,1);
for i = 1:length(codes_g7)
    w_h4_g7(strcmpi(tbl_h4.code,codes_g7{i}),1) = f_opt_g7(i+14);
end
weights = [w_m30_g7;w_h1_g7;w_h4_g7];
freq = [freq_m30_g7;freq_h1_g7;freq_h4_g7];
tbl = [tbl_m30;tbl_h1;tbl_h4];
tbl_allfreq_g7 = [tbl,table(freq),table(weights)];
%%
% assumption 
cashbalance = 1e7/4;
leverage = 4;
totalnotional = leverage * cashbalance;
n = size(tbl_allfreq_g7,1);
allocatedNotional = totalnotional*tbl_allfreq_g7.weights;
lots = floor(allocatedNotional./tbl_allfreq_g7.opennotional);
closepnlcash = tbl_allfreq_g7.closepnl.*lots;

tbl_allfreq_g7_plot = [tbl_allfreq_g7,table(allocatedNotional),table(lots),table(closepnlcash)];
tbl_allfreq_g7_plot = sortrows(tbl_allfreq_g7_plot,'closedatetime','ascend');

%plot and statistical summary
figure(2);
plot(cumsum(tbl_allfreq_g7_plot.closepnlcash./cashbalance),'b');
xtick = get(gca,'XTick');
nxtick = length(xtick);
xticklabel = cell(nxtick,1);
for i = 1:nxtick
    if xtick(i) > n
        xticklabel{i} = '';
    elseif xtick(i) == 0
        xticklabel{i} = datestr(tbl_allfreq_g7_plot.closedatetime(1),'mmm-yy');
    else
        xticklabel{i}= datestr(tbl_allfreq_g7_plot.closedatetime(xtick(i)),'mmm-yy');
    end
end
set(gca,'XTickLabel',xticklabel,'fontsize',8);



nperiod = (datenum(tbl_allfreq_g7.closedatetime(end))-datenum(tbl_allfreq_g7.opendatetime(1)))/365.25;

annualret = sum(tbl_allfreq_g7_plot.closepnlcash./cashbalance)/nperiod;

% rolling return
[days,~,idx] = unique(floor(datenum(tbl_allfreq_g7_plot.closedatetime)));
closepnlcashdaily = accumarray(idx, tbl_allfreq_g7_plot.closepnlcash);
closepnlcashannually = zeros(length(days)-260,1);
for i = 1:length(closepnlcashannually)
    closepnlcashannually(i) = sum(closepnlcashdaily(i:i+260));
end

yearinfo = year(days);
monthinfo = month(days);
dayinfo = day(days);
N = histcounts(idx,1:1:length(days)+1);
tradecount = N';
statstable = table(days,closepnlcashdaily,yearinfo,monthinfo,dayinfo,tradecount);

statsout = kellyratio2(closepnlcashdaily/cashbalance);

statsout













