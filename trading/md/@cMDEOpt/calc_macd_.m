function [macdvec,sig,data] = calc_macd_(mdeopt,varargin)
% a cMDEOpt function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.addParameter('RemoveLimitPrice',0,@isnumeric);
    p.parse(varargin{:});
    
    includeLastCandle = p.Results.IncludeLastCandle;
    removeLimitPrice = p.Results.RemoveLimitPrice;
    
    candlesticks = mdeopt.getallcandles(mdeopt.underlier_);
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
    
    try
        lead = mdeopt.macdlead_(1);
    catch
        lead = 12;
    end
    
    try
        lag = mdeopt.macdlag_(1);
    catch
        lag = 26;
    end
    
    try
        naverage = mdeopt.macdavg_(1);
    catch
        naverage = 9;
    end
    
    [leadvec,lagvec] = movavg(closep,lead,lag,'e');
    
    macdvec = leadvec - lagvec;
    
    warning('off');
    [~,sig] = movavg(macdvec,1,naverage,'e');
    
        
end