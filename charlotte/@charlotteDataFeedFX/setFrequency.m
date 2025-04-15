function setFrequency(obj,code,freq)
%a charlotteDataFeedFX function
    idxfound = -1;
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
    
    obj.freq_{idxfound} = freq;
    
    if strcmpi(freq,'5m')
        obj.fn_{idxfound} = [obj.dir_,obj.codes_{idxfound},'.lmx_M5_running.csv'];
    elseif strcmpi(freq,'15m')
        obj.fn_{idxfound} = [obj.dir_,obj.codes_{idxfound},'.lmx_M15_running.csv'];
    elseif strcmpi(freq,'30m')
        obj.fn_{idxfound} = [obj.dir_,obj.codes_{idxfound},'.lmx_M30_running.csv'];
    elseif strcmpi(freq,'1h')
        obj.fn_{idxfound} = [obj.dir_,obj.codes_{idxfound},'.lmx_H1_running.csv'];
    elseif strcmpi(freq,'4h')
        obj.fn_{idxfound} = [obj.dir_,obj.codes_{idxfound},'.lmx_H4_running.csv'];
    elseif strcmpi(freq,'daily')
        obj.fn_{idxfound} = [obj.dir_,obj.codes_{idxfound},'.lmx_D1_running.csv'];
    else
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteDataFeedFX:setFrequency:invalid freq input...'));
        return
    end
    
    try
        lastrow = readlastrowfromcsvfile(obj.fn_{idxfound});
        lastbardate = lastrow{1};
        lastbardatestr = [lastbardate(1:4),lastbardate(6:7),lastbardate(9:10)];
        lastbartimestr = lastrow{2};
        lastbartime = datenum([lastbardatestr,' ',lastbartimestr],'yyyymmdd HH:MM');
        obj.lastbartime_(idxfound) = lastbartime;
    catch ME
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData(ME.message));
        return
    end
    
end