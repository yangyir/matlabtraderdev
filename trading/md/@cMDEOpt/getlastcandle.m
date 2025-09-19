function candlesticks = getlastcandle(mdeopt,instrument)
% a cMDEOpt function
    if isempty(mdeopt.candles_count_), return; end

    if isempty(mdeopt.candles_), return;end

    instruments = mdeopt.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    counts = mdeopt.getcandlecount;

    if nargin < 2    
        candlesticks = cell(ns,1);    
        for i = 1:ns
            candlestick = mdeopt.candles_{i};
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

    if ~isa(instrument,'cInstrument'), error('%s:getlastcandle:invalid instrument input',class(mdeopt)); end
    
    flag = false;
    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            flag = true;
            candlesticks = cell(1,1);
            candlestick = mdeopt.candles_{i};
            if counts(i) > 0
                candlestick = candlestick(counts(i),:);
                candlesticks{1} = candlestick;
            else
                candlesticks = {};
            end
            
            break
        end
    end

    if ~flag, error('%s:getlastcandle:instrument not found',class(mdeopt));end

end
%end of getlastcandle