function [] = onNewData(obj,~,eventData)
    data = eventData.MarketData;
    ncodes = size(obj.codes_,1);
    for i = 1:ncodes
        data_i = data{i};
        if isempty(data_i), continue;end
        newcandle_i = [data_i.time,data_i.open,data_i.high,data_i.low,data_i.close];
        candles_i = obj.candles_{i};
        obj.candles_{i} = [candles_i;newcandle_i];
        fprintf('%s latest bar time: %s and close at %s\n', ...
                obj.codes_{i}, datestr(data_i.time,'yyyymmdd HH:MM'),num2str(data_i.close));
        
        
%         generateSignal(obj.codes_{i});
%         updateTrade(obj.codes_{i});
    end
    
end