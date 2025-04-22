function [] = onMarketClose(obj,~,eventData)
% a charlotteDataFeedFut function
    data = eventData.MarketData;
    t = data.time;
    if obj.qmsconnected_
        fprintf('charlotteDataFeedFut:onMarketClose called: CTP logoff at %s\n',...
            datestr(t,'yyyy-mm-dd HH:MM:SS'))
        obj.qms_.ctplogoff;
        obj.qmsconnected_ = false;
    end
end