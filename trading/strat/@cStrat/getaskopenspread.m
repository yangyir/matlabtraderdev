function askspread = getaskopenspread(strategy,instrument)
%cStrat
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getaskspread:instrument not found');end
    askspread = strategy.askopenspread_(idx);

end
%end of getaskopenspread