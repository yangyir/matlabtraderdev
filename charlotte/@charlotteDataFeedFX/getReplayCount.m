function [data] = getReplayCount(obj,code)
% a charlotteDataFeedFX function
    if ~strcmpi(obj.mode_,'replay')
        data = [];
        fprintf('charlotteDataFeedFX:getReplayCount:mode realtime\n');
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
            charlotteErrorEventData('charlotteDataFeedFX:getReplayCount:invalid code input...'));
        return
    end
    
    data = obj.replaycounts_(idxfound);
end