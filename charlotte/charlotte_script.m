asset = 'soda ash';
freq = 'intraday';
dtfrom = '2024-07-19';
[tblout,kellyout,tblout_notused] = charlotte_kellycheck('assetname',asset,...
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
code = 'cu2409';
[tblb_headers,tblb_data,~,tbls_data,data] = fractal_gettradesummary(code,...
    'frequency','intraday',...
    'usefractalupdate',0,...
    'usefibonacci',1,...
    'direction','both');
%%
charlotte_plot('futcode','CF409','figureindex',3,'datefrom','2024-06-14');
%%
assetlist = {'copper';'aluminum';'zinc';'lead';'nickel';'tin'};
nasset = length(assetlist);
tblpnlcell = cell(nasset,1);
for i = 1:nasset
    [tblpnlcell{i},~,~] = charlotte_gensingleassetprofile('assetname',assetlist{i});
end
%%
code = 'SA409';
dt1 = datenum('2024-05-17','yyyy-mm-dd');
% dt2 = datenum('2024-07-29','yyyy-mm-dd');
dt2 = dt1;
dt3 = [datestr(dateadd(dt1,'-1b'),'yyyy-mm-dd'),' 21:00:00'];
dt4 = [datestr(dateadd(dt2,'1d'),'yyyy-mm-dd'),' 02:30:00'];
resstruct = charlotte_plot('futcode',code,'figureindex',4,'datefrom',dt3,'dateto',dt4);
fut = code2instrument(code);
if strcmpi(fut.asset_name,'govtbond_10y') || strcmpi(fut.asset_name,'govtbond_30y')
    data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_30m.mat']);
    kellytables = data.strat_govtbondfut_30m;
else
    data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\strat_comdty_i.mat']);
    kellytables = data.strat_comdty_i;
end

idxstart = find(resstruct.px(:,1) >= datenum(dt3,'yyyy-mm-dd HH:MM'),1,'first');
idxend = find(resstruct.px(:,1) <= datenum(dt4,'yyyy-mm-dd HH:MM'),1,'last');
clc;
for i = idxstart:idxend
    %1st check whether is any conditional open entrust
    ei1 = fractal_truncate(resstruct,i-1);
    ei2 = fractal_truncate(resstruct,i);
    output1 = fractal_signal_conditional2('extrainfo',ei1,...
        'ticksize',fut.tick_size,...
        'kellytables',kellytables,...
        'assetname',fut.asset_name);
    output2 = fractal_signal_conditional2('extrainfo',ei2,...
        'ticksize',fut.tick_size,...
        'kellytables',kellytables,...
        'assetname',fut.asset_name);
    if ~isempty(output1)
        if output1.directionkellied == 1
            if ei2.px(end,3) > ei1.hh(end)
                if ei2.px(end,5) >= ei1.hh(end)
                    [signal,op] = fractal_signal_unconditional(ei2,fut.tick_size,4);
                    try
                        kelly_ = kelly_k(op.comment,fut.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l);
                        wprob_ = kelly_w(op.comment,fut.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.winprob_matrix_l);
                    catch
                        kelly_ = -9.99;
                        wprob_ = 0;
                    end
                    fprintf('%6s:\t%s:%2d\t%s with %s:%2.1f%%\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signal(1),[output1.opkellied,' success'],op.comment,100*kelly_);
                else
                    fprintf('%6s:\t%s:%2d\t%s\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output1.directionkellied,[output1.opkellied,' failed...']);
                end
                
            end
        elseif output1.directionkellied == -1
            if ei2.px(end,4) < ei1.ll(end)
                if ei2.px(end,5) <= ei1.ll(end)
                    [signal,op] = fractal_signal_unconditional(ei2,fut.tick_size,4);
                    try
                        kelly_ = kelly_k(op.comment,fut.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s);
                        wprob_ = kelly_w(op.comment,fut.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s);
                    catch
                        kelly_ = -9.99;
                        wprob_ = 0;
                    end
                    fprintf('%6s:\t%s:%2d\t%s with %s:%2.1f%%\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signal(1),[output1.opkellied,' success'],op.comment,100*kelly_);
                else
                    fprintf('%6s:\t%s:%2d\t%s\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output1.directionkellied,[output1.opkellied,' failed...']);
                end
            end
        end
    else
        
    end
    
    
    ei_ = fractal_truncate(resstruct,i);
    output = fractal_signal_conditional2('extrainfo',ei_,...
        'ticksize',fut.tick_size,...
        'kellytables',kellytables,...
        'assetname',fut.asset_name);
    if isempty(output)
        [signal,op] = fractal_signal_unconditional(ei_,fut.tick_size,4);
        if isempty(op)
            fprintf('%6s:\t%s:%2d\t%s\n',code,datestr(ei_.px(end,1),'yyyy-mm-dd HH:MM'),0,'no conditional signal');
        else
            try
                if signal(1) == -1
                    try
                        kelly_ = kelly_k(op.comment,fut.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s);
                        wprob_ = kelly_w(op.comment,fut.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s);
                    catch
                        idx = strcmpi(kellytables.kelly_table_s.opensignal_unique_s,op.comment);
                        kelly_ = kellytables.kelly_table_s.kelly_unique_s(idx);
                        wprob_ = kellytables.kelly_table_s.winp_unique_s(idx);
                    end
                elseif signal(1) == 1
                    try
                        kelly_ = kelly_k(op.comment,fut.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l);
                        wprob_ = kelly_w(op.comment,fut.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.winprob_matrix_l);
                    catch
                        idx = strcmpi(kellytables.kelly_table_l.opensignal_unique_l,op.comment);
                        kelly_ = kellytables.kelly_table_l.kelly_unique_l(idx);
                        wprob_ = kellytables.kelly_table_l.winp_unique_l(idx);
                    end
                else
                    if op.direction == 1
                        idx = strcmpi(kellytables.kelly_table_l.opensignal_unique_l,op.comment);
                        kelly_ = kellytables.kelly_table_l.kelly_unique_l_sample(idx);
                        wprob_ = kellytables.kelly_table_l.winp_unique_l_sample(idx);
                    elseif op.direction == -1
                        idx = strcmpi(kellytables.kelly_table_s.opensignal_unique_s,op.comment);
                        kelly_ = kellytables.kelly_table_s.kelly_unique_s_sample(idx);
                        wprob_ = kellytables.kelly_table_s.winp_unique_s_sample(idx);
                    end
                end
                
                fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',code,datestr(ei_.px(end,1),'yyyy-mm-dd HH:MM'),signal(1),op.comment,100*kelly_);
                
                
            catch
                fprintf('%6s:\t%s:%2d\t%s\n',code,datestr(ei_.px(end,1),'yyyy-mm-dd HH:MM'),0,'no conditional signal');
            end
        end
    else
        fprintf('%6s:\t%s:%2d\t%s\n',code,datestr(ei_.px(end,1),'yyyy-mm-dd HH:MM'),output.directionkellied,output.opkellied);
    end
    
end
%%
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

