function [] = updatecandleinmem(mdefut)
    if isempty(mdefut.ticks_), return; end
    ns = size(mdefut.ticks_,1);
    count = mdefut.ticks_count_;
    for i = 1:ns
        buckets = mdefut.candles_{i}(:,1);
        buckets4save = mdefut.candles4save_{i}(:,1);
        t = mdefut.ticks_{i}(count(i),1);
        px_trade = mdefut.ticks_{i}(count(i),4);
        idx = buckets(1:end-1)<=t & buckets(2:end)>t;
        idx4save = buckets4save(1:end-1)<=t & buckets4save(2:end)>t;
        this_bucket = buckets(idx);
        this_bucket_save = buckets4save(idx4save);
        %
        if ~isempty(this_bucket)
            this_count = find(buckets == this_bucket);
        else
            if t >= buckets(end) && t < buckets(end)+buckets(end)-buckets(end-1)
                this_count = size(buckets,1);
            else
                this_count = [];
            end
        end

        if ~isempty(this_count)
            if this_count ~= mdefut.candles_count_(i)
                mdefut.candles_count_(i) = this_count;
                newset = true;
            else
                newset = false;
            end
            mdefut.candles_{i}(this_count,5) = px_trade;
            if newset
                mdefut.candles_{i}(this_count,2) = px_trade;   %px_open
                mdefut.candles_{i}(this_count,3) = px_trade;   %px_high
                mdefut.candles_{i}(this_count,4) = px_trade;   %px_low
            else
                high = mdefut.candles_{i}(this_count,3);
                low = mdefut.candles_{i}(this_count,4);
                if px_trade > high, mdefut.candles_{i}(this_count,3) = px_trade; end
                if px_trade < low, mdefut.candles_{i}(this_count,4) = px_trade;end
            end
        end
        %
        if ~isempty(this_bucket_save)
            this_count_save = find(buckets4save == this_bucket_save);
        else
            if t >= buckets4save(end) && t < buckets4save(end)+buckets4save(end)-buckets4save(end-1)
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