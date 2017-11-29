function [] = setlimitamount(strategy,instrument,limit)
    if ~isnumeric(limit), error('cStrat:setlimitamount:invalid limit input'); end

    if isempty(strategy.pnl_limit_), strategy.pnl_limit_ = inf*ones(strategy.count,1);end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:setlimitamount:instrument not found');end

    strategy.pnl_limit_(idx) = limit;

end
%end of 'setlimitamount'