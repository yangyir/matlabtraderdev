function [buysetup,sellsetup,levelup,leveldn,buycountdown,sellcountdown] = calc_tdsq_(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
    p.addParameter('Lag',4,@isnumeric);
    p.addParameter('Consecutive',9,@isnumeric);
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.parse(instrument,varargin{:});
    instrument = p.Results.Instrument;
    nLag = p.Results.Lag;
    nConsecutive = p.Results.Consecutive;
    includeLastCandle = p.Results.IncludeLastCandle;
    
    histcandles = mdefut.gethistcandles(instrument);
    candlesticks = mdefut.getcandles(instrument);
    
    if isempty(histcandles)
        histcandles = [];
    else
        histcandles = histcandles{1};
    end
    
    if isempty(candlesticks)
        candlesticks = [];
    else
        candlesticks = candlesticks{1};
        if ~includeLastCandle
            candlesticks = candlesticks(1:end-1,:);
        end
    end
    
    if isempty(histcandles) && isempty(candlesticks)
        timevec = [];
        openp = [];
        highp = [];
        lowp = [];
        closep = [];
    elseif isempty(histcandles) && ~isempty(candlesticks)
        timevec = candlesticks(:,1);
        openp = candlesticks(:,2);
        highp = candlesticks(:,3);
        lowp = candlesticks(:,4);
        closep = candlesticks(:,5);
    elseif ~isempty(histcandles) && isempty(candlesticks)
        timevec = histcandles(:,1);
        openp = histcandles(:,2);
        highp = histcandles(:,3);
        lowp = histcandles(:,4);
        closep = histcandles(:,5);
    elseif ~isempty(histcandles) && ~isempty(candlesticks)
        timevec = [histcandles(:,1);candlesticks(:,1)];
        openp = [histcandles(:,2);candlesticks(:,2)];
        highp = [histcandles(:,3);candlesticks(:,3)];
        lowp = [histcandles(:,4);candlesticks(:,4)];
        closep = [histcandles(:,5);candlesticks(:,5)];
    end
    
    %remove possible zeros
    checks = openp.*highp.*lowp.*closep;
    idx = checks ~= 0;
    timevec = timevec(idx);
    openp = openp(idx);
    highp = highp(idx);
    lowp = lowp(idx);
    closep = closep(idx);
    data = [timevec,openp,highp,lowp,closep];
    %%
    [buysetup,sellsetup,levelup,leveldn,buycountdown,sellcountdown] = tdsq(data,...
        'Lag',nLag,...
        'Consecutive',nConsecutive);
    
end
