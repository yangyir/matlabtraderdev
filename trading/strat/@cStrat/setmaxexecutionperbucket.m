function [] = setmaxexecutionperbucket(strat,instrument,value)
    if isempty(strat.maxexecutionperbucket_), strat.maxexecutionperbucket_ = ones(strat.count,1);end
    
    [flag,idx] = strat.instruments_.hasinstrument(instrument);
    
    if flag
        strat.maxexecutionperbucket_(idx) = value;
    else
        error('cStrat:setmaxexecutionperbucket:instrument not found')
    end
    
end