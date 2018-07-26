function [] = setcandlefreq(mdefut,freq,instrument)
    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    if strcmpi(mdefut.mode_,'realtime')
        cobdate = today;
    else
        cobdate = mdefut.replay_date1_;
    end

    if nargin < 3
        %note:no particular instrument is given
        for i = 1:ns
            if mdefut.candle_freq_(i) ~= freq
                mdefut.candle_freq_(i) = freq;
                fut = instruments{i};
                buckets = getintradaybuckets2('date',cobdate,...
                    'frequency',[num2str(mdefut.candle_freq_(i)),'m'],...
                    'tradinghours',fut.trading_hours,...
                    'tradingbreak',fut.trading_break);
                mdefut.candles_{i} = [buckets,zeros(size(buckets,1),4)];
            end
        end

        return
    end

    if ischar(instrument)
        instrument = code2instrument(instrument);
    end
    if ~isa(instrument,'cInstrument')
        error('cMDEFut:setcandlefreq:invalid instrument input')
    end

    flag = false;
    for i = 1:ns
        if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
            flag = true;
            if mdefut.candle_freq_(i) ~= freq
                mdefut.candle_freq_(i) =  freq;
                fut = instruments{i};
                buckets = getintradaybuckets2('date',cobdate,...
                    'frequency',[num2str(mdefut.candle_freq_(i)),'m'],...
                    'tradinghours',fut.trading_hours,...
                    'tradingbreak',fut.trading_break);
                mdefut.candles_{i} = [buckets,zeros(size(buckets,1),4)];
            end
            break
        end
    end

    if ~flag, error('cMDEFut:setcandlefreq:instrument not foung'); end

end
%end of setcandlefreq