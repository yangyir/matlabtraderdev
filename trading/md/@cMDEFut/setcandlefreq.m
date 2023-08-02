function [] = setcandlefreq(mdefut,freq,instrument)
    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

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

    if nargin < 3
        %note:no particular instrument is given
        for i = 1:ns
            if mdefut.candle_freq_(i) ~= freq
                mdefut.candle_freq_(i) = freq;
                fut = instruments{i};
                if mdefut.candle_freq_(i) ~= 1440
                    buckets = getintradaybuckets2('date',cobdate,...
                        'frequency',[num2str(mdefut.candle_freq_(i)),'m'],...
                        'tradinghours',fut.trading_hours,...
                        'tradingbreak',fut.trading_break);
                    mdefut.candles_{i} = [buckets,zeros(size(buckets,1),4)];
                else
                    if isa(fut,'cStock')
                        category = 1;
                    else
                        category = getfutcategory(fut);
                    end
                    if category == 1 || category == 2 || category == 3
                        buckets = getintradaybuckets2('date',cobdate,...
                            'frequency',[num2str(mdefut.candle_freq_(i)),'m'],...
                            'tradinghours',fut.trading_hours,...
                            'tradingbreak',fut.trading_break);
                        mdefut.candles_{i} = [buckets,zeros(size(buckets,1),4)];
                    else
                        prevbusdate = businessdate(cobdate,-1);
                        buckets = [prevbusdate+0.875;cobdate+0.875];
                        ds = cLocal;
                        if category == 4
                            candles = ds.intradaybar(fut,...
                                datestr(prevbusdate+0.875,'yyyy-mm-dd HH:MM:SS'),...
                                [datestr(prevbusdate,'yyyy-mm-dd'),' 23:00:00'],1,'trade');
                        elseif category == 5
                            candles = ds.intradaybar(fut,...
                                datestr(prevbusdate+0.875,'yyyy-mm-dd HH:MM:SS'),...
                                [datestr(cobdate,'yyyy-mm-dd'),' 02:30:00'],1,'trade');
                        end
                        row1 = [buckets(1),candles(1,2),max(candles(:,3)),min(candles(:,4)),candles(end,5)];
                        row2 = [buckets(2),zeros(1,4)];
                        mdefut.candles_{i} = [row1;row2];
                        mdefut.candles_count_(i) = 1;
                    end
                end
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
                if mdefut.candle_freq_(i) ~= 1440
                    buckets = getintradaybuckets2('date',cobdate,...
                        'frequency',[num2str(mdefut.candle_freq_(i)),'m'],...
                        'tradinghours',fut.trading_hours,...
                        'tradingbreak',fut.trading_break);
                    mdefut.candles_{i} = [buckets,zeros(size(buckets,1),4)];
                else
                    if isa(fut,'cStock')
                        category = 1;
                    else
                        category = getfutcategory(fut);
                    end
                    if category == 1 || category == 2 || category == 3
                        buckets = getintradaybuckets2('date',cobdate,...
                            'frequency',[num2str(mdefut.candle_freq_(i)),'m'],...
                            'tradinghours',fut.trading_hours,...
                            'tradingbreak',fut.trading_break);
                        mdefut.candles_{i} = [buckets,zeros(size(buckets,1),4)];
                    else
                        prevbusdate = businessdate(cobdate,-1);
                        buckets = [prevbusdate+0.875;cobdate+0.875];
                        ds = cLocal;
                        if category == 4
                            candles = ds.intradaybar(fut,...
                                datestr(prevbusdate+0.875,'yyyy-mm-dd HH:MM:SS'),...
                                [datestr(prevbusdate,'yyyy-mm-dd'),' 23:00:00'],1,'trade');
                        elseif category == 5
                            candles = ds.intradaybar(fut,...
                                datestr(prevbusdate+0.875,'yyyy-mm-dd HH:MM:SS'),...
                                [datestr(prevbusdate+1,'yyyy-mm-dd'),' 02:30:00'],1,'trade');
                        end
                        row1 = [buckets(1),candles(1,2),max(candles(:,3)),min(candles(:,4)),candles(end,5)];
                        row2 = [buckets(2),zeros(1,4)];
                        mdefut.candles_{i} = [row1;row2];
                        mdefut.candles_count_(i) = 1;
                    end
                end
            end
            break
        end
    end

    if ~flag, error('cMDEFut:setcandlefreq:instrument not foung'); end

end
%end of setcandlefreq