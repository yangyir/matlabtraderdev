function [] = onMarketClose(obj,~,eventData)
% a charlotteTraderFut function
% eventData from charlotteDataFeedFut
    data = eventData.MarketData;
    mode = data.mode;
    
    if strcmpi(mode,'realtime')
        %1.log off counter
        
        %2.save trades
    elseif strcmpi(mode,'replay')
        %1.save trades
        
    end
end