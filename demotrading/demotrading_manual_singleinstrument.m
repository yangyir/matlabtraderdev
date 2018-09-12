clear all;clc;delete(timerfindall);cd('C:\Users\yiran\Documents\MATLAB');
%%
countername = 'citic_kim_fut';
bookname = 'book-demotrading';
markettype = 'futures';
strategyname = 'manual';
instruments = {'cu1811';'al1811';'zn1811';'ni1811';'ni1901';'rb1901';'i1901';'SR901';'m1901';'IC1809';'IH1809';'IF1809';'T1812'};
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

