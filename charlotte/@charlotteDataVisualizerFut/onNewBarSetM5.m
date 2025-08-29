function [] = onNewBarSetM5(obj,~,eventData)
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
    obj.candles_m5_{idxfound} = [obj.candles_m5_{idxfound};newBar];
    %the follow line is for testing purpose
%     fprintf('%6s last bar close:%s\n',obj.codes_{idxfound},num2str(data.close));
    [resmat,~] = tools_technicalplot1(obj.candles_m5_{idxfound},6,0,'volatilityperiod',0,'tolerance',0);
    
    fut = code2instrument(code);
    
    n = size(resmat,1);
    if n <= 60
        tools_technicalplot2(resmat(1:end,:),i+1,[code,'-5m'],true,2.0*fut.tick_size);
    else
        tools_technicalplot2(resmat(end-59:end,:),i+1,[code,'-5m'],true,2.0*fut.tick_size);
    end
end