function n = getexecutionperbucket(strat,instrument)
    [flag,idx] = strat.instruments_.hasinstrument(instrument);
    
    if flag
        n = strat.executionperbucket_(idx);
    else
        error('cStrat:getexecutionperbucket:instrument not found')
    end
end