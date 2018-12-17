%%
clear;clc;
codes = {'ni1809';'rb1810';'T1809'};
startdt = '2018-06-04';
enddt = '2018-06-19';
strategyname = 'manual';
fn = 'config_manual_regressiontest.txt';
dir_ = [getenv('HOME'),'regressiontest\cstrat\',strategyname,'\'];
genconfigfile(strategyname,[dir_,fn],'instruments',codes);
for i = 1:size(codes,1),modconfigfile([dir_,fn],'code',codes{i},'propnames',{'samplefreq'},'PropValues',{'5m'});end

%%
db = cLocal;
instruments = cell(size(codes));
candle_db_1m = cell(size(codes));
for i = 1:size(codes,1), instruments{i} = code2instrument(codes{i});end
for i = 1:size(codes,1), candle_db_1m{i} = db.intradaybar(instruments{i},startdt,enddt,1,'trade');end
%%
configfile = [dir_,fn];
configs = cell(size(codes));
candle_used = cell(size(codes));
wr = cell(size(codes));
for i = 1:size(codes,1)
    configs{i} = cStratConfig;
    configs{i}.loadfromfile('code',codes{i},'filename',configfile);
    [~,candle_used{i}] = bkfunc_gentrades_wlpr(codes{i},candle_db_1m{i},...
        'SampleFrequency',configs{i}.samplefreq_,...
        'NPeriod',144,...
        'AskOpenSpread',configs{i}.askopenspread_,...
        'BidOpenSpread',configs{i}.bidopenspread_,...
        'WRMode','classic',...
        'OverBought',-0,...
        'OverSold',-100);
    wr{i} = willpctr(candle_used{i}(:,3),candle_used{i}(:,4),candle_used{i}(:,5),144);
    figure(i)
    subplot(211);
    idx = find(candle_used{i}(:,1) >=  datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS'),1,'first');
    candle(candle_used{i}(idx:end,3),candle_used{i}(idx:end,4),candle_used{i}(idx:end,5),candle_used{i}(idx:end,2));
    grid on;
    subplot(212);
    plot(wr{i}(idx:end));grid on;
end
%
%%
clc;delete(timerfindall);
cd(dir_);
%
%user inputs:
bookname = ['replay_',strategyname];
availablefund = 1e6;
usehistdata = false;
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',configfile,...
    'initialfundlevel',availablefund,'usehistoricaldata',usehistdata);
% replay
fprintf('nruning regressiontest_wlpr_singleday_nickel...\n');
fprintf('switch mode to replay...\n');
if ~isempty(combos.mdefut), combos.mdefut.mode_ = 'replay';end
if ~isempty(combos.mdeopt), combos.mdeopt.mode_ = 'replay';end
if ~isempty(combos.ops), combos.ops.mode_ = 'replay';end
if ~isempty(combos.strategy), combos.strategy.mode_ = 'replay';end
%
replayspeed = 50;
fprintf('set replay speed to %s...\n',num2str(replayspeed));
if ~isempty(combos.mdefut),combos.mdefut.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.mdeopt),combos.mdeopt.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.ops),combos.ops.settimerinterval(1/replayspeed);end
if ~isempty(combos.strategy),combos.strategy.settimerinterval(1/replayspeed);end
%
fprintf('load replay tick data....\n');
replaydt1 = enddt;
replaydt2 = enddt;
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
fprintf('load historical candle data...\n');
combos.strategy.initdata;
combos.mdefut.printflag_ = true;
combos.ops.printflag_ = true;
for i = 1:size(codes,1), disp(combos.strategy.riskcontrols_.node_(i));end
fprintf('replay ready...\n');
%%
combos.mdefut.start;
combos.ops.start;
combos.strategy.start;
%%
combos.mdefut.stop
%% nickel
prices = [114000;113500;113000;112900;112800];
for i = 1:size(prices,1)
    combos.strategy.placeentrust(codes{1},'buysell','b','price',prices(i),'volume',1,...
    'limit',prices(i)+400,'stop',prices(i)-1000,'riskmanagername','batman');
end
%% deformed bar
prices = [3780;3750];
for i = 1:size(prices,1)
    combos.strategy.placeentrust(codes{2},'buysell','b','price',prices(i),'volume',1,...
        'limit',prices(i)+20,'stop',prices(i)-40,'riskmanagername','batman');
