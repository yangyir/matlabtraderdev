clear all;clc;delete(timerfindall);
%%
countername = 'citic_kim_fut';
bookname = 'book-demotrading';
markettype = 'futures';
strategyname = 'manual';
instruments = {'T1812'};
combos = rtt_setup('CounterName',countername,'BookName',bookname,...
    'MarketType','futures','StrategyName',strategyname,'Instruments',instruments);
fprintf('\ncombos successfully created...\n');
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
%limit order - buy at price which is 10 ticks away from market quote
volume = 1;
spread = 10;
combos.strategy.longopensingleinstrument(instruments{1},volume,spread);

%%
%withdraw
combos.strategy.withdrawentrusts(instruments{1});
%%
combos.mdefut.stop
%%
c.logout

