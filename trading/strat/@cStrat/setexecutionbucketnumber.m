function [] = setexecutionbucketnumber(strategy,instrument,value)
%cStrat
    if ~isnumeric(value), error('%s:setexecutionbucketnumber:invalid date type input',class(strategy));end
    
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.executionbucketnumber_)
            strategy.executionbucketnumber_ = value*ones(strategy.count,1);
        else
            if size(strategy.executionbucketnumber_,1) < strategy.count
                strategy.executionbucketnumber_ = [strategy.executionbucketnumber_;value];
            end
        end
    else
        strategy.executionbucketnumber_(idx) = value;
    end
    
end