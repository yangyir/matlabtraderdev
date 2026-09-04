function [data] = getReplayData(obj,code,freq)
% a charlotteDataFeedFX function
    if ~strcmpi(obj.mode_,'replay')
        data = [];
        fprintf('charlotteDataFeedFX:mode realtime\n');
        return
    end
    
    idxfound = -1;
    data = [];
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break
        end
    end
    if idxfound <= 0
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteDataFeedFX:getReplayData:invalid code input...'));
        return
    end

    if strcmpi(freq,'m15')
        data = obj.replaydata_m15_{idxfound};
    elseif strcmpi(freq,'m30')
        data = obj.replaydata_m30_{idxfound};
    elseif strcmpi(freq,'h1')
        data = obj.replaydata_h1_{idxfound};
    elseif strcmpi(freq,'h4')
        data = obj.replaydata_h4_{idxfound};
    else
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteDataFeedFX:getReplayData:invalid freq input...'));
        return
    end
    
    
end