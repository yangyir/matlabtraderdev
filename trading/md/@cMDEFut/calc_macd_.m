function [macdvec,sig,diffbar] = calc_macd_(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
    p.addParameter('Lead',12,@isnumeric);
    p.addParameter('Lag',26,@isnumeric);
    p.addParameter('Average',9,@isnumeric);
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.parse(instrument,varargin{:});
    lead = p.Results.Lead;
    lag = p.Results.Lag;
    naverage = p.Results.Average;
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
        closep = [];
    elseif isempty(histcandles) && ~isempty(candlesticks)
        closep = candlesticks(:,5);
    elseif ~isempty(histcandles) && isempty(candlesticks)
        closep = histcandles(:,5);
    elseif ~isempty(histcandles) && ~isempty(candlesticks)
        closep = [histcandles(:,5);candlesticks(:,5)];
    end
    
    idx = closep ~= 0;
    closep = closep(idx);
    
    [leadvec,lagvec] = movavg(closep,lead,lag,'e');
    
    macdvec = leadvec - lagvec;
    
    [~,sig] = movavg(macdvec,1,naverage,'e');
    
    diffbar = macdvec - sig;
        
end