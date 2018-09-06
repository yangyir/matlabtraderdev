function [] = setcalcsignalbucket(strategy,instrument,val)
%cStrat
    if ~isnumeric(val), error('cStrat:setcalcsignalbucket:invalid spread input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, 
        if isempty(strategy.calsignal_bucket_)
            strategy.calsignal_bucket_ = val*ones(strategy.count,1);
        else
            if size(strategy.calsignal_bucket_,1) < strategy.count
                strategy.calsignal_bucket_ = [strategy.calsignal_bucket_;val];
            end
        end

    else
        strategy.calsignal_bucket_(idx) = val;
    end
end