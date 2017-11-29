function type_ = getlimittype(strategy,instrument)
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getlimittype:instrument not found');end
    type_ = strategy.pnl_limit_type_{idx};

end
%end of 'getlimittype'