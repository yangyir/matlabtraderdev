function [] = generateNewData(obj)
%a charlotteDataFeedFut function
    ncodes = size(obj.codes_,1);
    if ncodes <= 0, return;end
    
    if obj.istime2sleep(now), return;end
    
    if obj.qmsconnected_
        try 
            obj.qms_.ctplogin('CounterName','ccb_ly_fut');
            obj.qmsconnected_ = obj.qms_.isconnect;
        catch
            notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData('Failed to connect to CTP server'));
        end
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
        currentticktime = quote.update_time1;
        if currentticktime > obj.lastticktime_(i)
            nupdate = nupdate + 1;
            obj.lastticktime_(i) = currentticktime;
            data_i = struct('time',currentticktime,...
                    'bid1',quote.bid1,...
                    'ask1',quote.ask1,...
                    'lasttrade',quote.last_trade);
            data{i} = data_i;
        end
    end
        
    if nupdate > 0
        % event triggered
        notify(obj, 'NewDataArrived', charlotteDataFeedEventData(data));
    end

end