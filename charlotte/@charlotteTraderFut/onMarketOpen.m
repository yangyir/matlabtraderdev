function [] = onMarketOpen(obj,~,eventData)
% a charlotteTraderFut function
% eventData from charlotteDataFeedFut
    data = eventData.MarketData;
    mode = data.mode;
    
    if strcmpi(mode,'realtime')
        %to be implemented
    elseif strcmpi(mode,'replay')
        fprintf('replay starts......\n');
    end
end