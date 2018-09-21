clear all;clc;delete(timerfindall);cd('C:\yangyiran');
%
countername = 'rh_demo';
bookname = 'book-demo-rh-single';
markettype = 'futures';
strategyname = 'batman';
instruments = {'rb1901'};
combos = rtt_setup('CounterName',countername,'BookName',bookname,'StrategyName',strategyname,'Instruments',instruments);
fprintf('\ncombos successfully created...\n');
%%
code = instruments{1};
samplefreq = 5;
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
price = 4170;
target = 4140;
stoploss = 4200;
volume = 4;
combos.strategy.placeentrust(code,'buysell','s','price',price,'volume',volume,'target',target,'stoploss',stoploss);

%%
%withdraw
combos.strategy.withdrawentrusts(code);
%% 新注册合约到策略
code2register = 'T1812';
combos.strategy.registerinstrument(code2register);
combos.strategy.setsamplefreq(code2register,samplefreq);
%%
code2trade = 'T1812';
price = 94.135;
target = 94.205;
stoploss = 94.100;
volume = 1;
buysell = 'b';
combos.strategy.placeentrust(code2trade,'buysell',buysell,'price',price,'volume',volume,'target',target,'stoploss',stoploss);

%%
combos.strategy.longclose('cu1811',2,1,'overrideprice',49750);
%%
combos.mdefut.stop
%%
c.logout
%%
mdlogout
