function value = getmaxexecutionperbucket(stratfutwr,instrument)
    
    [flag,idx] = stratfutwr.instruments_.hasinstrument(instrument);
    
    if flag
        value = stratfutwr.maxexecutionperbucket_(idx);
    else
        error('cStratFutMultiWR:getmaxexecutionperbucket:instrument not found')
    end
    
end