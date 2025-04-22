function [] = generateNewData(obj)
%a charlotteDataFeedFut function
    if obj.istime2sleep(now), return;end
    
    ncodes = size(obj.codes_,1);
    if ncodes <= 0, return;end
    
    mm = minute(now) + hour(now)*60;
    
    if ((mm >= obj.mm_02_30_ + 1 && mm <  obj.mm_08_50_) || ...
           (mm >= obj.mm_15_15_ + 1 && mm < obj.mm_20_50_))
       % 1 minute after market closes and 10 minutes before market opens
       data.time = now;
       notify(obj, 'MarketClose', charlotteDataFeedEventData(data));
    end
    
    if ((mm >= obj.mm_08_50_ && mm < obj.mm_09_00_) || ...
           (mm >= obj.mm_20_50_ && mm < obj.mm_21_00_))
       % 10 minutes before market opens
        data.time = now;
        notify(obj, 'MarketOpen', charlotteDataFeedEventData(data));
    end
    
    data = cell(ncodes,1);
    nupdate = 0;
    try
        obj.qms_.refresh;
    catch ME
        % error event triggered
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData(ME.message));
    end
    
     
    for i = 1:ncodes
        quote = obj.qms_.getquote(obj.codes_{i});
        lasttrade = quote.last_trade;
        if lasttrade <= 0, continue;end
        currentticktime = quote.update_time1;
        if (currentticktime > obj.lastticktime_(i)) || ...
                (currentticktime - obj.lastticktime_(i) < 5e-6 && lasttrade ~= obj.lasttrade_(i))
            nupdate = nupdate + 1;
            obj.lastticktime_(i) = currentticktime;
            obj.lasttrade_(i) = lasttrade;
            data_i = struct('time',currentticktime,...
                    'lasttrade',lasttrade);
            data{i} = data_i;
        end
    end
        
    if nupdate > 0
        % event triggered
        notify(obj, 'NewDataArrived', charlotteDataFeedEventData(data));
    end

end