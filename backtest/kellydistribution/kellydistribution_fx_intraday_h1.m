dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
strat_fx_h1_existing = load([dir_,'strat_fx_h1.mat']);
strat_fx_h1_existing = strat_fx_h1_existing.strat_fx_h1;
codes_fx = {'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf';'xauusd'};
freq_h1 = 'h1';
nfractal_h1 = charlotte_freq2nfractal(freq_h1);
%%
recalibrate = input('do you want to recalibrate the kelly criteria table? Y/N: ','s');
if strcmpi(recalibrate,'Y')
    output_fx_h1 = fractal_kelly_summary('codes',codes_fx,...
        'frequency','intraday-60m','usefractalupdate',0,'usefibonacci',1,'direction','both',...
        'nfractal',nfractal_h1);
    [~,~,tbl_fx_h1,~,~,~,~,strat_fx_h1] = kellydistributionsummary(output_fx_h1);
    [tbl_report_fx_h1,stats_report_fx_h1] = kellydistributionreport(tbl_fx_h1,strat_fx_h1);
else
    strat_fx_h1 = strat_fx_h1_existing;
end

%%
charlotte_strat_compare('strat1',strat_fx_h1_existing,'strat2',strat_fx_h1,'assetname','xauusd');
%%
tbl2check_fx_h1 = cell(size(codes_fx,1),1);
parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_h1,'nfractal',nfractal_h1);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_h1{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_h1,'showlogs',false,'doplot',false,'frequency',freq_h1,'nfractal',nfractal_h1,'compulsorycheckforconditional',true);
end
tbl2check_fx_h1_all = tbl2check_fx_h1{1};
for i = 2:size(codes_fx,1)
    temp = [tbl2check_fx_h1_all;tbl2check_fx_h1{i}];
    tbl2check_fx_h1_all = temp;
end
tbl2check_fx_h1_all = sortrows(tbl2check_fx_h1_all,'opendatetime','ascend');
%%
statsout = cell(size(codes_fx,1),1);
for i = 1:size(codes_fx,1)
    
    idxselect = strcmpi(tbl2check_fx_h1_all.code,codes_fx{i});    
    pnlret = tbl2check_fx_h1_all.pnlrel(idxselect);
    opendt = tbl2check_fx_h1_all.opendatetime(idxselect);
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
    
    
    code_i = codes_fx{i};
    
    statsout{i} = struct('code',code_i,...
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
%
end
fprintf('done with mt4 fx of %s time frame...\n',freq_h1);
%%

save([dir_,'strat_fx_h1.mat'],'strat_fx_h1');
save([dir_,'tbl2check_fx_h1_all.mat'],'tbl2check_fx_h1_all');
fprintf('strat fx h1 mat-file saved...\n');
