function [] = setmaxexecutionperbucket(stratfutwr,instrument,value)
    if isempty(stratfutwr.maxexecutionperbucket_), stratfutwr.maxexecutionperbucket_ = ones(stratfutwr.count,1);end
    
    [flag,idx] = stratfutwr.instruments_.hasinstrument(instrument);
    
    if flag
        stratfutwr.maxexecutionperbucket_(idx) = value;
    else
        error('cStratFutMultiWR:setmaxexecutionperbucket:instrument not found')
    end
    
end