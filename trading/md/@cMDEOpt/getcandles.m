function candlesticks = getcandles(mdeopt,instrument)
% a cMDEOpt function
    candlesticks = {};
    if isempty(mdeopt.candles_count_), return; end

    if isempty(mdeopt.candles_), return;end

    instruments = mdeopt.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    if nargin < 2    
        candlesticks = cell(ns,1);
        counts = mdeopt.getcandlecount;
        for i = 1:ns
            candlestick = mdeopt.candles_{i};
            candlestick = candlestick(1:counts(i),:);
            candlesticks{i} = candlestick;
        end
        return
    end
    
    if ischar(instrument), instrument = code2instrument(instrument); end

    if ~isa(instrument,'cInstrument'), error('%s:getcandles:invalid instrument input',class(mdeopt)); end

    flag = false;
    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            flag = true;
            candlesticks = cell(1,1);
            candlestick = mdeopt.candles_{i};
            count_i = mdeopt.getcandlecount(instrument);
            if count_i > 0
                candlestick = candlestick(1:count_i,:);
                candlesticks{1} = candlestick;
            else
                candlesticks = {};
            end
            break
        end
    end
    
    if ~flag, error('%s:getcandles:instrument not found',class(mdeopt));end

end