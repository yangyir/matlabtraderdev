function vol = calc_hv(obj,instrument,varargin)
%cMDEFut
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
    p.addParameter('NumOfPeriods',144,...
        @(x) validateattributes(x,{'numeric'},{},'','NumOfPeriods'));
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.addParameter('Method','linear',@ischar);
    p.parse(instrument,varargin{:});
    instrument = p.Results.Instrument;
    nperiods = p.Results.NumOfPeriods;
    includeLastCandle = p.Results.IncludeLastCandle;
    volmethod = p.Results.Method;
    if ~(strcmpi(volmethod,'linear') || strcmpi(volmethod,'ewma') || strcmpi(volmethod,'garch'))
        error('cMDEFut:invalid vol calculation method')
    end
    
    histcandles = obj.gethistcandles(instrument);
    candlesticks = obj.getcandles(instrument);
    
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
    
    idx_start = min(size(closep,1) - nperiods + 1,1);
    closep = closep(idx_start:end);
    if size(closep,1) == 1
        vol = 0;
        return
    end
    
    logret = log(closep(2:end)./closep(1:end-1));
    if strcmpi(volmethod,'linear')
        vol = std(logret)*sqrt(nperiods);
    elseif strcmpi(volmethod,'ewma')
        error('cMDEFut:vol calculation ewma to be implemented')
    elseif strcmpi(volmethod,'garch')
        error('cMDEFut:vol calculation garch to be implemented')
    end
    
end