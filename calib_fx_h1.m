codes_fx = {'audusd';'eurusd';'gbpusd';'usdcad';'usdchf';'usdjpy';'xauusd'};
freq_h1 = 'h1';
nfractal_h1 = charlotte_freq2nfractal(freq_h1);
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
strat_fx_h1_existing = load([dir_,'strat_fx_h1.mat']);
strat_fx_h1_existing = strat_fx_h1_existing.strat_fx_h1;
tbl2check_fx_h1_existing = cell(size(codes_fx,1),1);
fprintf('calculate statistics with existing strat tables......\n');
parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_h1,'nfractal',nfractal_h1);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_h1_existing{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_h1_existing,'showlogs',false,'doplot',false,'frequency',freq_h1,'nfractal',nfractal_h1,'compulsorycheckforconditional',true);
end
N = zeros(size(codes_fx,1),1);
P = N;R = N;K = N;MDD = N;%DD stands for drawdown
WA = N;LA = N;%winavg and lossavg
for i = 1:size(codes_fx,1)
    stats_i = kellyratio2(tbl2check_fx_h1_existing{i}.pnlrel);
    N(i) = stats_i.n;
    P(i) = stats_i.w;
    R(i) = stats_i.r;
    K(i) = stats_i.k;
    MDD(i) = stats_i.maxdrawdown;
    WA(i) = stats_i.winavg;
    LA(i) = stats_i.lossavg;
end
statstable_fx_h1_existing = table(codes_fx,N,P,R,K,MDD,WA,LA);
%%
% --------------------------------------------------------------------------
%step1: recalibration
%note:this recalibration is done with each asset alone and then combine
%tables altogether
fprintf('recalibrate strat tables with latest market data......\n')
[strat_fx_h1_recalib,tbltrades_fx_h1_recalib] = charlotte_calibrate('codes',codes_fx,...
    'frequency','intraday-60m','nfractal',nfractal_h1);
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
fprintf('save recalibrated strat tables and relevant trades information......\n')
save([dir_,'strat_fx_h1_recalib.mat'],'strat_fx_h1_recalib');
save([dir_,'tbltrades_fx_h1_recalib.mat'],'tbltrades_fx_h1_recalib');
%%
fprintf('calculate statistics with recalibrated strat tables......\n')
tbl2check_fx_h1_recalib = cell(size(codes_fx,1),1);
parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_h1,'nfractal',nfractal_h1);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_h1_recalib{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_h1_recalib,'showlogs',false,'doplot',false,'frequency',freq_h1,'nfractal',nfractal_h1,'compulsorycheckforconditional',true);
end
N = zeros(size(codes_fx,1),1);
P = N;R = N;K = N;MDD = N;%DD stands for drawdown
WA = N;LA = N;%winavg and lossavg
for i = 1:size(codes_fx,1)
    stats_i = kellyratio2(tbl2check_fx_h1_recalib{i}.pnlrel);
    N(i) = stats_i.n;
    P(i) = stats_i.w;
    R(i) = stats_i.r;
    K(i) = stats_i.k;
    MDD(i) = stats_i.maxdrawdown;
    WA(i) = stats_i.winavg;
    LA(i) = stats_i.lossavg;
end
statstable_fx_h1_recalib = table(codes_fx,N,P,R,K,MDD,WA,LA);
%%
% --------------------------------------------------------------------------
% step2: switch on trend tables below critial values
% ---------------------------------------------------------------------------
fprintf('switching on trend modes with kelly below the critical value of 0.088......\n');
pDummy = 0.6;rDummy = 2;kDummy = 0.4;
strat_fx_h1_trend = strat_fx_h1_recalib;

for i = 1:length(strat_fx_h1_trend.bmtc.K)
    k_i = strat_fx_h1_trend.bmtc.K(i);
    if k_i > 0.05 && k_i < 0.088
        strat_fx_h1_trend.bmtc.W(i) = pDummy;
        strat_fx_h1_trend.bmtc.R(i) = rDummy;
        strat_fx_h1_trend.bmtc.K(i) = kDummy;
    end
end
%
for i = 1:length(strat_fx_h1_trend.bstc.K)
    k_i = strat_fx_h1_trend.bstc.K(i);
    if k_i > 0.05 && k_i < 0.088
        strat_fx_h1_trend.bstc.W(i) = pDummy;
        strat_fx_h1_trend.bstc.R(i) = rDummy;
        strat_fx_h1_trend.bstc.K(i) = kDummy;
    end
