function [] = setexecutionperbucket(strat,instrument,value)
    if isempty(strat.executionperbucket_), strat.executionperbucket_ = zeros(strat.count,1);end
    
    [flag,idx] = strat.instruments_.hasinstrument(instrument);
    
    if flag
        strat.executionperbucket_(idx) = value;
    else
        error('cStrat:setexecutionperbucket:instrument not found')
    end
end