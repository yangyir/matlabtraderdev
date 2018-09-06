function [] = setexecutionperbucket(strategy,instrument,value)
%cStrat
    if ~isnumeric(value), error('cStrat:setexecutionperbucket:invalid date type input');end
    
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.executionperbucket_)
            strategy.executionperbucket_ = value*ones(strategy.count,1);
        else
            if size(strategy.executionperbucket_,1) < strategy.count
                strategy.executionperbucket_ = [strategy.executionperbucket_;value];
            end
        end
    else
        strategy.executionperbucket_(idx) = value;
    end
    
end