end
%
for i = 1:length(strat_fx_h1_trend.breachuplvlup_tc.K)
    k_i = strat_fx_h1_trend.breachuplvlup_tc.K(i);
    if k_i > 0.05 && k_i < 0.088
        strat_fx_h1_trend.breachuplvlup_tc.W(i) = pDummy;
        strat_fx_h1_trend.breachuplvlup_tc.R(i) = rDummy;
        strat_fx_h1_trend.breachuplvlup_tc.K(i) = kDummy;
    end
end
%
for i = 1:length(strat_fx_h1_trend.breachupsshighvalue_tc.K)
    k_i = strat_fx_h1_trend.breachupsshighvalue_tc.K(i);
    if k_i > 0.05 && k_i < 0.088
        strat_fx_h1_trend.breachupsshighvalue_tc.W(i) = pDummy;
        strat_fx_h1_trend.breachupsshighvalue_tc.R(i) = rDummy;
        strat_fx_h1_trend.breachupsshighvalue_tc.K(i) = kDummy;
    end
end
%
for i = 1:length(strat_fx_h1_trend.breachupsshighvalue_tc.K)
    k_i = strat_fx_h1_trend.breachupsshighvalue_tc.K(i);
    if k_i > 0.05 && k_i < 0.088
        strat_fx_h1_trend.breachupsshighvalue_tc.W(i) = pDummy;
        strat_fx_h1_trend.breachupsshighvalue_tc.R(i) = rDummy;
        strat_fx_h1_trend.breachupsshighvalue_tc.K(i) = kDummy;
    end
end
%
for i = 1:length(strat_fx_h1_trend.breachuphighsc13.K)
    k_i = strat_fx_h1_trend.breachuphighsc13.K(i);
    if k_i > 0.05 && k_i < 0.088
        strat_fx_h1_trend.breachuphighsc13.W(i) = pDummy;
        strat_fx_h1_trend.breachuphighsc13.R(i) = rDummy;
        strat_fx_h1_trend.breachuphighsc13.K(i) = kDummy;
    end
end
%
for i = 1:length(strat_fx_h1_trend.smtc.K)
    k_i = strat_fx_h1_trend.smtc.K(i);
    if k_i > 0.05 && k_i < 0.088
        strat_fx_h1_trend.smtc.W(i) = pDummy;
        strat_fx_h1_trend.smtc.R(i) = rDummy;
        strat_fx_h1_trend.smtc.K(i) = kDummy;
    end
end
%
for i = 1:length(strat_fx_h1_trend.sstc.K)
    k_i = strat_fx_h1_trend.sstc.K(i);
    if k_i > 0.05 && k_i < 0.088
        strat_fx_h1_trend.sstc.W(i) = pDummy;
        strat_fx_h1_trend.sstc.R(i) = rDummy;
        strat_fx_h1_trend.sstc.K(i) = kDummy;
    end
end
%
for i = 1:length(strat_fx_h1_trend.breachdnlvldn_tc.K)
    k_i = strat_fx_h1_trend.breachdnlvldn_tc.K(i);
    if k_i > 0.05 && k_i < 0.088
        strat_fx_h1_trend.breachdnlvldn_tc.W(i) = pDummy;
        strat_fx_h1_trend.breachdnlvldn_tc.R(i) = rDummy;
        strat_fx_h1_trend.breachdnlvldn_tc.K(i) = kDummy;
    end
end
%
for i = 1:length(strat_fx_h1_trend.breachdnbshighvalue_tc.K)
    k_i = strat_fx_h1_trend.breachdnbshighvalue_tc.K(i);
    if k_i > 0.05 && k_i < 0.088
        strat_fx_h1_trend.breachdnbshighvalue_tc.W(i) = pDummy;
        strat_fx_h1_trend.breachdnbshighvalue_tc.R(i) = rDummy;
        strat_fx_h1_trend.breachdnbshighvalue_tc.K(i) = kDummy;
    end
