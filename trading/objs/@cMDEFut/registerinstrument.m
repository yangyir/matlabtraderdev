function [] = registerinstrument(mdefut,instrument)
    codestr = instrument.code_ctp;
    flag = isoptchar(codestr);
    %first to make sure that it is not an option underlier
    if flag, return; end

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
        cobdate = today;
    else
        cobdate = mdefut.replay_date1_;
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

    % init ticks_
    if isempty(mdefut.ticks_)
        n = 1e5;%note:this size shall be enough for day trading
        d = cell(ns,1);
        for i = 1:ns, d{i} = zeros(n,7);end
        mdefut.ticks_ = d;
    else
        ns_ = size(mdefut.ticks_,1);
        if ns_ ~= ns
            ticks = cell(ns,1);
            for i = 1:ns_, ticks{i} = mdefut.ticks_{i}; end
            ticks{ns} = zeros(1e5,4);
            mdefut.ticks_ = ticks;
        end
    end

    % init ticks_count_
    if isempty(mdefut.ticks_count_)
        mdefut.ticks_count_ = zeros(ns,1);
    else
        ns_ = size(mdefut.ticks_count_);
        if ns_ ~= ns
            ticks_count = zeros(ns,1);
            ticks_count(1:ns_,:) = mdefut.ticks_count_;
            ticks_count(ns_+1:ns) = 0;
            mdefut.ticks_count_ = ticks_count;
        end 
    end

end
%end of registerinstrument
