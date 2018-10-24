clear all;clc;delete(timerfindall);dir_ = getenv('TRADINGDIR'); cd(dir_);
%%
countername = 'ccb_ly_fut';
bookname = 'book-batman-ctp';
markettype = 'futures';
strategyname = 'batman';
configfilename = 'batmanconfig_ctp.txt';
combos = rtt_setup('CounterName',countername,'BookName',bookname,'StrategyName',strategyname,'RiskConfigFileName',configfilename);
combos.strategy.setavailablefund(1000000,'firstset',true);
fprintf('\ncombos successfully created...\n');

%%
combos.mdefut.login('Connection','CTP','CounterName',countername);
%%
c = combos.ops.getcounter;
if ~c.is_Counter_Login;c.login;end
%%
%start mdefut to receive live market quotes
combos.mdefut.start
combos.ops.start;
combos.strategy.start;
%%
code = 'zn1812';
price = 22305;
target = 22255;
stoploss = 22505;
volume = 1;
combos.strategy.placeentrust(code,'buysell','s','price',price,'volume',volume,'target',target,'stoploss',stoploss);

%%
%withdraw
combos.strategy.withdrawentrusts(code);
%%
%%
combos.mdefut.stop
%%
c.logout
%%
mdlogout
