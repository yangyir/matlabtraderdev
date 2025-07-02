dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
strat_fx_m30_existing = load([dir_,'strat_fx_m30.mat']);
strat_fx_m30_existing = strat_fx_m30_existing.strat_fx_m30;
codes_fx = {'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf';'xauusd'};
freq_m30 = '30m';
nfractal_m30 = charlotte_freq2nfractal(freq_m30);
%%
recalib_flag = input('Recalibrate Kelly Tables?Y/N: ','s');
if strcmpi(recalib_flag,'Y')
    output_fx_m30 = fractal_kelly_summary('codes',codes_fx,...
        'frequency',['intraday-',freq_m30],'usefractalupdate',0,'usefibonacci',1,'direction','both',...
        'nfractal',nfractal_m30);
    [~,~,tbl_fx_m30,~,~,~,~,strat_fx_m30] = kellydistributionsummary(output_fx_m30);
else
    strat_fx_m30 = strat_fx_m30_existing;
end
%%
charlotte_strat_compare('strat1',strat_fx_m30_existing,'strat2',strat_fx_m30,'assetname','xauusd');
%%
tbl2check_fx_m30 = cell(size(codes_fx,1),1);
parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_m30,'nfractal',nfractal_m30);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_m30{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_m30,'showlogs',false,'doplot',false,'frequency',freq_m30,'nfractal',nfractal_m30);
end
tbl2check_fx_m30_all = tbl2check_fx_m30{1};
for i = 2:size(codes_fx,1)
    temp = [tbl2check_fx_m30_all;tbl2check_fx_m30{i}];
    tbl2check_fx_m30_all = temp;
end
tbl2check_fx_m30_all = sortrows(tbl2check_fx_m30_all,'opendatetime','ascend');
%%
statsout = cell(size(codes_fx,1)+1,1);
for i = 0:size(codes_fx,1)
    if i == 0
        pnlret = tbl2check_fx_m30_all.pnlrel;
    else
        idxselect = strcmpi(tbl2check_fx_m30_all.code,codes_fx{i});
        pnlret = tbl2check_fx_m30_all.pnlrel(idxselect);
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
fprintf('done with mt4 fx of %s time frame...\n',freq_m30);
%%
save([dir_,'strat_fx_m30.mat'],'strat_fx_m30');
save([dir_,'tbl2check_fx_m30_all.mat'],'tbl2check_fx_m30_all');
fprintf('strat fx 30m mat-file saved...\n');
