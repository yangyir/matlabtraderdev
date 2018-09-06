function bidspread = getbidclosespread(strategy,instrument)
%cStrat
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getbidclosespread:instrument not found');end
    bidspread = strategy.bidclosespread_(idx);

end
%end of getbidclosespread