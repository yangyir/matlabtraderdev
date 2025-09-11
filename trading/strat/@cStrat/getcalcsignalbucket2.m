function calcsignalbucket = getcalcsignalbucket2(strategy,underlier)
%cStrat
    [flag,idx] = strategy.hasunderlier(underlier);
    if ~flag, error('cStrat:getcalcsignalbucket2:underlier not found');end
    calcsignalbucket = strategy.calsignal_bucket_(idx);
end