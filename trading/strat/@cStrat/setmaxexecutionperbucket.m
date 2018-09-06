function [] = setmaxexecutionperbucket(strategy,instrument,value)
%cStrat
    if ~isnumeric(value), error('cStrat:setmaxexecutionperbucket:invalid date type input');end
    
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.maxexecutionperbucket_)
            strategy.maxexecutionperbucket_ = value*ones(strategy.count,1);
        else
            if size(strategy.maxexecutionperbucket_,1) < strategy.count
                strategy.maxexecutionperbucket_ = [strategy.maxexecutionperbucket_;value];
            end
        end
    else
        strategy.maxexecutionperbucket_(idx) = calcflag;
    end    
end