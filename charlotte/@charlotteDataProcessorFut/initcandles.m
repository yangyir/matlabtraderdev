function [] = initcandles(obj)
% a charlotteDataProcessorFut function
    if strcmpi(obj.mode_,'realtime')
        hh = hour(now);
        if hh < 2
            cobdate = today - 1;
        elseif hh  == 2
            mm = minute(now);
            if mm > 30
                cobdate = today;
            else
                cobdate = today - 1;
            end
        else
            cobdate = today;
        end
    else
        cobdate = floor(datenum(obj.feed_.getLastTickTime(obj.codes_{1}),'yyyy-mm-dd HH:MM:SS'));
    end
    
    
    ncodes = size(obj.codes_,1);
    for i = 1:ncodes
        fut_i = code2instrument(obj.codes_{i});
        category = getfutcategory(fut_i);
        obj.fut_categories_(i) = category;
        buckets_m1 = getintradaybuckets2('date',cobdate,...
            'frequency','1m',...
            'tradinghours',fut_i.trading_hours,...
            'tradingbreak',fut_i.trading_break);
        obj.candles_m1_{i} = [buckets_m1,zeros(size(buckets_m1,1),4)];
        %
        buckets_m5 = getintradaybuckets2('date',cobdate,...
            'frequency','5m',...
            'tradinghours',fut_i.trading_hours,...
            'tradingbreak',fut_i.trading_break);
        obj.candles_m5_{i} = [buckets_m5,zeros(size(buckets_m5,1),4)];
        %
        buckets_m15 = getintradaybuckets2('date',cobdate,...
            'frequency','15m',...
            'tradinghours',fut_i.trading_hours,...
            'tradingbreak',fut_i.trading_break);
        obj.candles_m15_{i} = [buckets_m15,zeros(size(buckets_m15,1),4)];
        %
        buckets_m30 = getintradaybuckets2('date',cobdate,...
            'frequency','30m',...
            'tradinghours',fut_i.trading_hours,...
            'tradingbreak',fut_i.trading_break);
        obj.candles_m30_{i} = [buckets_m30,zeros(size(buckets_m30,1),4)];
        %
        nintervals = size(fut_i.break_interval,1);
        datenum_open = zeros(nintervals,1);
        datenum_close = zeros(nintervals,1);
        blankstr = ' ';
        datestr_start = datestr(floor(buckets_m1(1)));
        datestr_end = datestr(floor(buckets_m1(end)));
        %
        if category > 3
            obj.num21_00_00_ = datenum([datestr_start,blankstr,'21:00:00']);
            obj.num21_00_0_5_ = datenum([datestr_start,blankstr,'21:00:0.5']);
        end
        if category == 5
            obj.num00_00_00_ = datenum([datestr_end,blankstr,'00:00:00']);
            obj.num00_00_0_5_ = datenum([datestr_end,blankstr,'00:00:0.5']);
        end
        %
        for j = 1:nintervals
            datenum_open(j,1) = datenum([datestr_start,blankstr,fut_i.break_interval{j,1}]);
            if category ~= 5
                datenum_close(j,1) = datenum([datestr_start,blankstr,fut_i.break_interval{j,2}]);
            else
                if j == nintervals
                    datenum_close(j,1) = datenum([datestr_end,blankstr,fut_i.break_interval{j,2}]);
                else
                    datenum_close(j,1) = datenum([datestr_start,blankstr,fut_i.break_interval{j,2}]);
                end
            end
        end
        obj.datenum_open_{i} = datenum_open;
        obj.datenum_close_{i} = datenum_close;
    end
end