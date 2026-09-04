function lastbartime = getLastBarTime(obj,code,freq)
%a charlotteDataFeedFX function
    idxfound = -1;
    lastbartime = [];
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break
        end
    end

    if idxfound <= 0
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteDataFeedFX:getLastBarTime:invalid code input...'));
        return
    end
    
    if strcmpi(freq,'m15')
        lastbartime = datestr(obj.lastbartime_m15_(idxfound),'yyyymmdd HH:MM');
    elseif strcmpi(freq,'m30')
        lastbartime = datestr(obj.lastbartime_m30_(idxfound),'yyyymmdd HH:MM');
    elseif strcmpi(freq,'h1')
        lastbartime = datestr(obj.lastbartime_h1_(idxfound),'yyyymmdd HH:MM');
    elseif strcmpi(freq,'h4')
        lastbartime = datestr(obj.lastbartime_h4_(idxfound),'yyyymmdd HH:MM');
    else
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteDataFeedFX:getLastBarTime:invalid freq input...'));
        return
    end
    
end