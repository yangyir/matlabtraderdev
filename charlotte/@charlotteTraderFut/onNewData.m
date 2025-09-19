function [] = onNewData(obj,~,eventData)
% a charlotteTraderFut function
% eventData from charlotteDataFeedFut

    %m5
    ntrades_m5 = obj.trades_m5_.latest_;
    livetrades_m5 = cTradeOpenArray;
    for i = 1:ntrades_m5
        trade_i = obj.trades_m5_.node_(i);
        if strcmpi(trade_i.status_,'closed'), continue;end
        livetrades_m5.push(trade_i);
    end
    nlivetrades_m5 = livetrades_m5.latest_;
    
    %m30
    ntrades_m30 = obj.trades_m30_.latest_;
    livetrades_m30 = cTradeOpenArray;
    for i = 1:ntrades_m30
        trade_i = obj.trades_m30_.node_(i);
        if strcmpi(trade_i.status_,'closed'), continue;end
        livetrades_m30.push(trade_i);
    end
    nlivetrades_m30 = livetrades_m30.latest_;
    
    if nlivetrades_m5 == 0 && nlivetrades_m30 == 0, return;end
    
    data = eventData.MarketData;
    ncodes = size(data,1);
    for i = 1:ncodes
        data_i = data{i};
        for j = 1:nlivetrades_m5
            trade_j = livetrades_m5.node_(j);
            if ~strcmpi(trade_j.code_,data_i.code),continue;end
            
            
        end
        
        
        for j = 1:nlivetrades_m30
            trade_j = livetrades_m30.node_(j);
            if ~strcmpi(trade_j.code_,data_i.code),continue;end
        end
        
        
    end
    

end