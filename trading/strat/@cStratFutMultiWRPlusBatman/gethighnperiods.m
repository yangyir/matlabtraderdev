function [highp,hight] = gethighnperiods(obj,instrument,varargin)
    if ~(isa(instrument,'cInstrument') || ischar(instrument)) 
        error('cStratFutMultiWRPlusBatman:gethighnperiods:invalid instrument input')
    end
    
    [flag,idx] = obj.hasinstrument(instrument);
    instruments = obj.getinstruments;
    if flag
        nperiods = obj.riskcontrols_.getconfigvalue('code',instruments{idx}.code_ctp,'propname','numofperiod');
    else
        error('cStratFutMultiWRPlusBatman:gethighnperiods:instrument not found')
    end

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('IncludeLastCandle',false,@islogical);
    p.parse(varargin{:});
    includeLastCandle = p.Results.IncludeLastCandle;
    
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
        if includeLastCandle
            candlesticks = candlesticks(1:end,:);
        else
            candlesticks = candlesticks(1:end-1,:);
        end
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
    
    %BUG FIX
    %remove zero entries
    idx = highpx>0;
    highpx = highpx(idx);
    timevec = timevec(idx);
    
    
    highp = max(highpx(end-nperiods-1:end));
    idx = highpx == highp;
    hight = timevec(idx);

end