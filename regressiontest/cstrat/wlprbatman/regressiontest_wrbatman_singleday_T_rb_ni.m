%user inputs:
clear;clc;delete(timerfindall);
fprintf('\nruning regressiontest_wrbatman_singleday_T_rb_ni...\n');
bookname = 'regression-wlprbatman';
strategyname = 'wlprbatman';
path = [getenv('HOME'),'regressiontest\cstrat\wlprbatman\'];
riskconfigfilename = 'wlprbatmanconfig_multi_regressiontest.txt';
% list = {'T1809';'rb1810';'ni1809'};
list = {'T1809';'rb1810';'ni1809'};
genconfigfile(strategyname,[path,riskconfigfilename],...
    'instruments',list);
combos = rtt_setup('bookname',bookname,...
    'strategyname',strategyname,...
    'riskconfigfilename',riskconfigfilename);
startdt = '2018-06-04';
enddt = '2018-06-19';
checkdt = '2018-06-19';

%%
fprintf('\nprint trades from backtest...\n');
instruments = combos.strategy.getinstruments;
db = cLocal;
ninstruments = size(instruments,1);
trades = cell(ninstruments,1);
trades2check = cell(ninstruments,1);
for i = 1:ninstruments;
    candle_db_1m = db.intradaybar(instruments{i},startdt,enddt,1,'trade');
    trade_freq = combos.strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','samplefreq');
    stop_period = 0.5*combos.strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','numofperiod');
    trades{i} = bkfunc_gentrades_wlpr(instruments{i}.code_ctp,candle_db_1m,...
        'SampleFrequency',trade_freq,...
        'NStopPeriod',stop_period);
    %find trades which executed on the checkdt
    checkdt_start = [checkdt,' ',instruments{i}.break_interval{1,1}];
    checkdt_end = [datestr(datenum(checkdt,'yyyy-mm-dd')+1,'yyyy-mm-dd'),' ',instruments{i}.break_interval{end,end}];
    trades2check{i} = cTradeOpenArray;
    for j = 1:trades{i}.latest_
        if trades{i}.node_(j).opendatetime1_ > datenum(checkdt_start) && ...
                trades{i}.node_(j).opendatetime1_ < datenum(checkdt_end)
            trades2check{i}.push(trades{i}.node_(j));
        end
    end
end
%
for i = 1:ninstruments;
    fprintf('%s:\n',instruments{i}.code_ctp);
    for j = 1:trades2check{i}.latest_
        trade_j = trades2check{i}.node_(j);
        fprintf('id:%2d,opentime:%s,direction:%2d,price:%s,stoptime:%s\n',...
            j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
            num2str(trade_j.openprice_),...
            trade_j.stopdatetime2_(end-8:end));
    end
end
fprintf('\n');
% print trades from backtest...
% T1809:
% id: 1,opentime: 09:15:01,direction:-1,price:95.22,stoptime: 09:15:00
% id: 2,opentime: 13:00:01,direction:-1,price:95.24,stoptime: 13:00:00
% id: 3,opentime: 13:15:01,direction:-1,price:95.405,stoptime: 13:15:00
% id: 4,opentime: 13:30:01,direction:-1,price:95.44,stoptime: 13:30:00
% id: 5,opentime: 14:00:01,direction:-1,price:95.445,stoptime: 14:00:00
% id: 6,opentime: 14:30:01,direction:-1,price:95.54,stoptime: 14:30:00
% rb1810:
% id: 1,opentime: 13:30:01,direction: 1,price:3755,stoptime: 14:15:00
% id: 2,opentime: 13:45:01,direction: 1,price:3748,stoptime: 14:30:00
% id: 3,opentime: 14:15:01,direction: 1,price:3743,stoptime: 21:00:00
% id: 4,opentime: 14:30:01,direction: 1,price:3742,stoptime: 21:15:00
% ni1809:
% id: 1,opentime: 09:00:01,direction: 1,price:114090,stoptime: 13:45:00
% id: 2,opentime: 14:00:01,direction: 1,price:113400,stoptime: 22:30:00
% id: 3,opentime: 14:15:01,direction: 1,price:113260,stoptime: 22:45:00
% id: 4,opentime: 14:30:01,direction: 1,price:112890,stoptime: 23:00:00
% id: 5,opentime: 21:00:01,direction: 1,price:112420,stoptime: 23:30:00
%%
% replay
fprintf('\nrunning replay...\n');
if ~isempty(combos.mdefut), combos.mdefut.mode_ = 'replay';end
if ~isempty(combos.mdeopt), combos.mdeopt.mode_ = 'replay';end
if ~isempty(combos.ops), combos.ops.mode_ = 'replay';end
if ~isempty(combos.strategy), combos.strategy.mode_ = 'replay';end
%
availablefund = 1e6;
combos.strategy.setavailablefund(availablefund,'firstset',true);
%
replayspeed = 20;
fprintf('set replay speed to %s...\n',num2str(replayspeed));
if ~isempty(combos.mdefut),combos.mdefut.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.mdeopt),combos.mdeopt.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.ops),combos.ops.settimerinterval(1/replayspeed);end
if ~isempty(combos.strategy),combos.strategy.settimerinterval(1/replayspeed);end
%
fprintf('load replay data....\n');
replaydt1 = checkdt;
replaydt2 = checkdt;
replaydts = gendates('fromdate',replaydt1,'todate',replaydt2);
try
    for i = 1:ninstruments
        code = instruments{i}.code_ctp;
        filenames = cell(size(replaydts,1),1);
        for j = 1:size(replaydts,1)
            filenames{j} = [code,'_',datestr(replaydts(j),'yyyymmdd'),'_tick.mat'];
        end
        combos.mdefut.initreplayer('code',code,'filenames',filenames);
    end
