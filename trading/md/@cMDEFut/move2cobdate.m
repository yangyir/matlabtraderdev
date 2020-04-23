function [] = move2cobdate(obj,cobdate)
%note:assuming all the instruments have been already registered with
%cMDEFut and all the following properties are re-initialized accordingly
%with the cobdate passing to a new date
%01.ticks_
%02.candles_
%03.candles4save_
%04.hist_candles_(if required)
%05.datenum_open_
%06.datenum_close_
%07.tick_count_
%08.candles_count_
%09.candles4save_count_
%10.num21_00_00_
%11.num21_00_0_5_
%12.num00_00_00_
%13.num00_00_0_5_

    if ischar(cobdate)
        datenuminput = datenum(cobdate);
    elseif isnumeric(cobdate)
        datenuminput = cobdate;
    else
        error('cMDEFut:move2cobdate:invalid cobdate input')
    end

    instruments = obj.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
    
    %ticks_
%     n = 1e5;%note:this size shall be enough for day trading
%     d = cell(ns,1);
%     for i = 1:ns, d{i} = zeros(n,7);end
%     obj.ticks_ = d;
    
    obj.ticksquick_ = zeros(ns,7);
    
    %hist_candles_
    if ~isempty(obj.hist_candles_)
        %in case historical candles are required, we
        %update the historical candles as well
        for i = 1:ns
            histcandles = obj.hist_candles_{i};
            candles = obj.candles_{i};
            idxremove = candles(:,2)==candles(:,3)&candles(:,2)==candles(:,4)&candles(:,2)==candles(:,5);
            idxkeep = ~idxremove;
            candles = candles(idxkeep,:);
            if ~isempty(candles)
                if datenuminput ~= floor(candles(1))
                    ncandle = size(candles,1);
                    %here we move the historical candle one day
                    %forward to save memory usage
                    histcandles = [histcandles(ncandle+1:end,:);candles];
                    obj.hist_candles_{i} = histcandles;
                end
            else
                %do nothing
            end 
        end
    end
    
    %candles_
    obj.candles_ = cell(ns,1);
    for i = 1:ns
        fut = instruments{i};
        buckets = getintradaybuckets2('date',datenuminput,...
                'frequency',[num2str(obj.candle_freq_(i)),'m'],...
                'tradinghours',fut.trading_hours,...
                'tradingbreak',fut.trading_break);
        obj.candles_{i} = [buckets,zeros(size(buckets,1),4)];
    end
     
    %candles4save_
    obj.candles4save_ = cell(ns,1);
    for i = 1:ns
        fut = instruments{i};
        buckets = getintradaybuckets2('date',datenuminput,...
            'frequency','1m',...
            'tradinghours',fut.trading_hours,...
            'tradingbreak',fut.trading_break);
        obj.candles4save_{i} = [buckets,zeros(size(buckets,1),4)];
    end
    
    % re-init datenum_open_ and datenum_close_
    blankstr = ' ';
    obj.datenum_open_ = cell(ns,1);
    obj.datenum_close_ = cell(ns,1);
    for i = 1:ns
        fut = instruments{i};
        nintervals = size(fut.break_interval,1);
        datenum_open = zeros(nintervals,1);
        datenum_close = zeros(nintervals,1);
        datestr_start = datestr(floor(obj.candles4save_{ns}(1,1)));
        datestr_end = datestr(floor(obj.candles4save_{ns}(end,1)));
        category = obj.categories_(i);
        for j = 1:nintervals
            datenum_open(j,1) = datenum([datestr_start,blankstr,fut.break_interval{j,1}]);
            if category ~= 5
                datenum_close(j,1) = datenum([datestr_start,blankstr,fut.break_interval{j,2}]);
            else
                if j == nintervals
                    datenum_close(j,1) = datenum([datestr_end,blankstr,fut.break_interval{j,2}]);
                else
                    datenum_close(j,1) = datenum([datestr_start,blankstr,fut.break_interval{j,2}]);
                end
            end
        end
        obj.datenum_open_{i,1} = datenum_open;
        obj.datenum_close_{i,1} = datenum_close;
    end
    
    %tick_count_
    obj.ticks_count_ = zeros(ns,1);
    
    %candles_count_
    obj.candles_count_ = zeros(ns,1);
    
    %candles4save_count_
    obj.candles4save_count_ = zeros(ns,1);
    
    %num21_00_00_
    if ~isempty(obj.num21_00_00_)
        obj.num21_00_00_ = datenum([datestr(datenuminput,'yyyy-mm-dd'),' 21:00:00']);
    end
    
    %num21_00_0_5_
    if ~isempty(obj.num21_00_0_5_)
        obj.num21_00_0_5_ = datenum([datestr(datenuminput,'yyyy-mm-dd'),' 21:00:0.5']);
    end
    
    %num00_00_00_
    if ~isempty(obj.num00_00_00_)
        obj.num00_00_00_ = datenum([datestr(datenuminput+1,'yyyy-mm-dd'),' 00:00:00']);
    end
    
    %num00_00_0_5_
    if ~isempty(obj.num00_00_0_5_)
        obj.num00_00_0_5_ = datenum([datestr(datenuminput+1,'yyyy-mm-dd'),' 00:00:0.5']);
    end
    
    %lastclose_
    lastbd = businessdate(datenuminput,-1);
    for i = 1:ns
        filename = [instruments{i}.code_ctp,'_daily.txt'];
        try
            dailypx = cDataFileIO.loadDataFromTxtFile(filename);
            idx = dailypx(:,1) == lastbd;
            lastpx = dailypx(idx,5);
            if ~isempty(lastpx)
                obj.lastclose_(i) = lastpx;
            else
                obj.lastclose_(i) = obj.hist_candles_{i}(end,5);
            end
        catch
            %in case the filename is not on directory
            obj.lastclose_(i) = obj.hist_candles_{i}(end,5);
        end
    end

end