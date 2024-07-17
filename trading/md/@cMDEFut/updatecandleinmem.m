function [] = updatecandleinmem(mdefut)
%     if isempty(mdefut.ticks_), return; end
    if isempty(mdefut.ticksquick_), return; end
    if isempty(mdefut.candles4save_), return; end
    if isempty(mdefut.candles_),return;end
    
%     ns = size(mdefut.ticks_,1);
    ns = size(mdefut.ticksquick_,1);
    count = mdefut.ticks_count_;
    instruments = mdefut.qms_.instruments_.getinstrument;
    for i = 1:ns
        if count(i) == 0,continue;end
        category = mdefut.categories_(i);
        buckets = mdefut.candles_{i}(:,1);
        buckets4save = mdefut.candles4save_{i}(:,1);
%         t = mdefut.ticks_{i}(count(i),1);
%         px_trade = mdefut.ticks_{i}(count(i),4);
        t = mdefut.ticksquick_(i,1);
        px_trade = mdefut.ticksquick_(i,4);
        if px_trade <= 0, continue;end

        %note:Bloomberg rule
        %open bracket on the left hand side and close bracket on the right
        %hand side
        if category > 3
            if t == mdefut.num21_00_00_ 
                t = mdefut.num21_00_0_5_;
            end
        end
        
        %ignore the tick in case the tick time is in break-time
        usetick = 1;
        nintervals = size(instruments{i}.break_interval,1);
        datenum_open = mdefut.datenum_open_{i};
        datenum_close = mdefut.datenum_close_{i};
        if t <= datenum_open(1)
            return
        end
        for k = 1:nintervals-1
            if t > datenum_close(k) && t <= datenum_open(k+1)
                usetick = 0;
                break
            end
        end
        if ~usetick, return; end
        
        if strcmpi(mdefut.mode_,'realtime')
            tnow = now;
            if tnow <= datenum_open(1)-1/86400
                return
            end
            for k = 1:nintervals-1
                %2 second buffer zone
                if tnow > datenum_close(k)+2/86400 && tnow <= datenum_open(k+1)-2/86400
                    return
                end
            end
            if abs(t-tnow) >= 1/1440 && tnow <= datenum_close(end)
                fprintf('%s:%s:tick time:%s is off boudary\n',datestr(tnow,'yyyy-mm-dd HH;MM:SS'),instruments{i}.code_ctp,datestr(t,'yyyy-mm-dd HH;MM:SS'));
                return
            end
        end
        
        % equalorNot 用来解决str相同，但是double不同导致最终比较结果错误的问题
        if mdefut.candle_freq_(i) ~= 1440
            equalorNot = (round(buckets(2:end) *10e+07) == round(t*10e+07));
            if sum(sum(equalorNot)) == 0
                idx = buckets(1:end-1) < t & buckets(2:end) >= t;
            else
                idx = buckets(1:end-1) <t & equalorNot;
            end
            this_bucket = buckets(idx);
        else
            if size(buckets,1) == 1
                this_bucket = buckets;
            else
                hh = hour(t);
                if hh >= 9 && hh <= 15
                    idx = 1;
                else
                    idx = 2;
                    
                end
                this_bucket = buckets(idx);
            end
        end
        %
        equalorNot4save = (round(buckets4save(2:end) *10e+07) == round(t*10e+07));
        if sum(sum(equalorNot4save)) == 0
           idx4save = buckets4save(1:end-1) < t & buckets4save(2:end) >= t;
        else
           idx4save = buckets4save(1:end-1) < t & equalorNot4save;
        end
        this_bucket_save = buckets4save(idx4save);
                        
        %
        if ~isempty(this_bucket)
            this_count = find(buckets == this_bucket);
        else
            if strcmpi(mdefut.mode_,'realtime')
                if t > buckets(end) && now >  buckets(end)
                    this_count = size(buckets,1);
                else
                    this_count = [];
                end
            else
                if t > buckets(end)
                    this_count = size(buckets,1);
                else
                    this_count = [];
                end
            end
        end

        if ~isempty(this_count)
            if this_count ~= mdefut.candles_count_(i)
                mdefut.candles_count_(i) = this_count;
                newset = true;
                mdefut.newset_(i) = newset;
                %note:once newset_ is set to TRUE,
                %candles_count moves to the idx of the current
                %candle to be feeded in. As a result, the previous
                %candle has been fully feeded in.
