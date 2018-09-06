function [] = setmaxunits(strategy,instrument,maxunits)
 %cStrat
    if ~isnumeric(maxunits), error('cStrat:setmaxunits:invalid data type input');end
    
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.maxunits_)
            strategy.maxunits_ = maxunits*ones(strategy.count,1);
        else
            if size(strategy.maxunits_,1) < strategy.count
                strategy.maxunits_ = [strategy.maxunits_;maxunits];
            end
        end
    else
        strategy.maxunits_(idx) = maxunits;
    end  

end
%end of setmaxunits