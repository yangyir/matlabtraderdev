function [maxp,maxt,maxcandle] = getmaxnperiods(obj,instrument,varargin)
%cStratFutMultiWR
    if ~(isa(instrument,'cInstrument') || ischar(instrument)) 
        error('%s:getmaxnperiods:invalid instrument input',class(obj))
    end
    
    [flag,idx] = obj.hasinstrument(instrument);
    instruments = obj.getinstruments;
    if flag
        nperiods = obj.riskcontrols_.getconfigvalue('code',instruments{idx}.code_ctp,'propname','numofperiod');
    else
        error('%s:getmaxnperiods:instrument not found',class(obj))
    end
    
    p = inputParser;
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.parse(varargin{:});
    includeLastCandle = p.Results.IncludeLastCandle;
    %
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
        candlesall = [];
    elseif isempty(histcandles) && ~isempty(candlesticks)
        timevec = candlesticks(:,1);
        highpx = candlesticks(:,3);
        candlesall = candlesticks;
    elseif ~isempty(histcandles) && isempty(candlesticks)
        timevec = histcandles(:,1);
        highpx = histcandles(:,3);
        candlesall = histcandles;
    else
        timevec = [histcandles(:,1);candlesticks(:,1)];
        highpx = [histcandles(:,3);candlesticks(:,3)];
        candlesall = [histcandles;candlesticks];
    end
    
    if size(timevec,1) < nperiods
        error('%s:getmaxnperiods:insufficient historical data',class(obj))
    end
    
    %BUG FIX
    %to remove zero entries
    idx = highpx>0;
    highpx = highpx(idx);
    timevec = timevec(idx);
    
    maxp = max(highpx(end-nperiods-1:end));
    idx = highpx == maxp;
    maxt = timevec(idx);
    maxcandle = candlesall(idx,:);

end