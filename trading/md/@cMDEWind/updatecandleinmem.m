function [] = updatecandleinmem(obj)
%cMDEWind
    if isempty(obj.ticksquick_), return; end
%     if isempty(obj.candles4save_), return; end
    if isempty(obj.candlesintraday_),return;end
    
    ns = size(obj.ticksquick_,1);
    count = obj.ticks_count_;
    for i = 1:ns
        if count(i) == 0,continue;end
%         category = obj.categories_(i);
        buckets = obj.candlesintraday_{i}(:,1);
%         buckets4save = obj.candles4save_{i}(:,1);
        t = obj.ticksquick_(i,1);
        px_trade = obj.ticksquick_(i,4);

        %note:Bloomberg rule
        %open bracket on the left hand side and close bracket on the right
        %hand side
        
        %ignore the tick in case the tick time is in break-time
        usetick = 1;
        nintervals = 2;
        datenum_open = obj.datenum_open_{i};
        datenum_close = obj.datenum_close_{i};
        for k = 1:nintervals-1
            if t > datenum_close(k) && t <= datenum_open(k+1)
                usetick = 0;
                break
            end
        end
        if ~usetick, return; end    
        
        % equalorNot 用来解决str相同，但是double不同导致最终比较结果错误的问题
        if obj.freq_(i) ~= 1440
            equalorNot = (round(buckets(2:end) *10e+07) == round(t*10e+07));
            if sum(sum(equalorNot)) == 0
                idx = buckets(1:end-1) < t & buckets(2:end) >= t;
            else
                idx = buckets(1:end-1) <t & equalorNot;
            end
            this_bucket = buckets(idx);
        else
            this_bucket = buckets;
        end
        %
%         equalorNot4save = (round(buckets4save(2:end) *10e+07) == round(t*10e+07));
%         if sum(sum(equalorNot4save)) == 0
%            idx4save = buckets4save(1:end-1) < t & buckets4save(2:end) >= t;
%         else
%            idx4save = buckets4save(1:end-1) < t & equalorNot4save;
%         end
%         this_bucket_save = buckets4save(idx4save);
                        
        %
        if ~isempty(this_bucket)
            this_count = find(buckets == this_bucket);
        else
            if t > buckets(end)
                this_count = size(buckets,1);
            else
                this_count = [];
            end
        end

        if ~isempty(this_count)
            if this_count ~= obj.candles_count_(i)
                obj.candles_count_(i) = this_count;
                newset = true;
                obj.newset_(i) = newset;
                %note:once newset_ is set to TRUE,
                %candles_count moves to the idx of the current
                %candle to be feeded in. As a result, the previous
                %candle has been fully feeded in.
            else
                newset = false;
                obj.newset_(i) = newset;
            end
            
            obj.candlesintraday_{i}(this_count,5) = px_trade;
            
            if newset
                obj.candlesintraday_{i}(this_count,2) = px_trade;   %px_open
                obj.candlesintraday_{i}(this_count,3) = px_trade;   %px_high
                obj.candlesintraday_{i}(this_count,4) = px_trade;   %px_low
                %NOTE:20190422
                %SOMETIMES we miss ticks for a certain bucket for illiquid
                %and the candle bucket will thus have zero entries; we need
                %to fix this by replacing zero entries with the last price
                %as of the previous candles
                if this_count > 1 && sum(obj.candlesintraday_{i}(this_count-1,2:5)) == 0
                    try
                        lastclose = obj.candlesintraday_{i}(this_count-2,5);
                    catch
                        lastclose = px_trade;
                    end
                    obj.candlesintraday_{i}(this_count-1,2:5) = lastclose;
                end
            else
                high = obj.candlesintraday_{i}(this_count,3);
                low = obj.candlesintraday_{i}(this_count,4);
                if px_trade > high, obj.candlesintraday_{i}(this_count,3) = px_trade; end
                if px_trade < low, obj.candlesintraday_{i}(this_count,4) = px_trade;end
            end
        end
        %
%         if ~isempty(this_bucket_save)
%             this_count_save = find(buckets4save == this_bucket_save);
%         else
%             if t > buckets4save(end)
%                 this_count_save = size(buckets4save,1);
%             else
%                 this_count_save = [];
%             end
%         end

%         if ~isempty(this_count_save)
%             if this_count_save ~= obj.candles4save_count_(i)
%                 obj.candles4save_count_(i) = this_count_save;
%                 newset = true;
%             else
%                 newset = false;
%             end
%             obj.candles4save_{i}(this_count_save,5) = px_trade;
%             if newset
%                 obj.candles4save_{i}(this_count_save,2) = px_trade;   %px_open
%                 obj.candles4save_{i}(this_count_save,3) = px_trade;   %px_high
%                 obj.candles4save_{i}(this_count_save,4) = px_trade;   %px_low
%                 %NOTE:20190422
%                 %SOMETIMES we miss ticks for a certain bucket for illiquid
%                 %and the candle bucket will thus have zero entries; we need
%                 %to fix this by replacing zero entries with the last price
%                 %as of the previous candles
%                 if this_count_save > 1 && sum(obj.candles4save_{i}(this_count_save-1,2:5)) == 0
%                     try
%                         lastclose = obj.candles4save_{i}(this_count_save-2,5);
%                     catch
%                         lastclose = px_trade;
%                     end
%                     obj.candles4save_{i}(this_count_save-1,2:5) = lastclose;
%                 end
%             else
%                 high = obj.candles4save_{i}(this_count_save,3);
%                 low = obj.candles4save_{i}(this_count_save,4);
%                 if px_trade > high, obj.candles4save_{i}(this_count_save,3) = px_trade; end
%                 if px_trade < low, obj.candles4save_{i}(this_count_save,4) = px_trade;end
%             end
%         end
        %
    end
end
%end of updatecandleinmem