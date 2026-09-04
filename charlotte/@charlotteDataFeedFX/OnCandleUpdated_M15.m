function [] = OnCandleUpdated_M15(obj,~,eventData)
    try
        data = eventData.MarketData;
    catch ME
        % error event triggered
        msg = ['charlotteDataFeedFX:OnCandleUpdated_M15:',ME.message];
        notify(obj, 'ErrorOccurred',charlotteErrorEventData(msg));
    end
end