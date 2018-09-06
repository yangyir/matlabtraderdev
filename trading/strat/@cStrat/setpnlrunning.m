function [] = setpnlrunning(strategy,instrument,pnl)
%cStrat
    if ~isnumeric(pnl), error('cStrat:setpnlrunning:invalid data input type');end
        
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.pnl_running_)
            strategy.pnl_running_ = pnl*ones(strategy.count,1);
        else
            if size(strategy.pnl_running_,1) < strategy.count
                strategy.pnl_running_ = [strategy.pnl_running_;pnl];
            end
        end
    else
        strategy.pnl_running_(idx) = pnl;
    end
end