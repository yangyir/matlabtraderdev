freq_signal = '4h';
freq_execution = 'm30';
nfractal_signal = charlotte_freq2nfractal(freq_signal);
nfractal_execution = charlotte_freq2nfractal(freq_execution);
codes_fx = {'audusd';'eurusd';'gbpusd';'usdcad';'usdchf';'usdjpy';'xauusd'};
nfx = length(codes_fx);

ei1 = cell(nfx,1);          % MT4 data of freq_signal
ei1_mt5 = cell(nfx,1);      % MT5 data of freq_signal
ei2_mt5 = cell(nfx,1);      % MT5 data of freq_execution
for i = 1:nfx
    [~,ei_i] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_signal,'nfractal',nfractal_signal,'usemt5',0);
    ei1{i} = ei_i;
    [~,ei_i] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_signal,'nfractal',nfractal_signal,'usemt5',1);
    ei1_mt5{i} = ei_i;
    [~,ei_i] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_execution,'nfractal',nfractal_execution,'usemt5',1);
    ei2_mt5{i} = ei_i;
end
%
% ei1_mt5 shall be cutoff from the first datetime of ei2_mt5
cutoff_dts = cell(nfx,1);
fprintf('\n');
for i = 1:nfx
    cutoff_dt = ei1{i}.px(1,1);
    cutoff_idx = find(ei1_mt5{i}.px(:,1)>=cutoff_dt,1,'first');
    ei_i = fractal_truncate(ei1_mt5{i},size(ei1_mt5{i}.px,1),cutoff_idx);
    ei1_mt5{i} = ei_i;
    fprintf('%s:back from %s\n',codes_fx{i},datestr(ei1_mt5{i}.px(1,1)));
    cutoff_dts{i} = datestr(cutoff_dt,'yyyy-mm-dd HH:MM');
end
%%

% data = load('c:\temp\celltrades.mat');celltrades = data.celltrades;
% data = load('c:\temp\strat_new.mat');strat_new = data.strat_new;
[strat_new,celltrades] = charlotte_calibrate('codes',codes_fx,'frequency','intraday-240m','nfractal',nfractal_signal,'usemt5',1,'fromdates',cutoff_dts);
%
tbltradestrend = cell(nfx,1);
for i = 1:nfx
    tbltrades = kellydistributionreport(celltrades{i},strat_new);
    tbltradestrend{i} = tbltrades(tbltrades.trendflag == 1 & tbltrades.use2 == 1,:);
end
%%
% ATRSL calibration
atrsl = 2;
xvalues = zeros(nfx,1);
ratio = 0.95;
for i = 1:nfx
    output = charlotte_atr_run('TableTrades',tbltradestrend{i},...
    'ExtraInfo',ei1_mt5{i},...
    'ATRBreakEven',[],...
    'ATRSL',atrsl,...
    'ATRTP',[]);
    
    pnl = output.PnL;
    atrmae = output.MAE;
    atrmfe = output.MFE;
    initialloss = output.InitialLoss;

    % initial stop optimization with profit-weighted MAE
    idxwin = pnl >= 0;
    maedist = [atrmae(idxwin),pnl(idxwin)];
    maedist = sortrows(maedist);

    xvalues(i) = maedist(find(cumsum(maedist(:,2)) > ratio*sum(maedist(:,2)),1,'first'),1);

end
tblxvalues = table(codes_fx,round(xvalues,1));
%audusd:1.5
%eurusd:1.5
%gbpusd:1.5
%usdcad:1.9
%usdchf:1.7
%usdjpy:1.6
%xauusd:1.7

% figure(2)
% plot(maedist(:,1),cumsum(maedist(:,2))/sum(maedist(:,2)),'b');hold on;
% xline(x1, 'r--', num2str(x1), 'LineWidth', 1.5,'LabelVerticalAlignment','bottom');
% yline(ratio,'r--','95% Threshold', 'LineWidth', 1.5)
% hold off;
% title([upper(code),' ALL: Profit-Weighted CDF'], 'FontSize', 12);
% xlabel('MAE-ATR','FontSize',8,'FontWeight','bold');
% ylabel('CDF','FontSize', 8,'FontWeight','bold');
%
%%
% ATRTP calibration
tps = 2.0:0.1:6;
ntps = length(tps);
sharpstp = cell(nfx,1);
totalpnltp = cell(nfx,1);
yvalues = zeros(nfx,1);
for i = 1:nfx
    output = charlotte_atr_run('TableTrades',tbltradestrend{i},...
    'ExtraInfo',ei1_mt5{i},...
    'ATRBreakEven',[],...
    'ATRSL',round(xvalues(i),1),...
    'ATRTP',[]);
    
    pnl = output.PnL;
    atrmae = output.MAE;
    atrmfe = output.MFE;
    initialloss = output.InitialLoss;

    % initial stop optimization with profit-weighted MAE
