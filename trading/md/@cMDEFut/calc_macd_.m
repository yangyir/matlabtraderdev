function [macdvec,sig,diffbar] = calc_macd_(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
    p.addParameter('Lead',12,@isnumeric);
    p.addParameter('Lag',26,@isnumeric);
    p.addParameter('Average',9,@isnumeric);
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.addParameter('RemoveLimitPrice',0,@isnumeric);
    p.parse(instrument,varargin{:});
    
    includeLastCandle = p.Results.IncludeLastCandle;
    removeLimitPrice = p.Results.RemoveLimitPrice;
    
    candlesticks = mdefut.getallcandles(instrument);
    data = candlesticks{1};
    if ~includeLastCandle && ~isempty(data)
        data = data(1:end-1,:);
    end
    
    if removeLimitPrice
        idxremove = data(:,2)==data(:,3)&data(:,2)==data(:,4)&data(:,2)==data(:,5);
        idxkeep = ~idxremove;
        data = data(idxkeep,:);
    end
    
    closep = data(:,5);
    
    [~,idx] = mdefut.qms_.instruments_.hasinstrument(instrument);
    try
        lead = mdefut.macdlead_(idx);
    catch
        lead = p.Results.Lead;
    end
    
    try
        lag = mdefut.macdlag_(idx);
    catch
        lag = p.Results.Lag;
    end
    
    try
        naverage = mdefut.macdavg_(idx);
    catch
        naverage = p.Results.Average;
    end
    
    [leadvec,lagvec] = movavg(closep,lead,lag,'e');
    
    macdvec = leadvec - lagvec;
    
    [~,sig] = movavg(macdvec,1,naverage,'e');
    
    diffbar = macdvec - sig;
        
end