function [] = generateNewData(obj)
%a charlotteDataFeedFut function
    ncodes = size(obj.codes_,1);
    if ncodes <= 0, return;end
    
    if strcmpi(obj.mode_,'realtime')
        t = now;
        
        if obj.istime2sleep(t), return;end
        
        mm = minute(t) + hour(t)*60; 
        if ((mm >= obj.mm_02_30_ + 1 && mm <  obj.mm_08_50_) || ...
                (mm >= obj.mm_15_15_ + 1 && mm < obj.mm_20_50_))
            % 1 minute after market closes and 10 minutes before market opens
            data.time = t;
            notify(obj, 'MarketClose', charlotteDataFeedEventData(data));
        end
        
        if ((mm >= obj.mm_08_50_ && mm < obj.mm_09_00_) || ...
                (mm >= obj.mm_20_50_ && mm < obj.mm_21_00_))
            % 10 minutes before market opens
            data.time = t;
            notify(obj, 'MarketOpen', charlotteDataFeedEventData(data));
        end
        %
        data = cell(ncodes,1);
        nupdate = 0;
        try
            obj.qms_.refresh;
        catch ME
            % error event triggered
            notify(obj, 'ErrorOccurred', charlotteErrorEventData(ME.message));
        end
        
        for i = 1:ncodes
            quote = obj.qms_.getquote(obj.codes_{i});
            lasttrade = quote.last_trade;
            
            if lasttrade <= 0, continue;end
            if isnan(lasttrade), continue;end
            if isempty(lasttrade),continue;end
            
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
        
        return
        
    end
    %
    %
    if strcmpi(obj.mode_,'replay')
        totalCount = size(obj.replaydata_{1},1);
        thisCount = obj.replaycounts_(1);
        if thisCount < totalCount
            t = obj.replaydata_{1}(thisCount,1);
            lasttrade = obj.replaydata_{1}(thisCount,2);
            obj.lastticktime_(1) = t;
            obj.lasttrade_(1) = lasttrade;
            data = cell(ncodes,1);
            data{1} = struct('time',t,'lasttrade',lasttrade);
            % event trigger
            notify(obj, 'NewDataArrived', charlotteDataFeedEventData(data));
            newCount = thisCount + 1;
            obj.replaycounts_(1) = newCount;
        else
            data.time = obj.replaydata_{1}(end,1)+1/86400;
            % event trigger
            notify(obj, 'MarketClose', charlotteDataFeedEventData(data));
        end
        
        return
        
        
    end
    
    
    
    
    
    
    
    
    
    
     
    
        
    

end