function type_ = getlimittype(strategy,instrument)
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getlimittype:instrument not found');end
    type_ = strategy.pnl_limit_type_(idx);
    if type_ == 0
        type_ = 'rel';
    else
        type_ = 'abs';
    end

end
%end of 'getlimittype'