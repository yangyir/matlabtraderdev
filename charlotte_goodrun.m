% overnight run
% let's run a 3 year back testing from 2023-07-01 to 2026-06-30
% we calibrate the params every quarter-end from the backtesting period
% onwards using the rolling period of 5 years
nfx = size(codes_fx,1);
calib_dates = {'2023-06-30';'2023-09-30';'2023-12-31';...
    '2024-03-31';'2024-06-30';'2024-09-30';'2024-12-31';...
    '2025-03-31';'2025-06-30';'2025-09-30';'2025-12-31';...
    '2026-03-31';'2026-06-30'};
ncalib = length(calib_dates);
calib_fromdates = cell(ncalib,1);
calib_todates = calib_dates;
for i = 1:ncalib
    calib_fromdates{i} = dateadd(calib_todates{i},'-5y');
end

output_fx_h4_recalibs = cell(ncalib,1);
tbl_fx_h4_recalibs = cell(ncalib,1);
strat_fx_h4_recalibs = cell(ncalib,1);
%
parfor i = 1:ncalib
    output_fx_h4_i = fractal_kelly_summary('codes',codes_fx,...
        'frequency','intraday-240m','usefractalupdate',0,...
        'nfractal',nfractal_h4,'useMT5',1,...
        'fromdate',calib_fromdates{i},...
        'todate',calib_todates{i});
    
    [~,~,tbl_fx_h4_i,~,~,~,~,strat_fx_h4_i] = kellydistributionsummary(output_fx_h4_i);

    output_fx_h4_recalibs{i} = output_fx_h4_i;
    tbl_fx_h4_recalibs{i} = tbl_fx_h4_i;
    strat_fx_h4_recalibs{i} = strat_fx_h4_i;
end
% save('c:\temp\output_fx_h4_recalibs.mat','output_fx_h4_recalibs');
% save('c:\temp\tbl_fx_h4_recalibs.mat','tbl_fx_h4_recalibs');
% save('c:\temp\strat_fx_h4_recalibs.mat','strat_fx_h4_recalibs');
%
%
%% STEP2
% tables to pop-up historical p and b with conditional trades....
% p and b are used to calibrate the sizing weights for later trading
statstable_fx_h4_sizing = cell(ncalib,1);
tbls_allcalib = cell(ncalib,1);
for i = 1:ncalib
    dt1 = calib_fromdates{i};
    dt2 = calib_todates{i};
    tbls_icalib = cell(nfx,1);
    kellytable_icalib = strat_fx_h4_recalibs{i};
    N = zeros(nfx,1);
    P = N;R = N;K = N;MDD = N;%DD stands for drawdown
    WA = N;LA = N;%winavg and lossavg
    parfor j = 1:nfx
        [~,~,tbls_icalib{j}] = charlotte_backtest_period('code',codes_fx{j},...
            'fromdate',dt1,...
            'todate',dt2,...
            'kellytables',kellytable_icalib,...
            'showlogs',false,'doplot',false,...
            'frequency',freq_h4,'nfractal',nfractal_h4,...
            'compulsorycheckforconditional',true,...
            'usemt5',1);
        stats_i = kellyratio2(tbls_icalib{j}.pnlrel);
        N(j) = stats_i.n;
        P(j) = stats_i.w;
        R(j) = stats_i.r;
        K(j) = stats_i.k;
        MDD(j) = stats_i.maxdrawdown;
        WA(j) = stats_i.winavg;
        LA(j) = stats_i.lossavg;
    end
    statstable_fx_h4_sizing{i} = table(codes_fx,N,P,R,K,MDD,WA,LA);
    tbl_temp = tbls_icalib{1};
    for j = 2:nfx
         temp = [tbl_temp; tbls_icalib{j}];
         tbl_temp = temp;
    end
    tbls_allcalib{i} = tbl_temp;
end
% save('c:\temp\tbls_allcalib.mat','tbls_allcalib');

