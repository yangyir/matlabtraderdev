clear all;clc;delete(timerfindall);cd('C:\yangyiran');
%%
countername = 'rh_demo';
bookname = 'book-demo-rh-single';
markettype = 'futures';
strategyname = 'batman';
instruments = {'rb1901'};
combos = rtt_setup('CounterName',countername,'BookName',bookname,'StrategyName',strategyname,'Instruments',instruments);
fprintf('\ncombos successfully created...\n');
%%
code = instruments{1};
samplefreq = 15;
combos.strategy.setsamplefreq(code,samplefreq);
combos.strategy.setmaxunits(code,3);
combos.strategy.setmaxexecutionperbucket(code,1);

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
combos.strategy.start;
%%
price = 4175;
target = 4150;
stoploss = 4200;
volume = 4;
combos.strategy.placeentrust(code,'buysell','s','price',price,'volume',volume,'target',target,'stoploss',stoploss);

%%
%withdraw
combos.strategy.withdrawentrusts(code);
%% 新注册合约到策略
code2register = 'zn1811';
combos.strategy.registerinstrument(code2register);
combos.strategy.setsamplefreq(code2register,samplefreq);
%%
price = 21825;
target = 21750;
stoploss = 21905;
volume = 5;
combos.strategy.placeentrust(code2register,'buysell','s','price',price,'volume',volume,'target',target,'stoploss',stoploss);

%%
combos.strategy.longclose(code2register,3,1,'overrideprice',21700);
%%
combos.mdefut.stop
%%
c.logout
%%
mdlogout
