function [buysetup,sellsetup,levelup,leveldn,buycountdown,sellcountdown,data] = calc_tdsq_(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
    p.addParameter('Lag',4,@isnumeric);
    p.addParameter('Consecutive',9,@isnumeric);
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.addParameter('RemoveLimitPrice',0,@isnumeric);
    p.parse(instrument,varargin{:});
    instrument = p.Results.Instrument;
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
    
    %%
    [~,idx] = mdefut.qms_.instruments_.hasinstrument(instrument);
    try
        nLag = mdefut.tdsqlag_(idx);
    catch
        nLag = p.Results.Lag;
    end
    try
        nConsecutive = mdefut.tdsqconsecutive_(idx);
    catch
        nConsecutive = p.Results.Consecutive;
    end
    
    [buysetup,sellsetup,levelup,leveldn,buycountdown,sellcountdown] = tdsq(data,...
        'Lag',nLag,...
        'Consecutive',nConsecutive);
    
end
