function [] = onMarketClose(obj,~,eventData)
% a charlotteDataFeedFut function
    data = eventData.MarketData;
    t = data.time;
    fprintf('charlotteDataFeedFut:onMarketClose called at %s\n',datestr(t,'yyyy-mm-dd HH:MM:SS'))
    if obj.qmsconnected_
        obj.qms_.ctplogoff;
        obj.qmsconnected_ = false;
    end
end