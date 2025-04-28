function [] = onNewIndicator(obj,~,eventData)
% a charlotteTraderFX function
    data = eventData.MarketData;
    
    obj.manageRisk(data);
end