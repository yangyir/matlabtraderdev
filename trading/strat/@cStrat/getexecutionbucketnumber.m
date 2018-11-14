function n = getexecutionbucketnumber(strat,instrument)
    [flag,idx] = strat.instruments_.hasinstrument(instrument);
    
    if flag
        n = strat.executionbucketnumber_(idx);
    else
        error('%s:getexecutionbucketnumber:instrument not found',class(strat))
    end
end