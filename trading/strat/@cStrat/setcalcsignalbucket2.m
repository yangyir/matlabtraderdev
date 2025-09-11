function [] = setcalcsignalbucket2(strategy,underlier,val)
%cStrat
    if ~isnumeric(val), error('cStrat:setcalcsignalbucket:invalid spread input');end

    [flag,idx] = strategy.hasunderlier(underlier);
    if ~flag 
        if isempty(strategy.calsignal_bucket_)
            strategy.calsignal_bucket_ = val*ones(strategy.countunderliers,1);
        else
            if size(strategy.calsignal_bucket_,1) < strategy.countunderliers
                strategy.calsignal_bucket_ = [strategy.calsignal_bucket_;val];
            end
        end
    else
        strategy.calsignal_bucket_(idx) = val;
    end
end