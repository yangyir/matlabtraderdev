function n = getexecutionperbucket(strat,instrument)
    [flag,idx] = strat.instruments_.hasinstrument(instrument);
    
    if flag
        n = strat.executionperbucket_(idx);
    else
        error('%s:getexecutionperbucket:instrument not found',class(strat))
    end
end