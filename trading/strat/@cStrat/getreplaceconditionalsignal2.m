function calcsignal = getreplaceconditionalsignal2(strategy,underlier)
%cStrat
    [flag,idx] = strategy.hasunderlier(underlier);
    if ~flag, error('cStrat:getreplaceconditionalsignal2:instrument not found');end
    calcsignal = strategy.replaceconditionalsignal_(idx);
end