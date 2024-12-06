function calcsignal = getreplaceconditionalsignal(strategy,instrument)
%cStrat
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getcalcsignal:instrument not found');end
    calcsignal = strategy.replaceconditionalsignal_(idx);
end