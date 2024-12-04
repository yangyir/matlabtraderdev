freq = '5m';
if strcmpi(freq,'30m') || strcmpi(freq,'15m')
    nfractal = 4;
elseif strcmpi(freq,'5m')
    nfractal = 6;
elseif strcmpi(freq,'daily') || strcmpi(freq,'1440m')
    nfractal = 2;
else
end
%%
asset = 'govtbond_30y';
dtfrom = '2024-11-13';
[tblout,kellyout,tblout_notused,kellytables] = charlotte_kellycheck('assetname',asset,'datefrom',dtfrom,'frequency',freq,'reportunused',true);
open tblout;open kellyout;open tblout_notused;
%%
[tblpnl,tblout2,statsout] = charlotte_gensingleassetprofile('assetname',asset,'frequency',freq);
open tblout2;open statsout;open tblpnl;
set(0,'defaultfigurewindowstyle','docked');
timeseries_plot([tblpnl.dts,tblpnl.runningnotional],'figureindex',2,'dateformat','yy-mmm-dd','title',asset);
timeseries_plot([tblpnl.dts,tblpnl.runningrets],'figureindex',3,'dateformat','yy-mmm-dd','title',asset);
%%
[tblroll,tblcheck_] = charlotte_backtest_all('assetname',asset,'frequency',freq);
[tblpnl_,tblout_,statsout_] = irene_trades2dailypnl('tradestable',tblcheck_);
timeseries_plot([tblpnl_.dts,tblpnl_.runningnotional],'figureindex',1,'dateformat','yy-mmm-dd','title',asset);
%%
%%
code = 'TL2503';
dt1 = '2024-12-02';
dt2 = '2024-12-03';
% dt2 = dt1;
[unwindedtrades,carriedtrades,tbl2check] = charlotte_backtest_period('code',code,'fromdate',dt1,'todate',dt2,'kellytables',kellytables,'showlogs',true,'figureidx',4,'frequency',freq);
% open tbl2check;
%%
code_ = 'T2406';
dt1_ = '2023-04-08';
dt2_ = '2023-04-08';
[~,~,tbl2check2] = charlotte_backtest_period('code',code_,'fromdate',dt1_,'todate',dt2_,'kellytables',kellytables,'showlogs',true,'figureidx',5);
%%
condup = strcmpi(tbl2check_.opensignal,'conditional-uptrendconfirmed') | ...
    strcmpi(tbl2check_.opensignal,'conditional-uptrendconfirmed-1') | ...
    strcmpi(tbl2check_.opensignal,'conditional-uptrendconfirmed-2') | ...
    strcmpi(tbl2check_.opensignal,'conditional-uptrendconfirmed-3');
condupclosestr = unique(tbl2check_.closestr(condup));
fprintf('conditional-uptrendconfirmed closestr:\n');
disp(condupclosestr);
%
conddn = strcmpi(tbl2check_.opensignal,'conditional-dntrendconfirmed') | ...
    strcmpi(tbl2check_.opensignal,'conditional-dntrendconfirmed-1') | ...
    strcmpi(tbl2check_.opensignal,'conditional-dntrendconfirmed-2') | ...
    strcmpi(tbl2check_.opensignal,'conditional-dntrendconfirmed-3');
conddnclosestr = unique(tbl2check_.closestr(conddn));
fprintf('\nconditional-dntrendconfirmed closestr:\n');
disp(conddnclosestr);

%%
close all;
signal2check = 'conditional-uptrendconfirmed';
closestr2check = 'conditional uptrendconfirmed failed:within2ticks2';
% closestr2check = 'fractal:lips';
idx = strcmpi(tbl2check_.opensignal,signal2check) & strcmpi(tbl2check_.closestr,closestr2check);
trades2check = tbl2check_(idx,:);
disp(trades2check);
n = size(trades2check,1);
for i = 1:n
    code_i = trades2check.codes{i};
    dt1_i = datestr(floor(datenum(dateadd(trades2check.opendt(i),'-0b'))),'yyyy-mm-dd');
    dt2_i = datestr(floor(datenum(dateadd(trades2check.closedt(i),'0b'))),'yyyy-mm-dd');
    [ut_i,~,~] = charlotte_backtest_period('code',code_i,'fromdate',dt1_i,'todate',dt2_i,'kellytables',kellytables,'showlogs',false,'figureidx',5+i);
%     for j = 1:ut_i.latest_
%         fprintf('%20s\t%60s\t%4.2f\n',ut_i.node_(j).opendatetime2_,ut_i.node_(j).closestr_,ut_i.node_(j).closepnl_);
%     end
%     results = input('continue 1 or not 0?');
%     if ~results
%         break
%     end
end

%%
asset_list={'gold';'silver';...
            'copper';'aluminum';'zinc';'lead';'nickel';'tin';...
            'pta';'lldpe';'pp';'methanol';'crude oil';'fuel oil';'lpg';'soda ash';'carbamide';...
            'sugar';'cotton';'corn';'egg';...
            'soybean';'soymeal';'soybean oil';'palm oil';...
            'rapeseed oil';'rapeseed meal';...
            'apple';...
            'rubber';...
            'live hog';...
            'coke';'coking coal';'deformed bar';'iron ore';'hotroiled coil';'glass';'pvc'};
nasset = length(asset_list);
tblpnls = cell(nasset,1);
tblout2s = cell(nasset,1);
statsouts = cell(nasset,1);
for i = 1:nasset
    [tblpnls{i},tblout2s{i},statsouts{i}] = charlotte_gensingleassetprofile('assetname',asset_list{i});
end
%
maxpnldrawdown = zeros(nasset,1);
varpnldrawdown = zeros(nasset,1);
varpnl = zeros(nasset,1);
avgpnl = zeros(nasset,1);
stdpnl = zeros(nasset,1);
sharpratio = zeros(nasset,1);
maxtradepnldrawdown = zeros(nasset,1);
vartradepnldrawdown = zeros(nasset,1);
avgtradepnl = zeros(nasset,1);
stdtradepnl = zeros(nasset,1);
Ns = zeros(nasset,1);
Ws = zeros(nasset,1);
Rs = zeros(nasset,1);
Ks = zeros(nasset,1);
maxretdrawdown = zeros(nasset,1);
varretsdrawdown = zeros(nasset,1);
varret = zeros(nasset,1);
avgret = zeros(nasset,1);
stdret = zeros(nasset,1);
maxtraderetdrawdown = zeros(nasset,1);
vartraderetdrawdown = zeros(nasset,1);
for i = 1:nasset
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
assetlist = asset_list;
tblreportbyasset = table(assetlist,maxpnldrawdown,varpnldrawdown,varpnl,avgpnl,stdpnl,...
    sharpratio,maxtradepnldrawdown,vartradepnldrawdown,avgtradepnl,stdtradepnl,...
    Ns,Ws,Rs,Ks,maxretdrawdown,varretsdrawdown,varret,avgret,stdret,...
    maxtraderetdrawdown,vartraderetdrawdown);

