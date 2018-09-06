function bidspread = getbidopenspread(strategy,instrument)
%cStrat
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getbidopenspread:instrument not found');end
    bidspread = strategy.bidopenspread_(idx);

end
%end of getbidopenspread