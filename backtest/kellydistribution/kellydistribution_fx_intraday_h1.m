dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
strat_fx_h1_existing = load([dir_,'strat_fx_h1.mat']);
strat_fx_h1_existing = strat_fx_h1_existing.strat_fx_h1;
codes_fx = {'audusd';'eurusd';'gbpusd';'usdcad';'usdchf';'usdjpy';'xauusd'};
freq_h1 = 'h1';
nfractal_h1 = charlotte_freq2nfractal(freq_h1);
%%
tbl2check_fx_h1_existing = cell(size(codes_fx,1),1);
%
%set untrended breachuplvlup unused
for i = 1:size(strat_fx_h1_existing.breachuplvlup_tb,1)
    strat_fx_h1_existing.breachuplvlup_tb.W(i) = 0.3;
    strat_fx_h1_existing.breachuplvlup_tb.R(i) = 1;
    strat_fx_h1_existing.breachuplvlup_tb.K(i) = -0.05;
end
%
%set untrended breachupsshighvalue unused
for i = 1:size(strat_fx_h1_existing.breachupsshighvalue_tb,1)
    strat_fx_h1_existing.breachupsshighvalue_tb.W(i) = 0.3;
    strat_fx_h1_existing.breachupsshighvalue_tb.R(i) = 1;
    strat_fx_h1_existing.breachupsshighvalue_tb.K(i) = -0.05;
end
%
%set untrended breachdnlvldn unused
for i = 1:size(strat_fx_h1_existing.breachdnlvldn_tb,1)
    strat_fx_h1_existing.breachdnlvldn_tb.W(i) = 0.3;
    strat_fx_h1_existing.breachdnlvldn_tb.R(i) = 1;
    strat_fx_h1_existing.breachdnlvldn_tb.K(i) = -0.05;
end
%set untrended breachdnbshighvalue unused
for i = 1:size(strat_fx_h1_existing.breachdnbshighvalue_tb,1)
    strat_fx_h1_existing.breachdnbshighvalue_tb.W(i) = 0.3;
    strat_fx_h1_existing.breachdnbshighvalue_tb.R(i) = 1;
    strat_fx_h1_existing.breachdnbshighvalue_tb.K(i) = -0.05;
end
%
parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_h1,'nfractal',nfractal_h1);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_h1_existing{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_h1_existing,'showlogs',false,'doplot',false,'frequency',freq_h1,'nfractal',nfractal_h1,'compulsorycheckforconditional',true);
end
N_existing = zeros(size(codes_fx,1),1);
P_existing = N_existing;R_existing = N_existing;K_existing = N_existing;MDD_existing = N_existing;%DD stands for drawdown
WA_existing = N_existing;LA_existing = N_existing;%winavg and lossavg
for i = 1:size(codes_fx,1)
    stats_i_existing = kellyratio2(tbl2check_fx_h1_existing{i}.pnlrel);
    N_existing(i) = stats_i_existing.n;
    P_existing(i) = stats_i_existing.w;
    R_existing(i) = stats_i_existing.r;
    K_existing(i) = stats_i_existing.k;
    MDD_existing(i) = stats_i_existing.maxdrawdown;
    WA_existing(i) = stats_i_existing.winavg;
    LA_existing(i) = stats_i_existing.lossavg;
end
statstable_existing = table(codes_fx,N_existing,P_existing,R_existing,K_existing,MDD_existing,WA_existing,LA_existing);

%%
recalibrate = input('do you want to recalibrate the kelly criteria table? Y/N: ','s');
if strcmpi(recalibrate,'Y')
    output_fx_h1 = fractal_kelly_summary('codes',codes_fx,...
        'frequency','intraday-60m','usefractalupdate',0,'usefibonacci',1,'direction','both',...
        'nfractal',nfractal_h1,...
        'useMT5',1,...
        'fromdate','2023-07-01');
    [~,~,tbl_fx_h1,~,~,~,~,strat_fx_h1] = kellydistributionsummary(output_fx_h1);
    [tbl_report_fx_h1,stats_report_fx_h1] = kellydistributionreport(tbl_fx_h1,strat_fx_h1);
else
    strat_fx_h1 = strat_fx_h1_existing;
end

%%
charlotte_strat_compare('existing',strat_fx_h1_existing,'updated',strat_fx_h1,'assetname','xauusd');
%%
tbl2check_fx_h1 = cell(size(codes_fx,1),1);
%
%set untrended breachuplvlup unused
for i = 1:size(strat_fx_h1.breachuplvlup_tb,1)
    strat_fx_h1.breachuplvlup_tb.W(i) = 0.3;
    strat_fx_h1.breachuplvlup_tb.R(i) = 1;
    strat_fx_h1.breachuplvlup_tb.K(i) = -0.05;
end
%
%set untrended breachupsshighvalue unused
for i = 1:size(strat_fx_h1.breachupsshighvalue_tb,1)
    strat_fx_h1.breachupsshighvalue_tb.W(i) = 0.3;
    strat_fx_h1.breachupsshighvalue_tb.R(i) = 1;
    strat_fx_h1.breachupsshighvalue_tb.K(i) = -0.05;
end
%
%set untrended breachdnlvldn unused
for i = 1:size(strat_fx_h1.breachdnlvldn_tb,1)
    strat_fx_h1.breachdnlvldn_tb.W(i) = 0.3;
    strat_fx_h1.breachdnlvldn_tb.R(i) = 1;
    strat_fx_h1.breachdnlvldn_tb.K(i) = -0.05;
