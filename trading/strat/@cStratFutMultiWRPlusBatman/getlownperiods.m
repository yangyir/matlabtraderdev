function [lowp,lowt] = getlownperiods(obj,instrument,varargin)
    if ~(isa(instrument,'cInstrument') || ischar(instrument)) 
        error('cStratFutMultiWRPlusBatman:getlownperiods:invalid instrument input')
    end
    
    [flag,idx] = obj.hasinstrument(instrument);
    instruments = obj.getinstruments;
    if flag
        nperiods = obj.riskcontrols_.getconfigvalue('code',instruments{idx}.code_ctp,'propname','numofperiod');
    else
        error('cStratFutMultiWRPlusBatman:getlownperiods:instrument not found')
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
        lowpx = [];
    elseif isempty(histcandles) && ~isempty(candlesticks)
        timevec = candlesticks(:,1);
        lowpx = candlesticks(:,4);
    elseif ~isempty(histcandles) && isempty(candlesticks)
        timevec = histcandles(:,1);
        lowpx = histcandles(:,4);
    else
        timevec = [histcandles(:,1);candlesticks(:,1)];
        lowpx = [histcandles(:,4);candlesticks(:,4)];
    end
    
    if size(timevec,1) < nperiods
        error('cStratFutMultiWRPlusBatman:gethighperiods:insufficient historical data')
    end
    
    %BUG FIX
    %to remove zero entries
    idx = lowpx>0;
    lowpx = lowpx(idx);
    timevec = timevec(idx);
    
    lowp = min(lowpx(end-nperiods-1:end));
    idx = lowpx == lowp;
    lowt = timevec(idx);
    
end