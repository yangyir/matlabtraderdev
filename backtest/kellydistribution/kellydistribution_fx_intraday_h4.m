dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
strat_fx_h4_existing = load([dir_,'strat_fx_h4.mat']);
strat_fx_h4_existing = strat_fx_h4_existing.strat_fx_h4;
%%
codes_fx = {'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf';'xauusd'};
freq_h4 = 'h4';
nfractal_h4 = charlotte_freq2nfractal(freq_h4);
output_fx_h4 = fractal_kelly_summary('codes',codes_fx,...
    'frequency','intraday-240m','usefractalupdate',0,'usefibonacci',1,'direction','both',...
    'nfractal',nfractal_h4);
[~,~,tbl_fx_h4,~,~,~,~,strat_fx_h4] = kellydistributionsummary(output_fx_h4);
%%
charlotte_strat_compare('strat1',strat_fx_h4_existing,'strat2',strat_fx_h4,'assetname','usdjpy');
%%
tbl2check_fx_h4 = cell(size(codes_fx,1),1);
parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_h4,'nfractal',nfractal_h4);
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_fx_h4{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_h4,'showlogs',false,'doplot',false,'frequency',freq_h4,'nfractal',nfractal_h4);
end
tbl2check_fx_h4_all = tbl2check_fx_h4{1};
for i = 2:size(codes_fx,1)
    temp = [tbl2check_fx_h4_all;tbl2check_fx_h4{i}];
    tbl2check_fx_h4_all = temp;
end
tbl2check_fx_h4_all = sortrows(tbl2check_fx_h4_all,'opendatetime','ascend');
%%
statsout = cell(size(codes_fx,1)+1,1);
for i = 0:size(codes_fx,1)
    if i == 0
        pnlret = tbl2check_fx_h4_all.pnlrel;
    else
        idxselect = strcmpi(tbl2check_fx_h4_all.code,codes_fx{i});
        pnlret = tbl2check_fx_h4_all.pnlrel(idxselect);
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
fprintf('done with mt4 fx of %s time frame...\n',freq_h4);
%%

save([dir_,'strat_fx_h4.mat'],'strat_fx_h4');
save([dir_,'tbl2check_fx_h4_all.mat'],'tbl2check_fx_h4_all');
fprintf('strat fx h4 mat-file saved...\n');
