clear;delete(timerfindall);clc;
%% general setup
bookname = 'replay_manual';
strategyname = 'manual';
riskconfigfilename = 'manualconfig_regression.txt';
% Name	cStratConfig	cStratConfig	cStratConfig
% CodeCTP	T1809	ni1809	rb1810
% SampleFreq	5m	5m	5m
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',riskconfigfilename);
% replay
fprintf('\n');
fprintf('switch mode to replay...\n');
if ~isempty(combos.mdefut), combos.mdefut.mode_ = 'replay';end
if ~isempty(combos.mdeopt), combos.mdeopt.mode_ = 'replay';end
if ~isempty(combos.ops), combos.ops.mode_ = 'replay';end
if ~isempty(combos.strategy), combos.strategy.mode_ = 'replay';end
availablefund = 1e6;
combos.strategy.setavailablefund(availablefund,'firstset',true);
%
%
replayspeed = 20;
fprintf('set replay speed to %s...\n',num2str(replayspeed));
if ~isempty(combos.mdefut),combos.mdefut.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.mdeopt),combos.mdeopt.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.ops),combos.ops.settimerinterval(1/replayspeed);end
if ~isempty(combos.strategy),combos.strategy.settimerinterval(1/replayspeed);end
fprintf('load replay data....\n');
replaydt1 = '2018-06-19';
replaydt2 = '2018-06-22';
replaydts = gendates('fromdate',replaydt1,'todate',replaydt2);
try
    instruments = combos.strategy.getinstruments;
    ninstruments = size(instruments,1);
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
fprintf('replay ready...\n');

%%
close all;
tickdata = combos.mdefut.replayer_.tickdata_{1};
timeseries_plot(tickdata(:,1:2),'dateformat','HH:MM');grid on;
%%
try
    combos.mdefut.start;
    combos.ops.start;
    combos.strategy.start
catch err
    fprintf('Error:%s\n',err.message);
end
%%
code = 'T1809';
instruments = combos.strategy.getinstruments;
[~,idx] = combos.strategy.hasinstrument(code);
instrument = instruments{idx};
t = combos.strategy.getreplaytime;

volume1 = 4;
volume2 = 4;
volume3 = 4;
volume4 = 4;
volume5 = 4;
price1 = 95.12;
price2 = 95.11;
price3 = 95.10;
price4 = 95.095;
price5 = 95.095;
nentrusts = combos.ops.entrusts_.latest;
while nentrusts == 0
    combos.strategy.longopen(code,volume1,'overrideprice',price1);
    combos.strategy.longopen(code,volume2,'overrideprice',price2);
    combos.strategy.longopen(code,volume3,'overrideprice',price3);
    combos.strategy.longopen(code,volume4,'overrideprice',price4);
    combos.strategy.longopen(code,volume5,'overrideprice',price5);
    nentrusts = combos.ops.entrusts_.latest;
    pause(5);
end

%% 停止regression
combos.mdefut.stop;

%% 用系统设定好的开仓spread开单
longvolume1 = 1;
combos.strategy.longopen('T1809',longvolume1);
% cStratManual:failed to place entrust as max allowance of 20 lots on T1809 breached...
%% 用价格-1开市价（market)单
longvolume2 = 5;
combos.strategy.longopen('T1809',longvolume2,'overrideprice',-1);
% cStratManual:failed to place entrust as max allowance of 4 lots per entrust on T1809 breached...
%% 用低于市场价的价格开单（limited order)
longvolume3 = 2;
combos.strategy.longopen('T1809',longvolume3,'overrideprice',95.11);
% cStratManual:failed to place entrust as max allowance of 20 lots on T1809 breached...
%% 用自己定义的开仓spread开单
longvolume4 = 2;
askopenspread = 5;
combos.strategy.longopen('T1809',longvolume3,'spread',askopenspread);
% cStratManual:failed to place entrust as max allowance of 20 lots on T1809 breached...

%%
shortvolume1 = 1;
combos.strategy.shortopen('T1809',shortvolume1);
%%
shortvolume2 = 1;
combos.strategy.shortopen('T1809',shortvolume1,'overrideprice',95.55);
%% 撤销委托
combos.strategy.withdrawentrusts('T1809')

%% 获取某一个品种的持仓盈亏情况
[runningpnl,closedpnl] = replay_strat.helper_.calcpnl('code','T1809','mdefut'combos.mdefut)
%% 打印策略资金信息
fprintf('\n');
currentmargin = combos.strategy.getcurrentmargin;
fprintf('%13s:%8s\n','CurrentMargin',num2str(round(currentmargin)));
%
availablefund = combos.strategy.getavailablefund;
fprintf('%13s:%8s\n','AvailableFund',num2str(round(availablefund)));
%
frozenmargin = combos.strategy.getfrozenmargin;
fprintf('%13s:%8s\n','FrozenMargin',num2str(round(frozenmargin)));
%
[runningpnl,closedpnl] = combos.strategy.helper_.calcpnl('mdefut',combos.mdefut);
fprintf('%13s:%8s\n','RunningPnL',num2str(sum(runningpnl)));
fprintf('%13s:%8s\n','ClosedPnL',num2str(sum(closedpnl)));
