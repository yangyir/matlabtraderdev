clear all;clc;delete(timerfindall);cd('C:\yangyiran');
%%
countername = 'rh_demo_tf';
bookname = 'book-demotrading-rh';
markettype = 'futures';
strategyname = 'manual';
% instruments = {'cu1811';'al1811';'zn1811';'ni1811';'ni1901';'rb1901'};
configfn = 'manualconfig_rh.txt';
combos = rtt_setup('CounterName',countername,'BookName',bookname,...
    'MarketType','futures','StrategyName',strategyname,'RiskConfigFileName',configfn);
fprintf('\ncombos successfully created...\n');
%%
combos.mdefut.login('Connection','CTP','CounterName','citic_kim_fut');
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
code = 'ni1811';
volume = 1;
spread = 5;
combos.strategy.longopen(code,volume,'spread',spread);
%%
code = 'ni1811';
volume = 1;
closetoday = 1;
price = 102240;
combos.strategy.shortclose(code,volume,closetoday,'overrideprice',price);

%%
%withdraw
combos.strategy.withdrawentrusts(code);
%%
combos.mdefut.stop
%%
c.logout
%%
