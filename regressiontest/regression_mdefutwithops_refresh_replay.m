%% Create a Book
clear;clc;
myCounter = CounterCTP.citic_kim_fut;
myTraderName = 'computer';
myBookName = 'book1';
myBook = cBook;
myBook.init(myBookName,myTraderName,myCounter);
%% Create a Ops
myOpsName = 'helper';
myOps = cOps;
myOps.init(myOpsName,myBook);
myOps.mode_ = 'replay';
%% Create Trade amd TradeArray
myTrade = cTradeOpen;
myTrade.id_ = 'mytrade1';
myTrade.countername_ = myCounter.char;
myTrade.bookname_ = myBook.bookname_;
myTrade.code_ = 'ni1809';
myTrade.opendatetime1_ = datenum('2018-06-15 14:59:59');
myTrade.openprice_ = 115780;
myTrade.openvolume_ = 2;
myTrade.opendirection_ = 1;
tradeArray = cTradeOpenArray;
tradeArray.push(myTrade);
tradesfileName = 'C:\yangyiran\regressiondata\trades\regressiontrades.txt';
tradeArray.totxt(tradesfileName);
%% call cOps::loadtrades methods
myOps.loadtrades('time',datenum('2018-06-19 08:50:00'),'filename',tradesfileName);
%% cMDEFut in replay mode
code = myTrade.code_;
myMDE = cMDEFut;
myMDE.registerinstrument(code);
data_dir_ = 'C:\yangyiran\regressiondata\';
replay_startdt = '2018-06-19';
replay_enddt = '2018-06-22';
replay_dates = gendates('fromdate',replay_startdt,'todate',replay_enddt);
replay_filenames = cell(size(replay_dates));
for i = 1:size(replay_dates,1)
    replay_filenames{i} = [data_dir_,code,'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.mat'];
end
myMDE.initreplayer('code',code,'fn',replay_filenames{1});
myMDE.timer_interval_ = 0.005;
%%
myOps.mdefut_ = myMDE;
myOps.timer_interval_ = myMDE.timer_interval_;
%%
myOps.start;
myMDE.start;
%%
myOps.stop;
myMDE.stop;
delete(timerfindall);

