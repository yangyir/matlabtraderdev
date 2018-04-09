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

    if ~isa(instrument,'cInstrument'), error('cMDEFut:getcandles:invalid instrument input'); end


    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            candlesticks = mdefut.candles_{i};
            count_i = mdefut.getcandlecount(instrument);
            candlesticks = candlesticks(1:count_i,:);
            break
        end
    end

end