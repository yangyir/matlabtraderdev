function bidspread = getbidspread(strategy,instrument)
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getbidspread:instrument not found');end
    bidspread = strategy.bidspread_(idx);

end
%end of getbidspread