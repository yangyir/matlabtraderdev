function calcsignalbucket = getcalcsignalbucket(strategy,instrument)
%cStrat
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getcalcsignalbucket:instrument not found');end
    calcsignalbucket = strategy.calsignal_bucket_(idx);
end