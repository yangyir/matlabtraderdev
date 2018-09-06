function [] = setlimitamount(strategy,instrument,limit)
%cStrat
    if ~isnumeric(limit), error('cStrat:setlimitamount:invalid pnl limit date type input');end
    
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.pnl_limit_)
            strategy.pnl_limit_ = limit*ones(strategy.count,1);
        else
            if size(strategy.pnl_limit_,1) < strategy.count
                strategy.pnl_limit_ = [strategy.pnl_limit_;limit];
            end
        end
    else
        strategy.pnl_limit_(idx) = limit;
    end

end
%end of 'setlimitamount'