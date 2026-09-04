function [] = OnCandleUpdated_H4(obj,~,eventData)
% a charlotteDataFeedFX method
    try
        data = eventData.MarketData;
    catch
        % error event triggered
        msg = ['charlotteDataFeedFX:OnCandleUpdated_H4:',ME.message];
        notify(obj, 'ErrorOccurred',charlotteErrorEventData(msg));
    end
end