end
%% govtbond
prices = [95.2;95.18;95.16;95.15];
for i = 1:size(prices,1)
    combos.strategy.placeentrust(codes{3},'buysell','b','price',prices(i),'volume',1,...
        'limit',prices(i)+0.1,'stop',prices(i)-0.2,'riskmanagername','batman');
end
%%
loaddir = [combos.ops.loaddir_,bookname,'\'];
tradesfn = [bookname,'_trades_',datestr(enddt,'yyyymmdd'),'.txt'];
trades = cTradeOpenArray;
trades.fromtxt([loaddir,tradesfn]);
fprintf('\ntrades executed on %s...\n',datestr(enddt,'yyyymmdd'));
closedpnl = 0;
runningpnl = 0;
for j = 1:trades.latest_
    trade_j = trades.node_(j);
    if strcmpi(trade_j.status_,'closed')
        fprintf('id:%2d,opentime:%s,direction:%2d,price:%s,status:%s,closedpnl:%s\n',...
            j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
            num2str(trade_j.openprice_),...
            trade_j.status_,...
            num2str(trade_j.closepnl_));
        closedpnl = closedpnl + trade_j.closepnl_;
    else
        fprintf('id:%2d,opentime:%s,direction:%2d,price:%s,status:%s,runningpnl:%s\n',...
            j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
            num2str(trade_j.openprice_),...
            trade_j.status_,...
            num2str(trade_j.runningpnl_));
        runningpnl = runningpnl + trade_j.runningpnl_;
    end
end
fprintf('closedpnl:%s,runningpnl:%s...\n',num2str(closedpnl),num2str(runningpnl));
% trades executed on 20180619...
% id: 1,opentime: 09:04:50,direction: 1,price:114000,status:closed,closedpnl:250
% id: 2,opentime: 09:05:36,direction: 1,price:113500,status:closed,closedpnl:480
% id: 3,opentime: 09:15:24,direction: 1,price:95.2,status:set,runningpnl:2700
% id: 4,opentime: 09:16:59,direction: 1,price:95.18,status:set,runningpnl:2900
% id: 5,opentime: 09:34:01,direction: 1,price:95.16,status:set,runningpnl:3100
% id: 6,opentime: 09:36:05,direction: 1,price:95.15,status:set,runningpnl:3200
% id: 7,opentime: 11:18:39,direction: 1,price:3780,status:closed,closedpnl:-410
% id: 8,opentime: 13:44:39,direction: 1,price:3750,status:set,runningpnl:190
% id: 9,opentime: 14:26:05,direction: 1,price:113000,status:set,runningpnl:40
% id:10,opentime: 14:29:34,direction: 1,price:112900,status:set,runningpnl:140
% id:11,opentime: 14:35:10,direction: 1,price:112800,status:set,runningpnl:240
% closedpnl:320,runningpnl:12510...

%%
fprintf('\ntrades info from replay......\n')
for j = 1:combos.ops.trades_.latest_
    trade_j = combos.ops.trades_.node_(j);
    fprintf('id:%2d,opentime:%s,direction:%2d,price:%s,status:%s,closedpnl:%s\n',...
        j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
        num2str(trade_j.openprice_),...
        trade_j.status_,...
        num2str(trade_j.closepnl_));
end
% trades info from replay......
% id: 1,opentime: 09:15:24,direction: 1,price:95.2,status:set,closedpnl:0
% id: 2,opentime: 09:16:59,direction: 1,price:95.18,status:set,closedpnl:0
% id: 3,opentime: 09:34:01,direction: 1,price:95.16,status:set,closedpnl:0
% id: 4,opentime: 09:36:05,direction: 1,price:95.15,status:set,closedpnl:0
% id: 5,opentime: 13:44:39,direction: 1,price:3750,status:set,closedpnl:0
% id: 6,opentime: 14:26:05,direction: 1,price:113000,status:closed,closedpnl:280
% id: 7,opentime: 14:29:34,direction: 1,price:112900,status:closed,closedpnl:320
% id: 8,opentime: 14:35:10,direction: 1,price:112800,status:closed,closedpnl:310
