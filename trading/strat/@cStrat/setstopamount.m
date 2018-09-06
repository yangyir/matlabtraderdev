function [] = setstopamount(strategy,instrument,stop)
%cStrat
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.pnl_stop_)
            strategy.pnl_stop_ = stop*ones(strategy.count,1);
        else
            if size(strategy.pnl_stop_,1) < strategy.count
                strategy.pnl_stop_ = [strategy.pnl_stop_;stop];
            end
        end
    else
        strategy.pnl_stop_(idx) = stop;
    end

end