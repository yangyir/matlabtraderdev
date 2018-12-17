%%
clear;clc;
% user_inputs
codes = {'rb1905'};
startdt = '2018-12-10';
enddt = '2018-12-14';
strategyname = 'wlpr';
fn = 'config_wlprflash_replay.txt';
dir_ = [getenv('HOME'),'replay\',strategyname,'\'];
genconfigfile(strategyname,[dir_,fn],'instruments',codes);
%modify risk configurations
for i = 1:size(codes,1),modconfigfile([dir_,fn],'code',codes{i},'PropNames',{'samplefreq';'wrmode';'riskmanagername'},'PropValues',{'3m';'flash';'batman'});end

%%
db = cLocal;
instruments = cell(size(codes));
candle_db_1m = cell(size(codes));
for i = 1:size(codes,1), instruments{i} = code2instrument(codes{i});end
for i = 1:size(codes,1), candle_db_1m{i} = db.intradaybar(instruments{i},startdt,enddt,1,'trade');end
clc
configfile =[dir_,fn];
configs = cell(size(codes));
trades = cell(size(codes));
candle_used = cell(size(codes));
wr = cell(size(codes));
for i = 1:size(codes,1)
    configs{i} = cStratConfigWR;
    configs{i}.loadfromfile('code',codes{i},'filename',configfile);
    [trades{i},candle_used{i}] = bkfunc_gentrades_wlpr(codes{i},candle_db_1m{i},...
        'SampleFrequency',configs{i}.samplefreq_,...
        'NPeriod',configs{i}.numofperiod_,...
        'AskOpenSpread',configs{i}.askopenspread_,...
        'BidOpenSpread',configs{i}.bidopenspread_,...
        'WRMode',configs{i}.wrmode_,...
        'OverBought',configs{i}.overbought_,...
        'OverSold',configs{i}.oversold_);
    wr{i} = willpctr(candle_used{i}(:,3),candle_used{i}(:,4),candle_used{i}(:,5),configs{i}.numofperiod_);
    figure(i)
    subplot(211);
    idx = find(candle_used{i}(:,1) >=  datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS'),1,'first');
    candle(candle_used{i}(idx:end,3),candle_used{i}(idx:end,4),candle_used{i}(idx:end,5),candle_used{i}(idx:end,2));
    grid on;
    subplot(212);
    plot(wr{i}(idx:end));grid on;
end
%
for i = 1:size(codes,1)
    count = 0;
    for j = 1:trades{i}.latest_
        if trades{i}.node_(j).opendatetime1_ > datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS')
            count = count + 1;
            fprintf('id:%2d,openbucket:%s,direction:%2d,price:%s\n',...
                    count,trades{i}.node_(j).opendatetime2_,trades{i}.node_(j).opendirection_,...
                    num2str(trades{i}.node_(j).openprice_));
        end
    end
    fprintf('\n');
end
% id: 1,openbucket:2018-12-14 09:33:01,direction:-1,price:3442
% id: 2,openbucket:2018-12-14 09:51:01,direction:-1,price:3446
% id: 3,openbucket:2018-12-14 21:03:01,direction:-1,price:3446

%%
clc;delete(timerfindall);
cd(dir_);
%
%user inputs:
bookname = 'replay_wlprflash_rb';
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
            filenames{j} = [getenv('DATAPATH'),'ticks\',code,'\',code,'_',datestr(replaydts(j),'yyyymmdd'),'_tick.txt'];
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

%%
loaddir = [combos.ops.loaddir_,bookname,'\'];
tradesfn = [bookname,'_trades_',datestr(enddt,'yyyymmdd'),'.txt'];
tradesexecuted = cTradeOpenArray;
tradesexecuted.fromtxt([loaddir,tradesfn]);
fprintf('\ntrades executed on %s...\n',datestr(enddt,'yyyymmdd'));
closedpnl = 0;
runningpnl = 0;
for j = 1:tradesexecuted.latest_
    trade_j = tradesexecuted.node_(j);
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
        runningpnl = trade_j.runningpnl_;
    end
end
fprintf('closedpnl:%s,runningpnl:%s...\n',num2str(closedpnl),num2str(runningpnl));
% trades executed on 20181214...
% id: 1,opentime: 09:36:45,direction:-1,price:3439,status:closed,closedpnl:-70
% closedpnl:-70,runningpnl:0...

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

