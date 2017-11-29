function type_ = getstoptype(strategy,instrument)
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getstoptype:instrument not found');end
    type_ = strategy.pnl_stop_type_{idx};

    end
%end of 'getstoptype'