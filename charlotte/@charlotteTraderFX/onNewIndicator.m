function [] = onNewIndicator(obj,~,eventData)
% a charlotteTraderFX function
    data = eventData.MarketData;
    
    obj.updatePendingBook(data);
    obj.manageRisk(data);
end