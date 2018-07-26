function candlesticks = getlastcandle(mdefut,instrument)
    if isempty(mdefut.candles_count_), return; end

    if isempty(mdefut.candles_), return;end

    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    counts = mdefut.getcandlecount;

    if nargin < 2    
        candlesticks = cell(ns,1);    
        for i = 1:ns
            candlestick = mdefut.candles_{i};
            if counts(i) > 0
                candlestick = candlestick(counts(i),:);
            else
                candlestick = [];
            end
            candlesticks{i} = candlestick;
        end
        return
    end
    
    if ischar(instrument), instrument = code2instrument(instrument); end

    if ~isa(instrument,'cInstrument'), error('cMDEFut:getlastcandle:invalid instrument input'); end
    
    flag = false;
    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            flag = true;
            candlesticks = cell(1,1);
            candlestick = mdefut.candles_{i};
            if counts(i) > 0
                candlestick = candlestick(counts(i),:);
                candlesticks{1} = candlestick;
            else
                candlesticks = {};
            end
            
            break
        end
    end

    if ~flag, error('cMDEFut:getlastcandle:instrument not found');end

end
%end of getlastcandle