%% STEP3.1
% portfolio sizing based on the above results
optimal_growth = zeros(ncalib,1);
for i = 1:ncalib
    tbl_i = statstable_fx_h4_sizing{i};
    p = tbl_i.P;
    b = tbl_i.R;
    fprintf('sum of kellies at %2d resizing: %.2f\n', i,sum(tbl_i.K));

    clear outcomes;
    [outcomes{1:nfx}] = ndgrid([0,1]); % 0=?, 1=?
    % number of outcomes (2^n?)
    outcome_mat = reshape(cat(nfx+1, outcomes{:}), [], nfx);
    num_outcomes = size(outcome_mat, 1);
    % probability of different scenarios
    prob = prod(outcome_mat .* p' + (1-outcome_mat) .* (1-p'), 2);
    % objective function
    objective = @(f) -kelly_calcgrowth(f,b,p);
    % constraints
    usage = 0.95;
    A = ones(1, nfx); 
    b_sum = usage;
    lb = zeros(1, nfx);
    ub = usage*ones(1,nfx);
    % initial value
    f0 = min(1, tbl_i.K / sum(tbl_i.K)) * usage;
    % calibration parameters
    options = optimoptions('fmincon', 'Display', 'iter', ...
        'Algorithm', 'sqp', 'MaxFunctionEvaluations', 10000);
    % use fmincon to calibrate
    [f_opt, fval] = fmincon(objective, f0, A, b_sum, [], [], lb, ub, [], options);
    optimal_growth(i) = -fval;
    tblnew_i = [tbl_i,table(f_opt)];
    statstable_fx_h4_sizing{i} = tblnew_i;
end
% save('c:\temp\statstable_fx_h4_sizing.mat','statstable_fx_h4_sizing');

%% STEP3.2
% calc stats for each calibration time windows
leverage = 3;
sl_single = 0.01*ones(nfx,1);
sharps_calib = zeros(ncalib,1);
mdd_calib = zeros(ncalib,1);
totallret_calib = zeros(ncalib,1);
wa_calib = zeros(ncalib,1);
la_calib = zeros(ncalib,1);
pnlres_calib = cell(ncalib,1);
for i = 1:ncalib
    res_i = calc_fx_sharp('leverage',leverage,'slpa',sl_single,'tbltrades',tbls_allcalib{i},'tblstats',statstable_fx_h4_sizing{i},'nslippage',10);
    sharps_calib(i) = res_i.sharp;
    mdd_calib(i) = res_i.mddtrade;
    totallret_calib(i) = res_i.totalret;
    wa_calib(i) = res_i.winavgtrade;
    la_calib(i) = res_i.lossavgtrade;
    pnlres_calib{i} = res_i;
end
tblpnl_calib = table(calib_fromdates,calib_todates,sharps_calib,mdd_calib,totallret_calib,wa_calib,la_calib);
%% STEP 3.3
% PnL attribution
pnlattribute = zeros(nfx,ncalib);
for i = 1:ncalib
    tbl_i = tbls_allcalib{i};
    tbl_i = sortrows(tbl_i,'closedatetime','ascend');
    res_i = pnlres_calib{i};
    for j = 1:nfx
        idx_j = strcmpi(tbl_i.code,codes_fx{j});
        pnlattribute(j,i) = sum(res_i.pnlpertrade(idx_j));
    end
end
%% STEP 3.4
% win/loss trade pnl distribution
pvalues = [0;0.01;0.05;0.1;0.25;0.5;0.75;0.9;0.99;1];
tbl_i = tbls_allcalib{end};
w_dist = zeros(length(pvalues),nfx);
l_dist = w_dist;
all_dist = w_dist;
for j = 1:nfx
    idx_j = strcmpi(tbl_i.code,codes_fx{j});
    pnl_j = tbl_i.pnlrel(idx_j).*tbl_i.openprice(idx_j);
    pnl_win_j = pnl_j(pnl_j>0);
    pnl_loss_j = pnl_j(pnl_j<0);
    for k = 1:length(pvalues)
        w_dist(k,j) = quantile(pnl_win_j,pvalues(k));
        l_dist(k,j) = quantile(pnl_loss_j,pvalues(k));
        all_dist(k,j) = quantile(pnl_j,pvalues(k));
    end
end
%% STEP 3.5
% The distribution of holding period
% in terms of number of candles
tbl_i = tbls_allcalib{end};
ei1_mt5 = cell(nfx,1);
for i = 1:nfx
    [~,ei_i] = charlotte_loaddata('futcode',codes_fx{i},'frequency','4h','nfractal',2,'usemt5',1);
    ei1_mt5{i} = ei_i;
