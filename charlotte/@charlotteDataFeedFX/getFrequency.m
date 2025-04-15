function freq = getFrequency(obj,code)
%a charlotteDataFeedFX function
    idxfound = -1;
    freq = '';
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break
        end
    end
    if idxfound <= 0
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteDataFeedFX:setFrequency:invalid code input...'));
        return
    end
    
    freq = obj.freq_{idxfound};
    
end