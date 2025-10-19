function [] = onMarketClose(obj,~,eventData)
% a charlotteDataFeedFut function
    data = eventData.MarketData;
    t = data.time;
    
    if strcmpi(obj.mode_,'realtime')
        if obj.qmsconnected_
            fprintf('charlotteDataFeedFut:onMarketClose called: CTP logoff at %s\n',...
                datestr(t,'yyyy-mm-dd HH:MM:SS'))
            try
                obj.qms_.ctplogoff;
                obj.qmsconnected_ = false;
            catch
                obj.qmsconnected_ = false;
                notify(obj, 'ErrorOccurred', ...
                        charlotteErrorEventData('Failed to log off CTP server'));
                obj.stop;    
            end
        end
    elseif strcmpi(obj.mode_,'replay')
        obj.stop;
    end
end