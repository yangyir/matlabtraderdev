function [] = setcandlefreq(mdeopt,freq,instrument)
%a cMDEOpt function
    instruments = mdeopt.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    if strcmpi(mdeopt.mode_,'realtime')
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
        cobdate = mdeopt.replay_date1_;
    end

    if nargin < 3
        %note:no particular instrument is given
        for i = 1:ns
            if mdeopt.candle_freq_(i) ~= freq
                mdeopt.candle_freq_(i) = freq;
                fut = instruments{i};
                buckets = getintradaybuckets2('date',cobdate,...
                    'frequency',[num2str(mdeopt.candle_freq_(i)),'m'],...
                    'tradinghours',fut.trading_hours,...
                    'tradingbreak',fut.trading_break);
                mdeopt.candles_{i} = [buckets,zeros(size(buckets,1),4)];
            end
        end

        return
    end

    if ischar(instrument)
        instrument = code2instrument(instrument);
    end
    if ~isa(instrument,'cInstrument')
        error('ERROR:%s:setcandlefreq:invalid instrument input',class(mdeopt))
    end

    flag = false;
    for i = 1:ns
        if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
            flag = true;
            if mdeopt.candle_freq_(i) ~= freq
                mdeopt.candle_freq_(i) =  freq;
                fut = instruments{i};
                buckets = getintradaybuckets2('date',cobdate,...
                    'frequency',[num2str(mdeopt.candle_freq_(i)),'m'],...
                    'tradinghours',fut.trading_hours,...
                    'tradingbreak',fut.trading_break);
                mdeopt.candles_{i} = [buckets,zeros(size(buckets,1),4)];
            end
            break
        end
    end

    if ~flag, error('ERROR:%s:setcandlefreq:instrument not found',class(mdeopt)); end

end
%end of setcandlefreq