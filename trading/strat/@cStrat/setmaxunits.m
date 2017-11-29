function [] = setmaxunits(strategy,instrument,maxunits)
    if ~isnumeric(maxunits), error('cStrat:setmaxunits:invalid baseunits input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        error('cStrat:setmaxunits:instrument not found')
    end
    strategy.maxunits_(idx) = maxunits;

end
%end of setmaxunits