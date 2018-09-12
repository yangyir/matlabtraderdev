function calcflag = getcalcsignalflag(obj,instrument)
    [flag,idx_instrument] = obj.instruments_.hasinstrument(instrument);
    if ~flag
        error('cStrat:getcalcsignalflag:instrument not found')
    end
    
    inst = obj.instruments_.getinstrument;
    if strcmpi(obj.status_,'working')
        candles = obj.mde_fut_.candles_{idx_instrument};
        buckets = candles(:,1);
        tick = obj.mde_fut_.getlasttick(inst{idx_instrument});
        %yangyiran:20180722
        %note:tick might be empty since mdefut runs a bit late than the
        %strategy. this is completely due to different timer associated
        %with the strategy and mdefut
        if isempty(tick)
            strategy.calcsignal_(idx_instrument) = 0;
            calcflag = strategy.calcsignal_(idx_instrument);
            return
        end
            
        t = tick(1);
        equalorNot = (round(buckets(2:end) *10e+07) == round(t*10e+07));
        if sum(sum(equalorNot)) == 0
            idx = buckets(1:end-1) < t & buckets(2:end) >= t;
        else
            idx = buckets(1:end-1) <t & equalorNot;
        end
        this_bucket = buckets(idx);
        if ~isempty(this_bucket)
            this_count = find(buckets == this_bucket);
        else
            if t > buckets(end)
                this_count = size(buckets,1);
            else
                this_count = [];
            end
        end
        %
        if ~isempty(this_count)
            if this_count ~= obj.calsignal_bucket_(idx_instrument)
                strategy.calcsignal_(idx_instrument) = 1;
                obj.calsignal_bucket_(idx_instrument) = this_count;
                if obj.printflag_
                    fprintf('\n%s:calc signal at:%s\n',obj.name_,datestr(t,'yyyy-mm-dd HH:MM:SS'));
                end
            else
                strategy.calcsignal_(idx_instrument) = 0;
            end
        else
            strategy.calcsignal_(idx_instrument) = 0;
        end    
    else
        strategy.calcsignal_(idx_instrument) = 0;
    end
    
    calcflag = strategy.calcsignal_(idx_instrument);
end