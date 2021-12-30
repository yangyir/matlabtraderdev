function [] = registerinstrument(mdefut,instrument)
    if ischar(instrument)
        codestr = instrument;
        flag = isoptchar(codestr);
        %first to make sure that it is not an option underlier
        if flag, return; end
        instrument = cFutures(codestr);
        instrument.loadinfo([codestr,'_info.txt']);
    else
        codestr = instrument.code_ctp;
        flag = isoptchar(codestr);
        %first to make sure that it is not an option underlier
        if flag, return; end
    end

    mdefut.qms_.registerinstrument(instrument);

    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    %init memory for technical_indicator_table_
    if isempty(mdefut.technical_indicator_table_)
        mdefut.technical_indicator_table_ = cell(ns,1);
    else
        ns_ = size(mdefut.technical_indicator_table_,1);
        if ns_ ~= ns
            titable = cell(ns,1);
            for i = 1:ns_, titable{i} = mdefut.technical_indicator_table_{i};end
            mdefut.technical_indicator_table_ = titable;
        end
    end

    %init of technical_indicator_autocalc_
    if isempty(mdefut.technical_indicator_autocalc_)
        mdefut.technical_indicator_autocalc_ = zeros(ns,1);
    else
        ns_ = size(mdefut.technical_indicator_autocalc_,1);
        if ns_ ~= ns
            autocalc = zeros(ns,1);
            autocalc(1:ns_) = mdefut.technical_indicator_autocalc_;
            autocalc(ns_+1:ns) = 0;
            mdefut.technical_indicator_autocalc_ = autocalc;
        end
    end
    
    %init of wrnperiod_, macdlead_,macdlag_,macdavg_,tdsqlag_,tdsqconsecutive_
    if isempty(mdefut.wrnperiod_)
        mdefut.wrnperiod_ = 144*ones(ns,1);
        %MACD
        mdefut.macdlead_ = 12*ones(ns,1);
        mdefut.macdlag_ = 26*ones(ns,1);
        mdefut.macdavg_ = 9*ones(ns,1);
        %TDSQ
        mdefut.tdsqlag_ = 4*ones(ns,1);
        mdefut.tdsqconsecutive_ = 9*ones(ns,1);
        %fractal
        mdefut.nfractals_ = 2*ones(ns,1);
    else
        ns_ = size(mdefut.wrnperiod_,1);
        if ns_ ~= ns
            mdefut.wrnperiod_ =  [mdefut.wrnperiod_;144*ones(ns-ns_,1)];
            mdefut.macdlead_ = [mdefut.macdlead_;12*ones(ns-ns_,1)];
            mdefut.macdlag_ = [mdefut.macdlag_;26*ones(ns-ns_,1)];
            mdefut.macdavg_ = [mdefut.macdavg_;9*ones(ns-ns_,1)];
            mdefut.tdsqlag_ = [mdefut.tdsqlag_;4*ones(ns-ns_,1)];
            mdefut.tdsqconsecutive_ = [mdefut.tdsqconsecutive_;9*ones(ns-ns_,1)];
            mdefut.nfractals_ = [mdefut.nfractals_;2*ones(ns-ns_,1)];
        end
    end          
    % init of candle freq
    if isempty(mdefut.candle_freq_)
        %default value of candle frequency is one minute
        mdefut.candle_freq_ = ones(ns,1);
    else
        ns_ = size(mdefut.candle_freq_,1);
        if ns_ ~= ns
            freqs_ = ones(ns,1);
            freqs_(1:ns_) = mdefut.candle_freq_;
            %default value of candle frequency is one minute
            freqs_(ns_+1:ns) = 1;
            mdefut.candle_freq_ = freqs_;
        end  
    end
    
    % init of newset
    if isempty(mdefut.newset_)
        %default value of newset is zero
        mdefut.newset_ = zeros(ns,1);
    else
        ns_ = size(mdefut.newset_,1);
        if ns_ ~= ns
            newset = zeros(ns,1);
            newset(1:ns_) = mdefut.newset_;
            %default value of newset is zero
            newset(ns_+1:ns) = 0;
            mdefut.newset_ = newset;
        end
    end

    % init of candles_count
    if isempty(mdefut.candles_count_)
        %default value of candles count is zero
        mdefut.candles_count_ = zeros(ns,1);
    else
        ns_ = size(mdefut.candles_count_,1);
        if ns_ ~= ns
            count_ = zeros(ns,1);
            count_(1:ns_) = mdefut.candles_count_;
            %default value of candles count is zero
            count_(ns_+1:ns) = 0;
            mdefut.candles_count_ =  count_;
        end
    end

    % init of candles
    if strcmpi(mdefut.mode_,'realtime')
        hh = hour(now);
        if hh < 3
            cobdate = today - 1;
        else
            cobdate = today;
        end
    else
        cobdate = mdefut.replay_date1_;
    end
    
    %init of lastclose_
    hh = hour(now);
    if hh < 16 && hh > 2
        lastbd = businessdate(cobdate,-1);
    else
        lastbd = cobdate;
    end
    if isempty(mdefut.lastclose_)
        mdefut.lastclose_ = nan(ns,1);
        for i = 1:ns
            filename = [instruments{i}.code_ctp,'_daily.txt'];
            dailypx = cDataFileIO.loadDataFromTxtFile(filename);
            idx = dailypx(:,1) == lastbd;
            lastpx = dailypx(idx,5);
            if ~isempty(lastpx), mdefut.lastclose_(i) = lastpx;end
        end
    else
        ns_ = size(mdefut.lastclose_,1);
        if ns_ ~= ns
            lastcloses = zeros(ns,1);
            lastcloses(1:ns_) = mdefut.lastclose_;
            for i = ns_+1:ns
                filename = [instruments{i}.code_ctp,'_daily.txt'];
                dailypx = cDataFileIO.loadDataFromTxtFile(filename);
                idx = dailypx(:,1) == lastbd;
                lastpx = dailypx(idx,5);
                if ~isempty(lastpx)
                    lastcloses(i) = lastpx;
                else
                    lastcloses(i) = NaN;
                end
            end
            mdefut.lastclose_ = lastcloses;
        end
    end

    if isempty(mdefut.candles_)
        mdefut.candles_ = cell(ns,1);
        for i = 1:ns
            fut = instruments{i};
            buckets = getintradaybuckets2('date',cobdate,...
                'frequency',[num2str(mdefut.candle_freq_(i)),'m'],...
                'tradinghours',fut.trading_hours,...
                'tradingbreak',fut.trading_break);
            candle_ = [buckets,zeros(size(buckets,1),4)];
            mdefut.candles_{i} = candle_;
        end
    else
        ns_ = size(mdefut.candles_,1);
        candles = cell(ns,1);
        if ns_ ~= ns
            for i = 1:ns_, candles{i} = mdefut.candles_{i};end
            for i = ns_+1:ns
                fut = instruments{i};
                buckets = getintradaybuckets2('date',cobdate,...
                    'frequency',[num2str(mdefut.candle_freq_(i)),'m'],...
                    'tradinghours',fut.trading_hours,...
                    'tradingbreak',fut.trading_break);
                candles{i} = [buckets,zeros(size(buckets,1),4)];
            end
            mdefut.candles_ = candles;
        end
    end

    %init candles4save_count_
    if isempty(mdefut.candles4save_count_)
        mdefut.candles4save_count_ = zeros(ns,1);
    else
        ns_ = size(mdefut.candles4save_count_,1);
        if ns_ ~= ns
            count_ = zeros(ns,1);
            count_(1:ns_) = mdefut.candles4save_count_;
            count_(ns_+1:ns) = 0;
            mdefut.candles4save_count_ =  count_;
        end
    end

    %init candles4save_
    if isempty(mdefut.candles4save_)
        mdefut.candles4save_ = cell(ns,1);
        for i = 1:ns
            fut = instruments{i};
            buckets = getintradaybuckets2('date',cobdate,...
                'frequency','1m',...
                'tradinghours',fut.trading_hours,...
                'tradingbreak',fut.trading_break);
            mdefut.candles4save_{i} = [buckets,zeros(size(buckets,1),4)];
        end
    else
        ns_ = size(mdefut.candles4save_,1);
        candles = cell(ns,1);
        if ns_ ~= ns
            for i = 1:ns_, candles{i} = mdefut.candles4save_{i};end
            for i = ns_+1:ns
                fut = instruments{i};
                buckets = getintradaybuckets2('date',cobdate,...
                    'frequency','1m',...
                    'tradinghours',fut.trading_hours,...
                    'tradingbreak',fut.trading_break);
                candles{i} = [buckets,zeros(size(buckets,1),4)];
            end
            mdefut.candles4save_ = candles;
        end
    end

