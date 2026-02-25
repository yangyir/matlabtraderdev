codes_fx =  {'audusd';'eurusd';'gbpusd';'usdcad';'usdchf';'usdjpy';'xauusd'};
nfx = size(codes_fx,1);
freq_h1 = 'h1';
nfractal_h1 = charlotte_freq2nfractal(freq_h1);
%
output_fx_h1_mt5 = fractal_kelly_summary('codes',codes_fx,...
    'frequency','intraday-60m','usefractalupdate',0,'usefibonacci',1,'direction','both',...
    'nfractal',nfractal_h1,'useMT5',1);
[~,~,tbl_fx_h1_mt5,~,~,~,~,strat_fx_h1_mt5] = kellydistributionsummary(output_fx_h1_mt5);
[tbl_report_fx_h1_mt5,stats_report_fx_h1_mt5] = kellydistributionreport(tbl_fx_h1_mt5,strat_fx_h1_mt5);
%%
tbl2check_fx_h1_mt5 = cell(nfx,1);
parfor i = 1:nfx
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_h1,'nfractal',nfractal_h1,'usemt5',1);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_h1_mt5{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,...
        'kellytables',strat_fx_h1_mt5,'showlogs',false,'doplot',false,'frequency',freq_h1,'nfractal',nfractal_h1,...
        'compulsorycheckforconditional',true,...
        'usemt5',1);
end
%%
save('mt5\strat_fx_h1_mt5.mat','stats_report_fx_h1_mt5')
save('mt5\tbl2check_fx_h1_mt5.mat','tbl2check_fx_h1_mt5')
%%
statsout_mt5 = cell(nfx,1);
for i = 1:nfx
    pnlret = tbl2check_fx_h1_mt5{i}.pnlrel;
    opendt = tbl2check_fx_h1_mt5{i}.opendatetime;
    opendt = datestr(opendt,'yyyymm');
    opendtyymm = zeros(size(opendt,1),1);
    
    for j = 1:size(opendt,1)
        opendtyymm(j) = str2double(opendt(j,:));
    end
        
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
    
    opendtyymmunique = unique(opendtyymm);
    res_i = opendtyymmunique;
    for j = 1:size(opendtyymmunique)
        idx_j = find(opendtyymm <= opendtyymmunique(j),1,'last');
        res_i(j,2) = idx_j;
        res_i(j,3) = winp_running(idx_j);
        res_i(j,4) = r_running(idx_j);
        res_i(j,5) = kelly_running(idx_j);
    end
    
    p_converge = -1;
    for j = 2:size(winp_running)
        if winp_running(j) == inf || winp_running(j) == -inf, continue;end
        x = winp_running(j:end);
        x = (x - mean(x))/std(x);
        h = kstest(x,'alpha',0.05);
        if h == 0
            p_converge = j;
            break;
        end
    end
    
    r_converge = -1;
    for j = 2:size(r_running)
        if r_running(j) == inf || r_running(j) == -inf, continue;end
        x = r_running(j:end);
        x = (x - mean(x))/std(x);
        h = kstest(x,'alpha',0.05);
        if h == 0
            r_converge = j;
            break;
        end
    end
    
    k_converge = -1;
    for j = 2:size(kelly_running)
        if kelly_running(j) == inf || kelly_running(j) == -inf, continue;end
        x = kelly_running(j:end);
        x = (x - mean(x))/std(x);
        h = kstest(x,'alpha',0.05);
        if h == 0
            k_converge = j;
            break;
        end
    end
    

    
    statsout_mt5{i} = struct('code',codes_fx{i},...
        'nTotal',size(pnlret,1),...
        'Pwin',Wret,...
        'Rret',Rret,...
        'Kret',Kret,...
        'MaxDrawdownret',pnlretdrawdownmax,...
        'PConverge',p_converge,...
        'RConverge',r_converge,...
        'KConverge',k_converge,...
        'ResMonthByMonth',{res_i},...
        'PRunning',{winp_running},...
        'RRunning',{r_running},...
        'KRunning',{kelly_running});

end

open statsout_mt5
%%
idxpair = 3;
signalmode = 'conditional-uptrendconfirmed-1';
direction = 1;
idxselect = tbl2check_fx_h1_mt5{idxpair}.direction == direction & ...
    strcmpi(tbl2check_fx_h1_mt5{idxpair}.opensignal,signalmode);
kellyselect = unique(tbl2check_fx_h1_mt5{idxpair}.kelly(idxselect,:));
% sanity check 1,i.e.kelly shall be unique
if length(kellyselect) > 1
    error('multiple kelly found for signal:%s\n',signalmode)
end
% sanity check2, i.e check in line with strat table
idx = strcmpi(strat_fx_h1_mt5.breachuplvlup_tc.asset,tbl2check_fx_h1_mt5{idxpair}.code{1});
kellystrat = strat_fx_h1_mt5.breachuplvlup_tc.K(idx);
if abs(kellystrat-kellyselect) > 1e-4
    error('inconsistent kelly found for signal:%s\n',signalmode)
end
% now we extract all trades under the same conditional signal mode
idxselect = tbl2check_fx_h1_mt5{idxpair}.direction == direction & ...
    (strcmpi(tbl2check_fx_h1_mt5{idxpair}.opensignal,signalmode) | ...
    strcmpi(tbl2check_fx_h1_mt5{idxpair}.opensignal,'breachup-lvlup')) & ...
    abs(tbl2check_fx_h1_mt5{idxpair}.kelly - kellyselect) < 1e-4;
tblselect = tbl2check_fx_h1_mt5{idxpair}(idxselect,:);
% let's calculate the stats








