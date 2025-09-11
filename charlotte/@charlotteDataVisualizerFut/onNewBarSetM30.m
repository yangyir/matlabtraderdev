function [] = onNewBarSetM30(obj,~,eventData)
    data = eventData.MarketData;
    code = data.code;
    ncodes = size(obj.codes_,1);
    idxfound = -1;
    for i = 1:ncodes
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break;
        end
    end
    if idxfound == -1, return;end
    newBar = [data.datetime,data.open,data.high,data.low,data.close];
    lastT = obj.candles_m30_{idxfound}(end,1);
    if lastT >= newBar(1)
        return;
    end
    obj.candles_m30_{idxfound} = [obj.candles_m30_{idxfound};newBar];
    %the follow line is for testing purpose
%     fprintf('%6s last bar close:%s\n',obj.codes_{idxfound},num2str(data.close));
    [resmat,~] = tools_technicalplot1(obj.candles_m30_{idxfound},4,0,'volatilityperiod',0,'tolerance',0);
    
    fut = code2instrument(code);
    
    n = size(resmat,1);
    if n <= 60
        tools_technicalplot2(resmat(1:end,:),idxfound*(ncodes-1)+4,[code,'-30m'],true,2.0*fut.tick_size);
    else
        tools_technicalplot2(resmat(end-59:end,:),idxfound*(ncodes-1)+4,[code,'-30m'],true,2.0*fut.tick_size);
    end
end