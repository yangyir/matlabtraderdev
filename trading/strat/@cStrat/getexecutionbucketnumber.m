function n = getexecutionbucketnumber(strat,instrument)
    [flag,idx] = strat.instruments_.hasinstrument(instrument);
    
    if flag
        n = strat.executionbucketnumber_(idx);
    else
        error('cStrat:getexecutionbucketnumber:instrument not found')
    end
end