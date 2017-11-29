function amount_ = getlimitamount(strategy,instrument)
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getlimitamount:instrument not found');end
    amount_ = strategy.pnl_limit_(idx);

end
%end of 'getlimitamount'