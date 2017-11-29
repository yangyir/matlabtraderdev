function maxunits = getmaxunits(strategy,instrument)
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        error('cStratFut:getmaxunits:instrument not found');
    end
    maxunits = strategy.maxunits_(idx);

end
%end of getmaxunits