function type_ = getstoptype(strategy,instrument)
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getstoptype:instrument not found');end
    type_ = strategy.pnl_stop_type_(idx);
    if type_ == 0
        type_ = 'rel';
    else
        type_ = 'abs';
    end
end
%end of 'getstoptype'