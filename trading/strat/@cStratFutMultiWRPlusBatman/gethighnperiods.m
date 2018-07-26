function [highp,hight] = gethighnperiods(obj,instrument)
    if ~(isa(instrument,'cInstrument') || ischar(instrument)) 
        error('cStratFutMultiWRPlusBatman:gethighnperiods:invalid instrument input')
    end
    
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        nperiods = obj.nperiods_(idx);
    else
        error('cStratFutMultiWRPlusBatman:gethighnperiods:instrument not found')
    end

    %note:both func 'gethistcandles' and 'getcandles' return cell-type
    %variables
    histcandles = obj.mde_fut_.gethistcandles(instrument);
    candlesticks = obj.mde_fut_.getcandles(instrument);
    if ~isempty(histcandles)
        histcandles = histcandles{1};
    else
        histcandles = [];
    end
    
    %note:getcandles return candel sticks of the current date including the last
    %candle stick which might not be fully feeded. as a result, we shall
    %exclude the last candle stick for the reason not violating with the
    %backtest process
    if ~isempty(candlesticks)
        candlesticks = candlesticks{1};
        candlesticks = candlesticks(1:end-1,:);
    else
        candlesticks = [];
    end
    
    if isempty(histcandles) && isempty(candlesticks)
        timevec = [];
        highpx = [];
    elseif isempty(histcandles) && ~isempty(candlesticks)
        timevec = candlesticks(:,1);
        highpx = candlesticks(:,3);
    elseif ~isempty(histcandles) && isempty(candlesticks)
        timevec = histcandles(:,1);
        highpx = histcandles(:,3);
    else
        timevec = [histcandles(:,1);candlesticks(:,1)];
        highpx = [histcandles(:,3);candlesticks(:,3)];
    end
    
    if size(timevec,1) < nperiods
        error('cStratFutMultiWRPlusBatman:gethighperiods:insufficient historical data')
    end
    
    highp = max(highpx(end-nperiods:end-1));
    idx = highpx == highp;
    hight = timevec(idx);

end