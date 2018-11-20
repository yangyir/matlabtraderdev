clear all;clc;delete(timerfindall);dir_ = getenv('TRADINGDIR'); cd(dir_);
%
countername = 'citic_kim_fut';
bookname = 'book-demotrading-wlprbatman';
strategyname = 'wlprbatman';
riskconfigfilename = 'wrbatmanconfig_demotrading.txt';
% tradesfilename = 'C:\yangyiran\ops\save\citic_kim_fut-book-demotrading-wlprbatman\citic_kim_fut-book-demotrading-wlprbatman_trades_20181115.txt';
tradesfilename = '';
combos = rtt_setup('CounterName',countername,...
    'BookName',bookname,...
    'StrategyName',strategyname,...
    'RiskConfigFileName',riskconfigfilename,...
    'TradesFileName',tradesfilename);
%%
availablefund = 1e6;
combos.strategy.setavailablefund(availablefund,'firstset',true);
fprintf('\ncombos strategy init historical data...\n');
combos.strategy.initdata;
fprintf('\ncombos successfully created...\n');
%%
combos.ops.book_.printpositions;
%%
combos.strategy.printinfo

%%
fprintf('\ncombos mdefut ctp login...\n');
combos.mdefut.login('Connection','CTP','CounterName',countername);
%%
c = combos.ops.getcounter;
if ~c.is_Counter_Login;c.login;end
%%
%start mdefut to receive live market quotes
combos.mdefut.start
combos.ops.start;
%%
combos.strategy.start;

%%
instruments = combos.strategy.getinstruments;
combos.strategy.withdrawentrusts(instruments{1});
%%
combos.mdefut.stop
%%
warning('on');
c.logout
%%
combos.mdefut.logoff
%%
combos.strategy.unwindpositions('sc1901');