%     % init ticks_
%     if isempty(mdefut.ticks_)
%         n = 1e5;%note:this size shall be enough for day trading
%         d = cell(ns,1);
%         for i = 1:ns, d{i} = zeros(n,7);end
%         mdefut.ticks_ = d;
%     else
%         ns_ = size(mdefut.ticks_,1);
%         if ns_ ~= ns
%             ticks = cell(ns,1);
%             for i = 1:ns_, ticks{i} = mdefut.ticks_{i}; end
%             ticks{ns} = zeros(1e5,7);
%             mdefut.ticks_ = ticks;
%         end
%     end

    % init ticks_count_
    if isempty(mdefut.ticks_count_)
        mdefut.ticks_count_ = zeros(ns,1);
    else
        ns_ = size(mdefut.ticks_count_,1);
        if ns_ ~= ns
            ticks_count = zeros(ns,1);
            ticks_count(1:ns_,:) = mdefut.ticks_count_;
            ticks_count(ns_+1:ns) = 0;
            mdefut.ticks_count_ = ticks_count;
        end 
    end
    
    % init ticksquick_
    if isempty(mdefut.ticksquick_)
        mdefut.ticksquick_ = zeros(ns,7);
    else
        ns_ = size(mdefut.ticksquick_,1);
        if ns_ ~= ns
            ticksquick = zeros(ns,7);
            ticksquick(1:ns_,:) = mdefut.ticksquick_;
            ticksquick(ns_+1:ns,:) = 0;
            mdefut.ticksquick_ = ticksquick;
        end
    end  
    
    % init categories_
    if isa(instrument,'cStock')
        category = 1;
    else
        category = getfutcategory(instrument);
    end
    if isempty(mdefut.categories_)
        mdefut.categories_ = zeros(ns,1);
        mdefut.categories_(ns,1) = category;
    else
        ns_ = size(mdefut.categories_,1);
        if ns_ ~= ns
            categories = zeros(ns,1);
            categories(1:ns_,:) = mdefut.categories_;
            categories(ns_+1:ns) = getfutcategory(instrument);
            mdefut.categories_ = categories;
        end
    end
    
    % compute num21_00_00_; num21_00_0_5_;num00_00_00_;num00_00_0_5_ if it
    % is required
    ns_ = size(mdefut.categories_,1);
    for i = 1:ns_
        if mdefut.categories_(i) > 3
            datestr_start = datestr(floor(mdefut.candles4save_{i}(1,1)));
            mdefut.num21_00_00_ = datenum([datestr_start,' 21:00:00']);
            mdefut.num21_00_0_5_ = datenum([datestr_start,' 21:00:0.5']);
        end
        if mdefut.categories_(i) == 5
            datestr_end = datestr(floor(mdefut.candles4save_{i}(end,1)));
            mdefut.num00_00_00_ = datenum([datestr_end,' 00:00:00']);
            mdefut.num00_00_0_5_ = datenum([datestr_end,' 00:00:0.5']);
        end
    end
    
    % init datenum_open_ and datenum_close_
    blankstr = ' ';
    if isempty(mdefut.datenum_open_)
        mdefut.datenum_open_ = cell(ns,1);
        mdefut.datenum_close_ = cell(ns,1);
        nintervals = size(instrument.break_interval,1);
        datenum_open = zeros(nintervals,1);
        datenum_close = zeros(nintervals,1);
        datestr_start = datestr(floor(mdefut.candles4save_{ns}(1,1)));
        datestr_end = datestr(floor(mdefut.candles4save_{ns}(end,1)));
        for j = 1:nintervals
            datenum_open(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,1}]);
            if category ~= 5
                datenum_close(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,2}]);
            else
                if j == nintervals
                    datenum_close(j,1) = datenum([datestr_end,blankstr,instrument.break_interval{j,2}]);
                else
                    datenum_close(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,2}]);
                end
            end
        end
        mdefut.datenum_open_{ns,1} = datenum_open;
        mdefut.datenum_close_{ns,1} = datenum_close;
    else
        ns_ = size(mdefut.datenum_open_,1);
        if ns_ ~= ns
            datenum_open = cell(ns,1);
            datenum_close = cell(ns,1);
            for i = 1:ns_
                datenum_open{i} = mdefut.datenum_open_{i};
                datenum_close{i} = mdefut.datenum_close_{i};
            end
            nintervals = size(instrument.break_interval,1);
            datenum_open_new = zeros(nintervals,1);
            datenum_close_new = zeros(nintervals,1);
            blankstr = ' ';
            datestr_start = datestr(floor(mdefut.candles4save_{ns}(1,1)));
            datestr_end = datestr(floor(mdefut.candles4save_{ns}(end,1)));
            for j = 1:nintervals
                datenum_open_new(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,1}]);
                if category ~= 5
                    datenum_close_new(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,2}]);
                else
                    if j == nintervals
                        datenum_close_new(j,1) = datenum([datestr_end,blankstr,instrument.break_interval{j,2}]);
                    else
                        datenum_close_new(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,2}]);
                    end
                end
            end
            datenum_open{ns,1} = datenum_open_new;
            datenum_close{ns,1} = datenum_close_new;
            mdefut.datenum_open_ = datenum_open;
            mdefut.datenum_close_ = datenum_close;
        end
    end

end
%end of registerinstrument
