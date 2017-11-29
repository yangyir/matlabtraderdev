function amount_ = getstopamount(strategy,instrument)
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getstoptype:instrument not found');end
    amount_ = strategy.pnl_stop_(idx);

end
%end of 'getstoptype'