function typeout = getexecutiontype(stratfutwr,instrument)    
    [flag,idx] = stratfutwr.instruments_.hasinstrument(instrument);
    
    if flag
        typeout = stratfutwr.executiontype_{idx};
    else
        error('cStratFutMultiWR:getexecutiontype:instrument not found')
    end
    
end