end
%
for i = 1:length(strat_fx_h1_trend.breachdnlowbc13.K)
    k_i = strat_fx_h1_trend.breachdnlowbc13.K(i);
    if k_i > 0.05 && k_i < 0.088
        strat_fx_h1_trend.breachdnlowbc13.W(i) = pDummy;
        strat_fx_h1_trend.breachdnlowbc13.R(i) = rDummy;
        strat_fx_h1_trend.breachdnlowbc13.K(i) = kDummy;
    end
end
%
%
%step3:recalculate stats after switching on all trends
%
fprintf('calculate stats with trend modes......\n');
tbl2check_fx_h1_trend = cell(size(codes_fx,1),1);
parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_h1,'nfractal',nfractal_h1);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_h1_trend{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_h1_trend,'showlogs',false,'doplot',false,'frequency',freq_h1,'nfractal',nfractal_h1,'compulsorycheckforconditional',true);
end
N_trend = zeros(size(codes_fx,1),1);
P_trend = N_trend;R_trend = N_trend;K_trend = N_trend;MDD_trend = N_trend;%DD stands for drawdown
WA_trend = N_trend;LA_trend = N_trend;%winavg and lossavg
for i = 1:size(codes_fx,1)
    stats_i_existing = kellyratio2(tbl2check_fx_h1_trend{i}.pnlrel);
    N_trend(i) = stats_i_existing.n;
    P_trend(i) = stats_i_existing.w;
    R_trend(i) = stats_i_existing.r;
    K_trend(i) = stats_i_existing.k;
    MDD_trend(i) = stats_i_existing.maxdrawdown;
    WA_trend(i) = stats_i_existing.winavg;
    LA_trend(i) = stats_i_existing.lossavg;
end
statstable_trend = table(codes_fx,N_trend,P_trend,R_trend,K_trend,MDD_trend,WA_trend,LA_trend);

%%
%
fprintf('modify/update strat tables and select with only positive kelly modes......\n');
strat_fx_h1_new = strat_fx_h1_recalib;
%
for i = 1:size(codes_fx,1)
    code_i = codes_fx{i};
    tbl_i = tbl2check_fx_h1_trend{i};
    %bmtc
    res_ij = charlotte_table_trendanalysis2(tbl_i,'bmtc',strat_fx_h1_recalib);
    k_model = res_ij.k_calib(strcmpi(res_ij.modes,'bmtc'));
    k_real = res_ij.k_empirical(end);
    if k_model < 0
        %nothing to do
    else
        if k_real > 0
            %nothing to do
        elseif k_real <= 0
            n_real = res_ij.n_empirical(end);
            p_real = res_ij.p_empirical(end);
            wa_real = res_ij.wa_empirical(end);
            la_real = res_ij.la_empirical(end);
            idx_ij = strcmpi(strat_fx_h1_new.bmtc.asset,code_i);
            
            strat_fx_h1_new.bmtc.N(idx_ij) = n_real;
            strat_fx_h1_new.bmtc.W(idx_ij) = p_real;
            strat_fx_h1_new.bmtc.K(idx_ij) = k_real;
            strat_fx_h1_new.bmtc.winavg(idx_ij) = wa_real;
            strat_fx_h1_new.bmtc.lossavg(idx_ij) = la_real;
        end
    end
end
%
%
for i = 1:size(codes_fx,1)
    code_i = codes_fx{i};
    tbl_i = tbl2check_fx_h1_trend{i};
    %bstc
    res_ij = charlotte_table_trendanalysis2(tbl_i,'bstc',strat_fx_h1_recalib);
    k_model = res_ij.k_calib(strcmpi(res_ij.modes,'bstc'));
    k_real = res_ij.k_empirical(end);
    if k_model < 0
        %nothing to do
    else
        if k_real > 0
            %nothing to do
        elseif k_real <= 0
            n_real = res_ij.n_empirical(end);
            p_real = res_ij.p_empirical(end);
            wa_real = res_ij.wa_empirical(end);
            la_real = res_ij.la_empirical(end);
            idx_ij = strcmpi(strat_fx_h1_new.bstc.asset,code_i);
            
            strat_fx_h1_new.bstc.N(idx_ij) = n_real;
            strat_fx_h1_new.bstc.W(idx_ij) = p_real;
            strat_fx_h1_new.bstc.K(idx_ij) = k_real;
            strat_fx_h1_new.bstc.winavg(idx_ij) = wa_real;
            strat_fx_h1_new.bstc.lossavg(idx_ij) = la_real;
        end
    end