end
%
ntrades = size(tbl_i,1);
holdperiodpertrade = zeros(ntrades,1);
opendtnum = datenum(tbl_i.opendatetime,'yyyy-mm-dd HH:MM:SS');
closedtnum = datenum(tbl_i.closedatetime,'yyyy-mm-dd HH:MM:SS');
for i = 1:ntrades
    code_i = tbl_i.code{i};
    switch code_i
        case 'audusd'
            ifx = 1;
        case 'eurusd'
            ifx = 2;
        case 'gbpusd'
            ifx = 3;
        case 'usdcad'
            ifx = 4;
        case 'usdchf'
            ifx = 5;
        case 'usdjpy'
            ifx = 6;
        case 'xauusd'
            ifx =7;
        otherwise
            error('invalid fx code')
    end
    px_ = ei1_mt5{ifx}.px;
    idxopen_i = find(px_(:,1)>=opendtnum(i),1,'first');
    idxclose_i = find(px_(:,1)<=closedtnum(i),1,'last');
    holdperiodpertrade(i) = idxclose_i-idxopen_i+1;
end
tblhodingperiod = table(tbl_i.code,holdperiodpertrade);



%% STEP4
% use the calibrated sizing to compute the insample stats, i.e shape,mmd
% and etc
% slippage decay analysis
slippage = 0:2:50;
nslippage = length(slippage);
sharps = zeros(nslippage,1);
winratios = zeros(nslippage,1);
res = cell(nslippage,1);
for jj = 1:nslippage
    res{jj} = calc_fx_sharp('leverage',leverage,'slpa',sl_single,'tbltrades',tbls_allcalib{end},'tblstats',statstable_fx_h4_sizing{end},'nslippage',slippage(jj));
    sharps(jj) = res{jj}.sharp;
    winratios(jj) = res{jj}.w;
end
figure(1);
plot(slippage/10,sharps,'b');
xlabel('Slippage in Pips');ylabel('Sharp Ratio');title('Decay of Sharp Ratio vs.Slippage');
hold on;
yline(1.5,'r--','1.5 Sharp Ratio Threshold', 'LineWidth', 1.5)
hold off;
figure(2)
plot(slippage/10,winratios,'b');
xlabel('Slippage in Pips');ylabel('Win Ratio');title('Decay of Win Ratio vs.Slippage');
hold off;

%% STEP5
% Out-of-Sample performance & Walk-Forwad Optimization
tbl2check_fx_h4_recalibs = cell(nfx,1);
hist_trades = cell(nfx,1);
for i = 1:nfx
    hist_trades{i} = cTradeOpenArray;
end

for i = 1:ncalib
    dt1 = calib_dates{i};
    try
        dt2 = calib_dates{i+1};
    catch
        dt2 = '2026-08-01';
    end
    %
    kellytable_icalib = strat_fx_h4_recalibs{i};
    statstable_icalib = statstable_fx_h4_sizing{i};
    f_opt = statstable_icalib.f_opt;
    mdd = statstable_icalib.MDD;
    parfor j = 1:nfx
        [ut_ij,~,tbls_ij] = charlotte_backtest_period('code',codes_fx{j},...
            'fromdate',dt1,'todate',dt2,...
            'kellytables',kellytable_icalib,...
            'showlogs',false,'doplot',false,...
            'frequency',freq_h4,'nfractal',nfractal_h4,...
            'compulsorycheckforconditional',true,...
            'usemt5',1);
        % asset weights allocation
        ntrades = size(tbls_ij,1);
        if ntrades > 0 
            wj1 = f_opt(j);
            wj2 = abs(1.5*sl_single(j) / (mdd(j)*leverage));
            weights = wj1*ones(ntrades,1);
            tbls_ij = [tbls_ij,table(weights)];

            %
            for itrade = 1:ut_ij.latest_
                hist_trades{j}.push(ut_ij.node_(itrade));
            end
            %
            if i == 1
                tbl2check_fx_h4_recalibs{j} = tbls_ij;
            else
                tbl1 = tbl2check_fx_h4_recalibs{j};
                tbl_combined = [tbl1;tbls_ij];
                tbl2check_fx_h4_recalibs{j} = tbl_combined;
            end
        end
        
    end
end
save('c:\temp\tbl2check_fx_h4_recalibs.mat','tbl2check_fx_h4_recalibs');
%% STEP 5.1 
% calculate the pnl
tbl2check_fx_h4_oos = tbl2check_fx_h4_recalibs{1};
for i = 2:nfx
    temp = [tbl2check_fx_h4_oos;tbl2check_fx_h4_recalibs{i}];
    tbl2check_fx_h4_oos = temp;
