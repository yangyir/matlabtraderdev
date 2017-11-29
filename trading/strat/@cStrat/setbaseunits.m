function [] = setbaseunits(strategy,instrument,baseunits)
    if ~isnumeric(baseunits), error('cStrat:setbaseunits:invalid baseunits input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        error('cStrat:setbaseunits:instrument not found')
    end
    strategy.baseunits_(idx) = baseunits;

end
%end of setbaseunits