end
%
%
for i = 1:size(codes_fx,1)
    code_i = codes_fx{i};
    tbl_i = tbl2check_fx_h1_trend{i};
    %breachup-lvlup
    res_ij = charlotte_table_trendanalysis2(tbl_i,'breachup-lvlup',strat_fx_h1_recalib);
    k_model = res_ij.k_calib(strcmpi(res_ij.modes,'breachup-lvlup'));
    k_real = res_ij.k_empirical(end);
    if k_model < 0
        %nothing to do
    else
        if k_real > 0
            %nothing to do
        elseif k_real <= 0
            n_real = res_ij.n_empirical(end);
            p_real = res_ij.p_empirical(end);
            wa_real = res_ij.wa_empirical(end);
            la_real = res_ij.la_empirical(end);
            idx_ij = strcmpi(strat_fx_h1_new.breachuplvlup_tc.asset,code_i);
            
            strat_fx_h1_new.breachuplvlup_tc.N(idx_ij) = n_real;
            strat_fx_h1_new.breachuplvlup_tc.W(idx_ij) = p_real;
            strat_fx_h1_new.breachuplvlup_tc.K(idx_ij) = k_real;
            strat_fx_h1_new.breachuplvlup_tc.winavg(idx_ij) = wa_real;
            strat_fx_h1_new.breachuplvlup_tc.lossavg(idx_ij) = la_real;
        end
    end
end
%
%
for i = 1:size(codes_fx,1)
    code_i = codes_fx{i};
    tbl_i = tbl2check_fx_h1_trend{i};
    %breachup-sshighvalue
    res_ij = charlotte_table_trendanalysis2(tbl_i,'breachup-sshighvalue',strat_fx_h1_recalib);
    k_model = res_ij.k_calib(strcmpi(res_ij.modes,'breachup-sshighvalue'));
    k_real = res_ij.k_empirical(end);
    if k_model < 0
        %nothing to do
    else
        if k_real > 0
            %nothing to do
        elseif k_real <= 0
            n_real = res_ij.n_empirical(end);
            p_real = res_ij.p_empirical(end);
            wa_real = res_ij.wa_empirical(end);
            la_real = res_ij.la_empirical(end);
            idx_ij = strcmpi(strat_fx_h1_new.breachupsshighvalue_tc.asset,code_i);
            
            strat_fx_h1_new.breachupsshighvalue_tc.N(idx_ij) = n_real;
            strat_fx_h1_new.breachupsshighvalue_tc.W(idx_ij) = p_real;
            strat_fx_h1_new.breachupsshighvalue_tc.K(idx_ij) = k_real;
            strat_fx_h1_new.breachupsshighvalue_tc.winavg(idx_ij) = wa_real;
            strat_fx_h1_new.breachupsshighvalue_tc.lossavg(idx_ij) = la_real;
        end
    end
end
%
%
for i = 1:size(codes_fx,1)
    code_i = codes_fx{i};
    tbl_i = tbl2check_fx_h1_trend{i};
    %breachup-highsc13
    res_ij = charlotte_table_trendanalysis2(tbl_i,'breachup-highsc13',strat_fx_h1_recalib);
    k_model = res_ij.k_calib(strcmpi(res_ij.modes,'breachup-highsc13'));
    k_real = res_ij.k_empirical(end);
    if k_model < 0
        %nothing to do
    else
        if k_real > 0
            %nothing to do
        elseif k_real <= 0
            n_real = res_ij.n_empirical(end);
            p_real = res_ij.p_empirical(end);
            wa_real = res_ij.wa_empirical(end);
            la_real = res_ij.la_empirical(end);
            idx_ij = strcmpi(strat_fx_h1_new.breachuphighsc13.asset,code_i);
            
            strat_fx_h1_new.breachuphighsc13.N(idx_ij) = n_real;
            strat_fx_h1_new.breachuphighsc13.W(idx_ij) = p_real;
            strat_fx_h1_new.breachuphighsc13.K(idx_ij) = k_real;
            strat_fx_h1_new.breachuphighsc13.winavg(idx_ij) = wa_real;
            strat_fx_h1_new.breachuphighsc13.lossavg(idx_ij) = la_real;
        end
    end