%     idxwin = pnl >= 0;
%     mfedist = [atrmfe(idxwin),pnl(idxwin),initialloss(idxwin)];
    mfedist = [atrmfe,pnl,initialloss];
    sharp_i = zeros(ntps,1);
    totalpnl_i = zeros(ntps,1);

    for j = 1:ntps
        pnl_j = mfedist(:,2);
        for k = 1:size(mfedist,1)
            if mfedist(k,1) > tps(j)
                pnl_j(k) = tps(j)*mfedist(k,3);
            end
        end
        temp = kellyratio2(pnl_j);
        sharp_i(j) = temp.sharp;
        totalpnl_i(j) = temp.totalpl;
    end
    sharpstp{i} = sharp_i;
    totalpnltp{i} = totalpnl_i;
%     [~,idx] = max(totalpnl_i);
%     yvalues(i) = tps(idx);
end

figure(3)
for i = 1:nfx
    subplot(2,4,i)
    [hAx,hLine1,hLine2] = plotyy(tps,sharpstp{i},tps,totalpnltp{i});
    title(codes_fx{i});
    xlabel('ATRTP');grid on;
    ylabel(hAx(1),'sharp') % left y-axis 
    ylabel(hAx(2),'total pnl') % right y-axis
end
yvalues = [4.2;3.0;3.5;4.8;3.5;3.5;3.5];
%audusd:4.2
%eurusd:3.0
%gbpusd:3.5
%usdcad:4.8
%usdchf:3.5
%usdjpy:3.5
%xauusd:3.5

%% 
% ATR lambda calibration
statsperfx = cell(nfx,1);
atrlambdavec = 0:0.1:1;
nlambda = length(atrlambdavec);
for ifx = 1:nfx
    tbltradestrend_i = tbltradestrend{ifx};
    ei_i = ei1_mt5{ifx};
    nbars_i = size(ei_i.px,1);
    ntrades_i = size(tbltradestrend_i,1);
    stats_ifx = cell(nlambda,1);
    for ilambda = 1:nlambda
        output = charlotte_atr_run('TableTrades',tbltradestrend_i,...
            'ExtraInfo',ei1_mt5{ifx},...
            'ATRBreakEven',1.5,...
            'ATRSL',round(xvalues(ifx),1),...
            'ATRTP',yvalues(ifx),...
            'ATRLambda',atrlambdavec(ilambda));
        stats_ifx{ilambda} = kellyratio2(output.PnL);
    end
    statsperfx{ifx} = stats_ifx;
end
%audusd:0.5
%eurusd:0.5
%gbpusd:0.5
%usdcad:0.5
%usdchf:0.5
%usdjpy:0.5
%xauusd:0.5

%% 
% plot ATR lambda against different stats
ifx = 7;
stats = statsperfx{ifx};
kvec = 0*atrlambdavec;
wvec = kvec;
rvec = kvec;
sharpvec = kvec;
calmarvec = kvec;
totalpnlvec = kvec;
for i = 1:length(stats)
    kvec(i) = stats{i}.k;
    wvec(i) = stats{i}.w;
    rvec(i) = stats{i}.r;
    sharpvec(i) = stats{i}.sharp;
    calmarvec(i) = stats{i}.calmar;
    totalpnlvec(i) = stats{i}.totalpl;
end
figure(4);
subplot(231);plot(atrlambdavec,kvec,'b');title([codes_fx{ifx},'-kelly']);xlabel('lamdba');grid on;
subplot(232);plot(atrlambdavec,wvec,'b');title([codes_fx{ifx},'-winp']);xlabel('lamdba');grid on;
subplot(233);plot(atrlambdavec,rvec,'b');title([codes_fx{ifx},'-ratio']);xlabel('lamdba');grid on;
subplot(234);plot(atrlambdavec,sharpvec,'b');title([codes_fx{ifx},'-sharp']);xlabel('lamdba');grid on;
subplot(235);plot(atrlambdavec,calmarvec,'b');title([codes_fx{ifx},'-calmar']);xlabel('lamdba');grid on;
subplot(236);plot(atrlambdavec,totalpnlvec,'b');title([codes_fx{ifx},'-pnl']);xlabel('lamdba');grid on;
%%
% after all the calibration of ATR related parameters
% re-calibrate the strat table 
[strat_new,~] = charlotte_calibrate('codes',codes_fx,'frequency','intraday-240m','nfractal',nfractal_signal,'usemt5',1,'fromdates',cutoff_dts);
%%
condsignals = cell(nfx,1);
parfor i = 1:nfx
    fut_i = code2instrument(codes_fx{i});
    ei_i = ei1_mt5{i};
    nbars_i = size(ei_i.px,1);
    condsignals_i = cell(nbars_i,2);
    for j = 1:nbars_i
        ei_ij = fractal_truncate(ei_i,j);
        signal = fractal_signal_conditional2('extrainfo',ei_ij,...
            'ticksize',fut_i.tick_size,...
            'nfractal',nfractal_signal,...
            'kellytables',strat_new,...
            'assetname',fut_i.asset_name,...
            'ticksizeratio',1);
        if ~isempty(signal)
            condsignals_i{j,1} = signal.directionkellied;
            condsignals_i{j,2} = signal;
        end
    end
    condsignals{i} = condsignals_i;
