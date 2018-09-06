function [] = setbaseunits(strategy,instrument,baseunits)
%cStrat
    if ~isnumeric(baseunits), error('cStrat:setbaseunits:invalid baseunits input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.baseunits_)
            strategy.baseunits_ = baseunits*ones(strategy.count,1);
        else
            if size(strategy.baseunits_,1) < strategy.count
                strategy.baseunits_ = [strategy.baseunits_;baseunits];
            end
        end
    else
        strategy.baseunits_(idx) = baseunits;
    end

end
%end of setbaseunits