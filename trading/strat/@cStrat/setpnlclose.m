function [] = setpnlclose(strategy,instrument,pnl)
%cStrat
    if ~isnumeric(pnl), error('cStrat:setpnlclose:invalid data input type');end
        
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.pnl_close_)
            strategy.pnl_close_ = pnl*ones(strategy.count,1);
        else
            if size(strategy.pnl_close_,1) < strategy.count
                strategy.pnl_close_ = [strategy.pnl_close_;pnl];
            end
        end
    else
        strategy.pnl_close_(idx) = pnl;
    end
end