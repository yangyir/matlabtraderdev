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
asset = 'aluminum';
dtfrom = '2024-06-03';
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
code = 'al2001';
dt1 = datenum('2019-11-15','yyyy-mm-dd');
dt2 = datenum('2019-11-15','yyyy-mm-dd');
% dt2 = dt1;
dt3 = [datestr(dt1,'yyyy-mm-dd'),' 09:00:00'];
dt4 = [datestr(dateadd(dt2,'1d'),'yyyy-mm-dd'),' 02:30:00'];
resstruct = charlotte_plot('futcode',code,'figureindex',4,'datefrom',dt3,'dateto',dt4,'frequency',freq);
grid off;
fut = code2instrument(code);

idxstart = find(resstruct.px(:,1) >= datenum(dt3,'yyyy-mm-dd HH:MM'),1,'first');
idxend = find(resstruct.px(:,1) <= datenum(dt4,'yyyy-mm-dd HH:MM'),1,'last');
clc;
for i = idxstart:idxend
    %1st check whether is any conditional open entrust
    ei1 = fractal_truncate(resstruct,i-1);
    ei2 = fractal_truncate(resstruct,i);
    output1 = fractal_signal_conditional2('extrainfo',ei1,...
        'nfractal',nfractal,...
        'ticksize',fut.tick_size,...
        'kellytables',kellytables,...
        'assetname',fut.asset_name,...
        'ticksizeratio',0.5);
    output2 = fractal_signal_conditional2('extrainfo',ei2,...
        'nfractal',nfractal,...
        'ticksize',fut.tick_size,...
        'kellytables',kellytables,...
        'assetname',fut.asset_name,...
        'ticksizeratio',0.5);
    %
    if ~isempty(output1)
        if output1.directionkellied == 1
            %up-trend conditional signal
            if ei2.px(end,3) > ei1.hh(end)
                if ei2.px(end,5) > ei1.hh(end)
                    signaluncond = fractal_signal_unconditional2('extrainfo',ei2,...
                        'ticksize',fut.tick_size,...
                        'nfractal',nfractal,...
                        'assetname',fut.asset_name,...
                        'kellytables',kellytables);
                    if ~isempty(signaluncond)
                        fprintf('%6s:\t%s:%2d\t%s with %s:%2.1f%%\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signaluncond.directionkellied,[output1.opkellied,' success'],signaluncond.op.comment,100*signaluncond.kelly);
                    else
                        %there was not a valid breach,i.e.the fractal hh
                        %was updated
                        fprintf('%6s:\t%s:%2d\t%s but invalid...\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),1,[output1.opkellied,' success']);
                    end
                else
                    fprintf('%6s:\t%s:%2d\t%s\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output1.directionkellied,[output1.opkellied,' failed...']);
                end
            else
                if ~isempty(output2)
                    fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output2.directionkellied,output2.opkellied,100*output2.kelly);
                else
                    fprintf('%6s:\t%s:%2d\t%s\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),0,'no signal');
                end
            end
        elseif output1.directionkellied == -1
            %dn-trend conditional signal
            if ei2.px(end,4) < ei1.ll(end)
                if ei2.px(end,5) < ei1.ll(end)
                    signaluncond = fractal_signal_unconditional2('extrainfo',ei2,...
                        'ticksize',fut.tick_size,...
                        'nfractal',nfractal,...
                        'assetname',fut.asset_name,...
                        'kellytables',kellytables);
                    if ~isempty(signaluncond)
                        fprintf('%6s:\t%s:%2d\t%s with %s:%2.1f%%\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signaluncond.directionkellied,[output1.opkellied,' success'],signaluncond.op.comment,100*signaluncond.kelly);
                    else
                        %there was not a valid breach,i.e.the fractal ll
                        %was updated
                        fprintf('%6s:\t%s:%2d\t%s but invalid as ll updates...\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),-1,[output1.opkellied,' success']);
                    end
                else
                    fprintf('%6s:\t%s:%2d\t%s\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output1.directionkellied,[output1.opkellied,' failed...']);
                end
            else
                if ~isempty(output2)
                    fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output2.directionkellied,output2.opkellied,100*output2.kelly);
                else
                    fprintf('%6s:\t%s:%2d\t%s\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),0,'no signal');
                end
            end
        elseif output1.directionkellied == 0
            %conditional signal with insuffient conditions to be placed
            signaluncond = fractal_signal_unconditional2('extrainfo',ei2,...
                'ticksize',fut.tick_size,...
                'nfractal',nfractal,...
                'assetname',fut.asset_name,...
                'kellytables',kellytables);
            
            if ~isempty(signaluncond)
                fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signaluncond.directionkellied,signaluncond.op.comment,100*signaluncond.kelly);       
            else
                fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output1.directionkellied,output1.opkellied,100*output1.kelly);
            end
            
        end
    else
        %no conditional signal was placed before-hand
        signaluncond = fractal_signal_unconditional2('extrainfo',ei2,...
                   'ticksize',fut.tick_size,...
                   'nfractal',nfractal,...
                   'assetname',fut.asset_name,...
                   'kellytables',kellytables);
        if isempty(signaluncond)
            if ~isempty(output2)
                fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output2.directionkellied,output2.opkellied,100*output2.kelly);
            else
                fprintf('%6s:\t%s:%2d\t%s\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),0,'no signal');
            end
        else
            fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',code,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signaluncond.directionkellied,signaluncond.op.comment,100*signaluncond.kelly);                
        end
    end
end
%
%
dts = gendates('fromdate',dt1,'todate',dt2);
unwindedtrades = cTradeOpenArray;
carriedtrades =  cTradeOpenArray;

for i = 1:length(dts)
    if i == 1
        [~,ct_i,ut_i] = charlotte_backtest_daily('code',code,'date',datestr(dts(i),'yyyy-mm-dd'),'frequency',freq);
    else
        if ct_i.latest_ > 0
            carriedtrade = ct_i.node_(1);
            [~,ct_i,ut_i] = charlotte_backtest_daily('code',code,'date',datestr(dts(i),'yyyy-mm-dd'),'frequency',freq,'carriedtrade',carriedtrade);
        else
            [~,ct_i,ut_i] = charlotte_backtest_daily('code',code,'date',datestr(dts(i),'yyyy-mm-dd'),'frequency',freq);
        end     
    end
    for j = 1:ut_i.latest_
        unwindedtrades.push(ut_i.node_(j));
    end
    if i == length(dts)
        for j = 1:ct_i.latest_
            carriedtrades.push(ct_i.node_(j));
        end
    end
end
%print backtest trades results
fprintf('\n');
if unwindedtrades.latest_ == 0 && carriedtrades.latest_ == 0
    fprintf('there were no trades...\n');
    tbl2check = {};
else
    if unwindedtrades.latest_ > 0
        n = unwindedtrades.latest_;
        codes = cell(n,1);
        bsflag = zeros(n,1);
        opendt = cell(n,1);
        openpx = zeros(n,1);
        closedt = cell(n,1);
        closepx = zeros(n,1);
        opensignal = cell(n,1);
        closestr = cell(n,1);
        closepnl = zeros(n,1);
        fprintf('unwinded trades:\n');
        for i = 1:n
            t_i = unwindedtrades.node_(i);
            fprintf('\t%6s\t%3d\t%20s\t%3.3f\t%20s\t%3.3f\t%30s\t%40s\n',code,t_i.opendirection_,t_i.opendatetime2_,t_i.openprice_,t_i.closedatetime2_,t_i.closeprice_,t_i.opensignal_.mode_,t_i.closestr_);
            codes{i} = code;
            bsflag(i) = t_i.opendirection_;
            opendt{i} = t_i.opendatetime2_;
            openpx(i) = t_i.openprice_;
            closedt{i} = t_i.closedatetime2_;
            closepx(i) = t_i.closeprice_;
            opensignal{i} = t_i.opensignal_.mode_;
            closestr{i} = t_i.closestr_;
            closepnl(i) = t_i.closepnl_;
        end
        tbl2check = table(codes,bsflag,opendt,openpx,closedt,closepx,opensignal,closestr,closepnl);
    end
    %
    if carriedtrades.latest_ > 0
        fprintf('carried trade:\n');
        t_i = carriedtrades.node_(1);
        fprintf('\t%6s\t%3d\t%20s\t%3.3f\t%20s\t%3.3f\t%30s\n',code,t_i.opendirection_,t_i.opendatetime2_,t_i.openprice_,'still live',9.99,t_i.opensignal_.mode_);
    end
end
%



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

