%%
ccbly.strategy.wlpr('T1903')

%%
ccbly.strategy.stratplot('T1903')

%%
candlescell = ccbly.mdefut.getcandles('T1903');
candles = candlescell{1};

datestr(candles(:,1))

