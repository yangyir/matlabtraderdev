function [] = onNewData(obj,~,eventData)
% a charlotteDataProcessorFut function
    data = eventData.MarketData;
    ncodes = size(obj.codes_,1);
    for i = 1:ncodes
        try
            data_i = data{i};
        catch
            data_i = [];
        end
        if ~isempty(data_i)
            datenum_open = obj.datenum_open_{i};
            datenum_close = obj.datenum_close_{i};
            ticktime = data_i.time;
            if ticktime >= datenum_open(1) && ticktime <= datenum_close(end)
                obj.tickcounts_(i) = obj.tickcounts_(i) + 1;
                newdata_i = [ticktime,data_i.lasttrade];
                if isempty(obj.ticks_{i})
                    obj.ticks_{i} = newdata_i;
                else
                    obj.ticks_{i} = [obj.ticks_{i};newdata_i];
                end
            end
        else
            
        end
    end
    obj.updatecandles;
    
%     fprintf('\n');
    
end