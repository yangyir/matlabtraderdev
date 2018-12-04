filename = [getenv('HOME'),'realtrading\batmanconfig_single.txt'];
code = 'sc1901';
genconfigfile('batman',filename,'instruments',{code});
ui_propnames = {'use'};
ui_propvalues = {1};
modconfigfile(filename,'code',code,'propnames',ui_propnames,'propvalues',ui_propvalues);
%
%%
countername = 'ccb_ly_fut';
bookname = 'book-crude-batman';
starupfund = 500000;
combos = rtt_setup('CounterName',countername,...
    'BookName',bookname,...
    'StrategyName','batman',...
    'RiskConfigFileName',filename);
combos.strategy.setavailablefund(starupfund,'firstset',true);
fprintf('\ncombos successfully created...\n');
%
%%
combos.mdefut.login('Connection','CTP','CounterName',countername);
%%
%start mdefut to receive live market quotes
combos.mdefut.start
combos.ops.start;
combos.strategy.start;
%
%%
price = 413.8;
direction = 1;
volume = 1;
%
if direction == 1
    directionstr = 'b';
elseif direction == -1;
    directionstr = 's';
else
    error('invalid direction');
end
target = price + direction*0.3;
stoploss = price - direction*3;
combos.strategy.placeentrust(code,'buysell',directionstr,'price',price,'volume',volume,'target',target,'stoploss',stoploss);
%
%%
combos.strategy.withdrawentrusts(code);