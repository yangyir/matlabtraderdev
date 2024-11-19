% names_fx = {'usdx';'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf';...
%     'eurjpy';'eurchf';'gbpeur';'gbpjpy';'audjpy';...
%     'usdcnh'};

names_fx = {'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf'; 'eurjpy'};

output_fx_daily = fractal_kelly_summary('codes',names_fx,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');

%%
[~,~,tbl_fx_daily,~,~,~,~,strat_fx_daily] = kellydistributionsummary(output_fx_daily);
%
[tbl_report_fx_daily,stats_report_fx_daily] = kellydistributionreport(tbl_fx_daily,strat_fx_daily);

%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
try
    cd(dir_);
catch
    mkdir(dir_);
    cd(dir_);
end
save([dir_,'strat_fx_daily.mat'],'strat_fx_daily');
fprintf('strat M-file saved...\n');

save([dir_,'tbl_report_fx_daily.mat'],'tbl_report_fx_daily');
fprintf('tbl report M-file saved...\n');

save([dir_,'output_fx_daily.mat'],'output_fx_daily');
fprintf('output M-file saved...\n');
%
filename = [getenv('onedrive'),'\fractal backtest\kelly distribution\tbl_report_fx_daily.xlsx'];
writetable(tbl_report_fx_daily,filename,'Sheet',1,'Range','A1');
fprintf('excel file saved...\n');
%%
%%

%
names_fx = {'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf'; 'eurjpy'};

nfx = length(names_fx);
tblpnls = cell(nfx,1);
tblout2s = cell(nfx,1);
statsouts = cell(nfx,1);
for i = 1:nfx
    [tblpnls{i},tblout2s{i},statsouts{i}] = charlotte_gensingleassetprofile('assetname',names_fx{i},'frequency','daily');
end
%
maxpnldrawdown = zeros(nfx,1);varpnldrawdown = zeros(nfx,1);
varpnl = zeros(nfx,1);avgpnl = zeros(nfx,1);stdpnl = zeros(nfx,1);
sharpratio = zeros(nfx,1);
maxtradepnldrawdown = zeros(nfx,1);vartradepnldrawdown = zeros(nfx,1);
avgtradepnl = zeros(nfx,1);stdtradepnl = zeros(nfx,1);
Ns = zeros(nfx,1);Ws = zeros(nfx,1);Rs = zeros(nfx,1);Ks = zeros(nfx,1);
maxretdrawdown = zeros(nfx,1);varretsdrawdown = zeros(nfx,1);
varret = zeros(nfx,1);avgret = zeros(nfx,1);stdret = zeros(nfx,1);
maxtraderetdrawdown = zeros(nfx,1);
vartraderetdrawdown = zeros(nfx,1);
for i = 1:nfx
    maxpnldrawdown(i) = statsouts{i}.maxpnldrawdown;
    varpnldrawdown(i) = statsouts{i}.varpnldrawdown;
    varpnl(i) = statsouts{i}.varpnl;
    avgpnl(i) = statsouts{i}.avgpnl;
    stdpnl(i) = statsouts{i}.stdpnl;
    sharpratio(i) = statsouts{i}.sharpratio;
    maxtradepnldrawdown(i) = statsouts{i}.maxtradepnldrawdown;
    vartradepnldrawdown(i) = statsouts{i}.vartradepnldrawdown;
    avgtradepnl(i) = statsouts{i}.avgtradepnl;
    stdtradepnl(i) = statsouts{i}.stdtradepnl;
    Ns(i) = statsouts{i}.N;
    Ws(i) = statsouts{i}.W;
    Rs(i) = statsouts{i}.R;
    Ks(i) = statsouts{i}.K;
    maxretdrawdown(i) = statsouts{i}.maxretdrawdown;
    varretsdrawdown(i) = statsouts{i}.varretsdrawdown;
    varret(i) = statsouts{i}.varret;
    avgret(i) = statsouts{i}.avgret;
    stdret(i) = statsouts{i}.stdret;
    maxtraderetdrawdown(i) = statsouts{i}.maxtraderetdrawdown;
    vartraderetdrawdown(i) = statsouts{i}.vartraderetdrawdown;
end
tblreport_fx = table(names_fx,maxpnldrawdown,varpnldrawdown,varpnl,avgpnl,stdpnl,...
    sharpratio,maxtradepnldrawdown,vartradepnldrawdown,avgtradepnl,stdtradepnl,...
    Ns,Ws,Rs,Ks,maxretdrawdown,varretsdrawdown,varret,avgret,stdret,...
    maxtraderetdrawdown,vartraderetdrawdown);
%%
tbloutput_all = tblout2s{1};
for i = 2:nfx
    temp = [tbloutput_all;tblout2s{i}];
    tbloutput_all = temp;
end
%
dtsvec = tblpnls{1}.dts;
dtmin = dtsvec(1);
dtmax = dtsvec(end);
for i = 1:nfx
    dtmin = max(dtmin,tblpnls{i}.dts(1));
    dtmax = min(dtmax,tblpnls{i}.dts(end));
    temp = [dtsvec;tblpnls{i}.dts];
    dtsvec = temp;
end
dtsvec = unique(dtsvec);
dtsvec = dtsvec(dtsvec >= dtmin & dtsvec <= dtmax);
dtopen = datenum(tbloutput_all.opendatetime,'yyyy-mm-dd');
dtclose = datenum(tbloutput_all.closedatetime,'yyyy-mm-dd');
%
%
usemat = zeros(length(dtsvec),nfx);
for i = 1:length(dtsvec)
    dt_i = dtsvec(i);
    idx = dtopen <= dt_i & dtclose >= dt_i;
    codes_i = tbloutput_all.code(idx);
    if ~isempty(codes_i)
        for j = 1:size(codes_i,1)
            for k = 1:nfx
                if strcmpi(names_fx{k},codes_i{j})
                    usemat(i,k) = 1;
                    break
                end
            end 
        end 
    end
end
%
%
runningrets = zeros(length(dtsvec),nfx);
for i = 1:length(dtsvec)
    dt_i = dtsvec(i);
    for j = 1:nfx
        runningrets(i,j) = tblpnls{j}.runningrets(find(tblpnls{j}.dts <= dt_i,1,'last'));
    end
    

end

    
%%
freq = 'daily';
nfractal = 2;
asset = 'usdjpy';
dtfrom = '2024-07-01';
[tblout,kellyout,tblout_notused,kellytables] = charlotte_kellycheck('assetname',asset,'datefrom',dtfrom,'frequency',freq,'reportunused',true);
%%
[tblpnl,tblout2,statsout] = charlotte_gensingleassetprofile('assetname',asset,'frequency',freq);
open tblout2;open statsout;open tblpnl;
set(0,'defaultfigurewindowstyle','docked');
timeseries_plot([tblpnl.dts,tblpnl.runningnotional],'figureindex',2,'dateformat','yy-mmm-dd','title',asset);
timeseries_plot([tblpnl.dts,tblpnl.runningrets],'figureindex',3,'dateformat','yy-mmm-dd','title',asset);
%%
dt1 = '2024-07-24';
dt2 = '2024-08-10';
[unwindedtrades,carriedtrades,tbl2check] = charlotte_backtest_period('code',asset,'fromdate',dt1,'todate',dt2,'kellytables',kellytables,'showlogs',true,'figureidx',4,'frequency',freq);