function value = getmaxexecutionperbucket(strat,instrument)
    
    [flag,idx] = strat.instruments_.hasinstrument(instrument);
    
    if flag
        value = strat.maxexecutionperbucket_(idx);
    else
        error('cStrat:getmaxexecutionperbucket:instrument not found')
    end
    
end