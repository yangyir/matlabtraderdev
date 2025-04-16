function lastticktime = getLastTickTime(obj,code)
% a charlotteDataFeedFut function
    idxfound = -1;
    lastticktime = [];
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break
        end
    end
    if idxfound <= 0
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteDataFeedFut:getLastTickTime:invalid code input...'));
        return
    end
    
    lastticktime = datestr(obj.lastticktime_(idxfound),'yyyy-mm-dd HH:MM:SS');
end