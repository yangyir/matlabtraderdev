function lastbartime = getLastBarTime(obj,code,freq)
%a charlotteDataFeedFX function
    idxfound = -1;
    lastbartime = [];
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},[code,'-',freq])
            idxfound = i;
            break
        end
    end
    if idxfound <= 0
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteDataFeedFX:getLastBarTime:invalid code input...'));
        return
    end
    
    if strcmpi(freq,'daily')
        lastbartime = datestr(obj.lastbartime_(idxfound),'yyyymmdd');
    else
        lastbartime = datestr(obj.lastbartime_(idxfound),'yyyymmdd HH:MM');
    end
    
end