function calcflag = getcalcsignalflag(strategy,instrument)
%cStrategy
    [flag,idx_instrument] = strategy.hasinstrument(instrument);
    if ~flag
        [flag,idx_instrument] = strategy.hasunderlier(instrument);
        if ~flag
            error('%s:getcalcsignalflag:instrument not found',class(strategy))
        else
            isunderlier = true;
        end
    else
        isunderlier = false;
    end
    
    if ~isunderlier
        autotrade = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','autotrade');
    else
        %here it may needs further enhancement
        autotrade = 1;
    end
    if ~autotrade
        calcflag = 0;
        return
    end
    
    if ~isunderlier
        inst = strategy.getinstruments;
    else
        inst = strategy.getunderliers;
    end
    
    if strcmpi(strategy.status_,'working')
        if ~isunderlier
            candles = strategy.mde_fut_.candles_{idx_instrument};
            buckets = candles(:,1);
            tick = strategy.mde_fut_.getlasttick(inst{idx_instrument});
        else
            candles = strategy.mde_opt_.candles_{1};
            buckets = candles(:,1);
            tick = strategy.mde_opt_.getlasttick(inst{1});
        end
        %yangyiran:20180722
        %note:tick might be empty since mdefut runs a bit late than the
        %strategy. this is completely due to different timer associated
        %with the strategy and mdefut
        if isempty(tick)
            strategy.calcsignal_(idx_instrument) = 0;
            calcflag = 0;
            return
        end
            
        t = tick(1);
        hh = hour(t);
        if (hh > 2 && hh < 9) || (hh > 15 && hh < 21)
            strategy.calcsignal_(idx_instrument) = 0;
            calcflag = 0;
            return
        end
        
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
        %we need to make sure we need to calc(re-calc) signal here
        %rule:we start to recalc signal once the candle K is fully
        %feeded. however, the newset flag is set once the first tick
        %after the candle bucket arrives and is reset FALSE after the
        %second tick arrives.
        if ~isempty(this_count)
            if this_count ~= strategy.calsignal_bucket_(idx_instrument)
                strategy.calcsignal_(idx_instrument) = 1;
                strategy.calsignal_bucket_(idx_instrument) = this_count;
                if strategy.printflag_
                    fprintf('%s:calc signal of %s at:%s\n',strategy.name_,instrument.code_ctp,datestr(t,'yyyy-mm-dd HH:MM:SS'));
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