end
%
%
for i = 1:size(codes_fx,1)
    code_i = codes_fx{i};
    tbl_i = tbl2check_fx_h1_trend{i};
    %smtc
    res_ij = charlotte_table_trendanalysis2(tbl_i,'smtc',strat_fx_h1_recalib);
    k_model = res_ij.k_calib(strcmpi(res_ij.modes,'smtc'));
    k_real = res_ij.k_empirical(end);
    if k_model < 0
        %nothing to do
    else
        if k_real > 0
            %nothing to do
        elseif k_real <= 0
            n_real = res_ij.n_empirical(end);
            p_real = res_ij.p_empirical(end);
            wa_real = res_ij.wa_empirical(end);
            la_real = res_ij.la_empirical(end);
            idx_ij = strcmpi(strat_fx_h1_new.smtc.asset,code_i);
            
            strat_fx_h1_new.smtc.N(idx_ij) = n_real;
            strat_fx_h1_new.smtc.W(idx_ij) = p_real;
            strat_fx_h1_new.smtc.K(idx_ij) = k_real;
            strat_fx_h1_new.smtc.winavg(idx_ij) = wa_real;
            strat_fx_h1_new.smtc.lossavg(idx_ij) = la_real;
        end
    end
end
%
for i = 1:size(codes_fx,1)
    code_i = codes_fx{i};
    tbl_i = tbl2check_fx_h1_trend{i};
    %sstc
    res_ij = charlotte_table_trendanalysis2(tbl_i,'sstc',strat_fx_h1_recalib);
    k_model = res_ij.k_calib(strcmpi(res_ij.modes,'sstc'));
    k_real = res_ij.k_empirical(end);
    if k_model < 0
        %nothing to do
    else
        if k_real > 0
            %nothing to do
        elseif k_real <= 0
            n_real = res_ij.n_empirical(end);
            p_real = res_ij.p_empirical(end);
            wa_real = res_ij.wa_empirical(end);
            la_real = res_ij.la_empirical(end);
            idx_ij = strcmpi(strat_fx_h1_new.sstc.asset,code_i);
            
            strat_fx_h1_new.sstc.N(idx_ij) = n_real;
            strat_fx_h1_new.sstc.W(idx_ij) = p_real;
            strat_fx_h1_new.sstc.K(idx_ij) = k_real;
            strat_fx_h1_new.sstc.winavg(idx_ij) = wa_real;
            strat_fx_h1_new.sstc.lossavg(idx_ij) = la_real;
        end
    end
end
%
for i = 1:size(codes_fx,1)
    code_i = codes_fx{i};
    tbl_i = tbl2check_fx_h1_trend{i};
    %breachdn-lvldn
    res_ij = charlotte_table_trendanalysis2(tbl_i,'breachdn-lvldn',strat_fx_h1_recalib);
    k_model = res_ij.k_calib(strcmpi(res_ij.modes,'breachdn-lvldn'));
    k_real = res_ij.k_empirical(end);
    if k_model < 0
        %nothing to do
    else
        if k_real > 0
            %nothing to do
        elseif k_real <= 0
            n_real = res_ij.n_empirical(end);
            p_real = res_ij.p_empirical(end);
            wa_real = res_ij.wa_empirical(end);
            la_real = res_ij.la_empirical(end);
            idx_ij = strcmpi(strat_fx_h1_new.breachdnlvldn_tc.asset,code_i);
            
            strat_fx_h1_new.breachdnlvldn_tc.N(idx_ij) = n_real;
            strat_fx_h1_new.breachdnlvldn_tc.W(idx_ij) = p_real;
            strat_fx_h1_new.breachdnlvldn_tc.K(idx_ij) = k_real;
            strat_fx_h1_new.breachdnlvldn_tc.winavg(idx_ij) = wa_real;
            strat_fx_h1_new.breachdnlvldn_tc.lossavg(idx_ij) = la_real;
        end
    end
