function [] = registercounter(strategy,counter)
    if ~isa(counter,'CounterCTP'), error('cStrat:registercounter:invalid counter input');end
    strategy.counter_ = counter;
%     strategy.entrusts_ = EntrustArray;
    %
    trader = cTrader;trader.init(strategy.name_);
    b1 = cBook;b1.init('bookrunning',trader.name_,counter);
    b2 = cBook;b2.init('bookbase',trader.name_,counter);
    trader.addbook(b1);
    strategy.trader_ = trader;
    strategy.bookrunning_ = b1;
    strategy.bookbase_ = b2;
    %
    ops = cOps;
    ops.init('ops1',strategy.bookrunning_);
    strategy.helper_ = ops;
    %
    
    
end
%end of registercounter