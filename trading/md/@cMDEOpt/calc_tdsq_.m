function [buysetup,sellsetup,levelup,leveldn,buycountdown,sellcountdown,data] = calc_tdsq_(mdeopt,varargin)
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
    
    %
    try
        nLag = mdeopt.tdsqlag_(1);
    catch
        nLag = 4;
    end
    try
        nConsecutive = mdeopt.tdsqconsecutive_(1);
    catch
        nConsecutive = 9;
    end
    
    [buysetup,sellsetup,levelup,leveldn,buycountdown,sellcountdown] = tdsq(data,...
        'Lag',nLag,...
        'Consecutive',nConsecutive);
    
end
