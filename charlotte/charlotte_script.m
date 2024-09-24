freq = '30m';
if strcmpi(freq,'30m') || strcmpi(freq,'15m')
    nfractal = 4;
elseif strcmpi(freq,'5m')
    nfractal = 6;
elseif strcmpi(freq,'daily') || strcmpi(freq,'1440m')
    nfractal = 2;
else
end
%%
asset = 'govtbond_10y';
dtfrom = '2024-09-03';
[tblout,kellyout,tblout_notused,kellytables] = charlotte_kellycheck('assetname',asset,...
    'datefrom',dtfrom,...
    'frequency',freq,...
    'reportunused',true);
open tblout;
open kellyout;
open tblout_notused;
%%
[tblpnl,tblout2,statsout] = charlotte_gensingleassetprofile('assetname',asset,'frequency',freq);
open tblout2;
open statsout;
open tblpnl;
set(0,'defaultfigurewindowstyle','docked');
timeseries_plot([tblpnl.dts,tblpnl.runningnotional],'figureindex',2,'dateformat','yy-mmm-dd','title',asset);
timeseries_plot([tblpnl.dts,tblpnl.runningrets],'figureindex',3,'dateformat','yy-mmm-dd','title',asset);
%%
charlotte_backtest_all;
figure(5);
plot(cumsum(tbl2check_.closepnl),'b');
%%
code = 'T2412';
dt1 = '2024-08-15';
dt2 = '2024-09-13';
[unwindedtrades,carriedtrades,tbl2check] = charlotte_backtest_period('code',code,'fromdate',dt1,'todate',dt2,'kellytables',kellytables,'showlogs',false,'figureidx',4);
open tbl2check;
%%
code_ = 'T2412';
dt1_ = '2024-09-20';
dt2_ = '2024-09-20';
[~,~,tbl2check2] = charlotte_backtest_period('code',code_,'fromdate',dt1_,'todate',dt2_,'kellytables',kellytables,'showlogs',true,'figureidx',5);

%%
%%
% asset_list={'gold';'silver';...
%             'copper';'aluminum';'zinc';'lead';'nickel';'tin';...
%             'pta';'lldpe';'pp';'methanol';'crude oil';'fuel oil';'lpg';'soda ash';'carbamide';...
%             'sugar';'cotton';'corn';'egg';...
%             'soybean';'soymeal';'soybean oil';'palm oil';...
%             'rapeseed oil';'rapeseed meal';...
%             'apple';...
%             'rubber';...
%             'live hog';...
%             'coke';'coking coal';'deformed bar';'iron ore';'hotroiled coil';'glass';'pvc'};
% nasset = length(asset_list);
% tblpnls = cell(nasset,1);
% tblout2s = cell(nasset,1);
% statsouts = cell(nasset,1);
% for i = 1:nasset
%     [tblpnls{i},tblout2s{i},statsouts{i}] = charlotte_gensingleassetprofile('assetname',asset_list{i});
% end
% %
% maxpnldrawdown = zeros(nasset,1);
% varpnldrawdown = zeros(nasset,1);
% varpnl = zeros(nasset,1);
% avgpnl = zeros(nasset,1);
% stdpnl = zeros(nasset,1);
% sharpratio = zeros(nasset,1);
% maxtradepnldrawdown = zeros(nasset,1);
% vartradepnldrawdown = zeros(nasset,1);
% avgtradepnl = zeros(nasset,1);
% stdtradepnl = zeros(nasset,1);
% Ns = zeros(nasset,1);
% Ws = zeros(nasset,1);
% Rs = zeros(nasset,1);
% Ks = zeros(nasset,1);
% maxretdrawdown = zeros(nasset,1);
% varretsdrawdown = zeros(nasset,1);
% varret = zeros(nasset,1);
% avgret = zeros(nasset,1);
% stdret = zeros(nasset,1);
% maxtraderetdrawdown = zeros(nasset,1);
% vartraderetdrawdown = zeros(nasset,1);
% for i = 1:nasset
%     maxpnldrawdown(i) = statsouts{i}.maxpnldrawdown;
%     varpnldrawdown(i) = statsouts{i}.varpnldrawdown;
%     varpnl(i) = statsouts{i}.varpnl;
%     avgpnl(i) = statsouts{i}.avgpnl;
%     stdpnl(i) = statsouts{i}.stdpnl;
%     sharpratio(i) = statsouts{i}.sharpratio;
%     maxtradepnldrawdown(i) = statsouts{i}.maxtradepnldrawdown;
%     vartradepnldrawdown(i) = statsouts{i}.vartradepnldrawdown;
%     avgtradepnl(i) = statsouts{i}.avgtradepnl;
%     stdtradepnl(i) = statsouts{i}.stdtradepnl;
%     Ns(i) = statsouts{i}.N;
%     Ws(i) = statsouts{i}.W;
%     Rs(i) = statsouts{i}.R;
%     Ks(i) = statsouts{i}.K;
%     maxretdrawdown(i) = statsouts{i}.maxretdrawdown;
%     varretsdrawdown(i) = statsouts{i}.varretsdrawdown;
%     varret(i) = statsouts{i}.varret;
%     avgret(i) = statsouts{i}.avgret;
%     stdret(i) = statsouts{i}.stdret;
%     maxtraderetdrawdown(i) = statsouts{i}.maxtraderetdrawdown;
%     vartraderetdrawdown(i) = statsouts{i}.vartraderetdrawdown;
% end
% assetlist = asset_list;
% tblreportbyasset = table(assetlist,maxpnldrawdown,varpnldrawdown,varpnl,avgpnl,stdpnl,...
%     sharpratio,maxtradepnldrawdown,vartradepnldrawdown,avgtradepnl,stdtradepnl,...
%     Ns,Ws,Rs,Ks,maxretdrawdown,varretsdrawdown,varret,avgret,stdret,...
%     maxtraderetdrawdown,vartraderetdrawdown);

