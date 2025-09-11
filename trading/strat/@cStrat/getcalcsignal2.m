function calcsignal = getcalcsignal2(strategy,underlier)
%cStrat
    [flag,idx] = strategy.hasunderlier(underlier);
    if ~flag, error('cStrat:getcalcsignal2:underlier not found');end
    calcsignal = strategy.calsignal_(idx);
end