function obj = init(obj,varargin)
% a charlotteDataFeedFut function
p = inputParser;
p.KeepUnmatched = true;p.CaseSensitive = false;
p.addParameter('codes',{},@iscell);
p.parse(varargin{:});
codes = p.Results.codes;

obj.codes_ = codes;
ncodes = size(codes,1);
if ncodes > 0
    obj.qms_ = cQMS;
    obj.qms_.setdatasource('ctp');
    for i = 1:ncodes
        instrument_i = code2instrument(codes{i});
        obj.qms_.registerinstrument(instrument_i);
    end
    
    obj.lastticktime_ = zeros(ncodes,1);
    obj.lasttrade_ = zeros(ncodes,1);
end
    
t = now;

if ~obj.istime2sleep(t)
    data.time = t;
    notify(obj, 'MarketOpen', charlotteDataFeedEventData(data));
    if obj.qmsconnected_
        try
            obj.qms_.refesh;
            for i = 1:ncodes
                quote = obj.qms_.getquote(obj.codes_{i});
                if quote.update_time1 == 0
                    obj.qms_.refresh;
                end
                quote = obj.qms_.getquote(obj.codes_{i});
                obj.lastticktime_(i) = quote.update_time1;
                obj.lasttrade_(i) = quote.last_trade;
            end
        catch
            notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData('Failed to get tick data from CTP server'));
        end
    end
end

end