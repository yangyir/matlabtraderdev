dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
strat_fx_h4_existing = load([dir_,'strat_fx_h4.mat']);
strat_fx_h4_existing = strat_fx_h4_existing.strat_fx_h4;
codes_fx = {'audusd';'eurusd';'gbpusd';'usdcad';'usdchf';'usdjpy';'xauusd'};
freq_h4 = 'h4';
nfractal_h4 = charlotte_freq2nfractal(freq_h4);
%%
recalibrate = input('do you want to recalibrate the kelly criteria table? Y/N: ','s');
if strcmpi(recalibrate,'Y')
    output_fx_h4 = fractal_kelly_summary('codes',codes_fx,...
        'frequency','intraday-240m','usefractalupdate',0,'usefibonacci',1,'direction','both',...
        'nfractal',nfractal_h4,'useMT5',1);
    [~,~,tbl_fx_h4,~,~,~,~,strat_fx_h4] = kellydistributionsummary(output_fx_h4);
else
    strat_fx_h4 = strat_fx_h4_existing;
end
%%
charlotte_strat_compare('strat1',strat_fx_h4_existing,'strat2',strat_fx_h4,'assetname','usdjpy');
%%
tbl2check_fx_h4 = cell(size(codes_fx,1),1);
uts = cell(size(codes_fx,1),1);
parfor i = 1:size(codes_fx,1)
    [~,ei] = charlotte_loaddata('futcode',codes_fx{i},'frequency',freq_h4,'nfractal',nfractal_h4,'ustmt5',1);
    dt1 = '2023-01-01';
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [uts{i},~,tbl2check_fx_h4{i}] = charlotte_backtest_period('code',codes_fx{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_fx_h4,'showlogs',false,'doplot',false,...
        'frequency',freq_h4,'nfractal',nfractal_h4,...
        'compulsorycheckforconditional',true,...
        'usemt5',1);
end
tbl2check_fx_h4_all = tbl2check_fx_h4{1};
for i = 2:size(codes_fx,1)
    temp = [tbl2check_fx_h4_all;tbl2check_fx_h4{i}];
    tbl2check_fx_h4_all = temp;
end
tbl2check_fx_h4_all = sortrows(tbl2check_fx_h4_all,'opendatetime','ascend');
%%
N = zeros(size(codes_fx,1),1);
P = N;R = N;K = N;MDD = N;%DD stands for drawdown
WA = N;LA = N;%winavg and lossavg
for i = 1:size(codes_fx,1)
    stats_i = kellyratio2(tbl2check_fx_h4{i}.pnlrel);
    N(i) = stats_i.n;
    P(i) = stats_i.w;
    R(i) = stats_i.r;
    K(i) = stats_i.k;
    MDD(i) = stats_i.maxdrawdown;
    WA(i) = stats_i.winavg;
    LA(i) = stats_i.lossavg;
end
statstable_fx_h4 = table(codes_fx,N,P,R,K,MDD,WA,LA);
%%
charlotte_backtest_period('code','usdjpy','fromdate','2026-06-24','todate','2026-06-25','kellytables',strat_fx_h4,'showlogs',true,'doplot',true,...
        'frequency',freq_h4,'nfractal',nfractal_h4,...
        'compulsorycheckforconditional',true,...
        'usemt5',1);



%%

save([dir_,'strat_fx_h4.mat'],'strat_fx_h4');
save([dir_,'tbl2check_fx_h4_all.mat'],'tbl2check_fx_h4_all');
fprintf('strat fx h4 mat-file saved...\n');
%%
output_fx_h4_reduced = fractal_kelly_summary('codes',codes_fx,...
        'frequency','intraday-240m','usefractalupdate',0,'usefibonacci',1,'direction','both',...
        'nfractal',nfractal_h4,'useMT5',1,...
        'fromdate','2020-01-01',...
        'todate','2024-12-31');
[~,~,tbl_fx_h4_reduced,~,~,~,~,strat_fx_h4_reduced] = kellydistributionsummary(output_fx_h4_reduced);