end
%
for i = 1:size(codes_fx,1)
    code_i = codes_fx{i};
    tbl_i = tbl2check_fx_h1_trend{i};
    %breachdn-bshighvalue
    res_ij = charlotte_table_trendanalysis2(tbl_i,'breachdn-bshighvalue',strat_fx_h1_recalib);
    k_model = res_ij.k_calib(strcmpi(res_ij.modes,'breachdn-bshighvalue'));
    k_real = res_ij.k_empirical(end);
    if k_model < 0
        %nothing to do
    else
        if k_real > 0
            %nothing to do
        elseif k_real <= 0
            n_real = res_ij.n_empirical(end);
            p_real = res_ij.p_empirical(end);
            wa_real = res_ij.wa_empirical(end);
            la_real = res_ij.la_empirical(end);
            idx_ij = strcmpi(strat_fx_h1_new.breachdnbshighvalue_tc.asset,code_i);
            
            strat_fx_h1_new.breachdnbshighvalue_tc.N(idx_ij) = n_real;
            strat_fx_h1_new.breachdnbshighvalue_tc.W(idx_ij) = p_real;
            strat_fx_h1_new.breachdnbshighvalue_tc.K(idx_ij) = k_real;
            strat_fx_h1_new.breachdnbshighvalue_tc.winavg(idx_ij) = wa_real;
            strat_fx_h1_new.breachdnbshighvalue_tc.lossavg(idx_ij) = la_real;
        end
    end
end
%
for i = 1:size(codes_fx,1)
    code_i = codes_fx{i};
    tbl_i = tbl2check_fx_h1_trend{i};
    %breachdn-lowbc13
    res_ij = charlotte_table_trendanalysis2(tbl_i,'breachdn-lowbc13',strat_fx_h1_recalib);
    k_model = res_ij.k_calib(strcmpi(res_ij.modes,'breachdn-lowbc13'));
    k_real = res_ij.k_empirical(end);
    if k_model < 0
        %nothing to do
    else
        if k_real > 0
            %nothing to do
        elseif k_real <= 0
            n_real = res_ij.n_empirical(end);
            p_real = res_ij.p_empirical(end);
            wa_real = res_ij.wa_empirical(end);
            la_real = res_ij.la_empirical(end);
            idx_ij = strcmpi(strat_fx_h1_new.breachdnlowbc13.asset,code_i);
            
            strat_fx_h1_new.breachdnlowbc13.N(idx_ij) = n_real;
            strat_fx_h1_new.breachdnlowbc13.W(idx_ij) = p_real;
            strat_fx_h1_new.breachdnlowbc13.K(idx_ij) = k_real;
            strat_fx_h1_new.breachdnlowbc13.winavg(idx_ij) = wa_real;
            strat_fx_h1_new.breachdnlowbc13.lossavg(idx_ij) = la_real;
        end
    end
end

%%
tbl2check_fx_h1_new = cell(size(codes_fx,1),1);

parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_h1,'nfractal',nfractal_h1);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_h1_new{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_h1_new,'showlogs',false,'doplot',false,'frequency',freq_h1,'nfractal',nfractal_h1,'compulsorycheckforconditional',true);
end
N_new = zeros(size(codes_fx,1),1);
P_new = N_new;R_new = N_new;K_new = N_new;MDD_new = N_new;%DD stands for drawdown
WA_new = N_new;LA_new = N_new;%winavg and lossavg
for i = 1:size(codes_fx,1)
    stats_i_new = kellyratio2(tbl2check_fx_h1_new{i}.pnlrel);
    N_new(i) = stats_i_new.n;
    P_new(i) = stats_i_new.w;
    R_new(i) = stats_i_new.r;
    K_new(i) = stats_i_new.k;
    MDD_new(i) = stats_i_new.maxdrawdown;
    WA_new(i) = stats_i_new.winavg;
    LA_new(i) = stats_i_new.lossavg;
end

tbl2check_fx_h1_new_combined = [tbl2check_fx_h1_new{1};...
    tbl2check_fx_h1_new{2};...
    tbl2check_fx_h1_new{3};...
    tbl2check_fx_h1_new{4};...
    tbl2check_fx_h1_new{5};...
    tbl2check_fx_h1_new{6};...
    tbl2check_fx_h1_new{7}];

statstable_fx_h1_new = table(codes_fx,N_new,P_new,R_new,K_new,MDD_new,WA_new,LA_new);
%%
save([dir_,'strat_fx_h1_new.mat'],'strat_fx_h1_new');
save([dir_,'tbl2check_fx_h1_new_combined.mat'],'tbl2check_fx_h1_new_combined');