function [] = onNewBarSetM1(obj,~,eventData)
    data = eventData.MarketData;
    code = data.code;
    ncodes = size(obj.codes_);
    idxfound = -1;
    for i = 1:ncodes
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break;
        end
    end
    if idxfound == -1, return;end
    newBar = [data.datetime,data.open,data.high,data.low,data.close];
    obj.candles_m1_{idxfound} = [obj.candles_m1_{idxfound};newBar];
    %the follow line is for testing purpose
    fprintf('%6s last bar close:%s\n',obj.codes_{idxfound},num2str(data.close));
end