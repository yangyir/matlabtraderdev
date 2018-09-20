clear all;clc;delete(timerfindall);dir_ = getenv('TRADINGDIR'); cd(dir_);
%%
countername = 'ccb_ly_fut';
bookname = 'book-batman-ctp';
markettype = 'futures';
strategyname = 'batman';
instruments = {'rb1901';'cu1811';'zn1811';'ni1811'};
combos = rtt_setup('CounterName',countername,'BookName',bookname,'StrategyName',strategyname,'Instruments',instruments);
fprintf('\ncombos successfully created...\n');
%%
for i = 1:size(instruments,1);
    code = instruments{i};
    samplefreq = 5;
    combos.strategy.setsamplefreq(code,samplefreq);
    combos.strategy.setmaxunits(code,3);
    combos.strategy.setmaxexecutionperbucket(code,1);
end

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
code = 'zn1811';
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
