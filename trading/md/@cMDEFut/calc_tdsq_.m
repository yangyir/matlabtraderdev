function [buysetup,sellsetup,levelup,leveldn,buycountdown,sellcountdown] = calc_tdsq_(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
    p.addParameter('Lag',4,@isnumeric);
    p.addParameter('Consecutive',9,@isnumeric);
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.parse(instrument,varargin{:});
    instrument = p.Results.Instrument;
    includeLastCandle = p.Results.IncludeLastCandle;
    candlesticks = mdefut.getallcandles(instrument);
    
    data = candlesticks{1};
    if ~includeLastCandle && ~isempty(data)
        data = data(1:end-1,:);
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
