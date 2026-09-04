function [] = OnCandleUpdated_H1(obj,~,eventData)
    try
        data = eventData.MarketData;
        extrainfo = cell(size(data,1),1);
        for i = 1:size(data,1)
            extrainfo{i} = data{i}.extrainfo;
        end
        % we display H1 only for the time-being
        fprintf('\n');
        obj.printExtraInfo(extrainfo,'h1');
    catch ME
        % error event triggered
        msg = ['charlotteDataFeedFX:OnCandleUpdated_H1:',ME.message];
        notify(obj, 'ErrorOccurred',charlotteErrorEventData(msg));
    end
end