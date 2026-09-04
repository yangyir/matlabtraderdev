function [] = OnCandleUpdated_M30(obj,~,eventData)
% a charlotteDataFeedFX method
    try
        data = eventData.MarketData;
    catch
        % error event triggered
        msg = ['charlotteDataFeedFX:OnCandleUpdated_M30:',ME.message];
        notify(obj, 'ErrorOccurred',charlotteErrorEventData(msg));
    end
end