end
tbl2check_fx_h4_oos = sortrows(tbl2check_fx_h4_oos,'closedatetime','ascend');
ntrades = size(tbl2check_fx_h4_oos,1);
costs = zeros(ntrades,1);
nslippage = 1.0;
for k = 1:length(costs)
    px_k = tbl2check_fx_h4_oos.openprice(k);
    code_k = tbl2check_fx_h4_oos.code{k};
    % the cost is commission + bid/ask spread + slippage + overnight swap
    if strcmpi(code_k,'audusd')
        costs(k) = 2.6/(px_k*1e5) + 2*1e-5/px_k + nslippage*2*1e-5/px_k;
    elseif strcmpi(code_k,'eurusd')
        costs(k) = 2.6/(px_k*1e5) + 1*1e-5/px_k + nslippage*2*1e-5/px_k;
    elseif strcmpi(code_k,'gbpusd')
        costs(k) = 2.6/(px_k*1e5) + 2*1e-5/px_k + nslippage*2*1e-5/px_k;
    elseif strcmpi(code_k,'usdcad')
        costs(k) = 2.6/1e5 + 3*1e-5/px_k + nslippage*2*1e-5/px_k;
    elseif strcmpi(code_k,'usdchf')
        costs(k) = 2.6/1e5 + 3*1e-5/px_k + nslippage*2*1e-5/px_k;
    elseif strcmpi(code_k,'usdjpy')
        costs(k) = 2.6/1e5 + 0.02/px_k + nslippage*2*1e-3/px_k;
    elseif strcmpi(code_k,'xauusd')
        costs(k) = 10/(px_k*1e2) + 0.15/px_k + nslippage*2*1e-2/px_k;
    end
end
balance = 1.0;
pnl_oos = (tbl2check_fx_h4_oos.pnlrel - costs).* tbl2check_fx_h4_oos.weights * balance * leverage;

[dts,~,idx] = unique(floor(datenum(tbl2check_fx_h4_oos.closedatetime,'yyyy-mm-dd HH:MM')));
pnl_oos_daily = zeros(length(dts),1);
for k = 1:length(dts)
    pnl_oos_daily(k) = sum(pnl_oos(idx == k));
end
%%
% compare with the in-sample stats
pnl_is_daily = pnlres_calib{end}.pnldaily;
[t,ia,ib] = intersect(dts,pnl_is_daily(:,1));
pnl_compare_daily = [t,pnl_oos_daily(ia),pnl_is_daily(ib,2)];
figure(1);
subplot(211);
plot(cumsum(pnl_compare_daily(:,2)),'b');
hold on;
plot(cumsum(pnl_compare_daily(:,3)),'r');
hold off;
xtick = get(gca,'XTick');
nxtick = length(xtick);
xticklabel = cell(nxtick,1);
for i = 1:nxtick
    if xtick(i) > size(pnl_compare_daily,1), continue;end
    if xtick(i) <= 1
        xticklabel{i} = datestr(pnl_compare_daily(1,1),'mmm-yy');
    else
        xticklabel{i}= datestr(pnl_compare_daily(xtick(i),1),'mmm-yy');
    end
end
set(gca,'XTickLabel',xticklabel,'fontsize',8);
legend('OOP','IS','Location','northwest','fontsize',10);
xlabel('date','fontsize',12,'fontweight','bold');
ylabel('total return','fontsize',12,'fontweight','bold');
title('Performance Comparison: OOP vs IS','fontsize',14,'fontweight','bold');
subplot(212);
plot(cumsum(pnl_compare_daily(:,2))-cumsum(pnl_compare_daily(:,3)),'g-');grid on;
xtick = get(gca,'XTick');
nxtick = length(xtick);
xticklabel = cell(nxtick,1);
for i = 1:nxtick
    if xtick(i) > size(pnl_compare_daily,1), continue;end
    if xtick(i) <= 1
        xticklabel{i} = datestr(pnl_compare_daily(1,1),'mmm-yy');
    else
        xticklabel{i}= datestr(pnl_compare_daily(xtick(i),1),'mmm-yy');
    end