end
%set untrended breachdnbshighvalue unused
for i = 1:size(strat_fx_h1.breachdnbshighvalue_tb,1)
    strat_fx_h1.breachdnbshighvalue_tb.W(i) = 0.3;
    strat_fx_h1.breachdnbshighvalue_tb.R(i) = 1;
    strat_fx_h1.breachdnbshighvalue_tb.K(i) = -0.05;
end
%
parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_h1,'nfractal',nfractal_h1);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_h1{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_h1,'showlogs',false,'doplot',false,'frequency',freq_h1,'nfractal',nfractal_h1,'compulsorycheckforconditional',true);
end
N = zeros(size(codes_fx,1),1);
P = N;R = N;K = N;MDD = N;%DD stands for drawdown
WA = N;LA = N;%winavg and lossavg
for i = 1:size(codes_fx,1)
    stats_i = kellyratio2(tbl2check_fx_h1{i}.pnlrel);
    N(i) = stats_i.n;
    P(i) = stats_i.w;
    R(i) = stats_i.r;
    K(i) = stats_i.k;
    MDD(i) = stats_i.maxdrawdown;
    WA(i) = stats_i.winavg;
    LA(i) = stats_i.lossavg;
end
statstable_updated = table(codes_fx,N,P,R,K,MDD,WA,LA);

% tbl2check_fx_h1_all = tbl2check_fx_h1{1};
% for i = 2:size(codes_fx,1)
%     temp = [tbl2check_fx_h1_all;tbl2check_fx_h1{i}];
%     tbl2check_fx_h1_all = temp;
% end
% tbl2check_fx_h1_all = sortrows(tbl2check_fx_h1_all,'opendatetime','ascend');
%%
% % %%
% % statsout = cell(size(codes_fx,1),1);
% % for i = 1:size(codes_fx,1)
% %     
% %     idxselect = strcmpi(tbl2check_fx_h1_all.code,codes_fx{i});    
% %     pnlret = tbl2check_fx_h1_all.pnlrel(idxselect);
% %     opendt = tbl2check_fx_h1_all.opendatetime(idxselect);
% %     opendt = datestr(opendt,'yyyymm');
% %     opendtyymm = zeros(size(opendt,1),1);
% %     for j = 1:size(opendt,1)
% %         opendtyymm(j) = str2double(opendt(j,:));
% %     end
% %         
% %     [winp_running,r_running,kelly_running] = calcrunningkelly(pnlret);
% %     
% %     opendtyymmunique = unique(opendtyymm);
% %     res_i = opendtyymmunique;
% %     for j = 1:size(opendtyymmunique)
% %         idx_j = find(opendtyymm <= opendtyymmunique(j),1,'last');
% %         res_i(j,2) = idx_j;
% %         res_i(j,3) = winp_running(idx_j);
% %         res_i(j,4) = r_running(idx_j);
% %         res_i(j,5) = kelly_running(idx_j);
% %     end
% %     
% %     p_converge = -1;
% %     for j = 2:size(winp_running)
% %         if winp_running(j) == inf || winp_running(j) == -inf, continue;end
% %         x = winp_running(j:end);
% %         x = (x - mean(x))/std(x);
% %         h = kstest(x,'alpha',0.05);
% %         if h == 0
% %             p_converge = j;
% %             break;
% %         end
% %     end
% %     PC(i) = p_converge;
% %     
% %     r_converge = -1;
% %     for j = 2:size(r_running)
% %         if r_running(j) == inf || r_running(j) == -inf, continue;end
% %         x = r_running(j:end);
% %         x = (x - mean(x))/std(x);
% %         h = kstest(x,'alpha',0.05);
% %         if h == 0
% %             r_converge = j;
% %             break;
% %         end
% %     end
% %     
% %     k_converge = -1;
% %     for j = 2:size(kelly_running)
% %         if kelly_running(j) == inf || kelly_running(j) == -inf, continue;end
% %         x = kelly_running(j:end);
% %         x = (x - mean(x))/std(x);
% %         h = kstest(x,'alpha',0.05);
% %         if h == 0
% %             k_converge = j;
% %             break;
% %         end
% %     end
% %     KC(i) = k_converge;
% %     
% %     
% %     code_i = codes_fx{i};
% %     
% %     statsout{i} = struct('code',code_i,...
% %         'nTotal',stats_i.n,...
% %         'Pwin',stats_i.w,...
% %         'Rret',stats_i.r,...
% %         'Kret',stats_i.k,...
% %         'MaxDrawdownret',stats_i.maxdrawdown,...
% %         'PConverge',p_converge,...
% %         'RConverge',r_converge,...
% %         'KConverge',k_converge,...
% %         'ResMonthByMonth',{res_i},...
% %         'PRunning',{winp_running},...
% %         'RRunning',{r_running},...
% %         'KRunning',{kelly_running});
% % %
% % end
% % 
% % fprintf('done with mt4 fx of %s time frame...\n',freq_h1);
%%

save([dir_,'strat_fx_h1.mat'],'strat_fx_h1');
save([dir_,'tbl2check_fx_h1_all.mat'],'tbl2check_fx_h1_all');
fprintf('strat fx h1 mat-file saved...\n');
