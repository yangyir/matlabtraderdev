function [indicators,wrseries,maxcandle,mincandle] = calc_wr_(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
    p.addParameter('NumOfPeriods',144,...
        @(x) validateattributes(x,{'numeric'},{},'','NumOfPeriods'));
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.parse(instrument,varargin{:});
    instrument = p.Results.Instrument;
    nperiods = p.Results.NumOfPeriods;
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
        highp = [];
        lowp = [];
        closep = [];
        candlesall = [];
    elseif isempty(histcandles) && ~isempty(candlesticks)
        timevec = candlesticks(:,1);
        highp = candlesticks(:,3);
        lowp = candlesticks(:,4);
        closep = candlesticks(:,5);
        candlesall = candlesticks;
    elseif ~isempty(histcandles) && isempty(candlesticks)
        timevec = histcandles(:,1);
        highp = histcandles(:,3);
        lowp = histcandles(:,4);
        closep = histcandles(:,5);
        candlesall = histcandles;
    elseif ~isempty(histcandles) && ~isempty(candlesticks)
        timevec = [histcandles(:,1);candlesticks(:,1)];
        highp = [histcandles(:,3);candlesticks(:,3)];
        lowp = [histcandles(:,4);candlesticks(:,4)];
        closep = [histcandles(:,5);candlesticks(:,5)];
        candlesall = [histcandles;candlesticks];
    end
    
    %remove possible zeros
    checks = highp.*lowp.*closep;
    idx = checks ~= 0;
    timevec = timevec(idx);
    highp = highp(idx);
    lowp = lowp(idx);
    closep = closep(idx);

    if size(closep,1) >= nperiods
        wrs = willpctr(highp,lowp,closep,nperiods);
        maxp = max(highp(end-nperiods+1:end));
        minp = min(lowp(end-nperiods+1:end));
        lastclose = closep(end);
        %
        %additional info
        maxp_before = max(highp(end-nperiods:end-1));
        minp_before = min(lowp(end-nperiods:end-1));
        idxmaxp = highp == maxp;
        maxt = timevec(idxmaxp);
        maxcandle = candlesall(idxmaxp,:);
        if size(maxt,1) > 1
            maxt = maxt(end);
            maxcandle = maxcandle(end,:);
        end
        
        idxminp = lowp == minp;
        mint = timevec(idxminp);
        mincandle = candlesall(idxminp,:);
        if size(mint,1) > 1
            mint = mint(end);
            mincandle = mincandle(end,:);
        end
        %
        indicators = [wrs(end),maxp,minp,lastclose,maxt,mint,maxp_before,minp_before];
        wrseries = wrs;
    else
        indicators = [];
        wrseries = [];
    end

end
%end of calc_wr_