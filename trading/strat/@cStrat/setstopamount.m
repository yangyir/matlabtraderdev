function [] = setstopamount(strategy,instrument,stop)
    if ~isnumeric(stop), error('cStrat:setstopamount:invalid stop input');end

    if isempty(strategy.pnl_stop_), strategy.pnl_stop_ = -inf*ones(strategy.count,1);end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:setstopamount:instrument not found');end

    strategy.pnl_stop_(idx) = stop;

end