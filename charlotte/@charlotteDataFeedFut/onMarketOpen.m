function [] = onMarketOpen(obj,~,eventData) 
% a charlotteDataFeedFut function
    data = eventData.MarketData;
    t = data.time;
    
    if ~obj.qmsconnected_
        fprintf('charlotteDataFeedFut:onMarketOpen called: CTP login at %s\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
        try 
            obj.qms_.ctplogin('CounterName','ccb_ly_fut');
            obj.qmsconnected_ = true;
        catch
            obj.qmsconnected_ = false;
            notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData('Failed to connect to CTP server'));
            obj.stop;
        end
    end
end