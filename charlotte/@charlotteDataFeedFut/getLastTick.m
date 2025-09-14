function lasttrade = getLastTick(obj,code)
% a charlotteDataFeedFut function
    idxfound = -1;
    lasttrade = [];
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break
        end
    end
    if idxfound <= 0
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteDataFeedFut:getLastTick:invalid code input...'));
        return
    end
    
    lasttrade = obj.lasttrade_(idxfound);
end