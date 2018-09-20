clear all;clc;delete(timerfindall);dir_ = getenv('TRADINGDIR'); cd(dir_);
%
countername = 'citic_kim_fut';
bookname = 'book-demotrading';
markettype = 'futures';
strategyname = 'wlprbatman';
instruments = {'ni1901'};
combos = rtt_setup('CounterName',countername,'BookName',bookname,...
    'MarketType','futures','StrategyName',strategyname,'Instruments',instruments);
fprintf('\ncombos successfully created...\n');

%%
code = instruments{1};
samplefreq = 5;
combos.strategy.setsamplefreq(code,samplefreq);
combos.strategy.setautotradeflag(code,1);
combos.strategy.setmaxunits(code,3);
combos.strategy.setmaxexecutionperbucket(code,1);
combos.strategy.setbandtarget(code,0.1);
combos.strategy.setbandstoploss(code,0.05);
combos.strategy.initdata;
%%
combos.strategy.printinfo

%%
combos.mdefut.login('Connection','CTP','CounterName',countername);
%%
c = combos.ops.getcounter;
if ~c.is_Counter_Login;c.login;end
%%
%start mdefut to receive live market quotes
combos.mdefut.start
%%
combos.ops.start;
%%
combos.strategy.start;

%%
%withdraw
combos.strategy.withdrawentrusts(instruments{1});
%%
combos.mdefut.stop
%%
warning('on');
c.logout
%%
combos.mdefut.logoff
