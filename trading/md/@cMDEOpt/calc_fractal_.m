function [idxHH,idxLL,HH,LL] = calc_fractal_(mdeopt,varargin)
% a cMDEOpt function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.addParameter('RemoveLimitPrice',0,@isnumeric);
    p.addParameter('VolatilityPeriod',0,@isnumeric);
    p.parse(varargin{:});
    includeLastCandle = p.Results.IncludeLastCandle;
    removeLimitPrice = p.Results.RemoveLimitPrice;
    volatilityperiod = p.Results.VolatilityPeriod;
    
    candlesticks = mdeopt.getallcandles(mdeopt.underlier_);
    data = candlesticks{1};
    
    if ~includeLastCandle && ~isempty(data); data = data(1:end-1,:);end
    
    if removeLimitPrice
        idxremove = data(:,2)==data(:,3)&data(:,2)==data(:,4)&data(:,2)==data(:,5);
        idxkeep = ~idxremove;
        data = data(idxkeep,:);
    end
    
    try
        nperiod = mdefut.nfractals_(1);
    catch
        nperiod = 2;
    end
    
    if volatilityperiod == 0
        [idxHH,idxLL,HH,LL] = fractal(data,nperiod);
    else
        [idxHH,idxLL,~,~,HH,LL] = fractalenhanced(data,nperiod,'volatilityperiod',volatilityperiod);
    end

end

