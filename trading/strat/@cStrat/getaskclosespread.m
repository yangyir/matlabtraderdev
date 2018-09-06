function askspread = getaskclosespread(strategy,instrument)
%cStrat
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getaskspread:instrument not found');end
    askspread = strategy.askclosespread_(idx);

end
%end of getaskclosespread