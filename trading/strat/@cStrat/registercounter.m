function [] = registercounter(strategy,counter)
    if ~isa(counter,'CounterCTP'), error('cStrat:registercounter:invalid counter input');end
    strategy.counter_ = counter;
    %
    %name conventions
    tradername = [strategy.name_,'->',counter.char];
    bn_running = [tradername,'->running'];
    bn_base = [tradername,'->base'];
    opsname = [strategy.name_,'->',counter.char,'->ops'];
    %
    
    trader = cTrader;trader.init(tradername);
    b1 = cBook;b1.init(bn_running,tradername,counter);
    b2 = cBook;b2.init(bn_base,tradername,counter);
    trader.addbook(b1);
    strategy.trader_ = trader;
    strategy.bookrunning_ = b1;
    strategy.bookbase_ = b2;
    %
    ops = cOps;
    ops.init(opsname,strategy.bookrunning_);
    %update entrusts and book every second
    ops.timer_interval_ = 1;
    strategy.helper_ = ops;
    strategy.helper_.start;
    strategy.helper_.timer_.tag = 'ops';
    %
    
end
%end of registercounter