function [indicators,wrseries] = calc_wr_(mdefut,instrument,varargin)
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
        highp = [];
        lowp = [];
        closep = [];
    elseif isempty(histcandles) && ~isempty(candlesticks)
        highp = candlesticks(:,3);
        lowp = candlesticks(:,4);
        closep = candlesticks(:,5);
    elseif ~isempty(histcandles) && isempty(candlesticks)
        highp = histcandles(:,3);
        lowp = histcandles(:,4);
        closep = histcandles(:,5);
    elseif ~isempty(histcandles) && ~isempty(candlesticks)
        highp = [histcandles(:,3);candlesticks(:,3)];
        lowp = [histcandles(:,4);candlesticks(:,4)];
        closep = [histcandles(:,5);candlesticks(:,5)];
    end
    
    %remove possible zeros
    checks = highp.*lowp.*closep;
    idx = checks ~= 0;
    highp = highp(idx);
    lowp = lowp(idx);
    closep = closep(idx);

    if size(closep,1) >= nperiods
        wrs = willpctr(highp,lowp,closep,nperiods);
        indicators = [wrs(end),max(highp(end-nperiods+1:end)),min(lowp(end-nperiods+1:end)),closep(end)];
        wrseries = wrs;
    else
        indicators = [];
        wrseries = [];
    end

end
%end of calc_wr_