end
set(gca,'XTickLabel',xticklabel,'fontsize',8);
xlabel('date','fontsize',12,'fontweight','bold');
ylabel('diff','fontsize',12,'fontweight','bold');
exl_dts = m2xdate(pnl_compare_daily(:,1));

%% STEP 6
% present EOD positions
balance = 1e6;
tbl2check_fx_h4_oos;
dts = datenum('2025-07-01'):datenum('2026-07-31');dts = dts';
wd = weekday(dts);
dts = dts(wd ~= 1 & wd~= 7);
ndts = length(dts);
eod_positions = zeros(ndts,nfx);
opendtnum = datenum(tbl2check_fx_h4_oos.opendatetime,'yyyy-mm-dd HH:MM:SS');
closedtnum = datenum(tbl2check_fx_h4_oos.closedatetime,'yyyy-mm-dd HH:MM:SS');
for i = 1:ndts
    dt_i = dts(i);
    dt_i = dt_i + 86399/86400;
    idx_i = opendtnum <= dt_i & closedtnum > dt_i;
    tbl_idate = tbl2check_fx_h4_oos(idx_i,:);
    if ~isempty(tbl_idate)
        for j = 1:nfx
            idxfx_j = strcmpi(tbl_idate.code,codes_fx{j});
            w_j = tbl_idate.weights(idxfx_j);
            if sum(w_j) ~= 0
%                 eod_positions(i,j) = sum(tbl_idate.direction(idxfx_j)) ;
                eod_positions(i,j) = leverage*sum(tbl_idate.weights(idxfx_j))*sum(tbl_idate.direction(idxfx_j)) ;
            end
        end
    end
end
dt_excel = m2xdate(dts);
%%
tbl_i = tbls_allcalib{end};
[dts,~,idx] = unique(floor(datenum(tbl_i.closedatetime,'yyyy-mm-dd HH:MM')));
ndts = length(dts);
eod_positions = zeros(ndts,nfx);
opendtnum = datenum(tbl_i.opendatetime,'yyyy-mm-dd HH:MM:SS');
closedtnum = datenum(tbl_i.closedatetime,'yyyy-mm-dd HH:MM:SS');
for i = 1:ndts
    dt_i = dts(i);
    dt_i = dt_i + 86399/86400;
    idx_i = opendtnum <= dt_i & closedtnum > dt_i;
    tbl_idate = tbl_i(idx_i,:);
    if ~isempty(tbl_idate)
        for j = 1:nfx
            idxfx_j = strcmpi(tbl_idate.code,codes_fx{j});
            eod_positions(i,j) = sum(tbl_idate.direction(idxfx_j)) ;
        end
    end
end
dt_excel = m2xdate(dts);
eod_totalpoitions = sum(abs(eod_positions),2);

%%

N = zeros(nfx,1);
P = N;R = N;K = N;MDD = N;%DD stands for drawdown
WA = N;LA = N;%winavg and lossavg
for i = 1:size(codes_fx,1)
    stats_i = kellyratio2(tbl2check_fx_h4_recalibs{i}.pnlrel);
    N(i) = stats_i.n;
    P(i) = stats_i.w;
    R(i) = stats_i.r;
    K(i) = stats_i.k;
    MDD(i) = stats_i.maxdrawdown;
    WA(i) = stats_i.winavg;
    LA(i) = stats_i.lossavg;
