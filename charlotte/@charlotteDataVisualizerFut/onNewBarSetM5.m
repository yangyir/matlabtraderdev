function [] = onNewBarSetM5(obj,~,eventData)
% a charlotteDataVisualizerFut function
    data = eventData.MarketData;
    ncodes = size(obj.codes_,1);
    
    for i = 1:ncodes
        data_i = data{i};
        if isempty(data_i)
            continue;
        end
        
        newBar = [data_i.datetime,data_i.open,data_i.high,data_i.low,data_i.close];
        lastT = obj.candles_m5_{i}(end,1);
        if lastT >= newBar(1)
            continue;
        end
        
        obj.candles_m5_{i} = [obj.candles_m5_{i};newBar];
        [resmat,~] = tools_technicalplot1(obj.candles_m5_{i},6,0,'volatilityperiod',0,'tolerance',0);
        
        code = data_i.code;
        fut = code2instrument(code);
    
        n = size(resmat,1);
        if n <= 60
            tools_technicalplot2(resmat(1:end,:),i*(ncodes-1)+2,[code,'-5m'],true,2.0*fut.tick_size);
        else
            tools_technicalplot2(resmat(end-59:end,:),i*(ncodes-1)+2,[code,'-5m'],true,2.0*fut.tick_size);
        end
    end
    
end