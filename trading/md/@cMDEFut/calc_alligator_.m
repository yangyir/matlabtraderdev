function [jaw,teeth,lips] = calc_alligator_(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.addParameter('RemoveLimitPrice',0,@isnumeric);
    p.parse(instrument,varargin{:});
    instrument = p.Results.Instrument;
    includeLastCandle = p.Results.IncludeLastCandle;
    removeLimitPrice = p.Results.RemoveLimitPrice;
    
    candlesticks = mdefut.getallcandles(instrument);
    data = candlesticks{1};
    
    if ~includeLastCandle && ~isempty(data); data = data(1:end-1,:);end
    
    if removeLimitPrice
        idxremove = data(:,2)==data(:,3)&data(:,2)==data(:,4)&data(:,2)==data(:,5);
        idxkeep = ~idxremove;
        data = data(idxkeep,:);
    end
    
    %use default setups
    jaw = smma(data,13,8);jaw = [nan(8,1);jaw];
    teeth = smma(data,8,5);teeth = [nan(5,1);teeth];
    lips = smma(data,5,3);lips = [nan(3,1);lips];
    
    
end