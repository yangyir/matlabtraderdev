function askspread = getaskspread(strategy,instrument)
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getaskspread:instrument not found');end
    askspread = strategy.askspread_(idx);

end
%end of getaskspread