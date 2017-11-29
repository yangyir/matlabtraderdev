function [] = registercounter(strategy,counter)
    if ~isa(counter,'CounterCTP'), error('cStrat:registercounter:invalid counter input');end
    strategy.counter_ = counter;
    strategy.entrusts_ = EntrustArray;
end
%end of registercounter