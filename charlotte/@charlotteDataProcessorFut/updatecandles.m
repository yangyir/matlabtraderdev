function [] = updatecandles(obj)
% a charlotteDataProcessorFut function
    ncodes = size(obj.codes_,1);
    for i = 1:ncodes
        lasttick = obj.ticks_{i}(end,:);
        lasttick_t = lasttick(1);
        lasttick_p = lasttick(2);
        if lasttick_p <= 0; continue; end
        if obj.fut_categories_(i) > 3
            if lasttick_t == obj.num21_00_00_
                lasttick_t = obj.num21_00_0_5_;
            end
        end
        datenum_open = obj.datenum_open_{i};
        datenum_close = obj.datenum_close_{i};
        %open bracket on the left and close bracket on the right
        if lasttick_t <= datenum_open(1), continue;end
        ninterval = size(datenum_open,1);
        usetick = 1;
        for k = 1:ninterval - 1
            if lasttick_t > datenum_close(k) && lasttick_t <= datenum_open(k+1)
                usetick = 0;
                break;
            end
        end
        if ~usetick, continue; end
        
        tnow = now;
        if tnow <= datenum_open(1)-1/86400, continue; end
        usetick = 1;
        for k = 1:ninterval - 1
            % 2 seconds buffer zone
            if tnow > datenum_close(k)+2/86400 && tnow <= datenum_open(k+1)-2/86400
                usetick = 0;
                break
            end
        end
        if ~usetick, continue;end
        %
        if abs(lasttick_t-tnow) >= 1/1440 && tnow <= datenum_close(end), continue; end
        %
        %
        for k = 1:4
            if k == 1
                buckets = obj.candles_m1_{i}(:,1);
            elseif k == 2
                buckets = obj.candles_m5_{i}(:,1);
            elseif k == 3
                buckets = obj.candles_m15_{i}(:,1);
            else
                buckets = obj.candles_m30_{i}(:,1);
            end
            equalorNot = (round(buckets(2:end) *10e7) == round(lasttick_t*10e7));
            if sum(sum(equalorNot)) == 0
                %open bracket on the left and close bracket on the right
                idx = buckets(1:end-1) < lasttick_t & buckets(2:end) >= lasttick_t;
            else
                idx = buckets(1:end-1) < lasttick_t & equalorNot;
            end
            this_bucket = buckets(idx);
            if ~isempty(this_bucket)
                this_count = find(buckets == this_bucket,1,'first');
            else
                if lasttick_t > buckets(end) && tnow > buckets(end)
                    this_count = size(buckets,1);
                else
                    this_count = [];
                end
            end
            %
            if isempty(this_count), continue; end
            %
            if k == 1
                if this_count ~= obj.candles_m1_count_(i)
                    obj.newset_m1_(i) = 1;
                    obj.candles_m1_count_(i) = this_count;
                    fprintf('%6s:candles_m1 set to bucket starting at %s\n',obj.codes_{i},datestr(obj.candles_m1_{i}(this_count,1)));
                    if i == ncodes
                        fprintf('\n');
                    end
                else
                    obj.newset_m1_(i) = 0;
                end
                obj.candles_m1_{i}(this_count,5) = lasttick_p;
                if obj.newset_m1_(i)
                    obj.candles_m1_{i}(this_count,2) = lasttick_p;
                    obj.candles_m1_{i}(this_count,3) = lasttick_p;
                    obj.candles_m1_{i}(this_count,4) = lasttick_p;
                else
                    high = obj.candles_m1_{i}(this_count,3);
                    low = obj.candles_m1_{i}(this_count,4);
                    if lasttick_p > high, obj.candles_m1_{i}(this_count,3) = lasttick_p;end
                    if lasttick_p < low, obj.candles_m1_{i}(this_count,4) = lasttick_p;end
                end
                %
            elseif k == 2
                if this_count ~= obj.candles_m5_count_(i)
                    obj.newset_m5_(i) = 1;
                    obj.candles_m5_count_(i) = this_count;
                    fprintf('%6s:candles_m5 set to bucket starting at %s\n',obj.codes_{i},datestr(obj.candles_m5_{i}(this_count,1)));
                    if i == ncodes
                        fprintf('\n');
                    end
                else
                    obj.newset_m5_(i) = 0;
                end
                obj.candles_m5_{i}(this_count,5) = lasttick_p;
                if obj.newset_m5_(i)
                    obj.candles_m5_{i}(this_count,2) = lasttick_p;
                    obj.candles_m5_{i}(this_count,3) = lasttick_p;
                    obj.candles_m5_{i}(this_count,4) = lasttick_p;
                else
                    high = obj.candles_m5_{i}(this_count,3);
                    low = obj.candles_m5_{i}(this_count,4);
                    if lasttick_p > high, obj.candles_m5_{i}(this_count,3) = lasttick_p;end
                    if lasttick_p < low, obj.candles_m5_{i}(this_count,4) = lasttick_p;end
                end
                %
            elseif k == 3
                if this_count ~= obj.candles_m15_count_(i)
                    obj.newset_m15_(i) = 1;
                    obj.candles_m15_count_(i) = this_count;
                else
                    obj.newset_m15_(i) = 0;
                end
                obj.candles_m15_{i}(this_count,5) = lasttick_p;
                if obj.newset_m15_(i)
                    obj.candles_m15_{i}(this_count,2) = lasttick_p;
                    obj.candles_m15_{i}(this_count,3) = lasttick_p;
                    obj.candles_m15_{i}(this_count,4) = lasttick_p;
                else
                    high = obj.candles_m15_{i}(this_count,3);
                    low = obj.candles_m15_{i}(this_count,4);
                    if lasttick_p > high, obj.candles_m15_{i}(this_count,3) = lasttick_p;end
                    if lasttick_p < low, obj.candles_m15_{i}(this_count,4) = lasttick_p;end
                end
                %
            else
                if this_count ~= obj.candles_m30_count_(i)
                    obj.newset_m30_(i) = 1;
                    obj.candles_m30_count_(i) = this_count;
                else
                    obj.newset_m30_(i) = 0;
                end
                obj.candles_m30_{i}(this_count,5) = lasttick_p;
                if obj.newset_m30_(i)
                    obj.candles_m30_{i}(this_count,2) = lasttick_p;
                    obj.candles_m30_{i}(this_count,3) = lasttick_p;
                    obj.candles_m30_{i}(this_count,4) = lasttick_p;
                else
                    high = obj.candles_m30_{i}(this_count,3);
                    low = obj.candles_m30_{i}(this_count,4);
                    if lasttick_p > high, obj.candles_m30_{i}(this_count,3) = lasttick_p;end
                    if lasttick_p < low, obj.candles_m30_{i}(this_count,4) = lasttick_p;end
                end
                %
            end
        end
        
        
        
    end
end