function candles = timeseries_tick2candle(varargin)
% note:convert tick data to 1m intraday candles
% the following are Bloomberg rules
% 1.The Bloomberg candle time indicates when the candle start
% 2.The Bloomberg candle use the open bracket for the candle start and
% close bracket for the candle end, e.g. 09:00 candle stores the
% open,high,low and close price of ticks with time after 09:00:00 and
% before or on 09:01:00.
% 3.However,the Bloomberg use the tick on 21:00:00 for the candle between
% 21:00:00 and 21:01:00
% 4.The Bloomberg doesn't take the govtbond tick on 11:30:00 into account
% 5.The Bloomberg treat ticks on 00:00:00 trickly,i.e.
% candle_23:59:59 = ticks (23:59:00 , 00:00:00] 
% candle_00:00:00 = ticks [00:00:00 , 00:01:00]
%
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('ticks',[],@isnumeric);
    p.parse(varargin{:});
    code = p.Results.code;
    ticks = p.Results.ticks;
    if isempty(code) || isempty(ticks)
        candles = {};
        return
    end
    
    [category,extrainfo,instrument] = getfutcategory(code);
    if category == 1
        error('timeseries_tick2candle:%s not implemented',extrainfo)
    end
        
    if category == 3
        error('timeseries_tick2candle:%s not implemented',extrainfo)
    end
        
    blankstr = ' ';
    cob_dates = unique(floor(ticks(:,1)));
    ndates = length(cob_dates);
    
    candles = cell(ndates,1);
    nintervals = size(instrument.break_interval,1);
    for i = 1:ndates
        buckets = getintradaybuckets2('date',cob_dates(i),...
            'frequency','1m',...
            'tradinghours',instrument.trading_hours,...
            'tradingbreak',instrument.trading_break);
        candles_i = nan(size(buckets,1),5);
        candles_i(:,1) = buckets;
        datestr_start = datestr(floor(buckets(1)));
        datestr_end = datestr(floor(buckets(end)));
        
        if category == 2
            num11_30_00 = datenum([datestr_start,blankstr,'11:30:00']);
        end
        
        if category > 3
            num21_00_00 = datenum([datestr_start,blankstr, '21:00:00']);
            num21_00_0_5 = datenum([datestr_start,blankstr, '21:00:0.5']);
        end
        
        if category == 5
            num00_00_00 = datenum([datestr_end,blankstr,'00:00:00']);
            num00_00_0_5 = datenum([datestr_end,blankstr,'00:00:0.5']);
            m = find(ticks(:,1) == datenum(num00_00_00));
            if ~isempty(m)
                paraticks(1:length(m),:) = ticks(m,1:end);
                paraticks(1:end,1) = num00_00_0_5;
                ticks = [ticks(1:m(end),:);paraticks;ticks(m(end)+1:end,:)];
            end
        end
        
        datenum_open = zeros(nintervals,1);
        datenum_close = zeros(nintervals,1);
        for j = 1:nintervals
            datenum_open(j) = datenum([datestr_start,blankstr,instrument.break_interval{j,1}]);
            if category ~= 5
                datenum_close(j) = datenum([datestr_start,blankstr,instrument.break_interval{j,2}]);
            else
                if j == nintervals
                    datenum_close(j) = datenum([datestr_end,blankstr,instrument.break_interval{j,2}]);
                else
                    datenum_close(j) = datenum([datestr_start,blankstr,instrument.break_interval{j,2}]);
                end
            end
        end
        
        %find the first tick which traded after the market open
        idx_start = find(ticks(:,1) > datenum_open(1),1,'first');
        idx_end = find(ticks(:,1) <= datenum_close(end),1,'last');
        
        if isempty(idx_start), return;end
        
        t = ticks(idx_start,1);
        if category == 2 && t == num11_30_00            
             idx_start = idx_start+1;
             t = ticks(idx_start,1);
        end
        pxtrade = ticks(idx_start,2);
        
        if category > 3
            if t == num21_00_00, t = num21_00_0_5;end
        end
        
        if t > buckets(end)
            count = size(buckets,1);
        else
            idx_candle = buckets(1:end-1) < t & buckets(2:end) >= t;
            this_bucket = buckets(idx_candle);
            count = find(buckets == this_bucket);
        end
        candles_i(count,2:end) = pxtrade;
        
        for j = idx_start+1:idx_end
            t = ticks(j,1);
            pxtrade = ticks(j,2);
            
            if category == 2 && t == num11_30_00, continue; end
            
            if category > 3
                if t == num21_00_00, t = num21_00_0_5;end
            end
            %ignore the tick in case the tick time is in break-time
            usetick = 1;
            for k = 1:nintervals-1
                if t > datenum_close(k) && t <= datenum_open(k+1)
                    usetick = 0;
                    break
                end
            end
            
            if ~usetick, continue;end
            
            % equalorNot 用来解决str相同，但是double不同导致最终比较结果错误的问题
            equalorNot = (round(buckets(2:end) *10e+07) == round(t*10e+07));
            if sum(sum(equalorNot))==0
                idx = buckets(1:end-1) < t & buckets(2:end) >= t;
            else
                idx = buckets(1:end-1) <t & equalorNot;
            end
            this_bucket = buckets(idx);
            %
            if ~isempty(this_bucket)
                this_count = find(buckets == this_bucket);
            else
                if t >= buckets(end), this_count = size(buckets,1);end
            end
            
            if isempty(this_count), continue;end
             
            if this_count ~= count
                count = this_count;
                newset = true;
            else
                newset = false;
            end
            
            if newset
                candles_i(this_count,2:5) = pxtrade;
            else
                candles_i(this_count,5) = pxtrade;
                high = candles_i(this_count,3);
                low = candles_i(this_count,4);
                if pxtrade > high, candles_i(this_count,3) = pxtrade; end
                if pxtrade < low, candles_i(this_count,4) = pxtrade;end
            end
            
        end
        candles{i} = candles_i;
        
    end

        
end