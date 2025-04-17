function [] = onMarketOpen(obj,~,eventData) 
% a charlotteDataFeedFut function
    data = eventData.MarketData;
    t = data.time;
    fprintf('charlotteDataFeedFut:onMarketOpen called at %s\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
    if ~obj.qmsconnected_
        try 
            obj.qms_.ctplogin('CounterName','ccb_ly_fut');
            obj.qmsconnected_ = true;
        catch
            obj.qmsconnected_ = false;
            notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData('Failed to connect to CTP server'));
        end
    end
end