catch err
    fprintf('Error:%s\n',err.message);
end
combos.strategy.initdata;
combos.mdefut.printflag_ = false;
combos.ops.print_timeinterval_ = 60*trade_freq;
fprintf('replay ready...\n');

%%
close all;
ticks = combos.mdefut.replayer_.tickdata_{1};
timeseries_plot(ticks(:,1:2),'dateformat','HH:MM');
%%
clc;
combos.mdefut.start;
combos.ops.start; 
combos.strategy.start;

%%
try
    combos.mdefut.stop;
    delete(timerfindall);
catch
    clear all;
    fprintf('all deleted\n');
end
%%
fprintf('\ntrades info from replay......\n')
totalpnl = 0;
for i = 1:ninstruments
    trades_i = combos.ops.trades_.filterby('code',instruments{i}.code_ctp);
    fprintf('%s:\n',instruments{i}.code_ctp);
    for j = 1:trades_i.latest_
        trade_j = trades_i.node_(j);
        fprintf('id:%2d,opentime:%s,direction:%2d,price:%s,closetime:%s,pnl:%s\n',...
            j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
            num2str(trade_j.openprice_),...
            trade_j.closedatetime2_(end-8:end),...
            num2str(trade_j.closepnl_));
        totalpnl = totalpnl + trade_j.closepnl_;
    end
end
fprintf('total pnl:%s\n',num2str(totalpnl));
% trades info from replay......
% rb1810:
% id: 1,opentime: 14:36:18,direction: 1,price:3742,closetime: 21:15:01,pnl:80
% ni1809:
% id: 1,opentime: 14:30:02,direction: 1,price:112890,closetime: 21:00:00,pnl:-330
% id: 2,opentime: 21:00:05,direction: 1,price:112420,closetime: 00:00:01,pnl:360
% total pnl:110
%%
trades = cTradeOpenArray;
trades.fromtxt('c:\yangyiran\ops\save\citic_kim_fut-regression-wlprbatman\citic_kim_fut-regression-wlprbatman_trades_20180619.txt');
for i = 1:ninstruments
    trades_i = trades.filterby('code',instruments{i}.code_ctp);
    fprintf('%s:\n',instruments{i}.code_ctp);
    for j = 1:trades_i.latest_
        trade_j = trades_i.node_(j);
        if strcmpi(trade_j.status_,'closed')
            fprintf('id:%2d,opentime:%s,direction:%2d,price:%s,closetime:%s,pnl:%s\n',...
                j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
                num2str(trade_j.openprice_),...
                trade_j.closedatetime2_(end-8:end),...
                num2str(trade_j.closepnl_));
        end
    end
end

% T1809:
% id: 1,opentime: 13:03:17,direction:-1,price:95.24,stoptime: 13:00:00,closetime: 13:15:01,pnl:-1700
% id: 2,opentime: 13:15:01,direction:-1,price:95.405,stoptime: 13:14:59,closetime: 13:30:22,pnl:-250
% id: 3,opentime: 13:30:01,direction:-1,price:95.44,stoptime: 13:30:00,closetime: 14:10:45,pnl:-150
% id: 4,opentime: 14:10:21,direction:-1,price:95.445,stoptime: 13:59:59,closetime: 14:15:01,pnl:-800
% id: 5,opentime: 14:35:29,direction:-1,price:95.54,stoptime: 14:30:00,closetime: 15:00:52,pnl:-200
% rb1810:
% id: 1,opentime: 13:32:26,direction: 1,price:3755,closetime: 13:45:02,pnl:-20
% id: 2,opentime: 13:45:16,direction: 1,price:3748,closetime: 14:15:01,pnl:-10
% id: 3,opentime: 14:19:54,direction: 1,price:3743,closetime: 14:37:10,pnl:-30
% ni1809:
% id: 1,opentime: 09:04:49,direction: 1,price:114090,closetime: 09:21:08,pnl:-60
% id: 2,opentime: 14:12:47,direction: 1,price:113400,closetime: 14:15:01,pnl:-140
% id: 3,opentime: 14:15:01,direction: 1,price:113260,closetime: 14:30:00,pnl:-360