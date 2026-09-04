function [ei] = getExtraInfo(obj,code,freq)
%a charlotteDataFeedFX function
    idxfound = -1;
    ei = [];
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break
        end
    end

    if idxfound <= 0
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteDataFeedFX:getExtraInfo:invalid code input...'));
        return
    end
    
    if strcmpi(freq,'m15')
        ei = obj.extrainfo_m15_{idxfound};
    elseif strcmpi(freq,'m30')
        ei = obj.extrainfo_m30_{idxfound};
    elseif strcmpi(freq,'h1')
        ei = obj.extrainfo_h1_{idxfound};
    elseif strcmpi(freq,'h4')
        ei = obj.extrainfo_h4_{idxfound};
    else
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteDataFeedFX:getExtraInfo:invalid freq input...'));
        return
    end
    
end