end
fprintf('\nconditional signals are popped-up....\n');
%%
% popup trades with conditional signals
tradescell = cell(nfx,1);
parfor i = 1:nfx
    fut_i = code2instrument(codes_fx{i});
    ei_i = ei1_mt5{i};
    nbars_i = size(ei_i.px,1);
    trades_i = cTradeOpenArray;
    condsignals_i = condsignals{i};
    code_i = codes_fx{i};
    for j = 2:nbars_i
        if isempty(condsignals_i{j-1}), continue;end
        if condsignals_i{j-1,1} == 0, continue;end

        ei_ij = fractal_truncate(ei_i,j);
        trade = fractal_gentrade2(ei_ij,code_i,j,freq_signal,nfractal_signal,strat_new);
        if ~isempty(trade)
            % also we need to make sure the trade has the same direction as
            % the signal
            if trade.opendirection_ ~= condsignals_i{j-1,1}, continue;end
            trades_i.push(trade);
        end
    end
    tradescell{i} = trades_i;
end
fprintf('trades with conditional breakout signals generated....\n');
%%
% N = zeros(size(codes_fx,1),1);
% P = N;R = N;K = N;MDD = N;%DD stands for drawdown
% WA = N;LA = N;%winavg and lossavg
% 
% for i = 1:nfx
%     tbltrades = celltrades{i};
%     tbltradestrend{i} = tbltrades(tbltrades.trendflag == 1,:);
%     stats_i = kellyratio2(tbltradestrend{i}.pnlrel);
%     N(i) = stats_i.n;
%     P(i) = stats_i.w;
%     R(i) = stats_i.r;
%     K(i) = stats_i.k;
%     MDD(i) = stats_i.maxdrawdown;
%     WA(i) = stats_i.winavg;
%     LA(i) = stats_i.lossavg;
% end
% statstable_fx_h4_atrrecalib1 = table(codes_fx,N,P,R,K,MDD,WA,LA);
% 
% %%
% tbl2check_fx_h4_atrrecalib = cell(size(codes_fx,1),1);
% parfor i = 1:size(codes_fx,1)
%     ei_i = ei{i};
%     dt1 = datestr(ei_i.px(1,1),'yyyy-mm-dd');
%     dt2 = datestr(ei_i.px(end,1),'yyyy-mm-dd');
%     [~,~,tbl2check_fx_h4_atrrecalib{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_new,'showlogs',false,'doplot',false,'frequency',freq_h4,'nfractal',nfractal_h4,'compulsorycheckforconditional',true);
% end
% N = zeros(size(codes_fx,1),1);
% P = N;R = N;K = N;MDD = N;%DD stands for drawdown
% WA = N;LA = N;%winavg and lossavg
% for i = 1:size(codes_fx,1)
%     stats_i = kellyratio2(tbl2check_fx_h4_atrrecalib{i}.pnlrel);
%     N(i) = stats_i.n;
%     P(i) = stats_i.w;
%     R(i) = stats_i.r;
%     K(i) = stats_i.k;
%     MDD(i) = stats_i.maxdrawdown;
%     WA(i) = stats_i.winavg;
%     LA(i) = stats_i.lossavg;
% end
% statstable_fx_h4_atrrecalib = table(codes_fx,N,P,R,K,MDD,WA,LA);
% %%
% itrade = 22;
% idx = tbltradestrend.openid(itrade);
% mode = tbltradestrend.opensignal(itrade);
% longshort = tbltradestrend.direction(itrade);
% trade = fractal_gentrade(ei,code,idx,mode,longshort,freq_h4,nfractal_h4,true);
% 
% for i = idx:size(ei.px,1)
%     ei_i = fractal_truncate(ei,i);
%     ei_i.latestopen = ei_i.px(end,5);    
%     tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
%             'usecandlelastonly',false,...
%             'debug',false,...
%             'updatepnlforclosedtrade',true,...
%             'extrainfo',ei_i,...
%             'RunRiskManagementBeforeMktClose',false);
% %     fprintf('%f\n',trade.riskmanager_.pxstoploss2_);
%     if ~isempty(tradeout)
%         break
%     end
% end
% fractal_plottrade(trade,0);



%%


