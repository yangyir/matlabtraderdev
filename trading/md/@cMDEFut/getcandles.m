function candlesticks = getcandles(mdefut,instrument)
    candlesticks = {};
    if isempty(mdefut.candles_count_), return; end

    if isempty(mdefut.candles_), return;end

    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    if nargin < 2    
        candlesticks = cell(ns,1);
        counts = mdefut.getcandlecount;
        for i = 1:ns
            candlestick = mdefut.candles_{i};
            candlestick = candlestick(1:counts(i),:);
            candlesticks{i} = candlestick;
        end
        return
    end
    
    if ischar(instrument), instrument = code2instrument(instrument); end

    if ~isa(instrument,'cInstrument'), error('cMDEFut:getcandles:invalid instrument input'); end

    flag = false;
    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            flag = true;
            candlesticks = cell(1,1);
            candlestick = mdefut.candles_{i};
            count_i = mdefut.getcandlecount(instrument);
            if count_i > 0
                candlestick = candlestick(1:count_i,:);
                candlesticks{1} = candlestick;
            else
                candlesticks = {};
            end
            break
        end
    end
    
    if ~flag, error('cMDEFut:getcandles:instrument not found');end

end