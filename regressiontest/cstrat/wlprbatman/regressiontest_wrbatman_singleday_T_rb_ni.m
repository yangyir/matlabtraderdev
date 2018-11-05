%user inputs:
clear;clc;delete(timerfindall);
fprintf('\nruning regressiontest_wrbatman_singleday_T_rb_ni...\n');
bookname = 'regression-wlprbatman';
strategyname = 'wlprbatman';
path = [getenv('HOME'),'regressiontest\cstrat\wlprbatman\'];
riskconfigfilename = 'wlprbatmanconfig_multi_regressiontest.txt';
codes = genconfigfile(strategyname,[path,riskconfigfilename],...
    'instruments',{'T1809';'rb1810';'ni1809'});
%
combos = rtt_setup('bookname',bookname,...
    'strategyname',strategyname,...
    'riskconfigfilename',riskconfigfilename);
%%
fprintf('\nprint trades from backtest...\n');
instruments = combos.strategy.getinstruments;
startdt = '2018-06-04';
enddt = '2018-06-19';
checkdt = '2018-06-19';
trade_freq = 15;
stop_nperiod = 72;
db = cLocal;
ninstruments = size(instruments,1);
trades = cell(ninstruments,1);
trades2check = cell(ninstruments,1);
for i = 1:ninstruments;
    candle_db_1m = db.intradaybar(instruments{i},startdt,enddt,1,'trade');
    trades{i} = bkfunc_gentrades_wlpr(instruments{i}.code_ctp,candle_db_1m,'SampleFrequency',[num2str(trade_freq),'m'],...
    'NStopPeriod',stop_nperiod);
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
replayspeed = 50;
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
