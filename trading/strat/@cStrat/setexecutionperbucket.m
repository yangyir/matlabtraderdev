function [] = setexecutionperbucket(strategy,instrument,val)
%cStrat
    if ~isnumeric(val), error('%s:setexecutionperbucket:invalid spread input',class(strategy));end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, 
        if isempty(strategy.executionperbucket_)
            strategy.executionperbucket_ = val*zeros(strategy.count,1);
        else
            if size(strategy.executionperbucket_,1) < strategy.count
                strategy.executionperbucket_ = [strategy.executionperbucket_;val];
            end
        end

    else
        strategy.executionperbucket_(idx) = val;
    end
end