end
statstable_fx_h4_recalibs = table(codes_fx,N,P,R,K,MDD,WA,LA);
%%
% generate calibration stability tables and analysis
% 1. to see how many trades per underlying during each calibration period
audusd = zeros(ncalib,1);
eurusd = zeros(ncalib,1);
gbpusd = zeros(ncalib,1);
usdcad = zeros(ncalib,1);
usdchf = zeros(ncalib,1);
usdjpy = zeros(ncalib,1);
xauusd = zeros(ncalib,1);
for i = 1:ncalib
    tbl_i = tbl_fx_h4_recalibs{i};
    audusd(i) = length(tbl_i.pnlrel(strcmpi(tbl_i.code,'audusd') & tbl_i.trendflag == 0));
    eurusd(i) = length(tbl_i.pnlrel(strcmpi(tbl_i.code,'eurusd') & tbl_i.trendflag == 0));
    gbpusd(i) = length(tbl_i.pnlrel(strcmpi(tbl_i.code,'gbpusd') & tbl_i.trendflag == 0));
    usdcad(i) = length(tbl_i.pnlrel(strcmpi(tbl_i.code,'usdcad') & tbl_i.trendflag == 0));
    usdchf(i) = length(tbl_i.pnlrel(strcmpi(tbl_i.code,'usdchf') & tbl_i.trendflag == 0));
    usdjpy(i) = length(tbl_i.pnlrel(strcmpi(tbl_i.code,'usdjpy') & tbl_i.trendflag == 0));
    xauusd(i) = length(tbl_i.pnlrel(strcmpi(tbl_i.code,'xauusd') & tbl_i.trendflag == 0));
    %
    output = kellyratio2(tbl_i.pnlrel(strcmpi(tbl_i.code,'audusd') & tbl_i.trendflag == 1));
    audusd(i) = output.w;
    output = kellyratio2(tbl_i.pnlrel(strcmpi(tbl_i.code,'eurusd') & tbl_i.trendflag == 1));
    eurusd(i) = output.w;
    output = kellyratio2(tbl_i.pnlrel(strcmpi(tbl_i.code,'gbpusd') & tbl_i.trendflag == 1));
    gbpusd(i) = output.w;
    output = kellyratio2(tbl_i.pnlrel(strcmpi(tbl_i.code,'usdcad') & tbl_i.trendflag == 1));
    usdcad(i) = output.w;
    output = kellyratio2(tbl_i.pnlrel(strcmpi(tbl_i.code,'usdchf') & tbl_i.trendflag == 1));
    usdchf(i) = output.w;
    output = kellyratio2(tbl_i.pnlrel(strcmpi(tbl_i.code,'usdjpy') & tbl_i.trendflag == 1));
    usdjpy(i) = output.w;
    output = kellyratio2(tbl_i.pnlrel(strcmpi(tbl_i.code,'xauusd') & tbl_i.trendflag == 1));
    xauusd(i) = output.w;
end
tblcalib_tradecounts = table(calib_dates,audusd,eurusd,gbpusd,usdcad,usdchf,usdjpy,xauusd);
%
output = kellyratio2(tbl_i.pnlrel(strcmpi(tbl_i.code,'audusd') & tbl_i.trendflag == 1),1);
%%
n = zeros(ncalib,1);p = n;r = n;k = n;mdd = n;winavg = n;lossavg = n;
a = cell(ncalib,1);
code = 'xauusd';
for i = 1:ncalib
    tbl_i = statstable_fx_h4_sizing{i};
    a{i} = code;
    n(i) = tbl_i.N(strcmpi(tbl_i.codes_fx,code));
    p(i) = tbl_i.P(strcmpi(tbl_i.codes_fx,code));
    r(i) = tbl_i.R(strcmpi(tbl_i.codes_fx,code));
    k(i) = tbl_i.K(strcmpi(tbl_i.codes_fx,code));
    mdd(i) = tbl_i.MDD(strcmpi(tbl_i.codes_fx,code));
    winavg(i) = tbl_i.WA(strcmpi(tbl_i.codes_fx,code));
    lossavg(i) = tbl_i.LA(strcmpi(tbl_i.codes_fx,code));
end
tblsizing_rearrange = table(calib_dates,a,n,p,r,k,mdd,winavg,lossavg);
%%
data = load('c:\temp\output_fx_h4_recalibs.mat');output_fx_h4_recalibs = data.output_fx_h4_recalibs;
data = load('c:\temp\tbl_fx_h4_recalibs.mat');tbl_fx_h4_recalibs = data.tbl_fx_h4_recalibs;
data = load('c:\temp\strat_fx_h4_recalibs.mat');strat_fx_h4_recalibs = data.strat_fx_h4_recalibs;
data = load('c:\temp\tbls_allcalib.mat');tbls_allcalib = data.tbls_allcalib;
data = load('c:\temp\statstable_fx_h4_sizing.mat');statstable_fx_h4_sizing = data.statstable_fx_h4_sizing;
data = load('c:\temp\tbl2check_fx_h4_recalibs.mat');tbl2check_fx_h4_recalibs = data.tbl2check_fx_h4_recalibs;
codes_fx = {'audusd';'eurusd';'gbpusd';'usdcad';'usdchf';'usdjpy';'xauusd'};
freq_h4 = 'h4';
nfractal_h4 = charlotte_freq2nfractal(freq_h4);