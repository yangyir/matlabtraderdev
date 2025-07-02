dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
strat_fx_m5_existing = load([dir_,'strat_fx_m5.mat']);
strat_fx_m5_existing = strat_fx_m5_existing.strat_fx_m5;
%
codes_fx = {'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf';'xauusd'};
freq_m5 = 'm5';
nfractal_m5 = charlotte_freq2nfractal(freq_m5);
%%
recalib_flag = input('Recalibrate Kelly Tables?Y/N: ','s');
if strcmpi(recalib_flag,'Y')
    output_fx_m5 = fractal_kelly_summary('codes',codes_fx,...
        'frequency','intraday-5m','usefractalupdate',0,'usefibonacci',1,'direction','both',...
        'nfractal',nfractal_m5);
    [~,~,tbl_fx_m5,~,~,~,~,strat_fx_m5] = kellydistributionsummary(output_fx_m5);
else
    strat_fx_m5 = strat_fx_m5_existing;
end
%%
charlotte_strat_compare('strat1',strat_fx_m5_existing,'strat2',strat_fx_m5,'assetname','eurusd');
%%
tbl2check_fx_m5 = cell(size(codes_fx,1),1);
parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_m5,'nfractal',nfractal_m5);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_m5{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_m5,'showlogs',false,'doplot',false,'frequency',freq_m5,'nfractal',nfractal_m5);
end
tbl2check_fx_m5_all = tbl2check_fx_m5{1};
for i = 2:size(codes_fx,1)
    temp = [tbl2check_fx_m5_all;tbl2check_fx_m5{i}];
    tbl2check_fx_m5_all = temp;
end
tbl2check_fx_m5_all = sortrows(tbl2check_fx_m5_all,'opendatetime','ascend');
%%
statsout = cell(size(codes_fx,1)+1,1);
for i = 0:size(codes_fx,1)
    if i == 0
        pnlret = tbl2check_fx_m5_all.pnlrel;
    else
        idxselect = strcmpi(tbl2check_fx_m5_all.code,codes_fx{i});
        pnlret = tbl2check_fx_m5_all.pnlrel(idxselect);
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
    if i == 0
        code_i = 'all';
    else
        code_i = codes_fx{i};
    end
    statsout{i+1} = struct('code',code_i,...
        'nTotal',size(pnlret,1),...
        'Pwin',Wret,...
        'Rret',Rret,...
        'Kret',Kret,...
        'MaxDrawdownret',pnlretdrawdownmax);
%
end
fprintf('done with mt4 fx of %s time frame...\n',freq_m5);
%%
save([dir_,'strat_fx_m5.mat'],'strat_fx_m5');
save([dir_,'tbl2check_fx_m5_all.mat'],'tbl2check_fx_m5_all');
fprintf('strat fx M5 mat-file saved...\n');
