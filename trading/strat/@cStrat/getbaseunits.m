function baseunits = getbaseunits(strategy,instrument)
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        error('cStrat:getbaseunits:instrument not found')
    end
    baseunits = strategy.baseunits_(idx);

end
%end of getbaseunit