%                 if mdefut.candle_freq_(i) == 1440 && this_count > 1
%                     mdefut.lastclose_(i) = mdefut.candles_{i}(1,5);                    
%                 end
            else
                newset = false;
                mdefut.newset_(i) = newset;
            end
            if mdefut.candle_freq_(i) == 1440 && ~isempty(strfind(instruments{i}.asset_name,'eqindex'))
                adj = mdefut.hist_candles_{i}(end,5)/mdefut.lastclose_(i);
                mdefut.candles_{i}(this_count,5) = px_trade*adj;
            else
                mdefut.candles_{i}(this_count,5) = px_trade;
            end
            if newset
                if mdefut.candle_freq_(i) == 1440 && ~isempty(strfind(instruments{i}.asset_name,'eqindex'))
                    adj = mdefut.hist_candles_{i}(end,5)/mdefut.lastclose_(i);
                    mdefut.candles_{i}(this_count,2) = px_trade*adj;   %px_open
                    mdefut.candles_{i}(this_count,3) = px_trade*adj;   %px_high
                    mdefut.candles_{i}(this_count,4) = px_trade*adj;   %px_low
                else
                    mdefut.candles_{i}(this_count,2) = px_trade;   %px_open
                    mdefut.candles_{i}(this_count,3) = px_trade;   %px_high
                    mdefut.candles_{i}(this_count,4) = px_trade;   %px_low
                end
                %NOTE:20190422
                %SOMETIMES we miss ticks for a certain bucket for illiquid
                %and the candle bucket will thus have zero entries; we need
                %to fix this by replacing zero entries with the last price
                %as of the previous candles
                if this_count > 1 && sum(mdefut.candles_{i}(this_count-1,2:5)) == 0
                    try
                        lastclose = mdefut.candles_{i}(this_count-2,5);
                    catch
                        lastclose = px_trade;
                    end
                    fprintf('candle data missing was found between %s and %s...\n',...
                        datestr(mdefut.candles_{i}(this_count-1),'yyyy-mm-dd HH:MM'),...
                        datestr(mdefut.candles_{i}(this_count),'yyyy-mm-dd HH:MM'));
                    mdefut.candles_{i}(this_count-1,2:5) = lastclose;
                end
                
            else
                high = mdefut.candles_{i}(this_count,3);
                low = mdefut.candles_{i}(this_count,4);
                if mdefut.candle_freq_(i) == 1440 && ~isempty(strfind(instruments{i}.asset_name,'eqindex'))
                    adj = mdefut.hist_candles_{i}(end,5)/mdefut.lastclose_(i);
                    if px_trade*adj > high, mdefut.candles_{i}(this_count,3) = px_trade*adj; end
                    if px_trade*adj < low, mdefut.candles_{i}(this_count,4) = px_trade*adj;end
                else
                    if px_trade > high, mdefut.candles_{i}(this_count,3) = px_trade; end
                    if px_trade < low, mdefut.candles_{i}(this_count,4) = px_trade;end
                end
            end
        end
        %
        if ~isempty(this_bucket_save)
            this_count_save = find(buckets4save == this_bucket_save);
        else
            if t > buckets4save(end)
                this_count_save = size(buckets4save,1);
            else
                this_count_save = [];
            end
        end

        if ~isempty(this_count_save)
            if this_count_save ~= mdefut.candles4save_count_(i)
                mdefut.candles4save_count_(i) = this_count_save;
                newset = true;
            else
                newset = false;
            end
            mdefut.candles4save_{i}(this_count_save,5) = px_trade;
            if newset
                mdefut.candles4save_{i}(this_count_save,2) = px_trade;   %px_open
                mdefut.candles4save_{i}(this_count_save,3) = px_trade;   %px_high
                mdefut.candles4save_{i}(this_count_save,4) = px_trade;   %px_low
                %NOTE:20190422
                %SOMETIMES we miss ticks for a certain bucket for illiquid
                %and the candle bucket will thus have zero entries; we need
                %to fix this by replacing zero entries with the last price
                %as of the previous candles
                if this_count_save > 1 && sum(mdefut.candles4save_{i}(this_count_save-1,2:5)) == 0
                    try
                        lastclose = mdefut.candles4save_{i}(this_count_save-2,5);
                    catch
                        lastclose = px_trade;
                    end
                    mdefut.candles4save_{i}(this_count_save-1,2:5) = lastclose;
                end
            else
                high = mdefut.candles4save_{i}(this_count_save,3);
                low = mdefut.candles4save_{i}(this_count_save,4);
                if px_trade > high, mdefut.candles4save_{i}(this_count_save,3) = px_trade; end
                if px_trade < low, mdefut.candles4save_{i}(this_count_save,4) = px_trade;end
            end
        end
        %
    end
end
%end of updatecandleinmem