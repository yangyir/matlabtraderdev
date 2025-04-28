dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
strat_fx_5m_existing = load([dir_,'strat_fx_5m.mat']);
strat_fx_5m_existing = strat_fx_5m_existing.strat_fx_5m;
%%
codes_fx = {'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf';'xauusd'};
freq_5m = '5m';
nfractal_5m = charlotte_freq2nfracal(freq_5m);

output_fx_5m = fractal_kelly_summary('codes',codes_fx,...
    'frequency',['intraday-',freq_5m],'usefractalupdate',0,'usefibonacci',1,'direction','both',...
    'nfractal',nfractal_5m);
[~,~,tbl_fx_5m,~,~,~,~,strat_fx_5m] = kellydistributionsummary(output_fx_5m);
%%
charlotte_strat_compare('strat1',strat_fx_5m_existing,'strat2',strat_fx_5m,'assetname','usdjpy');
%%
tbl2check_fx_5m = cell(size(codes_fx,1),1);
parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_5m,'nfractal',nfractal_5m);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_5m{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_5m,'showlogs',false,'doplot',false,'frequency',freq_5m,'nfractal',nfractal_5m);
end
tbl2check_fx_5m_all = tbl2check_fx_5m{1};
for i = 2:size(codes_fx,1)
    temp = [tbl2check_fx_5m_all;tbl2check_fx_5m{i}];
    tbl2check_fx_5m_all = temp;
end
tbl2check_fx_5m_all = sortrows(tbl2check_fx_5m_all,'opendatetime','ascend');
%%
statsout = cell(size(codes_fx,1)+1,1);
for i = 0:size(codes_fx,1)
    if i == 0
        pnlret = tbl2check_fx_5m_all.pnlrel;
    else
        idxselect = strcmpi(tbl2check_fx_5m_all.code,codes_fx{1});
        pnlrel = tbl2check_fx_5m_all.pnlrel(idxselect);
    end
[winp_running,r_running,kelly_running] = calcrunningkelly(pnlret);
Wret = winp_running(end);
Rret = r_running(end);
Kret = kelly_running(end);
pnlretcum = cumsum(pnlret);
pnlretmax = pnlretcum;
for i = 1:length(pnlretmax)
    pnlretmax(i) = max(pnlretcum(1:i));
    
    if pnlretmax(i) < 0
        pnlretmax(i) = 0;
    end
end
pnlretdrawdown = pnlretcum - pnlretmax;
pnlretdrawdownmax = min(pnlretdrawdown);
statsout = struct('nTotal',size(pnlret,1),...
    'Pwin',Wret,...
    'Rret',Rret,...
    'Kret',Kret,...
    'MaxDrawdownret',pnlretdrawdownmax);
%
end
fprintf('done with mt4 fx of %s time frame...\n',freq_5m);
%%

save([dir_,'strat_fx_5m.mat'],'strat_fx_5m');
save([dir_,'tbl2check_fx_5m_all.mat'],'tbl2check_fx_5m_all');
fprintf('strat fx 5m mat-file saved...\n');
